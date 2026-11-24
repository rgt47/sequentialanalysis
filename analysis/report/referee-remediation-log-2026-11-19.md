# Referee remediation log: report.Rmd
*2026-11-19 00:53 PST*

Addresses `referee-report-2026-11-18.md` (same directory). Builds on
the voice revision of 2026-11-18 and on
`docs/pub_review_remediation_2026-08-20.md`. Nothing was staged,
committed, pushed, or rendered. The PDF, `report.tex`, and the
figures under `report_files/` are therefore stale.

Environment note. gsDesign is not installed in the host R library.
It was installed (version 3.11.0) into the private scratch library
`/private/tmp/claude-501/rem-20/lib` and put on the path with
`R_LIBS`; no repo file refers to that library. `renv.lock` pins
gsDesign 3.9.0, and the August outputs recorded 3.10.1. Before any
code change, the unmodified driver's main grid was rerun on the host
and reproduced the stored `sim_results.rds` exactly
(`all.equal` TRUE for rejection rates and mean N).

## Fixed

- **M1 (spending function display) [verified].** Computed in R:
  gsDesign's cumulative upper spending times 2 equals
  2[2 - 2 Phi(z_0.0125 / sqrt(t))], not 2 - 2 Phi(z_0.025 / sqrt(t)).
  Methods 'Alpha spending function' now displays the per-tail
  function actually used, names the gsDesign call, and gives both
  curves at t = 0.5 (0.0031 versus 0.0056) by inline R. Code
  unchanged.
- **M7 (look/boundary misalignment) [verified].** New
  `look_schedule()` in `analysis/scripts/sim_study.R`;
  `compute_boundaries()` now computes boundaries at the realized
  fractions `round(j N / K) / N`. The simulators recover the same
  integer looks, so they were not changed; `stop_fraction` is now the
  realized fraction. Three new tinytests check the alignment. Full
  driver rerun (133 s). As expected, only cells whose look schedule
  changed moved (K = 3 at N = 200; K = 3, 10, 20, 50 at N = 85).
  For all other cells, rejection rates, mean N, and naive bias are
  `identical()` to the August values; stored stop fractions agree
  to 1e-12 (`all.equal`), differing only in floating-point
  representation.
- **M3 (power cost within Monte Carlo noise) [verified].** New
  `exact_oc()` in `sim_study.R`: recursive numerical integration via
  `gsDesign:::gsprob()` (internal; `gsProbability()` refuses k > 30),
  same boundaries and looks as the simulation, grid r = 80 (r = 18
  returns invalid probabilities at k = 200 with large drift;
  r = 40 versus 80 agree to < 1e-5 in power and < 0.001 pairs in
  ASN). Fixed-design exact power matches the closed form (test).
  The driver writes `analysis/data/derived_data/exact_results.rds`.
  Exact power at N = 85, delta = 0.5: fixed 0.903, fully sequential
  0.888 (loss 1.5 points, not the simulated 3.6). The stored
  simulated fully sequential cell at N = 85 (power 0.8675, ASN 58.5)
  is 2.8 and 4.2 MCSE from exact. A systematic z-check of every
  stored cell against exact found one other cell beyond 3 MCSE (K = 5,
  delta = 0.2, N = 200: ASN 179.0 versus exact 181.4, z = -3.2). Both
  cells were rerun once at 20,000 replicates in scratch (seed 777,
  not part of the reported results): N = 85 fully sequential gave
  0.8883 and 56.77 (about 1 MCSE from exact); K = 5, delta = 0.2 gave
  0.505 and 181.29 (within 0.4 MCSE). So the stored cells are
  outlying draws, not a code bug. The manuscript names both cells and
  treats exact values as authoritative; the scratch reruns are not
  cited there. The Results prose, the `hf-table-90pow` caption ('visibly
  declines'), the appendix 'measurable' sentence, and the delta = 0.2
  'cuts against the thesis' sentence were rewritten around the exact
  values. New Table `exact-table` (type I error, power at 0.2 and
  0.5, ASN at 0, 0.5, 0.8, inflation) for every K at N = 85.
- **M5 (type I error at K = 20 not simulated) [verified].** Exact
  type I error is 0.0499 to 0.0500 for every K in {1, 3, 5, 10, 20,
  50, N} at both N. Headline findings and Discussion now report the
  exact values and call the simulated upward trend (fully sequential
  1.9 MCSE above nominal) Monte Carlo noise. Recommendation 1 cites
  the exact K = 20 value.
- **M6 ('less than 1% inflation') [verified; claim was wrong].**
  `gsDesign(k, test.type = 2, alpha = 0.025, beta = 0.1,
  sfu = sfLDOF)$n.I[k]`: 1.012 (K = 3), 1.023 (5), 1.035 (10),
  1.044 (20), 1.050 (50), 1.051 (85), 1.053 (200). These use
  gsDesign's default grid (r = 18; `gsDesign(r = 80)` fails at
  k = 200). Re-evaluating each design's power with `gsprob(r = 80)`
  gives 0.9000 (K = 5, 20), 0.89997 (K = 85), and 0.8998 (K = 200),
  so the factors are accurate to about 0.0002 in power. Recommendation 2
  now reports 2.3, 4.4, and 5.3 percent by inline R and advises
  inflating N_max.
