# Referee report: 'Fully Sequential Analysis Revisited'
*2026-11-18 16:51 PST*

Manuscript: `analysis/report/report.Rmd` (baseline commit `5444109`).
Line numbers below refer to that commit, before the voice revision.
Section names and chunk labels are given so that anchors survive
later edits.

## 1. Summary of the manuscript

The manuscript reviews the history of fully sequential monitoring,
from Wald and Armitage through the group sequential era and the
Lan-DeMets alpha spending function. It then asks whether modern
computing, electronic data capture, and the spending function
framework justify renewed use of fully sequential designs in
confirmatory trials. A Monte Carlo study compares a fixed design,
Lan-DeMets O'Brien-Fleming group sequential designs with K = 3 and
K = 5, and a 'fully sequential' design with one look per enrolled
pair. The study uses a two-arm normal outcome with known variance at
N_max = 200 per arm and a power-calibrated N_max = 85 per arm. The
manuscript itself states that the main comparison reproduces known
results. It locates its own contribution in an appendix: a K-grid
(3, 5, 10, 20, 50, N) at delta = 0.5 showing diminishing returns in
expected sample size, and a recommendation to default to K = 20 with
an automated alerting architecture.

## 2. Overall assessment and recommendation

**Recommendation: major revision (reject in current form for a
top-tier statistics journal).**

The historical review is competent and readable, and the paper is
candid about several of its own limitations (no futility boundary,
paired looks, overpowered main grid). However, the empirical
contribution is thin, and several quantitative statements do not
match the stored simulation output. The legend of the main ASN
figure, as rendered, attaches the wrong design names to three of the
four curves. The appendix's central claims (a measurable power cost
of frequent monitoring, a bias that 'tends to increase with K', and
'no loss of type I error control' at K = 20) are either within Monte
Carlo noise, stale relative to the data, or not simulated at all.
The spending function displayed in the Methods is not the one the
code implements. Three bibliography DOIs resolve, on Crossref, to
unrelated papers, and two of those entries also carry wrong authors
or venue. The K-grid diminishing-returns result is, in my view,
largely available in the optimal-design and textbook literature and
does not by itself clear the bar for JASA, JRSS-B, or Biometrika.
With corrected numbers and figures, a delayed-response model,
futility boundaries, and an anytime-valid comparator, the work could
suit *Statistics in Medicine* or *Clinical Trials* as a tutorial and
design-guidance paper.

## 3. Significance and novelty

The main-body comparison (fixed versus K = 3, 5 versus fully
sequential) is acknowledged in the Introduction (lines 366-380) to
reproduce Sébille and Bellissant (2000, 2003) and Jennison and
Turnbull (2000, Chapter 7). I agree with that self-assessment.

The appendix claim of novelty is the shape of ASN as a function of K
between 5 and N. In my recollection this shape is well documented,
although I did not retrieve the relevant tables during this review.
Jennison and Turnbull (2000) tabulate expected sample size and
maximum-information inflation factors for O'Brien-Fleming, Pocock,
and error-spending tests over a range of K. Eales and Jennison (1992)
derive ASN-optimal one-sided tests for up to 200 groups (the group
count is confirmed from the abstract; the behavior of the optimum as
K grows is from recall). Barber and Jennison (2002) extend this to
asymmetric tests. A referee in this area would expect the manuscript
to report its K-grid alongside those published values and to explain
what it adds. As it stands, the contribution is a simulation
re-derivation of a curve that is at least partly known, at a single
effect size, and with no maximum-sample-size inflation, which is the
usual way of holding power fixed across K.

Contemporariness is mixed. The manuscript does engage with
anytime-valid inference (Howard et al. 2021; Ramdas et al. 2023;
Johari et al. 2017) in a dedicated subsection, which is welcome.
However, the treatment of delayed responses, the most important
practical barrier to frequent monitoring, ignores Hampson and
Jennison (2013), which shows that pipeline subjects erode the ASN
gains of early stopping. The proposed K = 20 default rests on this
gap.

## 4. Major comments

