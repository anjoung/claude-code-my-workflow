# Authoring Claude Code Rules: A Practical Guide

**A recipe for creating effective, enforceable rules for your Claude Code project.**

---

## Overview

**What is a rule?** A Markdown file in `.claude/rules/` that teaches Claude how to behave in specific contexts.

**Scope:** Rules can be global (applies everywhere) or file-scoped (applies only to matching paths).

**Format:** Optional YAML frontmatter + Markdown body.

**Naming:** `kebab-case-name.md` with descriptive suffixes (`-protocol.md` for workflows, `-conventions.md` for style guides, `-template.md` for fillable templates).

**Scale:** Target 20-70 lines for most rules. Below 15 lines for absolute mandates, up to 100+ for comprehensive domain protocols.

---

## Required Ingredients

### 1. Frontmatter (optional but recommended for scoped rules)

```yaml
---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
---
```

**When to include:**
- File-type-specific rules (LaTeX conventions, R style guides)
- Directory-scoped rules (exploration protocols, deployment scripts)

**When to omit:**
- Global workflow rules (plan-first, orchestrator, session logging)
- Cross-cutting concerns (quality gates, verification)

### 2. H1 Title + Tagline

```markdown
# Rule Name: Brief Descriptive Tagline
```

Examples:
- `# Plan-First Workflow`
- `# Orchestrator Protocol: Contractor Mode`
- `# No \pause in Beamer`

### 3. Bold Opening Thesis (1-2 sentences)

State the core principle upfront. This is what Claude reads first.

```markdown
**For any non-trivial task, enter plan mode before writing code.**
```

```markdown
**LaTeX Beamer is the single source of truth. Quarto RevealJS derives from it.**
```

### 4. The Rule / The Protocol Section

High-level description of what this rule enforces.

```markdown
## The Rule

[Core behavior described in 2-4 sentences]
```

### 5. Procedural Steps (numbered or bulleted)

```markdown
## The Protocol

1. **Enter Plan Mode** — use `EnterPlanMode`
2. **Check MEMORY.md** — read any `[LEARN]` entries
3. **Draft the plan** — what changes, which files, in what order
4. **Save to disk** — write to `quality_reports/plans/`
```

### 6. When to Apply / When NOT to Apply

Explicit inclusion AND exclusion criteria.

```markdown
## When to Apply

- Complex multi-file changes
- Architectural decisions
- Unfamiliar territory

## When NOT to Apply

- Single-line typo fixes
- Renaming variables
- Obvious corrections
```

### 7. Domain-Specific Tables (if applicable)

```markdown
| Environment | Effect | Use Case |
|-------------|--------|----------|
| `keybox` | Gold background | Key points |
```

```markdown
| Threshold | Gate | Action |
|-----------|------|--------|
| < 80 | Block | Iterate |
| >= 80 | Commit | Ship |
```

### 8. Common Pitfalls / Anti-Patterns Table

```markdown
## Common Pitfalls

| Anti-Pattern | Why It Fails | Correct Approach |
|--------------|--------------|------------------|
| Batching edits in one step | Hard to verify | One file at a time |
| Vague commit messages | Lost context | Specific, actionable |
```

### 9. Enforcement / Verification Checklist

```markdown
## Enforcement

- [ ] Plan saved to `quality_reports/plans/` before implementation
- [ ] Session log created post-approval
- [ ] Verification step completed before review
- [ ] Quality score >= 80 before commit
```

### 10. Cross-References

```markdown
See `orchestrator-protocol.md` for execution loop.
Template: `templates/session-log.md`
```

---

## Scope Declaration Guide

### File-Scoped Rules (use frontmatter)

```yaml
---
paths:
  - "Slides/**/*.tex"       # LaTeX-specific rules
  - "Quarto/**/*.qmd"       # Quarto-specific rules
  - "scripts/**/*.R"        # R code conventions
  - "explorations/**/*"     # Exploration protocols
---
```

### Global Rules (omit frontmatter)

- Workflow orchestration (`plan-first-workflow.md`)
- Quality gates (`quality-gates.md`)
- Session management (`session-logging.md`)
- Cross-cutting verification (`verification-protocol.md`)

---

## Writing Style Guide

### Imperative Mood for Actions

```markdown
Enter Plan Mode
Check MEMORY.md
Save to disk
Never use `\pause`
```

### Conditional for Decisions

```markdown
If verification fails → fix → re-verify
Score >= 80? YES → commit / NO → iterate
```

### Bold for Mandates

```markdown
**MUST** compile before commit
**NEVER** use relative paths in agent mode
**ALWAYS** run verification after edits
**CRITICAL:** Save plans to disk before implementation
**MANDATORY:** Quality score >= 80 for merge
```

### Quantified Standards (not vague)

| Vague | Quantified |
|-------|------------|
| "Good quality" | "Score >= 80" |
| "Enough space" | "0.2 units minimum clearance" |
| "Iterate until done" | "Max 5 review-fix rounds" |
| "Check carefully" | "Run all 3 verification agents" |

### Tables for Reference Data

Use tables for:
- Mappings (environment → effect)
- Thresholds (score → action)
- Pitfalls (anti-pattern → fix)
- Checklists (task → verification)

### ASCII Diagrams for Flows

```
Plan approved → orchestrator activates
  │
  Step 1: IMPLEMENT
  │
  Step 2: VERIFY
  │         If fails → fix → re-verify
  │
  └── Score >= 80?
        YES → commit
        NO  → iterate (max 5 rounds)
```

