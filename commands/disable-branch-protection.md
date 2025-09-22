Disable branch protection for: $ARGUMENTS

## Usage

- `/disable-branch-protection owner/repo branch`

## Steps

1. Check current protection matches expected baseline
2. If matches, remove all branch protection rules from branch
3. If doesn't match, fail with error message
4. Show confirmation that protection is disabled

## Commands

```bash
# Parse arguments (required)
ARGS="$ARGUMENTS"
if [ -z "$ARGS" ]; then
  echo "ERROR: Please specify repository and branch"
  echo "Usage: /disable-branch-protection owner/repo branch"
  exit 1
fi

REPO=$(echo "$ARGS" | cut -d' ' -f1)
BRANCH=$(echo "$ARGS" | cut -d' ' -f2)

if [ -z "$REPO" ] || [ -z "$BRANCH" ]; then
  echo "ERROR: Both repository and branch are required"
  echo "Usage: /disable-branch-protection owner/repo branch"
  exit 1
fi

echo "Repository: $REPO, Branch: $BRANCH"

# Define expected protection state
EXPECTED_PROTECTION='{
  "allow_deletions": { "enabled": false },
  "allow_force_pushes": { "enabled": false },
  "allow_fork_syncing": { "enabled": false },
  "block_creations": { "enabled": false },
  "enforce_admins": {
    "enabled": true,
    "url": "https://api.github.com/repos/'$REPO'/branches/'$BRANCH'/protection/enforce_admins"
  },
  "lock_branch": { "enabled": false },
  "required_conversation_resolution": { "enabled": false },
  "required_linear_history": { "enabled": false },
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false,
    "required_approving_review_count": 1,
    "url": "https://api.github.com/repos/'$REPO'/branches/'$BRANCH'/protection/required_pull_request_reviews"
  },
  "required_signatures": {
    "enabled": false,
    "url": "https://api.github.com/repos/'$REPO'/branches/'$BRANCH'/protection/required_signatures"
  },
  "url": "https://api.github.com/repos/'$REPO'/branches/'$BRANCH'/protection"
}'

# Check if current protection matches expected
CURRENT_PROTECTION=$(gh api repos/$REPO/branches/$BRANCH/protection --jq . 2>/dev/null | jq -S .)
if [ -z "$CURRENT_PROTECTION" ]; then
  echo "ERROR: Branch protection not found or already disabled"
  exit 1
fi

if [ "$CURRENT_PROTECTION" != "$(echo "$EXPECTED_PROTECTION" | jq -S .)" ]; then
  echo "ERROR: Current branch protection doesn't match expected baseline"
  echo "Please verify branch protection state before disabling"
  exit 1
fi

# Disable protection
gh api -X DELETE repos/$REPO/branches/$BRANCH/protection
echo "✓ Branch protection disabled for $REPO:$BRANCH"
```