Correctness problems come first (M1 to M7).

**M1. The stated spending function is not the one implemented
(inspected).** Methods, 'Alpha Spending Function', display equation
at line 439, gives the two-sided spending function
alpha*(t) = 2 - 2 Phi(z_{alpha/2} / sqrt(t)) with alpha = 0.05, so
z_{alpha/2} = 1.96. The code (`compute_boundaries()` in
`analysis/scripts/sim_study.R`) calls `gsDesign(test.type = 2,
alpha = alpha/2, sfu = sfLDOF)`. In gsDesign, `alpha` is the
one-sided level and `sfLDOF` spends 2 - 2 Phi(Phi^{-1}(1 - alpha/2) /
sqrt(t)) per side with that one-sided alpha, that is, with
z = 2.241. The implied total two-sided spending is
2[2 - 2 Phi(2.241 / sqrt(t))]. I computed both curves directly from
the formulas: at t = 0.5 the displayed function spends 0.0056 and the
implemented one 0.0031; at t = 0.25, 8.9e-5 versus 1.5e-5. Both reach
0.05 at t = 1. The gsDesign behavior is taken from its documented
definition. I did not run gsDesign, which is not installed on this
machine. **Remedy:** state the per-side spending function actually
used, or change the code to match the display, and say which one the
results reflect.

**M2. Hard-coded bias numbers in the appendix are stale and the
'reversal' does not exist (verified against stored output).**
Appendix, 'Bias Under High-Frequency Monitoring', lines 1241-1245,
says bias is '0.046 at K = 50 versus 0.044 at K = 200, a reversal
within Monte Carlo noise'. In `hf_results.rds` the naive bias is
0.0417 at K = 50 and 0.0448 at K = 200, so there is no reversal at
that step. The actual non-monotonicity is elsewhere: 0.0340 (K = 3),
0.0306 (K = 5), 0.0340 (K = 10), 0.0378, 0.0417, 0.0448. These
numbers appear to come from an earlier simulation run. **Remedy:**
replace every hard-coded result in the prose with inline R, as is
already done elsewhere, and rewrite the sentence to describe the
actual pattern.

**M3. The 'power cost' of sequential monitoring is not
distinguishable from Monte Carlo noise (verified against stored
output).** Results, 'Power-Calibrated Sensitivity Scenario', lines
650-663, report that fully sequential power at N_max = 85 is 0.868,
3.6 percentage points below the fixed design (0.904). The same design
at the same N_max and delta is simulated a second time, independently,
for the appendix (`hf_results_90pow.rds`, label 'Fully Seq'), and
there it gives 0.8905. The two estimates of the same quantity differ
by 0.023, about 2.2 combined Monte Carlo SEs. The appendix caption
(chunk `hf-table-90pow`) then says power 'visibly declines with K
(0.897 at K=3 to 0.891 at K=85)'. That 0.6-point difference is below
one MCSE (about 0.007), and the sequence across K is non-monotone
(0.8965, 0.901, 0.885, 0.8965, 0.884, 0.8905). Similarly, at
delta = 0.2 (lines 665-675) the fixed-versus-fully-sequential gap
(0.501 versus 0.484) is about 1.1 SE, while K = 3 and K = 5 both
exceed the fixed design. The text describes this as 'a loss that
cuts against the paper's ASN-savings thesis'. A modest power loss is
expected in theory, because the sequential designs do not inflate
N_max, but the simulation at n_rep = 2,000 cannot measure it.
**Remedy:** compute exact power for each design by numerical
integration (gsDesign `gsProbability()` gives this directly), which
removes Monte Carlo error entirely. Alternatively, increase n_rep and
use common random numbers across designs.

