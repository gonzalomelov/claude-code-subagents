# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains specialized subagents for Claude Code. The primary agent is `doc-reviewer`, which reviews documentation changes for semantic integrity and content preservation.

## Architecture

### Agent Structure (Agent-Centric Organization)
Each agent is organized as a self-contained module:

```
agents/
├── {agent-name}.md           # Agent definition at root for visibility
└── {agent-name}/             # All agent resources grouped together
    ├── README.md             # Agent documentation
    ├── output-template.md    # Output template
    ├── markdownlint.jsonc    # Validation configuration
    ├── rules/                # Custom validation rules
    ├── examples/             # Real-world usage examples
    └── eval/                # Evaluation framework
```

**Current Agents:**
- `doc-reviewer/` - Documentation change review specialist

**Supporting Documentation:**
- `docs/` - Static documentation (markdownlint rules, etc.)

### Agent Dependencies
The doc-reviewer agent depends on:
- Template file at `~/.claude/agents/doc-reviewer/output-template.md`
- Markdownlint config at `~/.claude/agents/doc-reviewer/markdownlint.jsonc`
- These files need to be installed in the user's Claude directory structure

## Common Commands

### Running Evaluations
```bash
# Run agent evaluation framework (example: doc-reviewer)
cd agents/{agent-name}/eval
python3 eval.py
```

### Markdown Linting
```bash
# Lint doc-reviewer output files
markdownlint-cli2 "tmp/doc-reviewer/doc-reviewer-*.md" --config "~/.claude/agents/doc-reviewer/markdownlint.jsonc"
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

## Evaluation Framework

Each agent includes a comprehensive evaluation system in its `eval/` directory:
- **Location**: `agents/{agent-name}/eval/`
- **Purpose**: Evaluates agent effectiveness (specific metrics depend on agent functionality)
- **Implementation**: Agent-specific evaluation logic and test scenarios
- **Test Cases**: JSON-defined scenarios with expected outcomes for the agent's domain
- **Current Status**: Uses real Claude Code CLI for testing

### Key Evaluation Files (per agent)
- `eval.py` - Main evaluation runner
- `test-cases.json` - Test scenarios with agent-specific validation criteria
- `results/` - Timestamped evaluation outputs
- `README.md` and `USAGE.md` - Framework documentation

## File Organization Principles

### Agent-Centric Structure
- **Self-contained**: Each agent directory contains everything related to that agent
- **Discoverable**: Agent definitions at root for visibility, resources nested in agent folders
- **Predictable**: Every agent follows the same organizational pattern
- **Scalable**: Easy to add new agents without restructuring existing ones

### Agent Components
- **Definition** (`{agent}.md`): Claude Code subagent with YAML frontmatter and instructions
- **Template** (`output-template.md`): Structured output format for consistent responses
- **Validation** (`markdownlint.jsonc` + `rules/`): Ensures output quality and format compliance
- **Examples** (`examples/`): Real-world usage demonstrations following the template
- **Evaluator** (`eval/`): Evaluation framework for measuring agent effectiveness
- **Documentation** (`README.md`): Agent-specific usage guide and architecture

### Benefits of This Structure
1. **Locality**: All agent-related files are co-located
2. **Independence**: Each agent is completely self-contained
3. **Clarity**: Easy to understand what belongs to which agent
4. **Maintainability**: Changes to one agent don't affect others
5. **Discoverability**: IDE search works intuitively (e.g., "doc-reviewer template")

## Development Practices

### Working with Agents
1. **Stage changes first**: Use `git add` before invoking doc-reviewer agent
2. **Follow agent structure**: New agents should follow the established directory pattern
3. **Use evaluation frameworks**: Test agent improvements with the eval/ directory
4. **Validate outputs**: Ensure generated files pass markdownlint validation
5. **Document thoroughly**: Each agent should have clear README and usage examples

### Adding New Agents
1. Create agent definition at `agents/{agent-name}.md`
2. Create agent directory `agents/{agent-name}/` with standard structure
3. Add README.md explaining the agent's purpose and capabilities
4. Include output-template.md for consistent output formatting
5. Set up markdownlint.jsonc and custom rules for validation
6. Add real-world examples in examples/ directory
7. Create evaluation framework in eval/ directory