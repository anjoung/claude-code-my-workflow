# Authoring Agents

**Location:** `.claude/agents/kebab-case-name.md`

## Frontmatter

```yaml
---
name: kebab-case-name
description: One-sentence role + when to use ("Use after...", "Use proactively...")
tools: Read, Grep, Glob
model: inherit
---
```

**Tool access by role:**

| Role | Tools |
|------|-------|
| Reviewer / critic | `Read, Grep, Glob` |
| Implementer / fixer | `Read, Write, Edit, Grep, Glob, Bash` |
| Verifier | `Read, Grep, Glob, Bash` |

## Body Structure

1. **Persona** (1-2 paragraphs): "You are a **[strong descriptor]** who..." — set expertise and tone.
2. **`## Your Task`**: Numbered steps or bullet list of what the agent does.
3. **Domain content**: Checklists, lenses, decision trees, or pattern catalogs for systematic coverage.
4. **`## Report Format`** (reviewers) or **`## Fix Process`** (implementers): Exact markdown template for output, including:
   - Header with date, reviewer name
   - Summary with metrics
   - Issues with severity (`CRITICAL / MAJOR / MINOR`), location, current state, proposed fix
   - Save location: `quality_reports/[context]_[type].md`
5. **`## Important Rules`**: Explicit DO/DON'T boundary list. Always state whether the agent edits files or only reports.

## Conventions

- Verdict: `APPROVED / NEEDS REVISION / REJECTED`
- Reviewers must never edit files — enforce via tools AND instructions
- Reference `.claude/rules/*.md` for project standards
- Priority: correctness > style, critical > major > minor
- Target **80-150 lines** — comprehensive prompt, not terse instructions

## Skeleton

```markdown
---
name: my-agent
description: One-sentence role. Use after [trigger context].
tools: Read, Grep, Glob
model: inherit
---

You are a **[expertise]** specializing in [domain].

## Your Task

1. Read the target file(s)
2. Evaluate against [criteria]
3. Produce a structured report

## [Domain Checklist]

- [ ] Check 1
- [ ] Check 2

## Report Format

# [Report Type]: [Filename]
**Date:** YYYY-MM-DD
**Reviewer:** my-agent

## Summary
[Verdict + metrics]

## Issues
### Issue 1: [Title]
- **Location:** [file:line]
- **Severity:** CRITICAL / MAJOR / MINOR
- **Current:** [what's wrong]
- **Fix:** [what to do]

Save to: `quality_reports/[file]_[type]_report.md`

## Important Rules

- Do NOT edit any files — report only
- [Additional boundaries]
```
