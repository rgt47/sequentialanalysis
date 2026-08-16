# Publication Review White Paper: 20-sequential-analysis
*Review date: 2026-08-16 10:11 PDT*

Reviewer standard: statistical journal referee (Statistics in
Medicine, Clinical Trials, Biometrics tier). Workspace:
`~/prj/res/20-sequential-analysis/sequentialanalysis`. One
manuscript reviewed: `analysis/report/report.Rmd` (rendered PDF and
`report.tex` present). Supporting code inspected:
`analysis/scripts/sim_study.R`, `docs/morris-audit-2026-04-17.md`,
`inst/tinytest/test_basic.R`, `DESCRIPTION`.

Epistemic status conventions: "verified" means I ran code and
observed the result; "inspected" means I read the source or the
rendered output; "inferred" means consistent with the surrounding
evidence but not directly checked; "unverified" means not checked.
No code was run in this review; all findings are inspected or
inferred unless noted.

## 1. Summary of the work under review

`analysis/report/report.Rmd` ("Fully Sequential Analysis Revisited:
A Contemporary Reassessment of Continuous Monitoring in Clinical
Trials") is a hybrid document: roughly half is a narrative
literature review tracing the arc from Wald's SPRT and Armitage's
sequential medical trials through the group sequential and alpha
spending frameworks; the remainder is a Monte Carlo simulation
comparing fixed, group sequential (K = 3, 5), and fully sequential
(K = N = 200 per arm) designs under Lan-DeMets O'Brien-Fleming
spending, with a two-arm normal outcome, known variance, effect
sizes 0, 0.2, 0.5, 0.8, and 2,000 replications. An appendix extends
the simulation to K in {3, 5, 10, 20, 50, 200} at delta = 0.5,
reports naive-MLE bias at stopping, and argues that high-frequency
monitoring (K = 20 to 50) is the practically productive middle
ground, closing with a proposed software architecture (boundary
engine, bias-corrected estimation, automated DSMB alerting) and
five practice recommendations. The simulation is implemented in
`analysis/scripts/sim_study.R` and executed inline in the Rmd with
knitr caching; a prior ADEMP audit (2026-04-17) is summarized in a
section appended after the References heading.

## 2. Major issues

### M1. The simulation grid never covers the practically relevant
power regime, and headline efficiency claims are inflated by
overpowering

Location: `report.Rmd` Methods (Simulation Procedure) and Results;
`report.tex` power table (inspected).

At n_max = 200 per arm, the rendered power table shows power of
0.999 to 1.000 for every design at delta = 0.5 and 0.8, and power
of roughly 0.48 to 0.52 for every design at delta = 0.2. There is
no scenario in the 80 to 90 percent power range where real trials
are designed. The appendix's centerpiece analysis (delta = 0.5,
n_max = 200) is therefore conducted at power ~1, a regime known to
maximize sequential sample size savings; the reported 38 to 55
percent savings and the shape of the diminishing-returns curve in K
are conditional on gross overpowering and will not transfer to a
trial sized for 90 percent power. A referee will treat the central
empirical conclusion ("K = 20 captures most of the benefit") as
unestablished in the relevant design regime. Remediation: size
n_max to give the fixed design 80 or 90 percent power at each
delta (or add such scenarios), rerun the K-grid analysis there,
and report savings in that regime. Retain one overpowered scenario
only as a sensitivity case if desired.

### M2. The designs have no futility boundary, so the comparison
under the null and the framing around "stopping for futility" are
disconnected from the simulation

Location: `sim_study.R` (`compute_boundaries` uses
`gsDesign(test.type = 2)`, symmetric two-sided rejection only;
inspected); `report.Rmd` Introduction and Discussion.

The Introduction motivates fully sequential monitoring partly
through Armitage's lower futility/harm boundary, and the appendix
recommends conditional-power futility alerts, but the simulated
designs stop early only on rejection. Consequently, under H0 the
mean N is 198 to 200 for every design (rendered type I table,
inspected): the simulation exhibits essentially no expected sample
size benefit under the null, and the paper never states this. For
a paper whose thesis is ASN efficiency, omitting binding futility
stopping (test.type 3 or 4 in gsDesign, or a beta spending
function) removes half of the classical argument for sequential
monitoring. Remediation: either add futility (beta spending)
boundaries to all sequential designs and report ASN under H0 and
under small deltas, or explicitly restrict the paper's claims to
efficacy-only stopping and remove futility from the motivation and
recommendations.

### M3. The text claims Monte Carlo standard errors appear "in the
tables below," but no rendered table contains an MCSE column

