---
description: "Address PR review comments systematically"
argument-hint: "<pr-number>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Address review comments on PR #$ARGUMENTS.

Steps:

1. Get PR details and checkout the branch
   gh pr view $ARGUMENTS --json number,title,headRefName,headRepository
   gh pr checkout $ARGUMENTS
2. Fetch and analyze all PR review comments using GraphQL for comprehensive thread context
   REPO_INFO=$(gh repo view --json owner,name)
   OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
   NAME=$(echo "$REPO_INFO" | jq -r '.name')
   gh api graphql -f query="query {
     repository(owner: \"$OWNER\", name: \"$NAME\") {
       pullRequest(number: $ARGUMENTS) {
         reviewThreads(first: 100) {
           nodes {
             isResolved
             path
             line
             comments(first: 10) {
               nodes {
                 body
                 author { login }
               }
             }
           }
         }
       }
     }
   }"
3. Run Claude to address the comments. This background job will take time to finish. If timeouts happen, just sleep for a bit and check BashOutput until finished. DO NOT run claude more than once
   claude --dangerously-skip-permissions -p "I'm working on addressing review comments for PR #$ARGUMENTS. Please: 1) First get repository info with 'gh repo view --json owner,name', 2) Fetch all review comments using GraphQL query to get reviewThreads with resolved status, 3) Focus on UNRESOLVED comments first, 4) List all unresolved comments and required changes, 5) Think hard and draft a production-grade solution plan for each comment, 6) Address each comment systematically with high-quality changes, 7) Update code and documentation as needed, 8) Run tests and linting after changes, 9) Create descriptive commit messages referencing PR #$ARGUMENTS, 10) Push the updates to the PR."
4. Document the Claude session (after Claude completes)
   REPO_NAME=$(basename $(pwd))
   ls ~/.claude/projects/*${REPO_NAME}/*.jsonl | head -1 | xargs -I {} python3 ~/.claude/scripts/conversation-jsonl-to-csv/jsonl-to-csv.py {} "tmp/${CONVERSATION_ID}.csv"
5. Commit the work documentation and push
   git add tmp/${CONVERSATION_ID}.csv && git commit -m "Add Claude Code work log for PR #$ARGUMENTS review comments (REMOVE BEFORE MERGE)"

Focus on understanding reviewer intent and making thoughtful improvements that fully satisfy each review comment.
