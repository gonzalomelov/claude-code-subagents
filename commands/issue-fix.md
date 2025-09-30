---
description: "Analyze and fix a GitHub issue with implementation"
argument-hint: "<issue-number or issue-url>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "Task"]
---

Please analyze and fix the GitHub issue: $ARGUMENTS.

Steps:

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Think hard and draft a production-grade solution plan
5. Implement the necessary changes to fix the issue
6. Write and run tests to verify the fix
7. Ensure code passes linting and type checking
8. Create a descriptive commit message
9. Push and create a PR

Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.
