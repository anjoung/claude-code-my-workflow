# Authoring Claude Code Skills: A Practical Guide

A skill is a slash command that extends Claude Code. This guide shows you how to build one.

---

## What Is a Skill?

**Location:** `.claude/skills/skill-name/SKILL.md`

**Invocation:** Directory name becomes the command. `.claude/skills/proofread/` → `/proofread`

**What happens:** When a user types `/proofread Lecture1.qmd`, Claude reads `SKILL.md` and executes the instructions with `$ARGUMENTS = "Lecture1.qmd"`.

---

## Required Ingredients

### 1. YAML Frontmatter (Exactly These Fields)

```yaml
---
name: skill-name
description: One-sentence summary of what this does
disable-model-invocation: true
argument-hint: "[file or topic]"
allowed-tools: ["Read", "Bash", "Glob", "Grep", "Write", "Edit", "Task"]
---
```

**Fields:**
- `name`: Must match directory name (kebab-case)
- `description`: Shown in `/help` — keep it under 80 characters
- `disable-model-invocation`: Always `true` in this project (prevents infinite recursion)
- `argument-hint`: Placeholder text for help messages (e.g., `"[file.tex]"`, `"[topic]"`, `"[LectureN]"`)
- `allowed-tools`: Array of tools the skill can use (Read, Write, Edit, Bash, Glob, Grep, Task)

### 2. Body Structure (Consistent Across All Skills)

```markdown
# Skill Title

Brief description of what the skill does (1-2 sentences).

**Input:** $ARGUMENTS — [description of expected input]

## Steps

1. **Action 1** — description
   - Sub-step details
   - Code blocks or examples

2. **Action 2** — description
   ...

## [Optional Sections]
- Constraints
- Principles
- Output Format
- Important
- Quality Rubric
```

**Conventions:**
- H1 title immediately after frontmatter
- Imperative mood in steps ("**Read** the file", "**Launch** the agent")
- CAPITALIZED CRITICAL warnings
- Tables for gates, rubrics, checklists
- Iteration limits always explicit ("max 5 rounds")

---

## Argument Handling

Skills access user input via the `$ARGUMENTS` variable. Three common patterns:

### Pattern 1: Direct Substitution

Used in bash-heavy skills (compile, deploy).

```bash
# User types: /compile-latex Lecture01_Intro
# Skill uses:
xelatex $ARGUMENTS.tex
bibtex $ARGUMENTS
```

### Pattern 2: Conditional Logic

Used when arguments are optional (commit).

```markdown
If `$ARGUMENTS` is provided, use it as the commit message.
Otherwise, analyze staged changes and write a message explaining *why*, not just *what*.
```

### Pattern 3: Semantic Parsing

Used for complex inputs (data-analysis, lit-review, interview-me).

