# Authoring Claude Code Agents: A Practical Guide

**Target audience:** You want to create a new agent for your Claude Code workflow.

**What this is:** A recipe with all the ingredients and proportions. Copy, customize, ship.

---

## 1. What Is an Agent?

An agent is a specialized Claude instance with:
- **A role** (reviewer, implementer, verifier)
- **Tool access** (read-only for critics, write access for fixers)
- **A system prompt** (Markdown file with YAML frontmatter)
- **A home** (`.claude/agents/kebab-case-name.md`)

Agents are called by skills or by the orchestrator during automated review loops.

---

## 2. File Format

**Location:** `.claude/agents/kebab-case-name.md`

**Structure:**
```markdown
---
name: kebab-case-name
description: One-sentence role + trigger ("Use after...", "Use proactively...")
tools: Read, Grep, Glob
model: inherit
---

[Markdown body: persona, task, checklist, report format, rules]
```

**Line count guidance:** 66-177 lines (avg: 131). Don't write terse instructions — these are comprehensive system prompts.

---

## 3. Required Ingredients

### 3.1 YAML Frontmatter (exact format)

```yaml
---
name: agent-name           # kebab-case, matches filename
description: Expert [role] for [domain]. [What it checks]. Use [when].
tools: Read, Grep, Glob    # see Tool Access Decision Guide below
model: inherit             # always use inherit unless you have a reason
---
```

**Description format examples:**
- "Expert proofreading agent for academic lecture slides. Reviews for grammar, typos, overflow, and consistency. Use proactively after creating or modifying lecture content."
- "Adversarial QA agent that compares Quarto HTML against Beamer PDF benchmark. Produces harsh, actionable criticism. Does NOT edit files — read-only analysis only."
- "Template agent — customize the 5 review lenses for your field. Checks derivation correctness, assumption sufficiency, citation fidelity..."

### 3.2 Persona Statement (1-2 paragraphs)

**Pattern:** "You are a **[strong role descriptor]** for [domain]."

Use bold for key attributes. Examples:
- "You are an **expert proofreading agent** for academic lecture slides."
- "You are a **merciless visual critic** for TikZ diagrams in academic slides."
- "You are a **Senior Principal Data Engineer** (Big Tech caliber) who also holds a **PhD** with deep expertise in quantitative methods."
- "You are a **harsh, uncompromising quality auditor** for academic presentation slides."

**Optional second paragraph:** Clarify scope or philosophy.

### 3.3 Task/Mission Section

**Section name:** `## Your Task` or `## Your Mission` or `## Your Role`

**Format:** Bullet list or numbered steps.

**Example (read-only agent):**
```markdown
## Your Task

Review the specified file thoroughly and produce a detailed report of all issues found. **Do NOT edit any files.** Only produce the report.
```

**Example (write-access agent):**
```markdown
## Your Task

1. Read the critic's report from `quality_reports/`
2. Apply each fix in order of priority (Critical → Major → Minor)
3. Re-render the slides
4. Verify fixes compiled correctly
5. Report what was done
```

### 3.4 Domain-Specific Content (bulk of the agent)

**This is where you specify WHAT to review/fix/verify.**

**Common patterns:**
- Checklists (checkboxes for each category)
- Decision trees (if X then Y)
- Severity taxonomies (CRITICAL/MAJOR/MINOR)
- Known pitfall lists
- Visual comparison lenses
- Format-specific rules

**Example structures:**
- `## Check for These Categories` → subsections with `###` headers
- `## Review Protocol` → numbered steps
- `## [N] Pedagogical Patterns to Validate` → enumerated list
- `## Comparison Dimensions` → table or list

### 3.5 Report Format (for read-only agents) or Fix Application Process (for write agents)

**CRITICAL:** Show the exact markdown template for output.

**Read-only agent pattern:**
```markdown
## Report Format

For each issue found, provide:

\```markdown
### Issue N: [Brief description]
- **File:** [filename]
- **Location:** [slide title or line number]
- **Current:** "[exact text that's wrong]"
- **Proposed:** "[exact text with fix]"
- **Category:** [Grammar / Typo / Overflow / Consistency / Academic Quality]
- **Severity:** [High / Medium / Low]
\```

## Save the Report

Save to `quality_reports/[FILENAME_WITHOUT_EXT]_report.md`
```

