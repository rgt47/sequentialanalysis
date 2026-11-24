# Deferred-item pass: 20-sequential-analysis
*2026-11-23 12:52 PST*

Scope. This pass covers the Deferred section of
`docs/pub_review_remediation_2026-08-20.md`, which answers
`docs/pub_review_whitepaper_2026-08-16.md`. It is the only file in
the workspace that matches `pub_review_remediation_*.md`. A later,
uncommitted referee cycle also exists:
`analysis/report/referee-report-2026-11-18.md` and
`analysis/report/referee-remediation-log-2026-11-19.md`. Its
deferrals are not counted in the inventory. They are listed
separately as carry-over items because several of them decide what
is still open.

State checked against. Commits since 2026-08-20 are `eef69fe` (CI
sync), `790c80e` and `8c8f07d` (auto-backups of `report.Rmd`),
`e53176d` (LaTeX artifacts ignored), and `5444109` (auto-backup).
The November work is uncommitted: 18 modified files plus five
untracked files (`exact_results.rds`, the referee report, the
referee remediation log, the voice revision log, and
`share/report-2026-11-19-1441-5444109-wip.pdf`). A SHA-256 baseline of
every modified or untracked file was taken before this pass, so the
file list below contains only this pass's changes. No git operation
was performed.

## 1. Inventory

| # | Source log | Item | Class |
|---|---|---|---|
| 1 | 2026-08-20 | M7: restructure around the high-frequency thesis; promote the appendix | AUTHOR-DECISION |
| 2 | 2026-08-20 | M5: mSPRT or confidence-sequence comparator in the simulation | AUTHOR-DECISION |
| 3 | 2026-08-20 | M2: futility (beta-spending) boundary in code | AUTHOR-DECISION |
| 4a | whitepaper item 13 (omitted from the August Deferred list) | m10: tinytest coverage of boundary values | DO-NOW (done) |
| 4b | 2026-08-20 | m10 / item 13: extract `sim_study.R` into `R/` with roxygen2 | AUTHOR-DECISION |
| 5 | 2026-08-20 | 'Full-scale rerun verification beyond what was done' | NO-LONGER-APPLIES |

Notes on classification.

- Item 4 is split. The August bullet named only the extraction into
  `R/`. Whitepaper item 13 also asks for tinytest coverage of
  boundary values. The August tests checked boundary shape
  (monotone, final look near 1.96) but never compared boundary
  values with an independent source, so that part was still open.
- Item 5 was a note, not an action: the August log recorded that no
  reduced-replicate fallback was needed. It is also superseded. The
  November cycle reran the full driver, and this pass reproduced the
  stored outputs exactly (section 2).
- Item 1 was checked against the current outline (`grep '^#'`). The
  abstract was rewritten in November around the K-grid result and
  the 20-look recommendation. The title is still 'Fully Sequential
  Analysis Revisited', the Introduction still has nine historical
  subsections, and the K-grid, bias, and recommendations material
  is still in the Appendix. The restructure has therefore not been
  done.
- Items 2 and 3 were checked by grep. `report.Rmd` still states that
  no futility boundary and no mSPRT or confidence-sequence
  comparator is implemented (Discussion, Limitations, Future
  research items 8 and 9). `compute_boundaries()` still calls
  `gsDesign(test.type = 2)`.

### Carry-over from the 2026-11-19 referee remediation log

| Item | Status found today |
|---|---|
| Render needed | Done after that log: `report.pdf` and `report.tex` dated 2026-11-19 14:41-14:42, later than `report.Rmd` (00:59); `share/report-2026-11-19-1441-5444109-wip.pdf` staged; `report.log` has no undefined references or citations, only four float-placement warnings. No commit records it. Only `report.log` and two figures were inspected in this pass; the new tables in the PDF were not. |
| M4 legends 'applied, unverified visually' | Verified today by inspecting the rendered figures (section 2). |
| Container rerun (gsDesign 3.9.0 per `renv.lock`) | LONG-RUN (section 3). |
| `gsDesign:::gsprob()` signature under 3.9.0 untested | Part of the container rerun (section 3). |
| Minor 13: `anderson2022gsdesign` says 3.5.0; `wassmer2023rpact` has no version | Blocked on the container rerun (section 3). |
| `zotero-sync/missing-references-for-zotero-import.bib` still has the old `kulkarni2016continuous` and `whitehead2013evolution` entries | Author (section 4). Not edited: the manuscript does not read it. |
| Barber and Jennison (2002) not added; Wang-Tsiatis end page; `jennison1989interim` pages; three content attributions from recall | Author (section 4). |

