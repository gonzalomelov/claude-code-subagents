---
description: "Re-enable branch protection rules after maintenance"
argument-hint: "<owner/repo> <branch>"
allowed-tools: ["Bash(bash ~/.claude/scripts/branch-protection-enable.sh:*)"]
---

Re-enable branch protection for: $ARGUMENTS

Steps:

1. Check if branch protection is currently disabled
2. If disabled, apply standard branch protection rules to branch
3. If already protected, fail with error message
4. Verify protection matches expected state after enabling

Commands:

```bash
# Execute the branch protection enable script
bash ~/.claude/scripts/branch-protection-enable.sh $ARGUMENTS
```
