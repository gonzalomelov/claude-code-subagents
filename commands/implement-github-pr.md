Please analyze and solve the GitHub PR: $ARGUMENTS.

Follow these steps:

1. Use `gh pr view` to get the PR details
2. Write failing tests following TDD principles
3. Wait for my approval on the test validity before implementation
4. Commit the tests
5. Implement the fix to make tests pass. Use subagents if needed. Do not modify the tests
6. Build the shared package, lint, type-check, and ensure all tests pass
7. Update README and Changesets if applicable
8. Commit the changes, push, and mark the PR as open

Use the GitHub CLI (gh) for all GitHub actions.
