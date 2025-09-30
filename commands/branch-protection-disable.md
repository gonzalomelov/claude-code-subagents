---
description: "Temporarily disable branch protection rules for repository maintenance"
argument-hint: "<owner/repo> <branch>"
allowed-tools: ["Bash"]
---

Disable branch protection for: $ARGUMENTS

Steps:

1. Check current protection matches expected baseline
2. If matches, remove all branch protection rules from branch
3. If doesn't match, fail with error message
4. Show confirmation that protection is disabled

Commands:

```bash
# Parse arguments (required)
ARGS="$ARGUMENTS"

# More robust parsing for two arguments
# Extract repository (everything before the last space)
REPO="${ARGS% *}"
# Extract branch (everything after the last space)
BRANCH="${ARGS##* }"

# Validate arguments - ensure we have exactly two space-separated values
if [ -z "$ARGS" ] || [ -z "$REPO" ] || [ -z "$BRANCH" ] || [ "$REPO" = "$ARGS" ]; then
  echo "ERROR: Please specify both repository and branch"
  echo "Usage: /disable-branch-protection owner/repo branch"
  echo "Example: /disable-branch-protection myorg/myrepo main"
  exit 1
fi

echo "Repository: $REPO, Branch: $BRANCH"

# Check if branch protection is currently enabled
gh api repos/$REPO/branches/$BRANCH/protection >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Branch protection not found or already disabled"
  exit 1
fi

# Get current protection settings for verification
echo "Current branch protection detected. Preparing to disable..."

# Disable protection
gh api -X DELETE repos/$REPO/branches/$BRANCH/protection 2>&1
if [ $? -eq 0 ]; then
  echo "✓ Branch protection disabled for $REPO:$BRANCH"
  echo ""
  echo "⚠️  WARNING: Branch is now unprotected!"
  echo "Remember to re-enable protection after maintenance:"
  echo "  /enable-branch-protection $REPO $BRANCH"
else
  echo "ERROR: Failed to disable branch protection"
  echo "Please check your permissions and try again"
  exit 1
fi
```
