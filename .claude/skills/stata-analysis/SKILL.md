---
name: stata-analysis
description: End-to-end Stata data analysis workflow from exploration through regression to publication-ready tables and figures
disable-model-invocation: true
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Stata Analysis Workflow

Run an end-to-end data analysis in Stata: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` -- a dataset path (e.g., `data/county_panel.dta`) or a description of the analysis goal (e.g., "regress wages on education with state fixed effects using CPS data").

---

## Constraints

- **Follow Stata code conventions** in `.claude/rules/stata-code-conventions.md`
- **Save all .do files** to `scripts/Stata/` with descriptive names
- **Save all outputs** (figures, tables, logs) to `output/`
- **Use `esttab`** for all regression tables, exporting `.tex` + `.csv`
- **Run stata-reviewer** on the generated script before presenting results

---

## Workflow Phases

### Phase 0: Environment Check

1. Verify Stata is available: `which stata` or check PATH
2. Read `.claude/rules/stata-code-conventions.md` for project standards
3. Create output directories: `output/tables/`, `output/figures/`, `output/logs/`

### Phase 1: Setup and Data Loading

1. Create .do file with proper header (title, author, purpose, inputs, outputs, Stata version, date)
2. `version 19` at top
3. `set seed 42` and `set sortseed 42`
4. Set `root` global to project directory
5. `log using "output/logs/filename.log", text replace`
6. Load and `describe` the dataset

### Phase 2: Exploratory Data Analysis

Generate diagnostic outputs:
- **Summary statistics:** `sum`, `tab`, missingness with `misstable sum`
- **Distributions:** `histogram` for key continuous variables
- **Relationships:** `scatter`, `corr` or `pwcorr`
- **Panel structure:** If panel, `xtset` then `xtdes`, `xtsum`
- **Time series:** If TS, `tsset` then `tsline`
- **Group comparisons:** If treatment/control, `ttest` or `tab, sum`

Save diagnostic figures to `output/diagnostics/`.

### Phase 3: Main Analysis

Based on the research question:
- **Regression analysis:** `reghdfe` for fixed effects, `reg` for OLS, `ivregress` for IV
- **Standard errors:** Cluster at the appropriate level (document why). Always specify explicitly.
- **Multiple specifications:** Start simple, progressively add controls and fixed effects
- **Store estimates:** `eststo` for each specification

### Phase 4: Publication-Ready Output

**Tables:**
```stata
eststo clear
eststo: reg y x1, robust
eststo: reg y x1 x2, cluster(state)
eststo: reghdfe y x1 x2, absorb(state year) cluster(state)

esttab using "output/tables/main_results.tex", ///
    replace booktabs label ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared")) ///
    title("Main Results") nomtitle

esttab using "output/tables/main_results.csv", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2)
```

**Figures:**
- Apply consistent scheme: `set scheme plotplainblind` (or project scheme)
- `graph export "output/figures/name.pdf", replace`
- `graph export "output/figures/name.png", replace width(1200)`
- Proper axis labels with units, readable at projection size

### Phase 5: Save and Review

1. `log close`
2. Save processed datasets: `save "output/data/processed.dta", replace`
3. Run the stata-reviewer agent on the generated script:

```
Delegate to the stata-reviewer agent:
"Review the script at scripts/Stata/[script_name].do"
```

4. Address any CRITICAL or MAJOR issues from the review.

---

## Do-File Template

```stata
* ============================================================
* [Descriptive Title]
* Author: [from project context]
* Purpose: [What this script does]
* Inputs: [Data files]
* Outputs: [Tables, figures, logs]
* Stata version: 19/SE
* Date: [YYYY-MM-DD]
* ============================================================

* --- 0. Setup ---
version 19
clear all
set more off
set seed 42
set sortseed 42

global root "."
cap mkdir "${root}/output/tables"
cap mkdir "${root}/output/figures"
cap mkdir "${root}/output/logs"
cap mkdir "${root}/output/data"
cap mkdir "${root}/output/diagnostics"

log using "${root}/output/logs/analysis_name.log", text replace

* --- 1. Data Loading ---
use "${root}/data/dataset.dta", clear
describe
isid id_var

* --- 2. Exploratory Analysis ---
sum
misstable sum
histogram main_var, name(dist, replace)
graph export "${root}/output/diagnostics/dist.png", replace width(1200)

* --- 3. Main Analysis ---
eststo clear
eststo: reg y x1, robust
eststo: reg y x1 x2, cluster(state)
eststo: reghdfe y x1 x2, absorb(state year) cluster(state)

* --- 4. Tables and Figures ---
esttab using "${root}/output/tables/main_results.tex", ///
    replace booktabs label ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared")) ///
    title("Main Results") nomtitle

esttab using "${root}/output/tables/main_results.csv", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2)

* --- 5. Export and Cleanup ---
save "${root}/output/data/processed.dta", replace
log close
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Print summary statistics before jumping to regression.
- **Check for issues.** Look for multicollinearity, outliers, influential observations.
- **Use relative paths.** All paths via `${root}/...`
- **No hardcoded values.** Use locals for sample restrictions, date ranges, etc.
- **Install packages if needed.** Run `ssc install estout, replace` and similar at top of setup.