## 2. Done now

- **Item 4a: boundary-value tests against an independent oracle.
  [verified]** New file `inst/tinytest/test_boundaries.R`
  (18 assertions). The oracle does not use gsDesign. It integrates
  the joint normal distribution of the sequential z-statistics with
  `mvtnorm::pmvnorm()`, using correlation
  sqrt(min(t_i, t_j) / max(t_i, t_j)). It checks:

  - two-sided type I error of 0.05 and upper-tail crossing
    probability of 0.025, to within 1e-4, for K = 2, 3, 5, 10 at
    n_max = 85 and 200 (16 assertions; this covers the realized,
    unequally spaced look fractions introduced in November);
  - cumulative alpha spent at each of the five looks of the K = 5,
    n_max = 200 design against the Lan-DeMets O'Brien-Fleming
    function 2[2 - 2 Phi(z_0.0125 / sqrt(t))], the form the
    manuscript now displays;
  - `exact_oc()` power at K = 5, n_max = 85, delta = 0.5 against the
    same oracle (0.8966262 versus 0.8966265 in a prototype run).

  Evidence: prototype in the scratchpad gave type I error between
  0.0499963 and 0.0500156 for every case. The suite
  `Rscript -e 'pkgload::load_all("."); tinytest::run_test_dir("inst/tinytest")'`
  run from the repo root gave 'All ok, 45 results' (27 existing plus
  18 new) on host R 4.6.2 with gsDesign 3.11.0 and mvtnorm 1.4.2.
  The file is skipped with `exit_file()` if mvtnorm is absent.
  mvtnorm is not in `DESCRIPTION` Suggests or in `renv.lock`; it
  was left out of `DESCRIPTION` so as not to desynchronize the
  lockfile (see section 5). The file follows the repo's existing
  `test_*.R` naming rather than `test-*.R`.

- **Verification of the stored results (no file changed).
  [verified]** The current `sim_study.R` (modified 2026-11-19 00:59)
  postdates the stored `.rds` files (00:47), so it was not certain
  that the stored outputs came from the final code. The driver was
  copied with `DESCRIPTION` and `sim_study.R` to a scratch tree and
  run there (62 s wall clock, single process). All six result files
  (`sim_results`, `sim_results_null`, `sim_results_90pow`,
  `hf_results`, `hf_results_90pow`, `exact_results`) are
  `identical()` to the stored ones. The repo's `.rds` files were not
  touched, so `sim_metadata.rds` still records R 4.6.0 and the
  rendered PDF stays consistent with it. Run time was 62 s today,
  versus 133 s reported in the November log.

- **Carry-over M4: legend order. [verified]** Inspected
  `report_files/figure-latex/asn-plot-1.pdf` and
  `stopping-ecdf-1.pdf` from the 2026-11-19 render. In `asn-plot`
  the curve labeled Fixed is flat at 200, GS (K=3) is highest among
  the sequential designs and Fully Sequential is lowest. In
  `stopping-ecdf` the GS (K=3) curve steps at 0.335 and 0.665 (67
  and 133 of 200 pairs) and GS (K=5) at 0.4, 0.6, 0.8, as
  `look_schedule()` predicts. The labels match the curves.

## 3. Long runs

- **Container rerun of the simulations** (carry-over from the
  2026-11-19 log; not an item of the August inventory). No image
  for this project exists (`docker images` lists none), so the
  image must be built from `renv.lock` first. Before building, add
  mvtnorm to `DESCRIPTION` Suggests and snapshot it into
  `renv.lock`; otherwise `make docker-test` skips all 18 assertions
  of `test_boundaries.R` in the gsDesign 3.9.0 run, which is where
  an independent boundary check matters most. Commands, from the
  repo root (target names read from the Makefile; not run, and the
  `DOCKER_RUN` and `docker-test` recipes were not inspected):

  ```
  make docker-build
  make docker-script SCRIPT=analysis/scripts/run_all_simulations.R
  make docker-test
  make docker-render REPORT=analysis/report/report.Rmd
  ```

  The R work is about 1 minute natively (62 s measured today). On
  this ARM machine the amd64 image runs under emulation, which
  typically multiplies R run time several-fold. The image build
  dominates and could not be estimated without starting it. This
  run also tests the untested dependency on the internal
  `gsDesign:::gsprob(theta, I, a, b, r, overrun)` under gsDesign
  3.9.0. Afterwards: delete the three-sentence TODO in 'Data and
  code availability' (`report.Rmd`, around line 1136); compare the
  new `.rds` files with the current ones (`identical()` expected if
  gsDesign 3.9.0 gives the same boundaries); set the
  `anderson2022gsdesign` version and year in `references.bib` to
  the version recorded in `sim_metadata.rds`, and add a version to
  `wassmer2023rpact` (Minor 13).

