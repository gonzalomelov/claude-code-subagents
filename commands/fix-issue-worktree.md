---
description: "Fix a GitHub issue in a new git worktree"
argument-hint: "<issue-number>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Fix GitHub issue #$ARGUMENTS in a new worktree.

Steps:

1. Get issue details and show the title
   gh issue view $ARGUMENTS --json number,title,body
2. Generate branch name from issue number and title. Generate worktree folder name by adding repo name as prefix to the branch name
3. Create worktree using the defined names
   git worktree add "../${WORKTREE_FOLDER_NAME}" -b "${BRANCH}"
4. Navigate to and run Claude in the worktree. This background job will take time to finish. If timeouts happen, just sleep for a bit and check BashOutput until finished. DO NOT run claude more than once
   cd "../${WORKTREE_FOLDER_NAME}" && claude --dangerously-skip-permissions -p "I'm working on fixing issue #$ARGUMENTS. Please: 1) Get issue details using 'gh issue view $ARGUMENTS', 2) Analyze the issue and search for relevant files, 3) Think hard and draft a production-grade solution plan, 4) Implement the necessary changes to fix the issue, 5) Write and run tests to verify the fix, 6) Ensure code passes linting and type checking, 7) Create a descriptive commit message referencing issue #$ARGUMENTS, 8) Push and create a PR."
5. Document the Claude session (after Claude completes)
   ls ~/.claude/projects/*${WORKTREE_FOLDER_NAME}/*.jsonl | head -1 | xargs -I {} python3 ~/.claude/scripts/conversation-jsonl-to-csv/jsonl-to-csv.py {} "../${WORKTREE_FOLDER_NAME}/tmp/${CONVERSATION_ID}.csv"
6. Commit the work documentation
   cd "../${WORKTREE_FOLDER_NAME}" && git add tmp/${CONVERSATION_ID}.csv && git commit -m "Add Claude Code work log for issue #$ARGUMENTS (REMOVE BEFORE MERGE)"
