---
description: "Delete a worktree and clean up all associated resources"
argument-hint: "<worktree-path-or-branch-name>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Delete worktree at $ARGUMENTS and clean up all associated Docker resources

Steps:

1. Resolve worktree path and branch name from argument
   - If argument contains '/', treat as path
   - Otherwise, find worktree by branch name: git worktree list | grep "$ARGUMENTS"
   - Extract branch name from worktree list output
2. Extract worktree folder name from path (basename of the directory)
   This will be used as the Docker Compose project name
3. Stop and remove Docker resources using docker compose
   - Determine project name from folder basename
   - Run: docker compose -p "${PROJECT_NAME}" down -v
   - The -v flag removes volumes
   - This handles containers, networks, and volumes in one command
4. Remove git worktree registration
   git worktree remove "${WORKTREE_PATH}"
   - This also deletes the directory if it's clean
   - Add --force flag if directory has uncommitted changes
5. Delete the branch
   git branch -D "${BRANCH_NAME}"
6. Verify cleanup:
   - Check worktree removed: git worktree list (should not show the deleted worktree)
   - Check branch deleted: git branch --list "${BRANCH_NAME}" (should be empty)
   - Check Docker resources gone:
     * docker ps -a --filter "name=${PROJECT_NAME}"
     * docker volume ls --filter "name=${PROJECT_NAME}"
     * docker network ls --filter "name=${PROJECT_NAME}"

Safety checks:
- Warn if worktree has uncommitted changes before using --force
- Confirm before deleting if it's the current worktree
- Don't delete main/master branch worktrees without explicit confirmation
