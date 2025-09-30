---
description: "Create a GitHub PR following repository conventions"
argument-hint: "<pr description>"
allowed-tools: ["Bash"]
---

Create a GitHub pull request for: $ARGUMENTS

Steps:

1. Check existing PRs to match the repository's style
   - Run `gh pr list --limit 3` to see recent PRs
   - Run `gh pr view` on them to examine their format
   - Analyze their structure, conventions, and patterns
   - Follow the same style for consistency

2. Follow this structure:
   - Summary of changes (what was done)
   - Implementation approach (how it was done)
   - Technical details & code changes
   - Testing & verification steps
   - Screenshots/UI changes (if applicable)
   - Related issue (link with "Fixes #X")

3. DO NOT include (these belong in issues):
   - Problem statement or requirements
   - Business context or user stories
   - Scope definition or acceptance criteria
   - Priority or feature planning

4. Use `gh pr create` with appropriate title and body

Rule of Thumb: PR = HOW & WHAT CHANGED
