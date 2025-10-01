---
description: "Get all PRs related to a GitHub issue"
argument-hint: "<issue-number>"
allowed-tools: ["Bash"]
---

Get all PRs related to issue: $ARGUMENTS

Steps:

1. Parse issue number from arguments
2. Fetch cross-referenced PRs using GitHub GraphQL API
3. Display all related PRs with their status

Commands:

```bash
# Parse arguments (required)
ISSUE_NUMBER="$ARGUMENTS"

if [ -z "$ISSUE_NUMBER" ]; then
  echo "ERROR: Please specify an issue number"
  echo "Usage: /issue-related-prs <issue-number>"
  exit 1
fi

# Get repository info from current directory
REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
OWNER=$(echo "$REPO_INFO" | cut -d'/' -f1)
NAME=$(echo "$REPO_INFO" | cut -d'/' -f2)

if [ -z "$OWNER" ] || [ -z "$NAME" ]; then
  echo "ERROR: Could not determine repository. Make sure you're in a git repository."
  exit 1
fi

echo "# Related PRs for Issue #$ISSUE_NUMBER in $REPO_INFO"
echo ""

# Fetch related PRs using GraphQL
gh api graphql -f query="
query {
  repository(owner: \"$OWNER\", name: \"$NAME\") {
    issue(number: $ISSUE_NUMBER) {
      number
      title
      timelineItems(itemTypes: CROSS_REFERENCED_EVENT, first: 20) {
        nodes {
          ... on CrossReferencedEvent {
            source {
              ... on PullRequest {
                number
                title
                state
                url
              }
            }
          }
        }
      }
    }
  }
}" | jq -r '
  .data.repository.issue as $issue |
  "## Issue: #" + ($issue.number | tostring) + " - " + $issue.title + "\n" +
  if ($issue.timelineItems.nodes | map(select(.source)) | length) == 0 then
    "\n**No related PRs found**"
  else
    "\n**Related PRs:**\n\n" +
    ($issue.timelineItems.nodes |
     map(select(.source)) |
     map(.source) |
     map("- PR #" + (.number | tostring) + ": " + .title + " (" + .state + ")\n  " + .url) |
     join("\n"))
  end
'
```
