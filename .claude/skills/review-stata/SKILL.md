---
name: review-stata
description: Run the Stata code review protocol on .do files. Checks code quality, reproducibility, domain correctness, and professional standards.
disable-model-invocation: true
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Stata Scripts

Run the comprehensive Stata code review protocol.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.do` filename: review that file only
   - If `$ARGUMENTS` is `all`: review all .do files in `scripts/Stata/`

2. **For each script, launch the `stata-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `.claude/rules/stata-code-conventions.md` for current standards
   - Save report to `quality_reports/[script_name]_stata_review.md`

3. **After all reviews complete**, present a summary:
   - Total issues found per script
   - Breakdown by severity (CRITICAL / MAJOR / MINOR)
   - Top 3 most critical issues

4. **IMPORTANT: Do NOT edit any .do source files.**
   Only produce reports. Fixes are applied after user review.