**Write-access agent pattern:**
```markdown
## Fix Application Process

### Step 1: Read the Critic's Report
The report will be at: `quality_reports/[Lecture]_qa_critic_round[N].md`

### Step 2: Apply Fixes (Priority Order)
**Always fix Critical issues first, then Major, then Minor.**

[Detailed instructions...]

### Step 3: Re-Render
\```bash
./scripts/sync_to_docs.sh LectureX
\```

### Step 4: Verify and Report
**Save report to:** `quality_reports/[Lecture]_qa_fixer_round[N].md`
```

### 3.6 Boundary Rules Section

**Section name:** `## Important Rules` or `## Rules` or `## Remember`

**Format:** DO/DON'T lists or numbered rules.

**Common rules for reviewers:**
```markdown
## Important Rules

1. **NEVER edit source files.** Report only.
2. **Be specific.** Include line numbers and exact code snippets.
3. **Be actionable.** Every issue must have a concrete proposed fix.
4. **Prioritize correctness.** Domain bugs > style issues.
5. **Check Known Pitfalls.** See `.claude/rules/[file].md` for project-specific bugs.
```

**Common rules for implementers:**
```markdown
## Rules

### DO:
- Follow critic instructions exactly
- Apply fixes in priority order
- Re-render after all fixes
- Verify fixes worked

### DO NOT:
- Make independent design decisions
- Add "improvements" not requested by critic
- Skip Critical issues
- Declare fixes successful without verification

### IF BLOCKED:
- If a fix instruction is unclear: apply most conservative interpretation
- If a fix requires user input: mark as "Blocked"
- If a fix causes render errors: revert and report the error
```

---

## 4. Tool Access Decision Guide

| Agent Role | Tools | Rationale |
|------------|-------|-----------|
| **Reviewers / Critics** | `Read, Grep, Glob` | Cannot edit files; report only |
| **Implementers / Fixers** | `Read, Write, Edit, Grep, Glob, Bash` | Full access to apply fixes and run commands |
| **Verifiers** | `Read, Grep, Glob, Bash` | Can run compilation/rendering commands but not edit source |
| **Translators** | `Read, Write, Edit, Grep, Glob, Bash` | Convert between formats; write new files |

**Hard enforcement boundary:** Review agents MUST NOT have Write/Edit access. This prevents them from silently fixing issues instead of reporting them.

---

## 5. Persona and Tone Guidance

### Strong Personas (examples from existing agents)

| Persona | Agent Type | Effect |
|---------|------------|--------|
| "Expert proofreading agent" | Reviewer | Professional, thorough |
| "Merciless visual critic" | Reviewer | High standards, harsh |
| "Harsh, uncompromising quality auditor" | Reviewer | Adversarial, assume guilty |
| "Senior Principal Data Engineer with PhD" | Reviewer | Authority + rigor |
| "Precise implementer" | Fixer | Follows instructions exactly |
| "Specialist in translating..." | Translator | Domain expert |

### Tone Patterns

**For adversarial reviewers:**
- "Your role is **adversarial**: assume the [output] is guilty until proven innocent."
- "Your job is to find EVERY visual flaw, no matter how small."
- "Be harsh — if something is 'close enough', it's NOT good enough."

**For implementers:**
- "You do NOT make independent design decisions — follow the critic's instructions exactly."
- "Your job is precise execution. Speed matters less than accuracy."
- "You are the **implementer**, not the decision-maker."

**For template agents:**
- "Template agent — customize the 5 review lenses for your field."
- Use `<!-- CUSTOMIZE: ... -->` HTML comments to mark customization points.

---

## 6. Severity and Verdict Conventions

### Severity Taxonomies (pick one)

**Hard gates (3-level):**
- **CRITICAL** — Blocks correctness, safety, or compilation
- **MAJOR** — Blocks professional quality or deployment
- **MINOR** — Improvement recommended

