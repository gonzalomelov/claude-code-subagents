---
description: "Convert Claude Code conversation to CSV documentation"
argument-hint: "<conversation-id>"
allowed-tools: ["Bash", "Read", "Write"]
---

Convert Claude Code conversation $ARGUMENTS to CSV documentation.

Steps:

1. Locate the JSONL conversation file for ID: $ARGUMENTS
2. Convert to CSV using the conversion script
3. Save CSV to tmp/ directory with meaningful name
4. Optionally commit the CSV for documentation

Commands:

- Find conversation: `ls ~/.claude/conversations/*$ARGUMENTS*.jsonl`
- Convert: `python3 scripts/conversation-jsonl-to-csv/jsonl-to-csv.py [input.jsonl] tmp/$ARGUMENTS.csv`

This creates a compact, readable record of the Claude Code session.