**M4. The legends of Figures 1 and 2 mislabel three of the four
designs (verified in the rendered figure).** Chunks `asn-plot` and
`stopping-ecdf` pass
`labels = c('Fixed', 'GS (K=3)', 'GS (K=5)', 'Fully Sequential')`
to `scale_linetype_manual()` and `scale_shape_manual()`. In
`sim_results.rds` the `design` column is character, so ggplot2 orders
the groups alphabetically: 'Fixed', 'Fully Seq', 'GS (K=3)',
'GS (K=5)' (confirmed in R). Positional labels therefore assign
'GS (K=3)' to the fully sequential curve, 'GS (K=5)' to K = 3, and
'Fully Sequential' to K = 5. I read the figure as last rendered
(`report_files/figure-latex/asn-plot-1.pdf`, August 20). The curve
with ASN of about 91 at delta = 0.5 and about 56 at delta = 0.8 (the
fully sequential values in the stored results) carries the legend
'GS (K=3)'. The curve at about 123 (K = 3) carries 'GS (K=5)'. A
reader would conclude that K = 3 has the lowest ASN and that fully
sequential monitoring is intermediate, which reverses the paper's
finding. The `stopping-ecdf` figure uses the same code pattern; I
did not inspect its rendering. **Remedy:** convert `design` to a
factor with explicit levels, or pass a named `labels` vector, and
re-render.

