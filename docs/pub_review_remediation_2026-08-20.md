# Remediation Log: 20-sequential-analysis

*2026-08-20*

Addresses `docs/pub_review_whitepaper_2026-08-16.md`. This log
covers remediation completed across two work sessions: the bulk of
the editing (report.Rmd, sim_study.R driver, references.bib,
test suite, Morris audit correction) was done in a prior session
that was interrupted after a successful render but before this log
was written; this session verified that prior work, reran the
simulation driver and the full render from a clean state, ran the
test suite, and confirms the state below reflects what is actually
on disk and reproducible right now.

## 1. Fixed

Required for correctness (whitepaper section 4, items 1-6):

- **M1** (grid never covers 80-90% power regime). Added a
  power-calibrated sensitivity scenario at `N_max = 85` per arm
  (fixed design at approximately 90% power for delta = 0.5), with
  its own power/ASN table and an HF K-grid rerun at the same
  `N_max`. File: `analysis/report/report.Rmd` ("Power-Calibrated
  Sensitivity Scenario" section, `hf-table-90pow` chunk). The
  original `N_max = 200` grid is retained and explicitly labeled
  overpowered rather than removed. `[verified]` - script rerun
  today reproduces `sim_results_90pow.rds` / `hf_results_90pow.rds`
  and the render completed using them.
- **M2** (no futility boundary; framing implies one). Did not add a
  beta-spending boundary to the simulation code (`compute_boundaries`
  in `analysis/scripts/sim_study.R` still uses `gsDesign(test.type =
  2)`, efficacy-only). Instead narrowed the manuscript's claims: the
  Discussion now states explicitly that all reported ASN savings are
  efficacy-only-stopping savings, that mean N under H0 is 197.7-200
  for every design, and that futility stopping is deferred to Future
  Research (added as item 9). File: `analysis/report/report.Rmd`
  (Discussion, Future Research). `[applied, unverified]` for the
  prose claims about mean N under H0 (values read from the
  already-verified type I error table, not independently
  recomputed this session).
- **M3** (MCSE claimed but absent from tables). Added `mcse_*`
  columns to the type I error, power, HF, and power-90 tables, and
  updated the "Monte Carlo SEs are reported alongside every
  performance measure" sentence to match. File:
  `analysis/report/report.Rmd` (`type1-table`, `power-table`,
  `hf-table`, `power90-table`, `hf-table-90pow` chunks).
  `[verified]` - MCSE columns render in `report.pdf` (23-page render
  confirmed this session).
- **M4** (type I error "within tolerance" claim not supported;
  fully sequential design 2.2 MCSEs below nominal at n_rep = 2000).
  Reran the null scenario at `n_rep = 20000` (MCSE approximately
  0.0015) via `analysis/scripts/run_all_simulations.R`, and rewrote
  the type I error prose to report the new precision, show both the
  n_rep = 2000 and n_rep = 20000 results, and state the shortfall
  was Monte Carlo noise rather than systematic conservatism. File:
  `analysis/report/report.Rmd` (Type I Error Control section).
  `[verified]` - reran `Rscript analysis/scripts/run_all_simulations.R`
  this session; `sim_results_null.rds` regenerated with
  `n_reps = 20000` and the rendered table reflects it.
- **M6** (reproducibility fragile under knitr cache; `sim_20.rds`
  orphaned). Removed `cache = TRUE` from `sim-run` and `hf-sim`
  chunks; created a standalone driver script
  `analysis/scripts/run_all_simulations.R` that sets the seed once
  (`set.seed(20260309)`, `RNGkind("L'Ecuyer-CMRG")`), runs every
  scenario, and writes versioned `.rds` files that the Rmd reads
  with plain `readRDS()`. Added a "Reproducibility" subsection
  documenting the exact command. Deleted the orphaned
  `analysis/data/derived_data/sim_20.rds` (no script referenced it).
  Files: `analysis/report/report.Rmd`,
  `analysis/scripts/run_all_simulations.R` (new),
  `analysis/data/derived_data/sim_20.rds` (deleted). `[verified]`
  - ran the script this session; it completed in under 30 seconds
    and wrote all six `.rds` outputs with a fresh timestamp.
- **m5** (Morris audit's "Paired comparisons: Met" is false).
  Corrected `docs/morris-audit-2026-04-17.md`'s table row to "Not
  met" with an explanation, added a dated correction note at the
  top of the file, and disclosed the independent-draws design
  choice in `report.Rmd`'s Limitations section rather than
  implementing common random numbers (a larger code change judged
  out of scope for a disclosure-tier fix). Files:
  `docs/morris-audit-2026-04-17.md`, `analysis/report/report.Rmd`.
  `[verified]` - confirmed by inspection that
  `run_simulation()`/`simulate_one_trial()` in `sim_study.R` draw
  independent `rnorm()` per design-by-effect-size cell.

Required for acceptance (items 7, 9, 10, 11 of 7-11):

- **M5** (anytime-valid inference literature absent). Added a
  "Position Relative to Anytime-Valid Inference" section citing
  Johari et al. 2017, Robbins 1970, Howard et al. 2021, Ramdas et
  al. 2023, Kulldorff et al. 2011, Proschan/Lan/Wittes 2006, and
  Jennison and Turnbull 1989 (repeated confidence intervals). Added
  all seven bib entries. Did not implement an mSPRT or
  confidence-sequence comparator in the simulation; the section
  explicitly states this and lists a head-to-head comparison as
  Future Research item 8. Files: `analysis/report/report.Rmd`,
  `analysis/report/references.bib`. `[verified]` - citations resolve
  and render without "??" in `report.pdf` (checked the rendered
  bibliography section and in-text citation marks).
- **m4** (Morris self-audit contradicts current code, sits under
  References heading). Removed the "Morris et al. (2019) ADEMP
  Compliance" section from `report.Rmd` entirely (it no longer
  appears in the manuscript body); the underlying audit document is
  corrected separately (see m5 above) and marked as superseded by
  this remediation log rather than summarized in the manuscript.
  File: `analysis/report/report.Rmd`. `[verified]` - section absent
  from rendered `report.pdf` table of contents.
- **m8, m6** (power cost at delta = 0.2 undiscussed; "fully
  sequential" is actually per-pair monitoring). Added a paragraph
  in Results quantifying the delta = 0.2 power loss (fixed 0.501 vs.
  fully sequential design, values now read live from
  `sim_results`), and a paragraph in Discussion stating explicitly
  that every look is evaluated after a treated-control pair (K = 200
  is 200 pairs / 400 subjects), not after each individual response.
  File: `analysis/report/report.Rmd`. `[verified]` - both paragraphs
  use inline `r` expressions against `sim_results`, confirmed
  present in rendered PDF.
- **m9** (no data/code availability, sessionInfo, package versions).
  Added a "Data and Code Availability" section reporting R version,
  package versions (gsDesign, dplyr, ggplot2, knitr), and the seed,
  all read live from `sim_metadata.rds` (written by
  `run_all_simulations.R`) rather than hardcoded. File:
  `analysis/report/report.Rmd`. `[verified]` - `sim_metadata.rds`
  regenerated this session with current R 4.6.1 and package
  versions; section renders with those live values.

Also addressed:

- **Numbers-in-prose desync** (implicit in the task instructions).
  Replaced every simulation chunk's cache-loaded objects with
  `readRDS()` reads from `analysis/data/derived_data/*.rds`, so
  prose numbers (delta = 0.2 power loss, K = 20 percent saved,
  type I error rates) are computed via inline `r` expressions
  against the same data the tables use, not hand-typed. `[verified]`
  by rerunning the driver script and the render together this
  session.
- **Placeholder test suite** (m10, partial). Replaced
  `inst/tinytest/test_basic.R` (previously `expect_true(TRUE)`)
  with 19 real assertions covering `compute_boundaries()` (O'Brien-
  Fleming monotonicity, k=1 reduces to the fixed-sample critical
  value), `simulate_one_trial()` (rejection logic, forced-boundary
  sanity check), `run_hf_simulation()`, and `run_simulation()`
  (dimensions, no-NA guarantees, fully sequential design not
  slower than fixed at a large effect). Did not extract
  `sim_study.R`'s functions into `R/` with roxygen2 docs (m10's
  second half; see Deferred). `[verified]` - ran
  `Rscript -e 'pkgload::load_all("."); tinytest::run_test_dir("inst/tinytest")'`
  this session: all ok, 19 results, 0.8s.
- **British spelling** (m11). Changed `colour =` to `color =` in
  the `hf-bias-plot` chunk. File: `analysis/report/report.Rmd`.
  `[verified]` by grep; no remaining `colour` in the Rmd.
- **Stopping-time density is misleading for discrete distributions**
  (m7). Replaced the `stopping-density` kernel-density chunk with a
  `stopping-ecdf` empirical-CDF chunk (`stat_ecdf`), with prose
  explaining why a density is dishonest for point-mass stopping
  times. File: `analysis/report/report.Rmd`. `[verified]` - old
  `stopping-density-1.pdf` deleted, new `stopping-ecdf-1.pdf`
  present and rendered into `report.pdf`.
- **90-percent caption arithmetic** (m2, minor-issues numbering,
  distinct from major M2 above). Figure caption for `hf-asn-plot`
  now states both the relative-to-fixed (96%) and relative-to-K=3
  (87%) definitions with the arithmetic shown. File:
  `analysis/report/report.Rmd`. `[verified]` by inspection of the
  rendered caption.
- **Bias monotonicity overclaim** (m1). Softened "grows
  monotonically with K" to "tends to increase with K, within Monte
  Carlo noise," with the K=50 vs. K=200 reversal and MCSE magnitude
  stated explicitly. File: `analysis/report/report.Rmd`. `[verified]`
  by inspection.
- **ADEMP Methods bullet inconsistent with what was run** (m3).
  Methods bullet now states the main grid runs K = 3, 5, fully
  sequential only, and that the finer K = 3, 5, 10, 20, 50, n_max
  grid is run only at delta = 0.5 in both the overpowered and
  power-calibrated scenarios. File: `analysis/report/report.Rmd`.
  `[verified]` by inspection, matches `run_all_simulations.R`.

## 2. Deferred

- **M7 / item 8 (restructure the paper around the high-frequency
  monitoring thesis; promote the appendix to the main body)**. Not
  done. This is a substantial structural rewrite (moving the
  K-grid analysis and recommendations out of the appendix, cutting
  the historical review, retitling) that the whitepaper itself
  frames as a judgment call about target journal and authorial
  voice (Recommended Framing, section 5), not a mechanical fix. A
  single signposting paragraph was added to the Introduction
  directing readers to the Appendix as the paper's actual empirical
  contribution, but the document's section order is unchanged
  (Introduction subsections 1.1-1.9, then Methods/Results, then
  Appendix). Requires an authorial decision on framing (a), (b), or
  (c) per the whitepaper's section 5; recommend the author choose
  framing (b) as the whitepaper recommends, then a follow-up
  editing pass to physically move the K-grid/architecture content
  into the main body.
- **M5 comparator (mSPRT or confidence-sequence head-to-head
  simulation)**. Not implemented; only cited and scoped out
  explicitly (see Fixed, M5). Implementing a comparably-tuned
  confidence-sequence procedure and matching it on type I error/
  power is a nontrivial simulation addition, not a "modest,
  well-specified addition" per the remediation instructions'
  threshold, and was correctly narrowed instead per the
  instructions' guidance. Logged as Future Research item 8 in the
  manuscript. No further action needed unless the author wants the
  comparator implemented for a stronger acceptance case.
- **M2 futility boundary (code-level implementation)**. Not
  implemented in `sim_study.R`; addressed instead by scope
  narrowing (see Fixed, M2), which is one of the two remediation
  paths the whitepaper explicitly allows. If the author later wants
  the futility-boundary version, `compute_boundaries()` would need
  `gsDesign(test.type = 4, ...)` (or 3) with a beta-spending
  function argument, plus new ASN-under-H0 and ASN-under-small-delta
  reporting; estimated a half-day to a day of work, not attempted
  here.
- **m10, second half (extract `sim_study.R` functions into `R/`
  with roxygen2 documentation)**. Not done; only the test suite
  (first half of m10) was addressed. This is explicitly the lowest
  priority ("desirable polish," item 13) and time-boxed out per the
  remediation instructions' budget guidance. `sim_study.R` remains
  outside `R/` (excluded via `.Rbuildignore` per the research-
  compendium layout); the new tinytest file documents this
  arrangement in its header comment.
- **Full-scale rerun verification beyond what was done**. The
  driver script was rerun in full this session (not a reduced
  version) and completed in well under a minute; no further rerun
  is needed. Noted here only to be explicit that the "reduced-
  replicate" fallback in the remediation instructions was not
  needed for this workspace.

## 3. New issues found while fixing

- `analysis/report/report.tex`, `.aux`, `.toc`, and the figure PDFs
  under `report_files/figure-latex/` are committed as generated
  artifacts alongside the Rmd source; this is consistent with the
  workspace's existing convention (they were already tracked before
  this remediation) but means every remediation edit to the Rmd
  requires a matching re-render and re-commit of these derived
  files to keep them in sync, which is easy to forget. Not a defect
  introduced by this remediation; flagging because the prior
  interrupted session left `report.pdf`/`.tex`/`.aux`/`.toc` in a
  modified-but-uncommitted state that could have gone stale if this
  session had not rerun the render.
- `analysis/report/tmp-pdfcrop-31480.tex` and `analysis/report/
  Rplots.pdf` are transient render byproducts left untracked in the
  working tree by `tools/render.sh` (pdfcrop temp file and a
  default graphics-device dump). They are harmless but not
  gitignored; the author may want to add them to `.gitignore` to
  keep `git status` clean after routine renders.
- `analysis/report/share/` now holds two near-duplicate
  "-wip.pdf" snapshots from consecutive renders in this session
  (`1323` and `1324` timestamps), both tagged `3fc5c0b-wip` since no
  new commit was made between them. This is expected behavior of
  the render wrapper's share-staging convention, not a bug, but the
  author should commit the current state before the next render to
  avoid share/ accumulating same-commit "-wip" duplicates.
