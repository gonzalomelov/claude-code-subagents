# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **Semantic Preservation Evaluation Framework** for testing the doc-reviewer subagent. It evaluates whether the doc-reviewer correctly identifies when semantic meaning is lost in documentation changes.

## Development Commands

### Running the Evaluation
```bash
python3 eval.py
```

### Prerequisites
- Ensure Claude Code CLI is installed and configured
- Ensure doc-reviewer subagent exists at `~/.claude/agents/doc-reviewer.md`
- Ensure doc-reviewer template and markdownlint config are installed in `~/.claude/agents/doc-reviewer/`

## Architecture

### Core Components

1. **SemanticPreservationEvaluator** (`eval.py`): Main evaluation engine that:
   - Creates temporary git repositories with staged documentation changes
   - Invokes the real doc-reviewer subagent via Claude Code CLI
   - Parses output files from `tmp/doc-reviewer/` directory
   - Evaluates semantic preservation detection accuracy

2. **Test Cases** (`test-cases.json`): Structured test data containing:
   - Git diffs representing documentation changes
   - Expected semantic outcomes (loss/preservation)
   - Severity classifications (critical/warning/none)

3. **Results Analysis** (`results/`): Generated evaluation reports with:
   - Detailed JSON results with classification outcomes
   - Human-readable summaries with accuracy metrics
   - Confusion matrix data for performance analysis

### Evaluation Process Flow

1. **Test Setup**: For each test case, create a temporary git repository
2. **Change Simulation**: Apply the git diff and stage changes
3. **Doc Review**: Execute doc-reviewer subagent via `claude --print`
4. **Output Parsing**: Extract findings from `tmp/doc-reviewer/doc-reviewer-*.md`
5. **Classification**: Compare detected issues against expected semantic loss
6. **Metrics**: Calculate precision, recall, F1 score, and accuracy

### Semantic Loss Detection Logic

- **Critical Issues**: Lines containing "CRITICAL ISSUES" or "CRITICAL" + "MUST FIX"
- **Classification Mapping**: Only CRITICAL findings count as semantic loss
- **Finding Format**: Must start with "Finding #" to be counted
- **Output Source**: Prioritizes `tmp/doc-reviewer/` files over stdout

## Test Case Structure

Each test case follows this format:
```json
{
  "test_id": "semantic_###",
  "description": "Brief description of what is being tested",
  "git_diff": "Git diff content showing the change",
  "semantic_check": {
    "original_capabilities": ["what users could do before"],
    "modified_capabilities": ["what users can do after"],
    "semantic_loss": true/false,
    "severity": "critical/warning/none"
  }
}
```

## Current Test Coverage

- **semantic_001**: Table column removal (lessons learned data loss)
- **semantic_002**: Resource link consolidation (multiple links → single redirect)
- **semantic_003**: Context removal (important technical insights deleted)
- **semantic_004**: Content reorganization (information preserved but restructured)

## Dependencies

- Python 3.8+ (standard library only)
- Claude Code CLI for doc-reviewer subagent execution
- Git for repository operations

## Philosophy

This framework prioritizes **semantic preservation** over pattern matching, testing whether meaning and capabilities are retained rather than looking for specific change types. The minimal implementation avoids heavy frameworks while providing robust evaluation metrics.