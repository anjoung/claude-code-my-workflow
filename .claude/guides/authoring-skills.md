# Authoring Skills

**Location:** `.claude/skills/skill-name/SKILL.md` — directory name = slash command (`/skill-name`)

## Frontmatter

```yaml
---
name: skill-name
description: One-sentence summary
disable-model-invocation: true
argument-hint: "[file or topic]"
allowed-tools: ["Read", "Bash", "Glob", "Grep", "Write", "Edit", "Task"]
---
```

- `name` must match directory name.
- `argument-hint` shows in help text.
- `allowed-tools` controls what the skill can use. Include `Task` if it spawns agents.

## Arguments

Access via `$ARGUMENTS`. Three patterns:

| Pattern | Example | When |
|---------|---------|------|
| Direct substitution | `xelatex $ARGUMENTS.tex` | Compilation, deployment |
| Conditional | "If `$ARGUMENTS` provided, use as message; otherwise analyze..." | Flexible commands |
| Semantic parsing | Parse natural language into structured parameters | Research workflows |

## Three Skill Patterns

### 1. Delegation (30-45 lines)
Launch one agent, return its report.
```markdown
## Steps
1. Read `$ARGUMENTS`
2. Launch the `agent-name` agent via Task tool
3. Present summary to user
```

### 2. Procedural (45-80 lines)
Linear steps with bash commands and verification.
```markdown
## Steps
1. Run command
2. Check output
3. Verify results
```

### 3. Orchestration (80-150 lines)
Multiple phases, agents, gates, or loops.
```markdown
## Workflow
Phase 0: Setup
Phase 1: Execute → GATE (user approval)
Phase 2: Agent loop (max 5 rounds)
Phase 3: Verify + report
```

## Conventions

- Outputs go to `quality_reports/` (reviews), `Figures/` (assets), `output/` (analysis)
- Always specify iteration limits for loops
- Include verification steps after compilation/deployment
- Reference rules: `.claude/rules/relevant-rule.md`
- Bold action verbs in steps; CAPITALIZE critical warnings

## Skeleton

```markdown
---
name: my-skill
description: What this does in one sentence
disable-model-invocation: true
argument-hint: "[expected input]"
allowed-tools: ["Read", "Bash", "Glob", "Grep"]
---

# Skill Title

Brief description of what this skill does.

**Input:** `$ARGUMENTS` — [what's expected]

## Steps

1. **Check input:** Verify `$ARGUMENTS` is provided
2. **Execute:** [main action]
3. **Verify:** [confirmation step]
4. **Report:** Present results to user
```
