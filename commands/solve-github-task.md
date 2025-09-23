---
description: "Complete a GitHub task from planning to implementation"
argument-hint: "<issue-number or issue-url>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Grep", "Glob", "WebFetch", "Task"]
---

Please analyze and solve the GitHub task: $ARGUMENTS.

Follow these steps:

1. Use `gh issue view` to get the issue details
2. Understand the problem. Read relevant files or URLs. Use subagents to verify or investigate specific questions. Do not write code yet
3. Think hard and draft a production-grade solution plan
4. Wait for my approval of the plan before proceeding
5. Once approved, open a draft PR with the plan
6. Write failing tests following TDD principles
7. Wait for my approval on the test validity before implementation
8. Commit the tests
9. Implement the fix to make tests pass. Use subagents if needed. Do not modify the tests
10. Build the shared package, lint, type-check, and ensure all tests pass
11. Update README and Changesets if applicable
12. Commit the changes, push, and mark the PR as open

Use the GitHub CLI (gh) for all GitHub actions.