- **M2 (stale bias numbers, nonexistent reversal) [verified].** The
  hard-coded 0.046/0.044 sentence is replaced by inline R from
  `hf_results.rds` describing the actual pattern (dip at K = 5 within
  noise, rise from K = 10 to K = 200). The `hf-bias-plot` caption no
  longer asserts a causal monotone increase.
- **M4 (legend mislabels three curves) [applied, unverified
  visually].** `asn-plot` and `stopping-ecdf` now convert `design` to
  a factor with explicit levels and labels before plotting; the
  positional `labels =` vectors are removed. The chunk code executes
  without error; the figure was not rendered.
- **M8 (no delayed response) [verified, partial].** New appendix
  subsection 'Delayed responses' and Table `pipeline-table`: exact
  expected enrollment with a fixed pipeline of p pairs per interim
  look (gsprob `overrun`). Discussion cites Hampson and Jennison
  (2013). Recommendation 1's 'less than one month' threshold is
  removed. Futility boundary and accrual model still deferred.
- **M9 and section 6 (bibliography) [verified on Crossref].** Every
  DOI in `references.bib` was resolved.
  `kulkarni2016continuous` replaced by `silva2015continuous` (Silva
  and Kulldorff, Biometrics 2015, 10.1111/biom.12324); prose now
  states what the abstract says (a uniformly better continuous design
  always exists) and drops the maxSPRT attribution.
  `whitehead2013evolution` replaced by `armitage2014evolution`
  (Armitage, J R Soc Med 107(1):34-39, 10.1177/0141076813514681,
  found by Crossref title search); the unverified content claims
  attributed to it were removed. `betensky1998continuous` DOI
  corrected to 10.2307/2533857. Added and cited: Wang and Tsiatis
  1987, Lan and DeMets 1989, Eales and Jennison 1992, Hampson and
  Jennison 2013, Whitehead 1986, Fan, DeMets and Lan 2004. Keys
  were renamed where the author changed, so that the key does not
  misname the source.
- **M10 (abstract) [applied].** See Abstract voice pass.
- **Minor 1 [record verified on Crossref; content from recall].**
  Interpolating family now attributed to Wang and Tsiatis (1987).
  Crossref confirms 'one-parameter boundaries'; that the family
  contains the Pocock and O'Brien-Fleming shapes is from recall.
- **Minor 2 [verified on Crossref title].** Calendar-time spending
  now cites Lan and DeMets (1989).
- **Minor 4 [applied].** The three split headings are joined.
- **Minor 5 [applied].** Internal note under 'References' removed.
- **Minor 6 [applied].** Revision-history sentences removed from
  Headline findings and Reproducibility.
- **Minor 7 [applied].** Bias-adjusted estimation cited (Whitehead
  1986; Emerson and Fleming 1990; Fan et al. 2004); the uncited
  'bootstrap' item was dropped.
- **Minor 8 [applied].** Present study and Design framework now say
  one look per enrolled pair.
- **Minor 9 [verified].** Methods states that rejection is
  two-sided; exact wrong-direction probability is at most 0.0007 for
  delta >= 0.2.
- **Minor 10 [applied].** `asn-plot` caption rewritten; notes the
  K = 3 versus K = 5 non-monotonicity at delta = 0.8.
- **Minor 11, 12 [applied].** Infrastructure and marginal-cost
  claims recast as conjectures with no measurement.
- **Hard-coded numbers.** '0.998 to 1.000', '0.996-1.000',
  '197.7 to 200', and the 96/87 percent figure caption (now 96/86
  after the K = 3 rerun) are computed from the `.rds` files.
- **Section 3 novelty.** Present study and the appendix now say the
  diminishing-returns shape is at least partly known and locate the
  contribution in exact values plus the pipeline calculation.

## Deferred

- **Minor 3 (Lai et al. 1980).** Not changed. The Crossref abstract
  states the rules are 'asymptotically optimal from both Bayesian and
  frequentist points of view', so the existing claim is supported.
- **Barber and Jennison (2002).** Not added: Crossref lists only
  'S. Barber' as author, so the coauthor could not be verified.
- **Wang and Tsiatis end page.** Crossref gives first page 193 only;
  the end page 199 is from the referee's recall.
