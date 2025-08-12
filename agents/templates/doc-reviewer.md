# Documentation Review Output Template

## ⚠️ TEMPLATE GUIDELINES (DO NOT INCLUDE IN OUTPUT)

**IMPORTANT**: The following guidelines are for the reviewer's reference only.
DO NOT copy these guidelines into your actual review output. Start your review
output from the "📊 REVIEW SUMMARY" section below.

### Required Elements for Each Finding

- Exact line numbers
- Before/after comparisons
- Specific restoration commands
- Quantifiable impact assessment

### Key Review Focus Areas

- No unintended content removal
- Key information preserved
- Semantic meaning maintained
- Structure improvements don't lose context
- Links and references still valid
- Code examples remain accurate
- No loss of critical warnings or notes
- Formatting changes preserve readability
- API documentation accuracy
- Cross-reference validity
- Version-specific information
- Security-related content

### Output Requirements

- Every finding must be actionable
- Include exact commands for fixes
- Provide clear prioritization
- Maintain professional tone throughout

---

## START YOUR REVIEW OUTPUT HERE ↓

<!-- Unescape this title. Use it as is. Do not change it -->
\# Documentation Review Refactor Analysis

## 📊 REVIEW SUMMARY

```text
Date: [YYYY-MM-DD HH:MM]
Files Reviewed: [count]
Total Changes: [+X lines, -Y lines]
Severity Distribution: Critical: [X] | Warning: [Y] | Suggestion: [Z]
Overall Risk Level: [High/Medium/Low]
```

## 📁 SCOPE OF CHANGES

```text
Modified Files:
1. [file_path] (+X/-Y lines)
   - Primary changes: [brief description]
   - Risk areas: [specific concerns]

2. [file_path] (+X/-Y lines)
   - Primary changes: [brief description]
   - Risk areas: [specific concerns]

New Files Added:
1. [file_path] (+X lines)
   - Primary changes: [brief description]
   - Risk areas: [specific concerns]

2. [file_path] (+X lines)
   - Primary changes: [brief description]
   - Risk areas: [specific concerns]
```

## 🚨 DETAILED FINDINGS

### CRITICAL ISSUES (Content Lost/Broken - MUST FIX)

````text
Finding #C1: [Descriptive Title]
File: [path/to/file.md]
Lines: [line_range]
Issue: [What was lost or broken]
Impact: [Why this matters]

BEFORE:
```[language]
[exact content that was removed/changed]
```

AFTER:
```[language]
[current state showing the problem]
```

RESTORE WITH:
```[language]
[exact fix to apply]
```
---
````

### ⚠️ WARNINGS (Meaning Changed - SHOULD FIX)

````text
Finding #W1: [Descriptive Title]
File: [path/to/file.md]
Lines: [line_range]
Issue: [How meaning was altered]
Impact: [Potential confusion or misinterpretation]

SEMANTIC COMPARISON:
Original meaning: "[summarize original intent]"
Current meaning: "[summarize current interpretation]"
Difference: [explain the semantic shift]

SUGGESTED FIX:
```[language]
[recommended correction]
```
---
````

### 💡 SUGGESTIONS (Clarity Improvements - CONSIDER)

```text
Finding #S1: [Descriptive Title]
File: [path/to/file.md]
Lines: [line_range]
Current: [brief description]
Enhancement: [proposed improvement]
Rationale: [why this would help]
---
```

## 🔍 SEMANTIC INTEGRITY ANALYSIS

Content Preservation Score: [X]

- Critical content retained: [✓/✗]
- Key concepts preserved: [✓/✗]
- Technical accuracy maintained: [✓/✗]
- Examples and warnings intact: [✓/✗]

**Meaning Consistency Matrix:**

| Section | Original Intent | Current State | Integrity |
|---------|----------------|---------------|-----------|
| [name]  | [summary]      | [summary]     | [✓/⚠️/✗]  |

## 📋 QUALITY METRICS

```text
Documentation Health Indicators:

- Readability Score: [Before: X] → [After: Y] [↑↓→]
- Link Integrity: [X/Y links valid]
- Code Example Validity: [X/Y examples verified]
- Reference Accuracy: [X/Y references correct]
- Format Consistency: [Maintained/Degraded/Improved]
```

## 🎯 ACTION ITEMS

**Immediate Actions Required:**

1. [ ] [Specific action for each critical issue]
2. [ ] [Include file path and line numbers]

**Recommended Improvements:**

1. [ ] [Specific action for warnings]
2. [ ] [Optional enhancements]
