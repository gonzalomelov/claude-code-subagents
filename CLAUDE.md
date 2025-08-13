# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains specialized subagents for Claude Code. The primary agent is `doc-reviewer`, which reviews documentation changes for semantic integrity and content preservation.

## Architecture

### Agent Structure
- `agents/` - Contains agent definition files and supporting resources
  - `doc-reviewer.md` - Main agent definition with instructions and tools
  - `doc-fixer.md` - Companion agent for implementing doc-reviewer fixes
  - `templates/` - Output templates for standardized agent responses
  - `markdownlint/` - Linting configuration and custom rules
  - `examples/` - Real-world usage examples
  - `evals/` - Evaluation framework for testing agent performance

### Agent Dependencies
The doc-reviewer agent depends on:
- Template file at `~/.claude/agents/templates/doc-reviewer.md`
- Markdownlint config at `~/.claude/agents/markdownlint/doc-reviewer.markdownlint.jsonc`
- These files need to be installed in the user's Claude directory structure

## Common Commands

### Running Evaluations
```bash
# Run the semantic preservation evaluation framework
cd agents/evals/doc-reviewer
python3 test_semantic_preservation.py
```

### Markdown Linting
```bash
# Lint doc-reviewer output files
markdownlint-cli2 "tmp/doc-reviewer/doc-reviewer-*.md" --config "~/.claude/agents/markdownlint/doc-reviewer.markdownlint.jsonc"
```

### Git Operations
The doc-reviewer agent expects to work with staged git changes:
```bash
git add .  # Stage changes first
# Then invoke doc-reviewer agent
```

## Agent Workflow

### Doc-Reviewer Agent
1. Runs `git diff --staged` to analyze staged documentation changes
2. Reviews changes for semantic integrity and content preservation
3. Creates structured output in `tmp/doc-reviewer/doc-reviewer-[task-name].md`
4. Validates output with markdownlint using custom configuration
5. Iterates until validation passes

### Doc-Fixer Agent
Designed to work with doc-reviewer output files to implement fixes identified during review.

## Evaluation Framework

The repository includes a comprehensive evaluation system:
- **Location**: `agents/evals/doc-reviewer/`
- **Purpose**: Tests semantic preservation detection accuracy
- **Metrics**: Precision, recall, F1-score for semantic loss detection
- **Test Cases**: JSON-defined scenarios with expected outcomes
- **Current Status**: Uses real Claude Code CLI (not mock) for testing

### Key Evaluation Files
- `test_semantic_preservation.py` - Main evaluation runner
- `test_cases.json` - Test scenarios with semantic checks
- `results/` - Timestamped evaluation outputs

## File Organization

### Agent Definitions
- Follow Claude Code subagent YAML frontmatter format
- Include `name`, `description`, `tools`, and `model` fields
- Main content provides detailed instructions for agent behavior

### Templates
- Structured output templates ensure consistent agent responses
- Include severity classifications (Critical/Warning/Suggestion)
- Provide actionable findings with specific line numbers and fixes

### Configuration
- Custom markdownlint rules enforce output format standards
- JSON configuration files define allowed heading structures
- Custom JavaScript rules for specialized validation

## Development Practices

When working with agents:
1. Stage documentation changes with `git add` before testing
2. Use the evaluation framework to validate agent improvements
3. Follow the template structure exactly for consistent outputs
4. Ensure markdownlint validation passes for all generated files
5. Test semantic preservation detection with representative scenarios