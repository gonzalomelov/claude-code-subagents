---
description: "Create a GitHub issue following repository conventions"
argument-hint: "<issue description>"
allowed-tools: ["Bash"]
---

Create a GitHub issue for: $ARGUMENTS

First, check existing issues to match the repository's style:

- Run `gh issue list --limit 3` to see recent issues
- Analyze their format, structure, and conventions
- Follow the same patterns for consistency

Follow this structure:

- Problem/goal in plain language
- Context/background
- Scope & constraints
- Acceptance criteria (testable bullets)
- Priority/labels

DO NOT include (these belong in PRs):

- Implementation details or solution approach
- Code changes or technical specifics
- Test details or verification steps
- Screenshots, UI changes or evaluations

Use gh issue create with appropriate title and body. Rule of Thumb: Issue = WHAT & WHY (not HOW)
