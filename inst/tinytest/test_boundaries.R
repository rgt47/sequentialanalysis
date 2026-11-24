## Boundary values from compute_boundaries() checked against an
## oracle that does not use gsDesign: the multivariate normal
## distribution of the sequential z-statistics, integrated with
## mvtnorm. Under H0 the z-statistics at information fractions
## t_i and t_j have correlation sqrt(min(t_i, t_j) / max(t_i, t_j)),
## so the crossing probabilities of the boundaries can be computed
## directly and compared with the Lan-DeMets O'Brien-Fleming
## spending function sfLDOF (whitepaper 2026-08-16, m10: tinytest
## coverage of boundary values).

library(tinytest)

if (!requireNamespace('mvtnorm', quietly = TRUE)) {
  exit_file('mvtnorm not installed; skipping boundary oracle tests')
}

pkg_root <- tryCatch(
  rprojroot::find_root(rprojroot::has_file('DESCRIPTION')),
  error = function(e) NULL
)
if (is.null(pkg_root)) {
  exit_file('sequentialanalysis root not found; skipping')
}
sim_script <- file.path(
  pkg_root, 'analysis', 'scripts', 'sim_study.R'
)
if (!file.exists(sim_script)) {
  exit_file('analysis/scripts/sim_study.R not found; skipping')
}

suppressMessages({
  library(gsDesign)
  library(dplyr)
  library(tidyr)
  library(purrr)
})
source(sim_script)

cross_prob <- function(b, t, drift = 0, two_sided = TRUE) {
  k <- length(t)
  sig <- outer(t, t, function(x, y) sqrt(pmin(x, y) / pmax(x, y)))
  lower <- if (two_sided) -b else rep(-Inf, k)
  set.seed(1)
  p_stay <- mvtnorm::pmvnorm(
    lower = lower, upper = b, mean = drift * sqrt(t), sigma = sig,
    algorithm = mvtnorm::GenzBretz(maxpts = 2e5, abseps = 1e-6)
  )
  1 - as.numeric(p_stay)
}

ldof_two_sided <- function(t, alpha = 0.05) {
  2 * (2 - 2 * pnorm(qnorm(1 - alpha / 4) / sqrt(t)))
}

for (n_max in c(85, 200)) {
  for (k in c(2, 3, 5, 10)) {
    bnd <- compute_boundaries(k, n_max)
    expect_true(
      abs(cross_prob(bnd$z_upper, bnd$info_frac) - 0.05) < 1e-4,
      info = paste0(
        'two-sided type I error is 0.05 by mvtnorm at K = ', k,
        ', n_max = ', n_max
      )
    )
    expect_true(
      abs(cross_prob(bnd$z_upper, bnd$info_frac,
        two_sided = FALSE) - 0.025) < 1e-4,
      info = paste0(
        'upper-tail crossing probability is 0.025 at K = ', k,
        ', n_max = ', n_max
      )
    )
  }
}

bnd5 <- compute_boundaries(5, 200)
cum_spent <- vapply(seq_len(5), function(j) {
  cross_prob(bnd5$z_upper[1:j], bnd5$info_frac[1:j])
}, numeric(1))
expect_true(
  all(abs(cum_spent - ldof_two_sided(bnd5$info_frac)) < 1e-4),
  info = paste(
    'cumulative alpha spent at each of 5 looks matches the',
    'Lan-DeMets O\'Brien-Fleming spending function'
  )
)

bnd5_85 <- compute_boundaries(5, 85)
drift_85 <- 0.5 / sqrt(2) * sqrt(85)
expect_true(
  abs(cross_prob(bnd5_85$z_upper, bnd5_85$info_frac, drift_85) -
    exact_oc(5, 85, 0.5)$reject) < 1e-4,
  info = paste(
    'exact_oc() power at K = 5, n_max = 85, delta = 0.5 agrees',
    'with the mvtnorm oracle'
  )
)
