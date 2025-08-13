# Using the Semantic Preservation Evaluation Framework

## Current Setup

The framework currently uses a **mock doc-reviewer** (`mock_doc_reviewer.py`) for testing. This allows you to:
1. Test the evaluation framework itself
2. Understand the expected behavior
3. Run tests without needing Claude Code CLI

## Switching to Real doc-reviewer

To use with the actual doc-reviewer subagent, modify `test_semantic_preservation.py`:

```python
# Line 88-92, change from:
mock_script = Path(__file__).parent / "mock_doc_reviewer.py"
cmd = ["python3", str(mock_script)]

# To:
cmd = [
    "claude",
    "--print",  # Non-interactive mode to capture output
    "Use doc-reviewer to review the staged documentation changes"
]
```

## Running Evaluations

### With Mock (Current)
```bash
cd doc-reviewer/eval
python3 test_semantic_preservation.py
```

### With Real doc-reviewer
1. Ensure Claude Code CLI is installed and configured
2. Ensure doc-reviewer subagent exists at `~/.claude/agents/doc-reviewer.md`
3. Make the code change above
4. Run the evaluation

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

### Current Performance
With the mock doc-reviewer:
- 100% accuracy on 4 test cases
- Detects: column removal, link deletion, context loss
- Correctly ignores: formatting-only changes

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

## Educational Path

### Phase 1 (Current) ✅
- Basic Python implementation
- Mock doc-reviewer for testing
- 4 test cases
- Simple metrics

### Phase 2 (Next Steps)
- Integration with real doc-reviewer
- Add 10+ more test cases
- Test edge cases
- Add confidence scoring

### Phase 3 (Future)
- Auto-generate test variations
- Multi-model validation
- Parallel execution
- CI/CD integration

### Phase 4 (Advanced)
- Consider frameworks like EleutherAI harness
- Distributed testing
- Standardized benchmarks
- Community contributions

## Why This Approach?

1. **Educational**: You understand every line of code
2. **Practical**: Solves real problem (doc review quality)
3. **Scalable**: Can grow as needs increase
4. **Generic**: Tests semantic preservation, not patterns
5. **Measurable**: Clear metrics for improvement

## Troubleshooting

### Mock not detecting issues
- Check the heuristics in `mock_doc_reviewer.py`
- Ensure git diff format is correct
- Verify the patterns match your test cases

### Low accuracy with real doc-reviewer
- Review the doc-reviewer prompt/template
- Check if it's using the correct severity levels
- Ensure it's outputting in expected format

### Test cases failing to parse
- Check git diff format in test_cases.json
- Ensure proper escaping of special characters
- Verify JSON is valid

## Next Steps

1. ✅ Framework created and tested
2. ✅ Mock doc-reviewer working
3. ✅ 100% accuracy on initial test cases
4. **TODO**: Integration with real doc-reviewer
5. **TODO**: Expand test suite to 20+ cases
6. **TODO**: Add to CI/CD pipeline