**M5. Recommendation 1 ('Default to K = 20 ... with no loss of type I
error control') is not supported by the simulation (inspected).**
Appendix, 'Practical Recommendations', lines 1360-1367. The null
scenario (`sim_results_null`) covers only fixed, K = 3, K = 5, and
fully sequential designs. K = 20 is simulated only at delta = 0.5.
Type I error control at K = 20 follows from the spending function
construction in theory, so the claim is plausibly true. However, the
manuscript presents it as a simulation finding. In addition, the
type I error estimates rise with K (0.049, 0.0515, 0.0518, 0.053),
and the fully sequential value sits 1.95 SE above nominal. This is
within two SEs, but the text (lines 531-537) calls it 'consistent
with nominal control' while stating that the earlier 0.039 value was
noise. At K = N = 200 the looks fall exactly on pairs 1 to 200, so
rounding of analysis times (M7) cannot explain the fully sequential
value. I have no explanation for the upward trend and did not
investigate it; it may be noise. **Remedy:** run the null at every
K in the grid, or compute exact type I error numerically, and report
it.

**M6. Recommendation 2 ('typically less than 1% inflation') is
unsupported and probably wrong (suspected).** Appendix, lines
1369-1375. The simulation never inflates N_max; all designs share
the fixed N_max, which is precisely why the sequential designs lose
power. My recollection is that published maximum-information
inflation factors for two-sided O'Brien-Fleming tests at
alpha = 0.05 and 90 percent power are a few percent for K = 5 to 20
(Jennison and Turnbull 2000, Chapter 2). I did not verify the table
values or recompute them, because gsDesign is not installed here.
**Remedy:** compute `gsDesign(k = K, test.type = 2, alpha = 0.025,
beta = 0.1, sfu = sfLDOF)$n.I[K] / n.fix` for K in the grid and
report it, then correct or remove the claim.

**M7. Analysis times are misaligned with the information fractions
used to compute boundaries (verified for the look schedule).** In
`simulate_one_trial()` and `simulate_one_trial_detailed()`,
boundaries are computed at `timing = seq(1/k, 1, length.out = k)`,
but looks occur at `round(info_frac * n_max)`. At N_max = 85 and
K = 50, I computed the realized looks in R. They are 2, 3, 5, 7, 8,
10, ..., 83, 85, with steps alternating between one and two pairs
and no repeats. At K = 20 the steps alternate between 4 and 5 pairs.
The boundaries therefore do not correspond exactly to the realized
information. The effect on error rates is probably small but was not
quantified. **Remedy:** compute boundaries at the realized fractions
`analysis_n / n_max`, which `gsDesign(timing = ...)` accepts.

**M8. The design omits the features that decide the paper's
practical question (inspected).** The Discussion (lines 817-834) and
the appendix argue for frequent monitoring when endpoints are fast.
The simulation assumes instantaneous response, no pipeline subjects,
no accrual model, and no futility boundary. Hampson and Jennison
(2013) show that the ASN benefit of early stopping shrinks as
response delay grows. Recommendation 1's threshold ('turnaround
times of less than one month') is stated without any model of
turnaround. **Remedy:** add a delayed-response scenario with a
stated accrual rate and response lag, measure expected sample size
as subjects enrolled (not responses observed), and add a
beta-spending futility boundary (the authors already list this as
Future Research item 9).

**M9. Three bibliography DOIs resolve to unrelated papers, and two
entries carry wrong authors or venue (verified on Crossref).**

- `kulkarni2016continuous` is cited (lines 327, 838, 879) as
  'Kulkarni, Silva, and Buras, Statistics in Medicine 2016, doi
  10.1002/sim.6989'. Crossref resolves that DOI to Murray, Thall, and
  Yuan, 'Utility-based designs for randomized comparative trials with
  categorical outcomes', *Statistics in Medicine* 35(24), 2016. The
  cited title belongs to Silva and Kulldorff, *Biometrics*
  71(3):851-858, 2015, doi 10.1111/biom.12324 (Crossref confirmed).
  The listed author 'Kulkarni' and coauthor 'Buras' do not appear on
  that paper. In addition, the manuscript says the paper compared
  maxSPRT with group sequential methods. According to its abstract,
  the paper concludes that continuous designs can always be found
  that are better on expected time to signal. That conclusion is
  stronger than the manuscript conveys and is directly relevant.
- `whitehead2013evolution` is cited as Whitehead, *JRSS-A* 2013, doi
  10.1111/rssa.12031. Crossref resolves that DOI to Deuchert and
  Wunsch, 'Evaluating nationwide health interventions: Malawi's
  insecticide-treated-net distribution programme', *JRSS-A*
  177(2), 2014. A search for the cited title found a 2013 James Lind
  Library commentary attributed to Peter Armitage, not a JRSS-A
  paper. The text at lines 202-208 attributes specific content ('His
  account identifies the key practical factors') to this source.
- `betensky1998continuous` carries doi 10.2307/2533858, which
  Crossref resolves to Sooriyarachchi and Whitehead (1998), a
  different *Biometrics* paper. The correct DOI is 10.2307/2533857
  (Crossref confirmed). The author, title, and pages of the entry are
  otherwise correct.

These are the kind of errors that suggest bibliography entries
generated without checking. **Remedy:** resolve every DOI in
`references.bib` against Crossref, correct the entries, and recheck
that each attached claim is supported by the real source.

**M10. The abstract does not describe what the paper delivers
(inspected).** The abstract (YAML, lines 7-27) describes a historical
reassessment and a review of 'regulatory conditions'. It does not
mention the simulation, the K-grid, the K = 20 recommendation, or the
power-calibrated scenario. No regulatory analysis appears in the
body; regulation is addressed in one list item (line 247) and one
Future Research item. **Remedy:** rewrite the abstract to state the
design, the main quantitative findings with their uncertainty, and
the recommendation.

## 5. Minor comments

1. Introduction, 'The Group Sequential Revolution', lines 140-143:
   the family of boundaries 'parameterized to interpolate between
   the Pocock and O'Brien-Fleming extremes' is, to my recollection,
   Wang and Tsiatis (1987). Fleming, Harrington, and O'Brien (1984)
   proposed a different design with a near-constant early boundary.
   (Likely misattribution; from recall, not rechecked against the
   papers.)
2. Future Research item 1, line 970: 'calendar-time spending
   function [@lan1983discrete]'. Calendar versus information time is
   treated in Lan and DeMets (1989), not the 1983 paper. (Suspected,
   from recall.)
3. Line 268: Lai, Levin, Robbins, and Siegmund (1980) is cited for
   asymptotic optimality 'from both Bayesian and frequentist
   perspectives'. To my recollection, that PNAS note concerns an
   ethical-cost formulation of a two-treatment trial. The claim would
   be better supported by Siegmund (1985). (Suspected.)
4. The three split section headings ('Comparison of Fully Sequential
   and Group Sequential / Approaches', 'Appendix: High-Frequency
   Monitoring as a Practical / Middle Ground', 'A Software
   Architecture for High-Frequency / Monitoring') do not render as
   intended. In the August 20 `report.tex` (lines 393-395,
   1107-1109, 1255-1257) the heading stops at the line break and the
   second line ('Approaches', 'Middle Ground', 'Monitoring') appears
   as a stray body paragraph. (Verified in the .tex.) Join each
   heading onto one line.
5. Lines 1406-1407: the sentence 'A remediation plan is recorded in
   the audit file and will be taken up in a subsequent revision'
   sits under the References heading and will render in the
   published PDF. It is an internal note and should be removed.
6. Lines 527-537 and lines 1072-1074 (code comment) contain revision
   history ('This supersedes an earlier reading ...', 'which
   previously left the appendix simulation's reproducibility
   undocumented'). Revision history belongs in a response letter, not
   in the manuscript.
7. Lines 1251-1254: bias-corrected estimation methods (median
   unbiased, conditional MLE, bootstrap) are listed without
   citations. Whitehead (1986), Emerson and Fleming (1990), and Fan,
   DeMets, and Lan (2004) would serve.
8. The 'fully sequential' label means one look per enrolled pair
   (lines 804-815). This is disclosed, but the title, abstract, and
   Methods (line 428, 'after each individual observation') still say
   otherwise. The Methods description should match the code.
9. Rejection is two-sided (`abs(z_val) >= z_upper[j]`), so 'power'
   includes rejections in the wrong direction. This is negligible at
   delta >= 0.2 but should be stated.
10. Figure caption for `asn-plot` says the fully sequential design
    'offers diminishing returns relative to the five-look group
    sequential design'. At delta = 0.8 in the main grid, K = 3 has
    a lower ASN (78.0) than K = 5 (78.2); that is noise, but the
    caption should not imply monotonicity at every delta.
11. Lines 1212-1214: 'By K = 50, the design is ... operationally
    indistinguishable from fully sequential monitoring, yet the
    infrastructure demands are far more manageable.' No
    infrastructure cost is measured. This should be phrased as a
    conjecture.
12. Lines 1346-1352: 'the marginal cost of the 21st analysis is
    approximately zero' and 'this investment seems easily
    justified' are unsupported. A reference or a cost model is
    needed.
13. Bibliography: `whitehead2013evolution` and
    `kulkarni2016continuous` lack volume and pages;
    `wassmer2023rpact` lacks a version; `anderson2022gsdesign` cites
    version 3.5.0 while `sim_metadata.rds` records gsDesign 3.10.1.

## 6. Missing and questionable references

| Claim location | Issue | Suggested source |
|---|---|---|
| Lines 327, 838, 879 | Wrong authors, venue, year, and DOI (Crossref) | Silva IR, Kulldorff M. Continuous versus group sequential analysis for post-market drug and vaccine safety surveillance. *Biometrics* 2015;71(3):851-858. doi:10.1111/biom.12324 |
| Lines 202-208 | DOI resolves to an unrelated JRSS-A paper; no JRSS-A source found | Armitage P. The evolution of ways of deciding when clinical trials should stop recruiting. *JLL Bulletin* 2013 (verify), or a verified Whitehead review |
| Lines 175, 768, 1281 | Wrong DOI | Betensky RA. Construction of a continuous stopping boundary from an alpha spending function. *Biometrics* 1998;54(3):1061-1071. doi:10.2307/2533857 |
| Lines 140-143 | Interpolating family likely misattributed | Wang SK, Tsiatis AA. Approximately optimal one-parameter boundaries for group sequential trials. *Biometrics* 1987;43(1):193-199 |
| Line 970 | Calendar-time spending | Lan KKG, DeMets DL. Group sequential procedures: calendar versus information time. *Stat Med* 1989;8(10):1191-1198 |
| Appendix, diminishing returns in K | Prior work not engaged | Eales JD, Jennison C. An improved method for deriving optimal one-sided group sequential tests. *Biometrika* 1992;79(1):13-24; Barber S, Jennison C. Optimal asymmetric one-sided group sequential tests. *Biometrika* 2002;89(1):49-60 |
| Discussion, delayed outcomes; Recommendation 1 | Delayed response not modeled or cited | Hampson LV, Jennison C. Group sequential tests for delayed responses (with discussion). *JRSS-B* 2013;75(1):3-54. doi:10.1111/j.1467-9868.2012.01030.x |
| Lines 1251-1254 | Bias correction uncited | Whitehead J. On the bias of maximum likelihood estimation following a sequential test. *Biometrika* 1986;73(3):573-581; Fan XF, DeMets DL, Lan KKG. Conditional bias of point estimates following a group sequential test. *J Biopharm Stat* 2004;14(2):505-530 |
| Line 268 | Asymptotic optimality | Siegmund D. *Sequential Analysis: Tests and Confidence Intervals*. Springer; 1985 |

Bibliographic details were confirmed by Crossref for Silva and
Kulldorff (2015) and Betensky (1998), and by web search results for
Hampson and Jennison (2013), Eales and Jennison (1992, journal and
volume only), and Barber and Jennison (2002, journal and volume
only). All other details are from recall and should be checked
before use.

## 7. Suggestions for strengthening the paper

1. Replace Monte Carlo operating characteristics with exact
   numerical values from `gsProbability()` for power, ASN, and
   type I error. Keep simulation only for the naive MLE bias and
   RMSE, and use common random numbers across K there.
2. Compare designs at equal power by inflating N_max for each K.
   This is the standard comparison and would answer the paper's
   question directly: what does each additional look cost in
   maximum sample size, and what does it save in ASN?
3. Report the K-grid over a range of delta (for example 0 to 1.2
   relative to the design alternative), not only at delta = 0.5.
4. Add a delayed-response and accrual model, and a futility
   boundary.
5. Add an anytime-valid comparator (mSPRT or a normal-mixture
   confidence sequence), which the Discussion already identifies.
6. Report bias-adjusted estimators alongside the naive MLE, since
   Recommendation 3 depends on them.

## 8. Scope of this review

**Verified (computed, read from stored output, or looked up):** all
numbers in `sim_results*.rds` and `hf_results*.rds` (read with
`readRDS()`); the type I error z-scores against nominal; the
cross-run discrepancy in fully sequential power at N_max = 85; the
stale bias numbers; the figure-caption arithmetic for the K = 20
share of ASN reduction (96 and 87 percent, both correct); the MCSE
arithmetic in the ADEMP section; the N = 85 power-calibration
formula; the two spending curves in M1, computed from their closed
forms in base R; the realized look schedule at N_max = 85 (M7); the
legend mislabeling in the rendered `asn-plot` figure (M4); the
split-heading rendering in `report.tex` (minor 4); the four DOIs in
M9 and Section 6, resolved through the Crossref API.

**Inspected (read the source and judged):** the simulation code in
`analysis/scripts/sim_study.R` and `run_all_simulations.R`; the
mapping between prose, tables, and code; the bibliography file.

**From recall, not verified:** the Jennison and Turnbull table
contents (M6, Section 3); what Eales and Jennison show about the
optimum as K grows; the attributions in minor comments 1 to 3; the
gsDesign `sfLDOF` definition (M1).

**Not checked:** the simulation was not rerun; gsDesign was not
available locally, so its boundary values and inflation factors were
not computed; the PDF was not re-rendered, and only the `asn-plot`
figure was opened; the full text of most cited papers was not read.

**Literature searches run (web):** the exact title of the
Kulkarni et al. entry; the DOI 10.1002/sim.6989; Whitehead 2013
'evolution' in JRSS-A; Betensky 1998 continuous stopping boundary;
Sébille and Bellissant 2000; Hampson and Jennison delayed responses;
optimal group sequential tests as a function of the number of
analyses (Eales and Jennison 1992). Crossref lookups: 10.1002/sim.6989,
10.1111/rssa.12031, 10.2307/2533858, 10.2307/2533857,
10.1111/biom.12324.