- **Content attributions to check against the papers (author).**
  The Wang-Tsiatis special cases (above); 'optimal group sequential
  tests have been studied as the number of analyses grows'
  (Eales and Jennison 1992; title only verified); 'the textbook
  literature reports expected sample sizes for several values of K'
  (Jennison and Turnbull 2000; from recall).
- **`jennison1989interim` pages.** Crossref gives 305-334; the bib
  says 305-361 (probably including the discussion). Not changed.
- **`analysis/report/zotero-sync/missing-references-for-zotero-import.bib`**
  still uses the old keys `kulkarni2016continuous` and
  `whitehead2013evolution` with the wrong metadata. The manuscript
  does not read this file; it was left for the author's Zotero sync.
- **Futility boundary, accrual model, anytime-valid comparator,
  bias-adjusted estimators in the simulation (M8 remainder, section
  7).** Larger additions; not attempted.
- **Container rerun.** Results were generated with host R 4.6.0 and
  gsDesign 3.11.0, not the lockfile's 3.9.0. A visible TODO is in
  'Data and code availability'. Command, inside the project
  container: `Rscript analysis/scripts/run_all_simulations.R`
  (about 2 to 3 minutes). Untested dependency: `exact_oc()` calls
  the internal `gsDesign:::gsprob(theta, I, a, b, r, overrun)`. Its
  signature was checked only in gsDesign 3.11.0, not in the
  lockfile's 3.9.0.
- **Minor 13.** `anderson2022gsdesign` still says version 3.5.0;
  `wassmer2023rpact` has no version. Updating needs the release year
  of the version finally used, which depends on the container rerun.
- **Render.** `bash tools/render.sh analysis/report/report.Rmd` is
  needed to refresh the PDF and to check the new tables, figure
  legends, and `\@ref` cross-references visually.

## New issues found while fixing

- `xiong1996continuous` omitted the first author. Crossref lists Tan
  and Xiong; fixed in the bib (key unchanged, since it is cited by
  that key in prose that names no author).
- The stored N = 85 fully sequential simulation cell is about 4 MCSE
  from exact on ASN (see M3). The manuscript now says so.
- gsDesign's integrator at its default grid (r = 18) returns
  probabilities above 1 and negative ASN for k = 200 with large
  drift. Anyone reusing `gsProbability()`-style calls at large K
  should raise r.

## Illustrative values chosen by this remediation

- Pipeline lengths p = 0, 5, 10, 20 pairs (exact delayed-response
  table) and the example '10 pairs = one-month lag at 10 pairs per
  month'. Labeled illustrative in the code comment, the table
  caption, and the prose.
- Seed 777 for the one-off 20,000-replicate checks of two cells,
  run in scratch only; not part of the reported results.

## Abstract voice pass

- Word count: 142 -> 140. No journal word limit is named in the YAML
  or the report. Structure: unstructured paragraph, kept.
- Factual changes:
  1. 'after each individual observation' -> 'after every response';
     the simulated design is one look per pair (minor 8).
  2. Removed the claim that the paper evaluates 'regulatory
     conditions'; no regulatory analysis is in the body (M10).
  3. Added the design compared (fixed versus O'Brien-Fleming
     spending designs with 3 to 50 looks or one per pair) and the
     setting (two arms, normal outcome, known variance) (M10).
  4. Added exact type I error of 0.05 at every K (M5).
  5. Added the exact findings at 90 percent power: about one third
     ASN reduction (33.1 percent) and 1.5 points power loss for one
     look per pair (M3).
  6. Added that 20 looks capture most of the gain and that a
     response lag reduces it (M8).
  7. Added that the results largely agree with known theory
     (section 3).
  8. Added the K = 20 recommendation, conditioned on fast responses.
  9. Removed the safety-surveillance and 'adaptive design
     methodology' framing to stay within the old length.
- The abstract numbers are typed, not inline R, because inline R in
  the YAML runs before the setup chunk loads the results. They match
  the deterministic exact values and will not change on a rerun with
  the same code.
- Longest sentence 20 words; none over 25. The spaced ' -- ' dash is
  gone. YAML parses with `yaml::yaml.load()`.

## Checks

- tinytest: 27 of 27 pass
  (`R_LIBS=<scratch lib> Rscript --vanilla -e
  'pkgload::load_all("."); tinytest::run_test_dir("inst/tinytest")'`).
- `knitr::purl()` succeeds. The purled code was also executed in
  scratch, and all 64 body inline R expressions were evaluated
  without error (structural check; the document was not rendered,
  so LaTeX, table layout, and `\@ref` links are unchecked).
- No R process from this session is left running.
- Every `@key` cited exists in `references.bib`.
- Em dashes: 0 before, 0 after. Spaced double hyphens: 1 before (the
  abstract), 0 after.
- A few prose lines holding long inline R expressions exceed 78
  characters; knitr inline code cannot be wrapped. Chunk code lines
  are all under 78.