Location: `report.Rmd` "Headline findings" ("All performance
measures include Morris Table 6 Monte Carlo SEs in the tables
below") and ADEMP Methods bullet; `report.Rmd` chunks
`type1-table`, `power-table`, `hf-table` (inspected);
`report.tex` tables (inspected).

`run_simulation()` and `run_hf_simulation()` do compute MCSE
columns (`mcse_rejection`, `mcse_mean_n`, `mcse_bias_naive`,
`mcse_rmse_naive`; inspected in `sim_study.R`), but every table
chunk `dplyr::select()`s them away, and the rendered tables in
`report.tex` show none. The manuscript therefore asserts a
reporting standard it does not meet, and the assertion is
falsifiable from its own tables. This is exactly the kind of
internal contradiction a referee flags as careless. Remediation:
add the MCSE columns (or parenthetical SEs) to all three tables,
or delete the claim.

### M4. The type I error claim is overstated relative to the
rendered results, and the conservatism of the fully sequential
design goes unexamined

Location: `report.Rmd` "Headline findings" and Discussion;
`report.tex` type I table (inspected).

The rendered null rejection rates are 0.058 (fixed), 0.048 (K=3),
0.047 (K=5), and 0.039 (fully sequential). With n_rep = 2,000 the
MCSE at p = 0.05 is about 0.0049, so 0.039 sits roughly 2.2 MCSEs
below nominal. The text's claim that all designs "held empirical
type I error within Monte Carlo tolerance" is therefore not
supported by the paper's own numbers for the fully sequential arm
(and 0.058 is itself 1.6 MCSEs above nominal). More importantly,
the Discussion claims the simulation "confirm[s] that type I error
is controlled at the nominal level under continuous monitoring"
without asking whether the K = 200 discrete spending construction
is systematically conservative (rounding of analysis times,
boundary behavior at very small information fractions, per-pair
rather than per-observation looks). Remediation: increase n_rep
for the null scenarios (n_rep = 20,000 gives MCSE ~0.0015), report
the MCSE next to each rate, and either explain or eliminate the
fully sequential shortfall before claiming nominal control.

### M5. The modern anytime-valid inference literature is absent,
which undermines the paper's central claim to be a "contemporary
reassessment"

Location: `report.Rmd` Introduction, Discussion, and
`references.bib` (inspected; 30 entries, none post-2016 on
continuous monitoring except the software manuals and Morris).

The largest actual revival of fully sequential analysis since
Armitage is the anytime-valid / always-valid inference literature:
mixture SPRTs and always-valid p-values for industrial A/B testing
(Johari, Koomen, Pekelis, Walsh), confidence sequences (Robbins;
Howard, Ramdas, McAuliffe, Sekhon), e-values and e-processes
(Ramdas, Grunwald, Vovk, Shafer), and safe anytime-valid inference
reviews. This body of work solves precisely the problem the paper
poses (continuous monitoring with error control, plus valid
estimation at arbitrary stopping times) and is deployed at scale
in industry. A paper titled "a contemporary reassessment" that
does not engage with it will be judged to have missed the field's
current state. Related omissions: Kulldorff et al. (2011), the
original maxSPRT paper (the cited Kulkarni 2016 is secondary);
Proschan, Lan, and Wittes (2006) monitoring monograph; repeated
confidence intervals (Jennison and Turnbull 1989), which the
appendix recommends without citation. Remediation: add a section
positioning the spending-function-with-K=N approach against
anytime-valid methods, and either compare against an mSPRT or
confidence-sequence comparator in the simulation or justify its
exclusion.

### M6. Reproducibility of the appendix simulation under knitr
caching is fragile, and the seed-once fix likely does not deliver
what it claims

Location: `report.Rmd` chunks `sim-source` (uncached, sets
RNGkind and seed), `sim-run` (cache=TRUE), `hf-sim` (cache=TRUE)
(inspected); status: inferred, not verified by execution.

The seed is set once in an uncached chunk; both simulation chunks
are cached. knitr's cache stores chunk objects but does not replay
the RNG state a cached chunk would have left behind. If `sim-run`
loads from cache while `hf-sim` is invalidated (or vice versa),
`hf-sim` executes from whatever RNG state the fresh session has
after `sim-source`, not the state that followed a fresh `sim-run`.
The appendix results are therefore reproducible only under a full
cold render with the cache deleted, which the manuscript nowhere
states. In addition, `analysis/data/derived_data/sim_20.rds`
exists with no script that reads or writes it (inspected via
grep over the repo); its provenance is unknown. Remediation:
either abandon chunk caching for the simulation chunks and
persist results to versioned `.rds` files written by a standalone
script with its own seed, or set explicit per-chunk seeds and
document the cold-render requirement. Delete or document
`sim_20.rds`.

### M7. Contribution and genre are unresolved: the paper is
two-thirds literature essay, and its actual novel content is
confined to an appendix

Location: whole manuscript; Introduction sections 1.1 to 1.9
versus the Appendix.

Sections 1.1 through 1.9 are a competent narrative review with no
new results; the Methods and Results sections reproduce a
comparison that Sebille and Bellissant (2000, 2003, both cited)
and standard texts (Jennison and Turnbull 2000, Chapter 7, cited
for exactly this point) have already made: most sequential
efficiency is captured by a few looks. The genuinely novel
material, the K-grid diminishing-returns analysis, the
bias-versus-K analysis, and the high-frequency monitoring
architecture and recommendations, is relegated to an appendix
framed as an afterthought that itself declares the main body's
framing "a false dichotomy." A referee will ask why the paper's
best content contradicts its own title and structure. Remediation:
restructure around the appendix thesis (see Recommended framing,
section 5).

## 3. Minor issues

### m1. Bias monotonicity claim contradicted by the paper's table

`report.Rmd` appendix text: bias "grows monotonically with K";
rendered HF table shows bias 0.046 at K = 50 versus 0.044 at
K = 200 (inspected). Within MC noise, but then monotonicity is
not established either. Soften to "tends to increase" and cite
the MCSE.

### m2. "K = 20 captures approximately 90 percent of the savings"
is baseline-dependent and unexplained

Figure caption, `hf-asn-plot`. Relative to the fixed design the
ratio is 52.7/54.8 = 96 percent; incremental over K = 3 it is
(52.7 - 38.2)/(54.8 - 38.2) = 87 percent. State the definition.

### m3. ADEMP Methods bullet inconsistent with the main simulation

Methods lists "group-sequential with K = 3, 5, 10, 20, 50" among
the compared methods, but the main study runs only fixed, K = 3,
K = 5, and K = N; the finer grid appears only in the appendix at
a single delta. Align the ADEMP declaration with what was run.

### m4. Structural defect: the Morris compliance section sits
under the References heading, and it is stale

`report.Rmd` places `## Morris et al. (2019) ADEMP Compliance`
after `# References`, so it renders inside the references block
before the bibliography. Its listed "key gaps" (no MCSE columns
in `sim_study.R:94-108`; seed set twice) describe the pre-fix
state: the code now computes MCSEs and the second `set.seed()`
was removed (inspected). A self-audit admitting resolved defects
does not belong in a submitted manuscript; move any residual
limitations to the Limitations section and drop the rest.

### m5. "Paired comparisons: Met" in the Morris audit is false

`docs/morris-audit-2026-04-17.md` asserts the same data are fed
to all designs per rep; `run_simulation()` generates independent
data inside `simulate_one_trial()` for every design-by-delta
cell (inspected). Cross-design contrasts are therefore noisier
than necessary. Either implement common random numbers (generate
the outcome stream once per rep and apply all K-schedules to it,
as `simulate_one_trial_detailed` nearly permits) or correct the
audit.

### m6. "Fully sequential" is actually per-pair monitoring

The code evaluates the boundary after each treated-control pair
(K = 200 looks over 400 subjects), not after each individual
response as the abstract states. State the paired-accrual
assumption explicitly.

### m7. The stopping-time density figure is misleading for
discrete stopping distributions

`stopping-density` chunk applies a kernel density to stopping
fractions that are point masses at K analysis times (and a large
atom at 1.0 for non-stopping trials, including the entire fixed
design). A histogram or ECDF by design would be honest; the
smoothed density manufactures spread that does not exist.

### m8. Power loss of sequential designs at delta = 0.2 is
visible but never discussed

Rendered power at delta = 0.2: fixed 0.501 versus fully
sequential 0.484 (inspected). The efficiency-versus-power
trade-off at realistic effect sizes deserves a sentence,
especially since it cuts against the paper's thesis.

### m9. No data availability, code availability, software
version, or hardware statement

No sessionInfo, package versions (gsDesign version matters for
boundary computation), runtime, or repository statement appears
in the manuscript. Journals in this tier require them.

### m10. The R package wrapper is empty and the test suite is a
placeholder

`R/` contains no functions; `inst/tinytest/test_basic.R` is
`expect_true(TRUE)` (inspected). None of the simulation functions
are unit-tested (e.g., boundary values against published
Lan-DeMets tables). Also, `CLAUDE.md` describes a testthat setup
that no longer matches the tinytest layout. Not a manuscript
defect per se, but "software development" is one of the paper's
recommendations, and the repo does not model the practice.

### m11. British spelling "colour" in plotting code

`hf-bias-plot` uses `colour =`; harmless to ggplot2 but the
project standard is US English in code.

## 4. What remains to be done

Ordered by importance for submission readiness.

Required for correctness:

1. Redesign the simulation grid around 80 to 90 percent power
   (M1); rerun the K-grid analysis in that regime.
2. Add futility/beta-spending boundaries or restrict all claims
   to efficacy-only stopping (M2).
3. Reconcile the MCSE claim with the tables: print MCSEs (M3).
4. Fix or explain the fully sequential type I error shortfall;
   raise n_rep for null scenarios; correct the "within Monte
   Carlo tolerance" sentence (M4).
5. Make the simulation reproducible without reliance on knitr
   cache state; document or remove `sim_20.rds` (M6).
6. Correct the false "paired comparisons" audit claim or
   implement common random numbers (m5).

Required for acceptance:

7. Engage the anytime-valid inference literature and add or
   justify the absent comparators (M5); add Kulldorff 2011,
   Proschan-Lan-Wittes 2006, Jennison-Turnbull 1989.
8. Restructure the paper around the high-frequency monitoring
   thesis; promote the appendix to the main body (M7, section 5).
9. Remove the Morris compliance section from the manuscript;
   relocate residual limitations (m4).
10. Discuss the power cost at small effects and the per-pair
    monitoring assumption (m8, m6).
11. Add data/code availability, sessionInfo, and versions (m9).

Desirable polish:

12. Replace the stopping-time density with an ECDF or histogram
    (m7); fix the 90-percent caption arithmetic (m2); soften the
    bias monotonicity claim (m1); align the ADEMP methods list
    (m3); fix "colour" (m11).
13. Extract simulation functions into `R/` with roxygen2 docs
    and tinytest coverage of boundary values (m10).

## 5. Recommended framing

Plausible framings:

(a) *Methodological reassessment of fully sequential analysis*
(the current title). Weak: the statistical content (few looks
capture most efficiency) is textbook material, the paper's own
appendix disavows the K = 5 versus K = N dichotomy, and without
the anytime-valid literature the "contemporary" claim fails.

(b) *Design-practice paper: high-frequency group sequential
monitoring (K = 20 to 50) as the practical optimum*, with the
diminishing-returns-in-K analysis as the empirical core, the
bias-versus-K analysis as the caveat, and the automated alerting
architecture as the operational proposal. This is the paper the
appendix already wants to be.

(c) *Tutorial/review with illustrative simulation* for a
review-friendly venue, tracing Wald to anytime-valid inference.
Viable but crowded: Whitehead (2013) and standard texts already
cover the history, so novelty would rest entirely on the
anytime-valid synthesis.

Recommendation: framing (b). Reasoning: the literature already
establishes both the history (Whitehead 2013, cited) and the
fully-sequential-versus-group-sequential comparison (Sebille and
Bellissant 2000/2003, cited; Jennison and Turnbull 2000 Ch. 7,
cited), so (a) offers no publishable delta. What practitioners
lack is a defensible rule for choosing K when data flow is
electronic and near-continuous, plus guidance on estimation and
DSMB operations at large K; that is a genuine gap between the
K = 3 to 5 convention and the anytime-valid methods that most
trialists do not yet use. Implications: retitle around choosing
the number of analyses in the era of continuous data capture;
rewrite the abstract around the K-grid result (restated in a
correctly powered regime per M1); compress the historical review
to a two-page background section; move the current main-body
K = 3/5/N comparison into the K-grid analysis; add anytime-valid
methods as a comparator or as explicitly scoped-out related work;
target Clinical Trials, Pharmaceutical Statistics, or a
Statistics in Medicine tutorial/practice paper. Emphasize: the
K-grid ASN and bias results, the alerting architecture, the five
recommendations (currently appendix). De-emphasize or move to
supplement: the long historical narrative (sections 1.1 to 1.5),
the stopping-time density figure, the Morris self-audit
(remove entirely).

## 6. Assessment

Verdict: major revision, and in its current structure the
manuscript is not yet a submission candidate for any of the
journals its style targets. The writing is clear and the
literature review through 2016 is accurate (inspected against the
bibliography), but the empirical core is conducted in a power
regime that inflates its headline numbers (M1), the designs
simulate only half of the stopping behavior the text discusses
(M2), the manuscript makes reporting claims its own tables refute
(M3, M4), and the survey misses the literature that constitutes
the actual contemporary revival of its subject (M5). The most
promising material is structurally buried in an appendix that
contradicts the paper's framing (M7). The remediation path is
well defined: rerun the simulation in a realistic power regime
with futility boundaries and MCSEs displayed, reframe around the
high-frequency monitoring thesis, and position against
anytime-valid inference. With that work, the paper has a credible
route to a design-practice journal.

## 7. Revision history

- 2026-08-16: Initial referee review. No prior
  `pub_review_whitepaper_*.md` existed in `docs/`. Seven major
  and eleven minor issues identified; verdict major revision.