**Soft scale (3-level):**
- **High** — Must fix before shipping
- **Medium** — Should fix when practical
- **Low** — Nice to have

**Reviewer-specific (4-level):**
- **Critical** — Math/logic error, missing content
- **High** — Quality concern, reproducibility issue
- **Medium** — Style inconsistency, minor oversight
- **Low** — Polish, aesthetic preference

### Verdict Patterns

**Binary (simple reviewers):**
```markdown
## Verdict: APPROVED / NEEDS REVISION
```

**Multi-level (comprehensive reviewers):**
```markdown
## Verdict: [APPROVED / NEEDS REVISION / REJECTED]

| Verdict | Condition |
|---------|-----------|
| **APPROVED** | Zero critical, zero major, ≤3 minor |
| **NEEDS REVISION** | Any critical OR major issues remain |
| **REJECTED** | Hard gate failure |
```

**Outcome-based (domain reviewers):**
```markdown
## Summary
- **Overall assessment:** [SOUND / MINOR ISSUES / MAJOR ISSUES / CRITICAL ERRORS]
- **Blocking issues (prevent teaching):** M
- **Non-blocking issues (should fix when possible):** K
```

---

## 7. Cross-References to Knowledge Base

**Pattern:** Agents read `.claude/rules/*.md` files for standards.

**Examples:**
- "Read `.claude/rules/r-code-conventions.md` for the current standards"
- "Check `.claude/rules/no-pause-beamer.md` for overlay command policy"
- "See `.claude/rules/tikz-visual-quality.md` for the full specification"
- "Check the knowledge base in `.claude/rules/` for notation conventions"

**Why:** Standards live in one place; agents reference them instead of duplicating.

---

## 8. Complete Agent Skeleton (Copy This)

```markdown
---
name: your-agent-name
description: [Role] for [domain]. [What it does]. Use [trigger].
tools: Read, Grep, Glob
model: inherit
---

You are a **[strong persona descriptor]** for [domain].

[Optional: Second paragraph clarifying scope or philosophy.]

## Your Task

[Numbered steps or bullet list of what this agent does.]

**Do NOT edit any files.** [For read-only agents]

---

## [Main Content Section]

[This is the bulk: checklists, decision trees, patterns to validate, etc.]

### Category 1: [Name]
- [ ] Check item 1
- [ ] Check item 2

**Flag:** [What to look for as a problem]

### Category 2: [Name]
[Details...]

---

## Report Format

[For read-only agents: Show exact markdown template for output]

**Save report to:** `quality_reports/[naming_pattern].md`

\```markdown
# [Report Title]
**Date:** [YYYY-MM-DD]
**Reviewer:** [agent-name] agent

## Summary
- **[Key metric]:** X
- **[Another metric]:** Y

## Issues

### Issue 1: [Title]
- **Severity:** [CRITICAL / MAJOR / MINOR]
- **Location:** [file:line or slide number]
- **Problem:** [description]
- **Fix:** [specific action]

[Repeat for each issue...]
\```

---

## [For write-access agents: Fix Application Process]

### Step 1: [Action]
[Instructions...]

### Step 2: [Action]
[Instructions...]

---

## Important Rules

1. **[Most important constraint]**
2. **[Second constraint]**
3. **[Third constraint]**

### DO:
- [Required behavior 1]
- [Required behavior 2]

### DO NOT:
- [Prohibited behavior 1]
- [Prohibited behavior 2]

### IF BLOCKED:
- [Guidance for edge cases]

---

## Remember

[Final philosophical reminder about the agent's role and priorities.]
```

---

## 9. Checklist: Before You Ship Your Agent

- [ ] Filename is kebab-case and matches `name:` in YAML
- [ ] Description explains role + usage trigger
- [ ] Tools match the role (reviewers = read-only; fixers = write access)
- [ ] Persona statement is strong and specific
- [ ] Task/Mission section is clear
- [ ] Domain content has concrete checklists or lenses
- [ ] Report format shows exact markdown template
- [ ] Boundary rules section exists with DO/DON'T lists
- [ ] Severity taxonomy is defined and consistent
- [ ] Verdict criteria are explicit
- [ ] Cross-references to `.claude/rules/*.md` where appropriate
- [ ] Agent is 66-177 lines (comprehensive, not terse)
- [ ] Template agents use `<!-- CUSTOMIZE -->` comments

