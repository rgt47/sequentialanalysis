# Morris et al. (2019) ADEMP Audit: 20-sequential-analysis
*2026-04-17 09:02 PDT*

**2026-08-20 update:** This audit is superseded by
`docs/pub_review_remediation_2026-08-20.md`. It is retained here as
a historical record (referenced by earlier commits) but is no
longer summarized in the manuscript body. Two corrections to the
table below, found during 2026-08-20 remediation:

1. "Paired comparisons: Met" is false. `run_simulation()` in
   `analysis/scripts/sim_study.R` calls `simulate_one_trial()`
   independently, with fresh `rnorm()` draws, for every
   design-by-effect-size cell; no common random numbers are shared
   across designs. The correct status is **Not met**. This is now
   disclosed in `analysis/report/report.Rmd`'s Limitations section.
2. The gaps listed below (no MCSE columns, seed set twice) describe
   the pre-2026-08-20 state of the code and are now resolved: MCSE
   columns are computed in `sim_study.R` and displayed in every
   manuscript table, and the seed is set exactly once, in
   `analysis/scripts/run_all_simulations.R`.

## Scope

Files audited:

- `analysis/scripts/sim_study.R`
- `analysis/report/report.Rmd`

## ADEMP scorecard

| Criterion | Status | Evidence |
|---|---|---|
| Aims explicit | Partial | group-sequential design evaluation described in prose |
| DGMs documented | Met | DGM parameterised for stage counts and boundaries |
| Factors varied factorially | Partial | scenario grid implicit |
| Estimand defined with true value | Met | treatment effect parameterised |
| Methods justified | Met | fixed vs GSD vs HF compared |
| Performance measures justified | Partial | rejection rate, mean N, bias listed |
| n_sim stated | Met | `n_rep = 2000` |
| n_sim justified via MCSE | Not met | no derivation |
| MCSE reported per metric | Not met | `sim_study.R:94-108` returns no MCSE cols |
| Seed set once | Partial | `set.seed(20260309)` appears twice (`report.Rmd:411` main, `:706` HF appendix); cache effectively preserves reproducibility, but formally violates seed-once |
| RNG states stored | Not met | not stored |
| Paired comparisons | Not met (corrected 2026-08-20; originally logged as "Met") | `simulate_one_trial()` draws independent `rnorm()` data per design-by-effect-size cell; no common random numbers |
| Reproducibility | Partial | `cache=TRUE` on chunks; RNGkind not pinned |

## Overall verdict

**Partially compliant.**

## Gaps

- No Monte Carlo SE on rejection rate, mean N, or bias
  (`sim_study.R:94-108`).
- `set.seed(20260309)` is called twice in the Rmd, once in the main
  chunk and again in the HF appendix. Morris §4.1: one seed per
  program run.
- `n_rep = 2000` not justified by MCSE derivation.
- Bias for sequential MLE is mentioned in narrative but not compared to
  a true-value-driven Monte Carlo SE.
- `RNGkind()` not pinned.

## Remediation plan

1. Add MCSE columns in `sim_study.R:94-108`: rejection rate
   `sqrt(p*(1-p)/n_rep)`; mean N `sd(stop_n)/sqrt(n_rep)`; bias
   `sd(est)/sqrt(n_rep)`.
2. Consolidate seed management: define a single seed at the top of
   `analysis/scripts/sim_study.R` and pass it into downstream chunks
   via a config helper; remove the second `set.seed()` at
   `report.Rmd:706`.
3. Add an n_rep justification derivation from a target MCSE.
4. Pin `RNGkind("L'Ecuyer-CMRG")`.
5. Store `.Random.seed` per rep.
6. Add ADEMP Methods section to `report.Rmd`.
7. Consider adding coverage as an additional performance measure if CIs
   are meaningful under the GSD (may require a bias-eliminated coverage
   variant per Morris §5.2).

## References

Morris TP, White IR, Crowther MJ. Using simulation studies to evaluate
statistical methods. Stat Med 2019;38:2074-2102. doi:10.1002/sim.8086

---
*Source: ~/prj/res/20-sequential-analysis/sequentialanalysis/docs/morris-audit-2026-04-17.md*