---

## Cross-Referencing Conventions

### Rule → Rule

```markdown
See `orchestrator-protocol.md` for execution loop.
After plan approval, follow `orchestrator-protocol.md`.
```

### Rule → Template

```markdown
Template: `templates/session-log.md`
Use the skeleton at `templates/quality-report.md`.
```

### Rule → Agent (implicit through skills)

```markdown
Run `/proofread` before commit.
Use `/compile-latex` for 3-pass XeLaTeX.
```

### Hierarchy

```
plan-first-workflow.md
  └─→ orchestrator-protocol.md
        └─→ verification-protocol.md
              └─→ quality-gates.md
```

---

## Iteration Limits and Enforcement

**ALWAYS specify loop limits.**

```markdown
## Limits

- **Main loop:** max 5 review-fix rounds
- **Critic-fixer sub-loop:** max 5 rounds
- **Verification retries:** max 2 attempts
- Never loop indefinitely
```

**Why:** Prevents infinite loops, forces escalation to user when stuck.

---

## Complete Skeleton Template

```markdown
---
paths:
  - "path/to/**/*.ext"
---

# Rule Name: Descriptive Tagline

**Bold opening thesis: the core principle in 1-2 sentences.**

## The Rule

High-level description of what this rule enforces. 2-4 sentences.

## The Protocol

1. **Step One** — specific action
2. **Step Two** — specific action
3. **Step Three** — specific action

## When to Apply

- Scenario A
- Scenario B
- Scenario C

## When NOT to Apply

- Exception A
- Exception B
- Exception C

## Domain-Specific Reference (optional)

| Item | Effect | Use Case |
|------|--------|----------|
| A    | X      | Y        |
| B    | X      | Y        |

## Common Pitfalls

| Anti-Pattern | Why It Fails | Correct Approach |
|--------------|--------------|------------------|
| Bad practice | Reason       | Good practice    |

## Limits (if applicable)

- **Main loop:** max N rounds
- **Retries:** max M attempts
- Never loop indefinitely

## Enforcement

- [ ] Verification step 1
- [ ] Verification step 2
- [ ] Verification step 3

## Cross-References

See `other-rule.md` for related protocol.
Template: `templates/template-name.md`
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Fix |
|--------------|--------------|-----|
| Vague thresholds ("good enough") | Unenforceable | Quantify: "score >= 80" |
| Missing loop limits | Infinite loops | "Max 5 rounds" |
| No "when NOT to apply" section | Over-application | Explicit exclusions |
| Buried key mandate in prose | Claude misses it | **Bold** critical rules |
| Relative file paths | Breaks in agent mode | Always absolute paths |
| No verification checklist | Forgotten steps | `- [ ]` task list |
| 200+ line mega-rule | Dilutes focus | Split into multiple rules |
| Assumed context | Fragile across sessions | Explicit cross-references |

---

## Checklist: Before You Ship Your Rule

- [ ] Filename is `kebab-case-name.md`
- [ ] Saved to `.claude/rules/`
- [ ] Frontmatter `paths:` if scoped, omitted if global
- [ ] H1 title + tagline
- [ ] Bold opening thesis (1-2 sentences)
- [ ] `## The Rule` or `## The Protocol` section
- [ ] Procedural steps (numbered or bulleted)
- [ ] `## When to Apply` and `## When NOT to Apply`
- [ ] Tables for reference data (if applicable)
- [ ] `## Common Pitfalls` table
- [ ] `## Limits` for any loops or retries
- [ ] `## Enforcement` checklist with `- [ ]` items
- [ ] Cross-references to related rules/templates
- [ ] All mandates use **bold** keywords: MUST, NEVER, ALWAYS
- [ ] All thresholds are quantified (numbers, not adjectives)
- [ ] ASCII diagram for complex flows (if needed)
- [ ] 20-70 lines for standard rules (11-15 for absolute mandates, 100+ for comprehensive protocols)
- [ ] Imperative mood for actions, conditional for decisions
- [ ] No assumed context — explicit and self-contained

---

## Examples by Category

**Workflow Orchestration:**
- `plan-first-workflow.md` (38 lines)
- `orchestrator-protocol.md` (48 lines)
- `session-logging.md` (24 lines)

**Content Synchronization:**
- `beamer-quarto-sync.md` (54 lines)
- `single-source-of-truth.md` (70 lines)

**Quality Standards:**
- `quality-gates.md` (58 lines)
- `verification-protocol.md` (64 lines)
- `proofreading-protocol.md` (42 lines)

**Domain Conventions:**
- `r-code-conventions.md` (106 lines)
- `no-pause-beamer.md` (11 lines)

**Exploration/Research:**
- `exploration-folder-protocol.md` (68 lines)
- `exploration-fast-track.md` (20 lines)

---

## Final Notes

**Rules are ingredients, not recipes.** They compose together to form your project's behavior. A good rule:
- Is self-contained (explicit, not assumed)
- Is enforceable (quantified, not vague)
- Is scoped (global or file-specific)
- Is bounded (loop limits, no infinite cycles)
- Is verifiable (checklist at the end)

**Start small.** A 20-line rule that enforces one thing well beats a 100-line rule that tries to do everything.

**Test in practice.** If Claude ignores your rule, it's too vague or too buried. Bold the mandate. Quantify the threshold. Move it higher in the file.

**Iterate.** Rules evolve as your project grows. Treat them as living documentation.
