# Voice and humanizer revision log: report.Rmd
*2026-11-18 16:58 PST*

Manuscript: `analysis/report/report.Rmd`. Baseline: `git show
5444109:analysis/report/report.Rmd` (HEAD did not move during the
session). Companion review: `referee-report-2026-11-18.md`. The file
was edited with the Edit tool only. Nothing was staged, committed,
rendered, or pushed.

## Scale

Of 335 baseline prose sentences (sentence split on terminal
punctuation, chunks excluded), 189 were changed, split, or replaced.
The work was done in 24 Edit calls, covering every prose section from
the Introduction through the Practical recommendations.

## Pass 2: voice revision (use_rgtvoice)

The kinds of changes made are as follows.

- Long sentences were split to one idea each, with a target of 15 to
  20 words and a ceiling of 25. Subordinate and relative clauses
  ('who introduced', 'in which', 'which provides', 'so that',
  'while', 'because') became separate sentences headed by a plain
  connective ('That is,', 'However,', 'In addition,', 'This', 'The
  reason is').
- Common words replaced Latinate ones in most places: 'demonstrate'
  became 'show', 'employ' became 'use', 'via' became 'by' in the
  Simulation procedure, and 'approximately' became 'about' in two
  prose hedges ('about 90 percent power'). 'Approximately optimal'
  (a technical phrase), 'approximately zero', and 'via posterior
  probabilities' were kept.
- Conditional constructions were rewritten as 'Suppose ... Then ...'
  (Introduction, marginal-cost section, DSMB enrollment example).
- Section headings were changed to sentence case only.
  'Armitage and Sequential Medical Trials' keeps its capitals,
  because it names Armitage's monograph. Two-line headings keep
  their line break (the referee report notes, as minor comment 4,
  that the second line renders as body text; that is left for the
  remediation step). The in-text pointers to the power-calibrated
  section and to Future research were updated to match the new
  heading case.

## Pass 3: humanizer (File mode)

- Dashes: the four spaced double hyphens used as dashes in prose
  (Discussion bullet on algorithmic monitoring; the three alert items
  in the appendix) were replaced by a period or colon. Prose ranges
  written with '--' ('K = 3--5', 'K = 20--50', '10--20\%',
  '0.998--1.000') became 'to' ranges. 'K = 20-50' in the
  anytime-valid subsection also became 'K = 20 to 50'. Two ranges
  with a single hyphen ('K = 3-5', '0.003-0.004') were left.
- Bold labels: bold run-in labels in numbered and bulleted lists
  (Why the field moved, ADEMP, Design framework, Simulation
  procedure, Future research, Practical recommendations) were made
  plain. The three run-in paragraph heads in the software
  architecture section became italic so that they still read as
  heads.
- Stock or inflated words: 'powerful' became 'strong', 'crucial'
  became 'major', 'valuable' became 'useful', 'key' became 'main'
  (three places), 'represents' became 'is', and 'actually' was
  dropped from the Present study paragraph. A final grep found no
  remaining instances of the humanizer's stock-word list in prose.
- Contrast formulas: 'not only X but also Y' in the bias-module
  paragraph was stated directly. 'Rather than requiring ...' was
  stated directly. Remaining 'not X but Y' and 'rather than'
  contrasts were kept where both halves carry information (fully
  sequential as the limiting case rather than a different method;
  one look per pair, not per observation; Monte Carlo noise rather
  than systematic conservatism; software engineering, not novel
  methodology).
- Colon-led lists inside sentences ('four sequential methods: ...',
  'three pillars: (i) ... (iii)') were turned into separate
  sentences. The roman numerals in the three-pillars sentence were
  replaced by 'The first ... The second ... The third'.

## Passages deliberately left alone

- The abstract (YAML), including its ' -- ' dash, per the hard
  constraint.
- All code chunks, chunk options, figure captions (`fig.cap`), and
  kable captions, including dash ranges and stale numbers inside
  them.
- All display and inline math and all inline R expressions.
- The Discussion opener ('We shall interpret the results in the
  context of ...') was kept. It is a signpost in the target voice,
  although the humanizer would class it as a staged run-up.
- Stale or contested claims flagged in the referee report were
  reworded only, never corrected or strengthened. These include the
  bias values '0.046 at K = 50 versus 0.044 at K = 200, a reversal'
  (M2), the power-cost language at N_max = 85 and at delta = 0.2
  (M3), the 'no loss of type I error control' and 'less than 1\%
  inflation' recommendations (M5, M6), the Fleming et al.
  interpolating-family attribution, the calendar-time attribution to
  Lan and DeMets (1983), and the content attributed to
  `whitehead2013evolution` and `kulkarni2016continuous` (M9).
- The internal note under '# References' ('A remediation plan is
  recorded in the audit file ...') was not deleted. It is flagged in
  the referee report (minor comment 5) for the remediation step.
- The revision-history sentences in the headline findings ('This
  supersedes an earlier reading ...') and in the Reproducibility
  subsection were reworded but kept, since they carry information.
- One enumerated estimand item in the ADEMP list (27 words with
  three numbered sub-items) was left as a single sentence, because
  splitting it would break the (i)-(iii) enumeration.
- No sentences were merged or deleted. Every hedge ('roughly',
  'about', 'essentially', 'somewhat', 'appears', 'perhaps', 'may')
  was kept.

## Verification

A script (`verify.py` in the private scratch directory) compared the
revised file against `git show 5444109:analysis/report/report.Rmd`.

| Invariant | Baseline | Revised | Result |
|---|---|---|---|
| Code-chunk lines (multiset) | 299 | 299 | identical |
| Inline R expressions | 27 | 27 | identical |
| `@` citation keys | 64 | 64 | identical |
| Numeric tokens | 462 | 462 | identical |
| YAML header | 1 block | 1 block | identical |
| Inline and display math spans | 49 | 49 | identical |
| Non-R inline code spans | 20 | 20 | identical |
| Heading lines (lowercased, in order) | 37 | 37 | identical |

No numeric token needed the punctuation exemption. The only remaining
spaced double hyphen is in the abstract, which is out of scope; no em
or en dash characters remain. A second script flagged prose sentences
over 25 words. After fixes, the only remaining flags are list items
that the splitter joins across bullets and the ADEMP estimand item
noted above.

The document was not rendered, so the effect of the edits on the PDF
layout was not checked.
