---
description: "Fix a GitHub issue in a new git worktree"
argument-hint: "<issue-number>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Fix GitHub issue #$ARGUMENTS in a new worktree

Steps:

1. Get issue details and show the title
   gh issue view $ARGUMENTS --json number,title,body,labels
2. Generate branch name from issue number and title. Generate worktree folder name by adding repo name as prefix to the branch name
3. Create worktree using the defined names
   git worktree add "../${WORKTREE_FOLDER_NAME}" -b "${BRANCH}"
4. Navigate to the worktree
   cd "../${WORKTREE_FOLDER_NAME}"
5. Run Claude in the worktree. This background job will take time to finish. If timeouts happen, just sleep for a bit and check BashOutput until finished. DO NOT run claude more than once
   claude --dangerously-skip-permissions -p "I'm working on fixing issue #$ARGUMENTS. Analyze the issue and delegate to the most appropriate subagent. The subagent must:

   1. Get full issue details using 'gh issue view $ARGUMENTS'
   2. Analyze the issue thoroughly and search for all relevant files
   3. Think hard and draft a production-grade solution plan
   4. Implement or make the necessary changes to fix the issue completely
   5. Write and run comprehensive code tests or docs evaluations to verify the fix
   6. Ensure all code or docs passes linting and type checking
   7. Create a descriptive commit message that references issue #$ARGUMENTS
   8. Push the branch and create a PR that closes issue #$ARGUMENTS

   Focus on delivering a production-ready solution that fully addresses the issue"

6. Document the Claude session (after claude cli completes)
   ls ~/.claude/projects/*${WORKTREE_FOLDER_NAME}/*.jsonl | head -1 | xargs -I {} python3 ~/.claude/scripts/conversation-jsonl-to-csv/jsonl-to-csv.py {} "../${WORKTREE_FOLDER_NAME}/tmp/${CONVERSATION_ID}.csv"
7. Commit the work documentation and push
   cd "../${WORKTREE_FOLDER_NAME}" && git add tmp/${CONVERSATION_ID}.csv && git commit -m "Add Claude Code work log for issue #$ARGUMENTS (REMOVE BEFORE MERGE)"