## 4. Author decisions

- **M7: framing and structure.** Options from the whitepaper
  (section 5): (a) keep the reassessment framing; (b) a design
  practice paper on choosing K, with the K-grid, exact, pipeline,
  and bias results in the main body and the history compressed to
  about two pages; (c) a tutorial or review. Evidence: the November
  abstract and recommendations already follow (b), and the
  manuscript itself now says the diminishing-returns shape is
  partly known and places the contribution in exact values and the
  pipeline calculation. The title, the nine-subsection history, and
  the appendix placement still follow (a). Recommendation: adopt
  (b) and retitle; this is a structural edit of about 1,700 lines
  and needs the author's voice.
- **M2: futility boundary in code.** Options: keep the
  efficacy-only scope (already disclosed in Discussion, Limitations,
  Future research item 9), or add a beta-spending boundary.
  Evidence (inspected code plus inference; nothing was run):
  `exact_oc()` already accepts separate lower and upper boundary
  vectors through `gsprob(a, b)`, which helps. It is not a drop-in
  change, however. gsDesign's `test.type = 4` gives a one-sided
  efficacy bound with a non-binding futility bound on the same
  z-scale. The simulators' two-sided rule `abs(z_val) >= z_upper[j]`
  and `exact_oc()`'s rejection sum `probhi + problo` would both have
  to change to one-sided efficacy with a futility stop. The type I
  error convention (two-sided 0.05) would also have to be
  restated. ASN under H0 would fall below 200 and the headline
  comparisons would change. The August estimate of half a day to a
  day of work is plausible.
  Recommendation: add it if the target is a practice journal under
  framing (b), since practitioners rarely run efficacy-only designs.
- **M5: anytime-valid comparator.** Options: keep it as scoped-out
  related work (current text), or add an mSPRT with a normal
  mixture tuned to the same alpha. Evidence (from recall; not
  implemented or run): the mSPRT boundary for
  a normal mean with known variance has a closed form, so a
  simulation arm is modest; matching power requires choosing the
  mixture variance, which is a design choice. Recommendation: add
  one mSPRT arm at n_max = 85 if framing (b) is adopted; otherwise
  leave as is.
- **m10: move `sim_study.R` into `R/`.** Options: keep the script
  layout (tests source it via `rprojroot`, documented in the test
  header) or move it into `R/` with roxygen2 and exports. Evidence
  (inferred from the code; not attempted): moving it requires adding gsDesign, dplyr, tidyr, purrr, and
  tibble to `Imports` and places a call to the unexported
  `gsDesign:::gsprob()` in package code, which `R CMD check` flags.
  Recommendation: keep the script layout; the package is a
  compendium wrapper, not a release.
- **Bibliography items left by the November log.** Barber and
  Jennison (2002) coauthor, the Wang-Tsiatis (1987) end page, the
  `jennison1989interim` page range (305-334 for the paper versus
  305-361 with discussion), the three content attributions made
  from recall, and the stale entries in
  `zotero-sync/missing-references-for-zotero-import.bib`. These
  need the author's Zotero library or the papers themselves.
  Recommendation: when syncing Zotero, copy the corrected
  `silva2015continuous`, `armitage2014evolution`,
  `betensky1998continuous`, and `xiong1996continuous` entries from
  `references.bib` into the zotero-sync file.

## 5. New issues found

- `sim_study.R` was edited after the `.rds` files were written on
  2026-11-19. The scratch rerun shows this did not change any
  result, but nothing in the repo records it.
- This pass introduced an undeclared dependency:
  `test_boundaries.R` uses mvtnorm, which is neither in
  `DESCRIPTION` Suggests nor in `renv.lock`. In the container the
  file will be skipped, not failed, until mvtnorm is added
  (section 3).
- In the rendered `stopping-ecdf` figure the GS (K=3) 'dashed' and
  Fully Sequential 'longdash' line types are hard to tell apart in
  grayscale where the curves overlap. Cosmetic; not changed, since
  editing `report.Rmd` would require another render and share
  snapshot.
- The working tree holds all November work uncommitted, including
  regenerated `.rds` files that cannot be recovered from git. This
  pass reproduced them exactly, but a commit would protect them.
