Re-enable branch protection for: $ARGUMENTS

## Usage

- `/enable-branch-protection owner/repo branch`

## Steps

1. Check if branch protection is currently disabled
2. If disabled, apply standard branch protection rules to branch
3. If already protected, fail with error message
4. Verify protection matches expected state after enabling

## Commands

```bash
# Parse arguments (required)
ARGS="$ARGUMENTS"
if [ -z "$ARGS" ]; then
  echo "ERROR: Please specify repository and branch"
  echo "Usage: /enable-branch-protection owner/repo branch"
  exit 1
fi

REPO=$(echo "$ARGS" | cut -d' ' -f1)
BRANCH=$(echo "$ARGS" | cut -d' ' -f2)

if [ -z "$REPO" ] || [ -z "$BRANCH" ]; then
  echo "ERROR: Both repository and branch are required"
  echo "Usage: /enable-branch-protection owner/repo branch"
  exit 1
fi

echo "Repository: $REPO, Branch: $BRANCH"

# Check if branch is currently unprotected
if gh api repos/$REPO/branches/$BRANCH/protection --jq . 2>/dev/null; then
  echo "ERROR: Branch protection is already enabled"
  echo "Use /disable-branch-protection first if you want to reset"
  exit 1
fi

# Enable protection
echo '{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": false
  },
  "restrictions": null
}' | gh api -X PUT repos/$REPO/branches/$BRANCH/protection --input -

# Define expected protection state after enabling
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

# Verify protection was applied correctly
CURRENT_PROTECTION=$(gh api repos/$REPO/branches/$BRANCH/protection --jq . | jq -S .)
if [ "$CURRENT_PROTECTION" != "$(echo "$EXPECTED_PROTECTION" | jq -S .)" ]; then
  echo "⚠️  Branch protection enabled but doesn't match expected state"
  echo "Protection was applied but may need manual verification"
else
  echo "✓ Branch protection enabled successfully for $REPO:$BRANCH"
fi
```