---

## 10. Examples by Category

### Read-Only Reviewers (7 agents)
- `proofreader.md` — Grammar, typos, overflow (66 lines, shortest)
- `slide-auditor.md` — Visual layout, overflow, spacing (114 lines)
- `pedagogy-reviewer.md` — 13 pedagogical patterns (160 lines)
- `r-reviewer.md` — R code quality, 10 categories (174 lines)
- `tikz-reviewer.md` — Visual critic for TikZ diagrams (87 lines)
- `quarto-critic.md` — Adversarial QA, hard gates (171 lines)
- `domain-reviewer.md` — Template for substantive review (177 lines, longest)

### Write-Access Implementers (2 agents)
- `quarto-fixer.md` — Applies fixes from quarto-critic (135 lines)
- `beamer-translator.md` — LaTeX → Quarto translation (134 lines)

### Verification Agent (1 agent)
- `verifier.md` — Compile/render/deploy checks (91 lines)

---

## 11. Anti-Patterns (Don't Do This)

❌ **Vague descriptions:** "Helps with slides" → ✅ "Reviews for grammar, typos, overflow, and consistency"
❌ **Missing report template:** Agent says "produce a report" but doesn't show format
❌ **Weak persona:** "You review code" → ✅ "You are a **Senior Principal Data Engineer with PhD**"
❌ **Wrong tools for role:** Reviewer with Write/Edit access → silently fixes instead of reporting
❌ **No boundary rules:** Agent doesn't know when to stop or what it can't do
❌ **Terse instructions:** 20-line agent that says "check for issues" with no specifics
❌ **Duplicate standards:** Agent copies rules that should be in `.claude/rules/*.md`
❌ **No severity taxonomy:** "Fix the issues" without priority guidance
❌ **Ambiguous save location:** "Save the report somewhere" instead of exact path pattern

---

## 12. How Agents Are Called

**By skills:**
```markdown
Agent: your-agent-name
Target: [file or directory]
```

**By orchestrator (automated):**
- Review agents run after implementation
- Fixer agents read critic reports and apply fixes
- Verifier runs after fixers complete

**Iteratively (critic-fixer loop):**
```
critic → report → fixer → apply fixes → re-render → critic (round 2) → ...
```

Max 5 rounds before surfacing to user.

---

## 13. Customization Points for Template Agents

**domain-reviewer.md** is explicitly a template. Customization instructions:

```markdown
<!-- ============================================================
     TEMPLATE: Domain-Specific Substance Reviewer

     CUSTOMIZE THIS FILE for your field by:
     1. Replacing the persona description (line ~15)
     2. Adapting the 5 review lenses for your domain
     3. Adding field-specific known pitfalls (Lens 4)
     4. Updating the citation cross-reference sources (Lens 3)
     ============================================================ -->
```

**beamer-translator.md** uses inline customization markers:

```markdown
### Environment Mapping

<!-- Customize this table for your project's custom environments -->
| Beamer | Quarto |
|--------|--------|
| `\begin{methodbox}...\end{methodbox}` | `::: {.methodbox}\n...\n:::` |
```

**Pattern:** Use HTML comments to mark what should be replaced. Don't just say "customize" — tell them WHERE and WHAT.

---

## 14. Final Advice

**Start with an existing agent as a template.** Copy the one closest to your role (reviewer vs fixer vs verifier).

**Write long, not short.** 66-177 lines. Comprehensive beats terse. You're writing a system prompt, not a command-line flag.

**Test iteratively.** Call your agent on a real file. Does it produce the report format you specified? Does it catch the issues you care about?

**Enforce tool boundaries.** Reviewers can't edit. Fixers must verify. Verifiers can't write.

**Make severity explicit.** Every issue needs a severity level. Every verdict needs criteria.

**Cross-reference standards.** Don't duplicate rules that live in `.claude/rules/*.md`.

**Ship when it's useful, not perfect.** Agents improve through use. Ship at 80%, iterate to 100%.
