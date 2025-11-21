---
description: "Create a GitHub issue following repository conventions"
argument-hint: "<issue description>"
allowed-tools: ["Bash"]
---

Create a GitHub issue for: $ARGUMENTS

Steps:

1. Check for issue template
   - Use `ls .github/ISSUE_TEMPLATE/` or `find .github/ISSUE_TEMPLATE/ -type f` to check for template files
   - If template exists, follow its structure exactly
   - If no template, check existing issues: `gh issue list --limit 3`

2. If repository has template, follow it. Otherwise use this structure:
   - ### Summary (What & Why)
     Problem + motivation in 3-5 lines
   - ### Acceptance Criteria
     Pass/fail checkboxes or bullets
   - ### Scope/Notes
     Out of scope, constraints, assumptions

3. DO NOT include (these belong in PRs):
   - Implementation details or solution approach
   - Code changes or technical specifics
   - Test details or verification steps
   - Screenshots, UI changes or evaluations

4. Use `gh issue create` with appropriate title and body
   - Match template title format if it exists (e.g., "[Issue]: " prefix)
   - Keep acceptance criteria specific and testable

Rule of Thumb: Issue = WHAT & WHY (not HOW)
