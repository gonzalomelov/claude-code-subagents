---
description: "Fetch and display PR review comments grouped by status"
argument-hint: "<owner/repo> <pr-number>"
allowed-tools: ["Bash"]
---

Get PR review comments (resolved and unresolved) for: $ARGUMENTS

## Usage

- `/pr-review-comments owner/repo pr-number`

## Steps

1. Parse repository owner, name, and PR number from arguments
2. Fetch all review threads from the PR using GitHub GraphQL API
3. Group comments by resolved status
4. Display both resolved and unresolved comments with details

## Commands

```bash
# Parse arguments (required)
ARGS="$ARGUMENTS"
if [ -z "$ARGS" ]; then
  echo "ERROR: Please specify repository and PR number"
  echo "Usage: /pr-review-comments owner/repo pr-number"
  exit 1
fi

REPO=$(echo "$ARGS" | cut -d' ' -f1)
PR_NUMBER=$(echo "$ARGS" | cut -d' ' -f2)

if [ -z "$REPO" ] || [ -z "$PR_NUMBER" ]; then
  echo "ERROR: Both repository and PR number are required"
  echo "Usage: /pr-review-comments owner/repo pr-number"
  exit 1
fi

# Extract owner and name from repo
OWNER=$(echo "$REPO" | cut -d'/' -f1)
NAME=$(echo "$REPO" | cut -d'/' -f2)

if [ -z "$OWNER" ] || [ -z "$NAME" ]; then
  echo "ERROR: Repository must be in format owner/repo"
  exit 1
fi

echo "# PR #$PR_NUMBER Review Comments - $REPO"
echo ""

# Fetch review comments and convert to markdown
gh api graphql -f query="query {
  repository(owner: \"$OWNER\", name: \"$NAME\") {
    pullRequest(number: $PR_NUMBER) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          path
          line
          comments(first: 10) {
            nodes {
              body
            }
          }
        }
      }
    }
  }
}" | jq -r '
  .data.repository.pullRequest.reviewThreads.nodes |
  group_by(.isResolved) |
  map({
    resolved: .[0].isResolved,
    count: length,
    comments: map({path, line, comment: .comments.nodes[0].body})
  }) |
  map(
    if .resolved == false then
      "## 🔴 Unresolved Comments (" + (.count | tostring) + ")\n\n" +
      (.comments | map("- **" + .path + ":" + (.line | tostring) + "**: \"" + .comment + "\"") | join("\n"))
    else
      "## ✅ Resolved Comments (" + (.count | tostring) + ")\n\n" +
      (.comments | map("- **" + .path + ":" + (.line | tostring) + "**: \"" + .comment + "\"") | join("\n"))
    end
  ) | join("\n\n")
'
```
