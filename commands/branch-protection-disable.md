---
description: "Temporarily disable branch protection rules for repository maintenance"
argument-hint: "<owner/repo> <branch>"
allowed-tools: ["Bash(bash ~/.claude/scripts/branch-protection-disable.sh:*)"]
---

Disable branch protection for: $ARGUMENTS

Steps:

1. Check current protection matches expected baseline
2. If matches, remove all branch protection rules from branch
3. If doesn't match, fail with error message
4. Show confirmation that protection is disabled

Commands:

```bash
# Execute the branch protection disable script
bash ~/.claude/scripts/branch-protection-disable.sh $ARGUMENTS
```
