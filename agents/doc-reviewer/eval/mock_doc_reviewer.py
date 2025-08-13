#!/usr/bin/env python3
"""
Mock doc-reviewer for testing the evaluation framework
Simulates the doc-reviewer subagent's behavior
"""

import subprocess
import sys
import random
from pathlib import Path

def analyze_git_diff():
    """Analyze git diff and generate mock findings"""
    try:
        # Get the staged diff
        result = subprocess.run(
            ["git", "diff", "--cached"],
            capture_output=True,
            text=True,
            check=True
        )
        
        diff_content = result.stdout
        
        # Simple heuristics to detect semantic issues
        critical_issues = []
        warnings = []
        
        lines = diff_content.split('\n')
        
        # Check for table header changes (column removal)
        removed_headers = [line for line in lines if line.startswith('-') and '|' in line and not line.startswith('---')]
        added_headers = [line for line in lines if line.startswith('+') and '|' in line and not line.startswith('+++')]
        
        # Check if Lessons column was removed
        for removed in removed_headers:
            if 'Lessons' in removed or 'lessons' in removed.lower():
                # Check if it's still in the added version
                lessons_preserved = any('Lessons' in added or 'lessons' in added.lower() for added in added_headers)
                if not lessons_preserved:
                    critical_issues.append("Table column 'Lessons' has been removed - critical loss of learning insights")
                    break
        
        # Check for link removals
        removed_links = [line for line in lines if line.startswith('-') and 'http' in line]
        added_links = [line for line in lines if line.startswith('+') and 'http' in line]
        
        if len(removed_links) > len(added_links) + 2:  # Significant link loss
            critical_issues.append(f"Multiple resource links removed ({len(removed_links)} links replaced with {len(added_links)})")
        
        # Check for context removal
        removed_content = ' '.join([line[1:] for line in lines if line.startswith('-') and not line.startswith('---')])
        added_content = ' '.join([line[1:] for line in lines if line.startswith('+') and not line.startswith('+++')])
        
        # Look for important context phrases
        context_phrases = ['difficult', 'challenging', 'struggle', 'tough decision', 'find it difficult']
        for phrase in context_phrases:
            if phrase in removed_content.lower() and phrase not in added_content.lower():
                critical_issues.append("Important context and learning insights have been removed")
                break
        
        
        # Additional check for test case 4 - verify if it's just formatting changes
        if not critical_issues and not warnings:
            # Check if this is just a reorganization (formatting changes only)
            # Remove whitespace and formatting to compare content
            removed_text = ''.join([line[1:].strip() for line in lines if line.startswith('-') and not line.startswith('---')])
            added_text = ''.join([line[1:].strip() for line in lines if line.startswith('+') and not line.startswith('+++')])
            
            # Remove markdown formatting for comparison
            import re
            removed_clean = re.sub(r'[*#\-\s]+', '', removed_text)
            added_clean = re.sub(r'[*#\-\s]+', '', added_text)
            
            # Check if core content is preserved
            if len(removed_clean) > 0 and len(added_clean) > 0:
                # Simple similarity check - if most content is preserved, it's just reorganization
                common_words = set(removed_clean.lower().split()) & set(added_clean.lower().split())
                if len(common_words) > len(set(removed_clean.lower().split())) * 0.7:
                    # This is just reorganization, no semantic loss
                    pass
        
        # Generate output in doc-reviewer format
        output = "# Documentation Review Refactor Analysis\n\n"
        output += "## 📊 REVIEW SUMMARY\n\n"
        output += f"Risk Level: {'HIGH' if critical_issues else 'LOW'}\n\n"
        
        if critical_issues:
            output += "## 🚨 CRITICAL ISSUES (Content Lost/Broken - MUST FIX)\n\n"
            for i, issue in enumerate(critical_issues, 1):
                output += f"Finding #C{i}: {issue}\n"
                output += "Impact: Semantic meaning lost\n\n"
        
        if warnings:
            output += "## ⚠️ WARNINGS\n\n"
            for warning in warnings:
                output += f"- {warning}\n"
        
        if not critical_issues and not warnings:
            output += "## ✅ NO SEMANTIC LOSSES DETECTED\n\n"
            output += "All content appears to be preserved during reorganization.\n"
        
        return output
        
    except subprocess.CalledProcessError:
        return "Error: Could not analyze git diff"

def main():
    """Main entry point for mock doc-reviewer"""
    output = analyze_git_diff()
    
    # Save to output file
    output_dir = Path("tmp/doc-reviewer")
    output_dir.mkdir(exist_ok=True)
    
    output_file = output_dir / "doc-reviewer-mock-test.md"
    output_file.write_text(output)
    
    print(output)
    print(f"\nAnalysis saved to {output_file}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())