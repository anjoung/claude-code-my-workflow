---
paths:
  - "**/*.do"
  - "scripts/**/*.do"
  - "scripts/Stata/**/*.do"
---

# Stata Code Standards

**Standard:** Senior Applied Econometrician + Replication Specialist quality

---

## 1. Reproducibility

- `version 19` at top of every .do file
- `set seed YYYYMMDD` called ONCE at top
- `set sortseed YYYYMMDD` for deterministic sort order
- All paths relative via a `root` global set once at top
- `log using "output/logs/filename.log", text replace` at top; `log close` at bottom
- `cap mkdir` for output directories
- Script runs cleanly from `stata -e do file.do` on a fresh clone

## 2. Do-File Header

```stata
* ============================================================
* [Descriptive Title]
* Author: [name]
* Purpose: [what this script does]
* Inputs: [data files]
* Outputs: [tables, figures, logs]
* Stata version: 19/SE
* Date: [YYYY-MM-DD]
* ============================================================
```

## 3. Section Structure

```stata
* --- 0. Setup ---
* --- 1. Data Loading ---
* --- 2. Exploratory Analysis ---
* --- 3. Main Analysis ---
* --- 4. Tables and Figures ---
* --- 5. Export and Cleanup ---
```

## 4. Style Conventions

- Standard abbreviations accepted: `gen`, `reg`, `sum`, `tab`, `des`, `qui`, `loc`, `glo`
- **Locals by default.** Globals only for directory paths set once at top.
- **`///` for line continuation.** Never use `#delimit ;`.
- 4-space indentation, no tabs
- Lines under 100 characters where possible
- `forvalues` for numeric sequences, `foreach` for variable/string lists

## 5. Macro Hygiene

- Prefer `local` over `global` for all temporary values
- Use `tempvar`, `tempfile`, `tempname` for scratch variables
- Quote macros containing strings with spaces: `` `"`macro'"' ``
- No nested global references in production code

## 6. Error Handling

- `capture noisily` over bare `capture` (don't silently swallow errors)
- `assert` for data validation: `assert _N == expected`, `assert var > 0 if !mi(var)`
- `isid` before every `merge` to verify uniqueness
- Check `_merge` after every `merge`: `tab _merge` then `assert _merge == 3` or document exceptions
- `confirm file` before loading data

## 7. Table Output (esttab)

```stata
eststo clear
eststo: reg y x1, robust
eststo: reg y x1 x2, cluster(state)
eststo: reghdfe y x1 x2, absorb(state year) cluster(state)

esttab using "output/tables/main_results.tex", ///
    replace booktabs label ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared")) ///
    title("Main Results") ///
    nomtitle
```

Always export both `.tex` (for Beamer) and `.csv` (for inspection).

## 8. Figure Quality

- Use a consistent scheme (e.g., `plotplainblind` or project-specific `.scheme` file)
- `graph export "output/figures/name.pdf", replace` for Beamer
- `graph export "output/figures/name.png", replace width(1200)` for Quarto
- Readable fonts at projection size
- Proper axis labels with units

## 9. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `set sortseed` | Non-reproducible results with tied sorts | Always set alongside `set seed` |
| `merge` without `tab _merge` | Silent data loss or duplication | Always inspect merge diagnostics |
| Bare `capture` | Errors silently swallowed | Use `capture noisily` |
| `#delimit ;` | State pollution, copy-paste bugs | Use `///` continuation |
| Global macros for temp values | Namespace pollution across files | Use `local` |
| `sort` without `stable` | Non-deterministic order for ties | Use `, stable` or `set sortseed` |

## 10. Code Quality Checklist

```
[ ] version 19 at top
[ ] set seed + set sortseed at top
[ ] log using at top, log close at bottom
[ ] All paths relative via root global
[ ] Locals preferred over globals
[ ] /// continuation, no #delimit
[ ] eststo/esttab with .tex + .csv export
[ ] Figures exported as .pdf + .png
[ ] assert/isid for data validation
[ ] Comments explain WHY not WHAT
```
