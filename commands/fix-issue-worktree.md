---
description: "Fix a GitHub issue in a new git worktree"
argument-hint: "<issue-number> <branch-name>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Fix GitHub issue #$1 in a new worktree with branch $2.

Steps:

1. Create worktree with the specified branch
   !git worktree add ../$2 -b $2
2. Navigate to the worktree
   !cd ../$2
3. Run Claude to fix the issue in the worktree
   !claude --dangerously-skip-permissions -p "I'm working on fixing issue #$1 in a dedicated worktree branch ($2). Please: 1) Get issue details using 'gh issue view $1', 2) Analyze the issue and search for relevant files, 3) Think hard and draft a production-grade solution plan, 4) Implement the necessary changes to fix the issue, 5) Write and run tests to verify the fix, 6) Ensure code passes linting and type checking, 7) Create a descriptive commit message referencing issue #$1, 8) Push and create a PR."
4. Document the Claude session (after Claude completes)
   Find the conversation JSONL file and convert to CSV:
   !ls ~/.claude/projects/*$2/*.jsonl | head -1 | xargs -I {} python3 scripts/conversation-jsonl-to-csv/jsonl-to-csv.py {} ../$2/tmp/issue-$1-fix.csv
5. Commit the documentation (optional)
   !cd ../$2 && git add tmp/issue-$1-fix.csv && git commit -m "Add Claude Code work log for issue #$1 (REMOVE BEFORE MERGE)"

This command creates an isolated workspace, runs Claude to fix the issue, and documents the work session.
