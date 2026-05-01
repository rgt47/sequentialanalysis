# Morris et al. (2019) ADEMP Audit: 20-sequential-analysis
*2026-04-17 09:02 PDT*

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
| Paired comparisons | Met | same data fed to all designs per rep |
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
