# Authoring Rules

**Location:** `.claude/rules/kebab-case-name.md`

## Frontmatter (optional)

```yaml
---
paths:
  - "Slides/**/*.tex"
  - "scripts/**/*.R"
---
```

Include `paths:` to scope the rule to specific files. Omit for global rules (workflows, quality gates).

## Body Structure

1. **H1 title** with descriptive tagline.
2. **Bold opening principle** (1-2 sentences) — the thesis. E.g.: "**Every edit to a Beamer `.tex` file MUST be immediately synced to the corresponding Quarto `.qmd` file.**"
3. **`## The Rule`** or **`## Workflow`**: High-level protocol, numbered steps, or decision tree.
4. **`## When to Apply` / `## When NOT to Apply`**: Explicit inclusion AND exclusion criteria.
5. **Reference tables** (if needed): mappings, thresholds, pitfalls.
6. **`## Verification`**: Checklist with `- [ ]` items.
7. **Cross-references**: Link related rules, templates, agents explicitly.

## Writing Style

- **Imperative mood**: "Run X", "Check Y", "Never do Z"
- **Quantify everything**: `score >= 80` not "good quality"; `max 5 rounds` not "iterate until done"
- **Bold mandates**: **MUST**, **NEVER**, **CRITICAL**
- **Specify loop limits**: every iterative process needs a termination condition

## Naming Suffixes

| Suffix | Use |
|--------|-----|
| `-protocol.md` | Workflows, procedures |
| `-conventions.md` | Style guides, standards |
| `-template.md` | Fillable templates |
| (descriptive) | Single directives, policies |

## Target Length

- **10-20 lines**: Absolute mandates (e.g., `no-pause-beamer.md`)
- **30-50 lines**: Workflow protocols
- **60-100 lines**: Comprehensive domain conventions

## Skeleton

```markdown
---
paths:
  - "relevant/**/*.ext"
---

# Rule Name: Tagline

**Bold core principle in 1-2 sentences.**

## The Rule

1. Step one
2. Step two
3. Step three

## When NOT to Apply

- Exception 1
- Exception 2

## Verification

- [ ] Concrete check 1
- [ ] Concrete check 2

See also: `other-rule.md`, `templates/relevant-template.md`
```
