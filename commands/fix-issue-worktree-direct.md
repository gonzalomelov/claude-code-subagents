---
description: "Fix a GitHub issue directly in a new git worktree"
argument-hint: "<issue-number>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task", "TodoWrite", "WebSearch", "WebFetch"]
---

Fix GitHub issue #$ARGUMENTS directly in a new worktree

Steps:

1. Get issue details and show the title
   gh issue view $ARGUMENTS --json number,title,body,labels
2. Generate branch name from issue number and title. Generate worktree folder name by adding repo name as prefix to the branch name
3. Create worktree using the defined names
   git worktree add "../${WORKTREE_FOLDER_NAME}" -b "${BRANCH}"
4. Navigate to the worktree
   cd "../${WORKTREE_FOLDER_NAME}"
5. Analyze the issue thoroughly and search for all relevant files
6. Think hard and draft a production-grade solution plan
7. Implement or make the necessary changes to fix the issue completely
8. Write and run comprehensive code tests or docs evaluations to verify the fix
9. Ensure all code or docs passes linting and type checking
10. Create a descriptive commit message that references issue #$ARGUMENTS
11. Push the branch and create a PR that closes issue #$ARGUMENTS
12. Document the Claude session (after completing the fix)
   ls ~/.claude/projects/*${WORKTREE_FOLDER_NAME}/*.jsonl | head -1 | xargs -I {} python3 ~/.claude/scripts/conversation-jsonl-to-csv/jsonl-to-csv.py {} "../${WORKTREE_FOLDER_NAME}/tmp/${CONVERSATION_ID}.csv"
13. Commit the work documentation and push
   cd "../${WORKTREE_FOLDER_NAME}" && git add tmp/${CONVERSATION_ID}.csv && git commit -m "Add Claude Code work log for issue #$ARGUMENTS (REMOVE BEFORE MERGE)"