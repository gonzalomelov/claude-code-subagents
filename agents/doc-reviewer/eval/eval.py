#!/usr/bin/env python3
"""
Semantic Preservation Evaluator for doc-reviewer subagent
Tests whether doc-reviewer correctly identifies semantic losses in documentation changes
"""

import json
import subprocess
import sys
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional
import tempfile
import re

class SemanticPreservationEvaluator:
    def __init__(self, test_cases_file: str = "test-cases.json"):
        self.test_cases_file = test_cases_file
        self.results_dir = Path("results")
        self.results_dir.mkdir(exist_ok=True)
        # doc_reviewer_output_dir will be set dynamically based on repo_path
        
    def load_test_cases(self) -> List[Dict]:
        """Load test cases from JSON file"""
        with open(self.test_cases_file, 'r') as f:
            return json.load(f)
    
    def create_temp_git_repo(self, diff_content: str) -> tempfile.TemporaryDirectory:
        """Create a temporary git repository with the provided diff staged"""
        tmpdir = tempfile.TemporaryDirectory()
        repo_path = Path(tmpdir.name)
        
        # Initialize git repo
        subprocess.run(["git", "init"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_path, check=True, capture_output=True)
        
        # Parse the diff to create files
        # This is a simplified version - in production, use a proper diff parser
        lines = diff_content.split('\n')
        current_file = None
        original_content = []
        modified_content = []
        
        for line in lines:
            if line.startswith('diff --git'):
                # Extract filename
                match = re.search(r'a/(.*?) b/', line)
                if match:
                    current_file = match.group(1)
            elif line.startswith('@@'):
                continue
            elif current_file and not line.startswith('---') and not line.startswith('+++') and not line.startswith('index'):
                if line.startswith('-'):
                    original_content.append(line[1:])
                elif line.startswith('+'):
                    modified_content.append(line[1:])
                elif line.startswith(' '):
                    # Context line - add to both
                    original_content.append(line[1:])
                    modified_content.append(line[1:])
                elif not line.startswith('\\'):
                    # Empty line
                    original_content.append('')
                    modified_content.append('')
        
        if current_file:
            # Create the original file and commit
            file_path = repo_path / current_file
            file_path.parent.mkdir(parents=True, exist_ok=True)
            file_path.write_text('\n'.join(original_content))
            subprocess.run(["git", "add", "."], cwd=repo_path, check=True, capture_output=True)
            subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo_path, check=True, capture_output=True)
            
            # Modify the file and stage changes
            file_path.write_text('\n'.join(modified_content))
            subprocess.run(["git", "add", "."], cwd=repo_path, check=True, capture_output=True)
        
        return tmpdir
    
    def run_doc_reviewer(self, repo_path: str) -> Optional[str]:
        """Run the doc-reviewer subagent and capture its output"""
        try:
            # Use real Claude Code CLI with doc-reviewer subagent
            cmd = [
                "claude",
                "--print",
                "--dangerously-skip-permissions",
                "Use doc-reviewer subagent to review the staged documentation changes. Return the output file only. If not output file is given, it failed"
            ]

            result = subprocess.run(
                cmd,
                cwd=repo_path,
                capture_output=True,
                text=True,
                timeout=420
            )
            
            # Debug: Print Claude's output
            print(f"\nDEBUG - Claude stdout (first 500 chars):\n{result.stdout[:500]}")
            print(f"\nDEBUG - Claude stderr (first 500 chars):\n{result.stderr[:500]}")
            
            # Look for the output file in tmp/doc-reviewer/ inside the repo
            doc_reviewer_output_dir = Path(repo_path) / "tmp/doc-reviewer"
            output_files = list(doc_reviewer_output_dir.glob("doc-reviewer-*.md")) if doc_reviewer_output_dir.exists() else []
            print(f"\nDEBUG - Looking in: {doc_reviewer_output_dir}")
            print(f"DEBUG - Found {len(output_files)} files in {doc_reviewer_output_dir}")
            
            if output_files:
                # Get the most recent file
                latest_file = max(output_files, key=lambda f: f.stat().st_mtime)
                print(f"DEBUG - Reading file: {latest_file}")
                content = latest_file.read_text()
                print(f"DEBUG - File content (first 500 chars):\n{content[:500]}")
                return content
            
            # If no files found, use Claude's stdout directly
            print("DEBUG - Using Claude's stdout for analysis")
            return result.stdout
            
        except subprocess.TimeoutExpired:
            print(f"Warning: doc-reviewer timed out")
            return None
        except Exception as e:
            print(f"Error running doc-reviewer: {e}")
            return None
    
    def extract_semantic_units(self, doc_reviewer_output: str) -> Dict:
        """Extract semantic findings from doc-reviewer output"""
        findings = {
            "critical": [],
            "warnings": [],
            "suggestions": []
        }
        
        if not doc_reviewer_output:
            print("DEBUG - No output to parse")
            return findings
        
        # Parse the doc-reviewer output for findings
        lines = doc_reviewer_output.split('\n')
        current_section = None
        
        for line in lines:
            # Look for section headers
            if 'CRITICAL ISSUES' in line.upper() or ('CRITICAL' in line.upper() and 'MUST FIX' in line.upper()):
                current_section = 'critical'
                print(f"DEBUG - Found critical section")
            elif 'WARNING' in line.upper() and ('SHOULD FIX' in line.upper() or 'MEANING CHANGED' in line.upper()):
                current_section = 'warnings'
                print(f"DEBUG - Found warnings section")
            elif 'SUGGESTION' in line.upper() and 'CONSIDER' in line.upper():
                current_section = 'suggestions'
                print(f"DEBUG - Found suggestions section")
            # Look for finding markers - only count the finding header, not the details
            elif current_section and line.strip().startswith('Finding #'):
                findings[current_section].append(line.strip())
                print(f"DEBUG - Found {current_section} finding: {line.strip()[:50]}")
        
        print(f"DEBUG - Extracted findings: {len(findings['critical'])} critical, {len(findings['warnings'])} warnings, {len(findings['suggestions'])} suggestions")
        return findings
    
    def evaluate_semantic_detection(self, test_case: Dict, doc_reviewer_output: str) -> Dict:
        """Evaluate if doc-reviewer correctly identified semantic losses"""
        findings = self.extract_semantic_units(doc_reviewer_output)
        expected_semantic_loss = test_case.get('semantic_check', {}).get('semantic_loss', False)
        expected_severity = test_case.get('semantic_check', {}).get('severity', 'warning')
        
        # Did doc-reviewer detect any semantic loss?
        # Only consider CRITICAL issues as semantic loss, not warnings or suggestions
        detected_semantic_loss = bool(findings['critical'])
        
        # Is the detection correct?
        success = detected_semantic_loss == expected_semantic_loss
        
        # Calculate metrics
        result = {
            'test_id': test_case['test_id'],
            'description': test_case['description'],
            'expected_semantic_loss': expected_semantic_loss,
            'expected_severity': expected_severity,
            'detected_semantic_loss': detected_semantic_loss,
            'findings': findings,
            'success': success,
            'timestamp': datetime.now().isoformat()
        }
        
        # Classify the result
        if expected_semantic_loss and detected_semantic_loss:
            result['classification'] = 'true_positive'
        elif expected_semantic_loss and not detected_semantic_loss:
            result['classification'] = 'false_negative'
        elif not expected_semantic_loss and detected_semantic_loss:
            result['classification'] = 'false_positive'
        else:
            result['classification'] = 'true_negative'
            
        return result
    
    def run_evaluation(self) -> Dict:
        """Run full evaluation suite"""
        test_cases = self.load_test_cases()
        results = []
        
        print(f"Running {len(test_cases)} test cases...")
        
        for i, test_case in enumerate(test_cases, 1):
            print(f"\n[{i}/{len(test_cases)}] Running test: {test_case['test_id']}")
            print(f"Description: {test_case['description']}")
            
            # Create temp repo with the diff
            tmpdir = self.create_temp_git_repo(test_case['git_diff'])
            repo_path = tmpdir.name
            
            # Run doc-reviewer
            doc_reviewer_output = self.run_doc_reviewer(repo_path)
            
            # Evaluate results
            result = self.evaluate_semantic_detection(test_case, doc_reviewer_output or "")
            results.append(result)
            
            # Print immediate feedback
            status = "✓" if result['success'] else "✗"
            print(f"Result: {status} ({result['classification']})")
            
            # Clean up temp directory
            tmpdir.cleanup()
        
        # Calculate aggregate metrics
        metrics = self.calculate_metrics(results)
        
        # Save results
        self.save_results(results, metrics)
        
        return metrics
    
    def calculate_metrics(self, results: List[Dict]) -> Dict:
        """Calculate evaluation metrics"""
        classifications = [r['classification'] for r in results]
        
        tp = classifications.count('true_positive')
        tn = classifications.count('true_negative')
        fp = classifications.count('false_positive')
        fn = classifications.count('false_negative')
        
        total = len(results)
        correct = tp + tn
        
        # Calculate metrics
        accuracy = correct / total if total > 0 else 0
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0
        recall = tp / (tp + fn) if (tp + fn) > 0 else 0
        f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
        
        metrics = {
            'total_tests': total,
            'passed': correct,
            'failed': total - correct,
            'accuracy': accuracy,
            'precision': precision,
            'recall': recall,
            'f1_score': f1_score,
            'confusion_matrix': {
                'true_positive': tp,
                'true_negative': tn,
                'false_positive': fp,
                'false_negative': fn
            }
        }
        
        return metrics
    
    def save_results(self, results: List[Dict], metrics: Dict):
        """Save evaluation results to file"""
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        
        # Save detailed results
        results_file = self.results_dir / f"eval-results-{timestamp}.json"
        with open(results_file, 'w') as f:
            json.dump({
                'metrics': metrics,
                'test_results': results,
                'timestamp': timestamp
            }, f, indent=2)
        
        # Save summary
        summary_file = self.results_dir / f"eval-summary-{timestamp}.txt"
        with open(summary_file, 'w') as f:
            f.write("="*50 + "\n")
            f.write("SEMANTIC PRESERVATION EVALUATION RESULTS\n")
            f.write("="*50 + "\n\n")
            f.write(f"Timestamp: {timestamp}\n")
            f.write(f"Total Tests: {metrics['total_tests']}\n")
            f.write(f"Passed: {metrics['passed']}\n")
            f.write(f"Failed: {metrics['failed']}\n")
            f.write(f"Accuracy: {metrics['accuracy']:.2%}\n")
            f.write(f"Precision: {metrics['precision']:.2%}\n")
            f.write(f"Recall: {metrics['recall']:.2%}\n")
            f.write(f"F1 Score: {metrics['f1_score']:.2%}\n\n")
            f.write("Confusion Matrix:\n")
            f.write(f"  True Positives: {metrics['confusion_matrix']['true_positive']}\n")
            f.write(f"  True Negatives: {metrics['confusion_matrix']['true_negative']}\n")
            f.write(f"  False Positives: {metrics['confusion_matrix']['false_positive']}\n")
            f.write(f"  False Negatives: {metrics['confusion_matrix']['false_negative']}\n")
        
        print(f"\nResults saved to {results_file}")
        print(f"Summary saved to {summary_file}")
    
    def print_summary(self, metrics: Dict):
        """Print evaluation summary to console"""
        print("\n" + "="*50)
        print("EVALUATION SUMMARY")
        print("="*50)
        print(f"Accuracy: {metrics['accuracy']:.2%}")
        print(f"Precision: {metrics['precision']:.2%}")
        print(f"Recall: {metrics['recall']:.2%}")
        print(f"F1 Score: {metrics['f1_score']:.2%}")
        print(f"\nTests Passed: {metrics['passed']}/{metrics['total_tests']}")


def main():
    evaluator = SemanticPreservationEvaluator()
    
    # Check if test cases exist
    if not Path("test-cases.json").exists():
        print("Error: test-cases.json not found. Creating sample test cases...")
        # Create sample test cases (we'll do this next)
        return 1
    
    metrics = evaluator.run_evaluation()
    evaluator.print_summary(metrics)
    
    # Return non-zero exit code if accuracy is below threshold
    if metrics['accuracy'] < 0.8:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())