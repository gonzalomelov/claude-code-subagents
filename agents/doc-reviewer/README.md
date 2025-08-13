# Doc-Reviewer Agent

Expert documentation change review specialist that proactively reviews documentation changes for semantic integrity and content preservation.

## Purpose

Automatically invoked after documentation modifications to ensure no loss of meaning, data, or critical information during refactoring or restructuring processes.

## Key Features

- **Semantic Loss Detection**: Identifies when content reorganization loses important information
- **Severity Classification**: Categorizes issues as Critical, Warning, or Suggestion
- **Actionable Findings**: Provides specific restoration commands with exact line numbers
- **Template Validation**: Ensures output follows standardized format with markdownlint
- **Comprehensive Analysis**: Reviews meaning preservation, link integrity, and technical accuracy

## Structure

- `output-template.md` - Structured output template for review results
- `markdownlint.jsonc` - Validation configuration for output format
- `rules/` - Custom markdownlint rules for specialized validation
- `examples/` - Real-world usage examples following the template
- `eval/` - Evaluation framework for testing semantic preservation detection

## Usage

The agent expects staged git changes (`git diff --staged`) and outputs structured reviews to `tmp/doc-reviewer/doc-reviewer-[task-name].md`. Each review is validated against the markdownlint configuration to ensure consistency and readability.

## Dependencies

- Access to `~/.claude/agents/templates/doc-reviewer.md` (template file)
- Access to `~/.claude/agents/markdownlint/doc-reviewer.markdownlint.jsonc` (validation config)
- markdownlint-cli2 for output validation