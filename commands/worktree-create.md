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
4. Determine next worktree number by counting existing worktrees (git worktree list | wc -l)
5. Change to new worktree directory and run environment setup
   cd "../${WORKTREE_FOLDER_NAME}" && ./scripts/setup-worktree-env.sh ${WORKTREE_NUMBER}
6. Generate AUTH_SECRET using openssl rand -base64 32
7. Update apps/web/.env.local with generated AUTH_SECRET and remind user to add remaining secrets:
   - AI_GATEWAY_API_KEY (for local development)
   - BLOB_READ_WRITE_TOKEN (for file uploads)
