---
description: "Address PR review comments systematically"
argument-hint: "<pr-number>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task", "TodoWrite"]
---

Address review comments on PR #$ARGUMENTS

Steps:

1. Get PR details and checkout the branch
   gh pr view $ARGUMENTS --json number,title,headRefName,headRepository
   gh pr checkout $ARGUMENTS
2. Fetch and analyze all PR review comments using GraphQL for comprehensive thread context
   gh repo view --json owner,name
   Use the repository owner and name from the above output in the GraphQL query below:
   gh api graphql -f query="query {
     repository(owner: \"OWNER_FROM_ABOVE\", name: \"NAME_FROM_ABOVE\") {
       pullRequest(number: $ARGUMENTS) {
         reviewThreads(first: 100) {
           nodes {
             isResolved
             path
             line
             startLine
             originalLine
             originalStartLine
             diffSide
             comments(first: 10) {
               nodes {
                 body
                 author { login }
                 createdAt
                 position
                 originalPosition
                 diffHunk
               }
             }
           }
         }
       }
     }
   }"
3. Run Claude to address the comments. This background job will take time to finish. If timeouts happen, just sleep for a bit and check BashOutput until finished. DO NOT run claude more than once. MANDATORY: You must delegate to Claude CLI - do not address comments directly yourself
   claude --dangerously-skip-permissions -p "I'm working on addressing review comments for PR #$ARGUMENTS. Analyze the PR comments and delegate to the most appropriate subagent. The subagent must:

   1. Get repository info with 'gh repo view --json owner,name'
   2. Fetch all review comments using the GraphQL query to get reviewThreads with resolved status
   3. Focus on UNRESOLVED comments first, listing all unresolved comments and required changes
   4. Address each comment systematically with high-quality changes
   5. Update code and documentation as needed to fully satisfy each review comment
   6. Write and run comprehensive tests to verify all changes work correctly
   7. Ensure all code passes linting and type checking after changes
   8. Create descriptive commit messages that reference PR #$ARGUMENTS and the addressed comments
   9. Push the updates to the PR branch

   Focus on understanding reviewer intent and making thoughtful improvements that fully satisfy each review comment"

4. Document the Claude session (after claude cli completes)
   Use separate bash commands to avoid escaping issues:
   - Get repo name: basename $(pwd)
   - Find latest conversation: ls -t ~/.claude/projects/*REPO_NAME/*.jsonl | head -1
   - Extract conversation ID from filename
   - Run: python3 ~/.claude/scripts/conversation-jsonl-to-csv/jsonl-to-csv.py [jsonl-file] "tmp/[conversation-id].csv"
5. Commit the work documentation with the title "Add Claude Code work log for PR #$ARGUMENTS review comments (REMOVE BEFORE MERGE)" and push

IMPORTANT: You MUST follow these exact steps in order. Do NOT deviate from this workflow even for simple changes