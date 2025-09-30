---
description: "Create a new worktree to fix a GitHub issue"
argument-hint: "<issue-number>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Create a new worktree to fix GitHub issue #$ARGUMENTS

Steps:

1. Get issue details and show the title
   gh issue view $ARGUMENTS --json number,title,body,labels
2. Generate branch name from issue number and title. Generate worktree folder name by adding repo name as prefix to the branch name
3. Create worktree using the defined names
   git worktree add "../${WORKTREE_FOLDER_NAME}" -b "${BRANCH}"
