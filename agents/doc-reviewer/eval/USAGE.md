# Using the Semantic Preservation Evaluation Framework

## Current Setup

The framework now uses the **real doc-reviewer** subagent via Claude Code CLI. The evaluation system:
1. Creates temporary git repositories with staged changes
2. Invokes the real doc-reviewer subagent via `claude --print`
3. Parses the doc-reviewer output files from `tmp/doc-reviewer/`
4. Evaluates semantic preservation detection accuracy

## Running Evaluations

### Prerequisites
1. Ensure Claude Code CLI is installed and configured
2. Ensure doc-reviewer subagent exists at `~/.claude/agents/doc-reviewer.md`
3. Ensure doc-reviewer template and markdownlint config are installed in `~/.claude/agents/doc-reviewer/`

### Running the Tests
```bash
cd agents/doc-reviewer/eval
python3 test_semantic_preservation.py
```

The framework will:
- Load test cases from `test_cases.json`
- Create temporary git repos with staged documentation changes
- Invoke the real doc-reviewer subagent for each test case
- Parse output files from `tmp/doc-reviewer/doc-reviewer-*.md`
- Evaluate detection accuracy and generate metrics

## Interpreting Results

### Metrics
- **Accuracy**: Overall correctness (100% = perfect)
- **Precision**: Of flagged issues, how many are real? (avoid false alarms)
- **Recall**: Of real issues, how many were caught? (avoid missing issues)
- **F1 Score**: Balance of precision and recall

### Classifications
- **True Positive**: Correctly identified semantic loss
- **True Negative**: Correctly identified no semantic loss
- **False Positive**: Incorrectly flagged as semantic loss
- **False Negative**: Missed a real semantic loss

### Detection Logic
The evaluator considers only **CRITICAL ISSUES** as semantic loss:
- Lines containing "CRITICAL ISSUES" or "CRITICAL" + "MUST FIX"
- Warnings and suggestions are not counted as semantic loss
- Each finding must start with "Finding #" to be counted

## Adding New Test Cases

1. Identify a semantic preservation scenario
2. Create a git diff showing the change
3. Add to `test_cases.json`:
```json
{
  "test_id": "semantic_005",
  "description": "Your test description",
  "git_diff": "...",
  "semantic_check": {
    "original_capabilities": ["what could be done before"],
    "modified_capabilities": ["what can be done after"],
    "semantic_loss": true/false,
    "severity": "critical/warning/none"
  }
}
```

## Troubleshooting

### Claude CLI not found
- Ensure Claude Code CLI is installed: `npm install -g @anthropic/claude-code`
- Verify it's in your PATH: `which claude`
- Test basic functionality: `claude --version`

### Doc-reviewer not found
- Check if subagent exists: `ls ~/.claude/agents/doc-reviewer.md`
- Ensure template exists: `ls ~/.claude/agents/doc-reviewer/output-template.md`
- Verify markdownlint config: `ls ~/.claude/agents/doc-reviewer/markdownlint.jsonc`

### Low accuracy with doc-reviewer
- Review the doc-reviewer template for critical issue patterns
- Check if severity mapping matches evaluator expectations
- Ensure output format follows "Finding #" pattern
- Debug with output files in `tmp/doc-reviewer/` directory

### Test cases failing to parse
- Verify git diff format in test_cases.json
- Ensure proper escaping of special characters
- Validate JSON structure: `python3 -m json.tool test_cases.json`
- Check temporary repo creation in debug output
