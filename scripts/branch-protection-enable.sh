#!/bin/bash

# Parse arguments (required)
ARGS="$*"

# More robust parsing for two arguments
# Extract repository (everything before the last space)
REPO="${ARGS% *}"
# Extract branch (everything after the last space)
BRANCH="${ARGS##* }"

# Validate arguments - ensure we have exactly two space-separated values
if [ -z "$ARGS" ] || [ -z "$REPO" ] || [ -z "$BRANCH" ] || [ "$REPO" = "$ARGS" ]; then
  echo "ERROR: Please specify both repository and branch"
  echo "Usage: /enable-branch-protection owner/repo branch"
  echo "Example: /enable-branch-protection myorg/myrepo main"
  exit 1
fi

echo "Repository: $REPO, Branch: $BRANCH"

# Check if branch is currently unprotected
if gh api repos/$REPO/branches/$BRANCH/protection >/dev/null 2>&1; then
  echo "ERROR: Branch protection is already enabled"
  echo "Use /disable-branch-protection first if you want to reset"
  exit 1
fi

# Enable protection
cat << 'EOF' | gh api -X PUT repos/$REPO/branches/$BRANCH/protection --input -
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["lint"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false
  },
  "restrictions": null
}
EOF

# Verify protection was applied correctly
gh api repos/$REPO/branches/$BRANCH/protection >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✓ Branch protection enabled successfully for $REPO:$BRANCH"
  echo ""
  echo "Protection settings applied:"
  echo "- Required status checks: lint"
  echo "- Require pull request reviews: Yes (1 approval)"
  echo "- Enforce admins: Yes"
  echo "- Allow force pushes: No"
  echo "- Allow deletions: No"
else
  echo "⚠️  Branch protection was applied but verification failed"
  echo "Please check manually: https://github.com/$REPO/settings/branches"
fi
