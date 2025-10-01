---
description: "Create a GitHub PR following repository conventions"
argument-hint: "<pr description>"
allowed-tools: ["Bash"]
---

Create a GitHub pull request for: $ARGUMENTS

Steps:

1. Check for PR template
   - Look for `.github/PULL_REQUEST_TEMPLATE.md`
   - If template exists, follow its structure exactly
   - If no template, check existing PRs: `gh pr list --limit 3` and `gh pr view`

2. If repository has template, follow it. Otherwise use this structure:
   - ## What / How
     Summary of changes and implementation approach
   - ## Result
     Screenshots, before/after, tests, perf/telemetry
   - ## Risks & Rollout
     Risks/mitigations, migrations/ops, backout plan
   - Closes #<issue-id>

3. DO NOT include (these belong in issues):
   - Problem statement or requirements
   - Business context or user stories
   - Scope definition or acceptance criteria
   - Priority or feature planning

4. Use `gh pr create` with appropriate title and body
   - Ensure issue link follows template format (e.g., "Closes #X")
   - Include all relevant sections from template

Rule of Thumb: PR = HOW & WHAT CHANGED