```markdown
**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/panel.csv`)
OR a description of the analysis goal (e.g., "regress wages on education
with state fixed effects").
```

**No formal validation** — skills trust the orchestrator to parse intent.

---

## The Three Skill Patterns

Choose the right pattern based on complexity:

| Pattern | Lines | Use When | Examples |
|---------|-------|----------|----------|
| **Simple Delegation** | 32-44 | Single agent, no bash | review-r, pedagogy-review, proofread |
| **Procedural Workflow** | 42-80 | Linear steps with bash | compile-latex, deploy, commit |
| **Multi-Phase Orchestration** | 85-156 | Multiple agents, gates, loops | create-lecture, slide-excellence, qa-quarto |

---

### Pattern 1: Simple Delegation (32-44 lines)

**When to use:** You need to launch a single agent and return a report.

**Structure:**
1. Identify file(s) to process (handle wildcards like "all" or "LectureN")
2. Launch agent via Task tool
3. Present summary

**Template:**

```markdown
---
name: review-something
description: Review something using the something-reviewer agent
disable-model-invocation: true
argument-hint: "[filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Something

Run the comprehensive review protocol for [files of type X].

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific filename: review that file only
   - If `$ARGUMENTS` is `LectureN`: review all matching files
   - If `$ARGUMENTS` is `all`: review everything in [directory]

2. **For each file, launch the `something-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read relevant rules from `.claude/rules/`
   - Save report to `quality_reports/[filename]_review.md`

3. **After all reviews complete**, present a summary:
   - Total issues found per file
   - Breakdown by severity (Critical / High / Medium / Low)
   - Top 3 most critical issues

4. **IMPORTANT: Do NOT edit source files.**
   Only produce reports. Fixes are applied after user review.
```

**Examples:**
- `review-r` (32 lines) — R code review
- `pedagogy-review` (37 lines) — pedagogical patterns
- `proofread` (44 lines) — grammar and typos

---

### Pattern 2: Procedural Workflow (42-80 lines)

**When to use:** Linear sequence of bash commands with verification steps.

**Structure:**
1. Pre-flight checks (locate files, verify state)
2. Execute bash commands (compile, render, deploy)
3. Verification (grep logs, check outputs)
4. Report results

**Template:**

```markdown
---
name: do-something
description: Do something with bash commands
disable-model-invocation: true
argument-hint: "[filename or identifier]"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Do Something

[Brief description of what this workflow does.]

## Steps

1. **Pre-flight checks:**
   - Verify required files exist
   - Check current state with `git status`

2. **Execute the main command:**

```bash
cd SomeDir
ENVVAR=../Path:$ENVVAR command $ARGUMENTS.ext
ENVVAR=../Path:$ENVVAR command2 $ARGUMENTS
```

3. **Check for warnings/errors:**
   - Grep output for [specific warnings]
   - Report any issues found

4. **Verify outputs:**
   ```bash
   open SomeDir/$ARGUMENTS.pdf
   ```

5. **Report results:**
   - Success/failure
   - Number of warnings
   - Output file size/page count

## Important
- Always use [specific tool], never [alternative]
- [Critical environment variable] is required because [reason]
```

**Examples:**
- `compile-latex` (57 lines) — 3-pass XeLaTeX compilation
- `deploy` (42 lines) — Quarto render + sync to docs/
- `commit` (80 lines) — Stage, commit, PR, merge

---

### Pattern 3: Multi-Phase Orchestration (85-156 lines)

**When to use:** Multiple agents, quality gates, iterative loops, or complex workflows.

**Structure:**
1. Phase 0: Pre-flight and context gathering
2. Phase 1-N: Sequential phases with gates
3. Agent coordination (parallel or iterative)
4. Quality gates between phases
5. Final report

**Sub-patterns:**

#### 3a. Parallel Multi-Agent (slide-excellence)

Launch multiple agents in parallel, then synthesize results.

```markdown
### 2. Run Review Agents in Parallel

**Agent 1: Visual Audit** (slide-auditor)
- [What it checks]
- Save: `quality_reports/[FILE]_visual_audit.md`

**Agent 2: Pedagogical Review** (pedagogy-reviewer)
- [What it checks]
- Save: `quality_reports/[FILE]_pedagogy_report.md`

[... agents 3-6 ...]

### 3. Synthesize Combined Summary

[Template for combining all reports]
```

#### 3b. Iterative Loop (qa-quarto)

Critic finds issues → Fixer applies corrections → Re-audit → Loop until APPROVED.

```markdown
## Workflow

```
Phase 0: Pre-flight → Phase 1: Critic audit → Phase 2: Fixer
→ Phase 3: Re-audit → Loop until APPROVED (max 5 rounds)
```

## Phase 2: Fix Cycle

If not APPROVED, launch `quarto-fixer` agent to apply fixes
(Critical → Major → Minor), re-render, and verify.

## Phase 3: Re-Audit

Re-launch critic to verify fixes. Loop back to Phase 2 if needed.

## Iteration Limits

Max 5 fix rounds. After that, escalate to user with remaining issues.
```

#### 3c. Sequential Phases with Gates (create-lecture)

User approval required before proceeding to next phase.

```markdown
### Phase 2: Structure Proposal
- Propose outline (template options)
- List diagrams and figures needed
- List new notation to introduce
- **GATE: User approves before Phase 3**

### Phase 3: Draft Slides (Iterative)
- Work in batches of 5-10 slides
- Check notation, apply creation patterns
- Quality checks during drafting
```

**Examples:**
- `slide-excellence` (71 lines) — 6 agents in parallel
- `qa-quarto` (57 lines) — Critic/fixer loop
- `create-lecture` (85 lines) — Sequential phases with gates
- `review-paper` (156 lines) — Most comprehensive

---

## Agent Delegation Patterns

6 of 19 skills delegate to agents. Use the Task tool to spawn agents.

### Single Agent

```markdown
2. **Launch the `r-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `.claude/rules/r-code-conventions.md` for current standards
   - Save report to `quality_reports/[script_name]_r_review.md`
```

### Parallel Multi-Agent

```markdown
### 2. Run Review Agents in Parallel

Launch all agents simultaneously using the Task tool. Each agent:
- Reads the same source file
- Applies its specialized lens
- Saves independent report to `quality_reports/`

Then synthesize results into a combined summary.
```

### Iterative Loop (Critic + Fixer)

```markdown
## Phase 1: Initial Audit
Launch the `quarto-critic` agent. Report saved to
`quality_reports/[Lecture]_qa_critic_round1.md`.

## Phase 2: Fix Cycle
If not APPROVED, launch `quarto-fixer` agent to apply fixes
(Critical → Major → Minor), re-render, and verify.

## Phase 3: Re-Audit
Re-launch critic to verify fixes. Loop back to Phase 2 if needed.

## Iteration Limits
Max 5 fix rounds.
```

---

## Output Location Conventions

**Consistent across all 19 skills:**

| Output Type | Location | Pattern |
|-------------|----------|---------|
| Review reports | `quality_reports/` | `[filename]_[type]_report.md` |
| Plans | `quality_reports/plans/` | `YYYY-MM-DD_description.md` |
| Session logs | `quality_reports/session_logs/` | `YYYY-MM-DD_description.md` |
| Merge reports | `quality_reports/merges/` | `YYYY-MM-DD_[branch-name].md` |
| Analysis output | `output/` | Subdirectories by analysis type |
| Figures | `Figures/` | Subdirectories by lecture |
| R scripts | `scripts/R/` | Descriptive names |

**Never hardcode dates** — generate them at runtime:

```bash
date +%Y-%m-%d
```

---

## Skeleton Templates

### Skeleton 1: Simple Delegation

```markdown
---
name: review-x
description: Review X files using the x-reviewer agent
disable-model-invocation: true
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review X Files

Run the comprehensive X review protocol.

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific filename: review that file
   - If `$ARGUMENTS` is `all`: review all X files in [directory]

2. **For each file, launch the `x-reviewer` agent** with instructions to:
   - Follow the protocol in `.claude/agents/x-reviewer/`
   - Read relevant rules from `.claude/rules/`
   - Save report to `quality_reports/[filename]_x_review.md`

3. **Present summary:**
   - Total issues per file
   - Breakdown by severity
   - Top 3 critical issues

4. **IMPORTANT: Do NOT edit source files.**
   Only produce reports.
```

### Skeleton 2: Procedural Workflow

```markdown
---
name: do-x
description: Do X with bash commands
disable-model-invocation: true
argument-hint: "[filename]"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Do X

[Brief description.]

## Steps

1. **Pre-flight:**
   - Verify file exists
   - Check prerequisites

2. **Execute:**

```bash
cd TargetDir
ENVVAR=../Path:$ENVVAR command $ARGUMENTS.ext
```

3. **Verify:**
   - Grep for warnings/errors
   - Check output quality

4. **Report:**
   - Success/failure
   - Relevant metrics

## Important
- Always use [specific tool]
- [Critical environment variable] required
```

### Skeleton 3: Multi-Phase Orchestration

```markdown
---
name: orchestrate-x
description: Multi-phase X workflow with quality gates
disable-model-invocation: true
argument-hint: "[identifier]"
allowed-tools: ["Read", "Bash", "Glob", "Grep", "Write", "Edit", "Task"]
---

# Orchestrate X

[Brief description of multi-phase workflow.]

## Workflow

```
Phase 0: Pre-flight → Phase 1: [Action] → GATE → Phase 2: [Action]
→ Phase 3: [Action] → Loop if needed (max 5 rounds)
```

## Hard Gates (Non-Negotiable)

| Gate | Condition |
|------|-----------|
| **Gate 1** | [Condition] |
| **Gate 2** | [Condition] |

## Phase 0: Pre-flight

1. [Step 1]
2. [Step 2]

## Phase 1: [Action]

Launch [agent(s)]. Report saved to `quality_reports/`.

## Phase 2: [Action]

If not APPROVED, [corrective action].

## Phase 3: Re-Verification

Re-check. Loop back to Phase 2 if needed.

## Iteration Limits

Max 5 rounds. After that, escalate to user.

## Final Report

Save to `quality_reports/[identifier]_final.md` with:
- Gate status
- Iteration summary
- Remaining issues (if any)
```

---

## Checklist: Before You Ship Your Skill

### Structure
- [ ] YAML frontmatter complete (all 5 required fields)
- [ ] `name` matches directory name (kebab-case)
- [ ] H1 title immediately after frontmatter
- [ ] Steps section with numbered, imperative instructions

### Functionality
- [ ] `$ARGUMENTS` usage documented clearly
- [ ] All bash commands tested (especially environment variables)
- [ ] Output paths follow project conventions
- [ ] Iteration limits explicit (if applicable)
- [ ] Error handling specified (what happens if file not found, compilation fails, etc.)

### Quality
- [ ] Tables for gates, rubrics, or checklists (if applicable)
- [ ] Code blocks properly fenced
- [ ] CAPITALIZED warnings for critical instructions
- [ ] Agent delegation clear (which agent, what instructions, where to save)
- [ ] Verification steps included (compile → check → report)

### Integration
- [ ] References to `.claude/rules/` files (if applicable)
- [ ] References to templates in `templates/` (if applicable)
- [ ] Quality thresholds align with `CLAUDE.md` gates (80/90/95)
- [ ] Follows existing conventions (output locations, naming patterns)

### Documentation
- [ ] `argument-hint` is helpful and accurate
- [ ] Description is under 80 characters
- [ ] "Important" or "Constraints" section for critical details
- [ ] Examples or code blocks for complex steps

---

## Quick Reference: Skill Complexity by Line Count

| Lines | Pattern | Examples |
|-------|---------|----------|
| 32-44 | Simple delegation | review-r (32), pedagogy-review (37), proofread (44) |
| 42-80 | Procedural workflow | deploy (42), compile-latex (57), commit (80) |
| 85-156 | Multi-phase orchestration | create-lecture (85), slide-excellence (71), review-paper (156) |

**Rule of thumb:**
- **< 50 lines:** Single agent or linear bash workflow
- **50-80 lines:** Multiple steps with verification, or conditional logic
- **> 80 lines:** Multiple agents, quality gates, or iterative loops

---

## Common Mistakes to Avoid

1. **Missing `disable-model-invocation: true`** — Will cause infinite recursion
2. **Forgetting environment variables in bash** — `TEXINPUTS`, `BIBINPUTS`, etc. are critical
3. **No iteration limits** — Always specify "max N rounds" for loops
4. **Vague argument descriptions** — Users need to know exactly what to pass
5. **Inconsistent output paths** — Follow the convention table above
6. **No verification steps** — Always check that bash commands succeeded
7. **Editing in place without user approval** — Report first, edit after approval (except in autonomous fixer agents)
8. **Assuming files exist** — Always verify file paths before processing

---

## Advanced: When to Create a New Skill vs. Use an Existing One

**Create a new skill when:**
- The workflow is reusable (you'll run it 3+ times)
- It combines multiple steps that are tedious to repeat
- It enforces quality gates or conventions
- It coordinates multiple agents in a specific sequence

**Use an existing skill when:**
- The task fits an existing pattern (review, compile, deploy, etc.)
- You just need to tweak arguments or file paths
- The workflow is one-off or exploratory

**Extend an existing skill when:**
- You need to add a new file type to a review skill
- You want to add a new quality gate to an existing workflow
- The pattern is right but missing one feature

---

## Resources

- **All skills:** `.claude/skills/*/SKILL.md`
- **Agent templates:** `.claude/agents/*/AGENT.md`
- **Rules:** `.claude/rules/*.md`
- **Templates:** `templates/*.md`
- **Project conventions:** `CLAUDE.md`

---

**Remember:** Skills are recipes. Write them for clarity, not cleverness. Future you (and future Claude sessions) will thank you.
