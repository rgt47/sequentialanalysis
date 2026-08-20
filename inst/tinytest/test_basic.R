## Tests for the simulation functions in
## analysis/scripts/sim_study.R that generate the manuscript's
## reported numbers (report.Rmd, via
## analysis/scripts/run_all_simulations.R).
##
## sim_study.R lives outside R/ (excluded from the built package by
## .Rbuildignore, per the research-compendium layout documented in
## CLAUDE.md), so it is sourced here by locating the package root
## with rprojroot rather than via NAMESPACE. This means these tests
## run correctly under
## `Rscript -e 'pkgload::load_all("."); tinytest::run_test_dir("inst/tinytest")'`
## and `make test`, which both execute from the project tree, but
## not under a relocated `R CMD check` install of the built tarball.

library(tinytest)

pkg_root <- tryCatch(
  rprojroot::find_root(rprojroot::has_file("DESCRIPTION")),
  error = function(e) NULL
)

if (is.null(pkg_root)) {
  exit_file("sequentialanalysis root not found; skipping sim tests")
}

sim_script <- file.path(
  pkg_root, "analysis", "scripts", "sim_study.R"
)

if (!file.exists(sim_script)) {
  exit_file(
    "analysis/scripts/sim_study.R not found; skipping sim tests"
  )
}

suppressMessages({
  library(gsDesign)
  library(dplyr)
  library(tidyr)
  library(purrr)
})
source(sim_script)

## compute_boundaries -------------------------------------------

bnd1 <- compute_boundaries(k = 1, n_max = 200)
expect_equal(
  bnd1$z_upper, qnorm(1 - 0.05 / 2),
  info = "k = 1 boundary is the fixed-sample normal critical value"
)
expect_equal(
  bnd1$info_frac, 1,
  info = "k = 1 has a single, final information fraction"
)

bnd5 <- compute_boundaries(k = 5, n_max = 200)
expect_equal(
  length(bnd5$z_upper), 5,
  info = "k = 5 boundary has 5 upper bounds"
)
expect_true(
  all(diff(bnd5$z_upper) <= 0),
  info = "O'Brien-Fleming boundary is non-increasing across looks"
)
expect_true(
  abs(bnd5$z_upper[5] - bnd1$z_upper) < 0.15,
  info = paste(
    "final O'Brien-Fleming look is close to the fixed-sample",
    "critical value (boundary shape check)"
  )
)
expect_equal(
  bnd5$info_frac, seq(0.2, 1, by = 0.2),
  info = "k = 5 equally spaced information fractions"
)

## simulate_one_trial ---------------------------------------------

set.seed(1)
one_trial <- simulate_one_trial(
  n_max = 200, delta = 0, design_type = "fixed", bounds = bnd1
)
expect_true(
  is.logical(one_trial$rejected),
  info = "rejected is a logical flag"
)
expect_true(
  one_trial$stop_n <= 200 && one_trial$stop_n >= 1,
  info = "stop_n is within [1, n_max]"
)

## Deterministic boundary crossing: force z_upper to 0 so the very
## first analysis always rejects.
always_reject_bounds <- list(z_upper = 0, info_frac = 1)
set.seed(2)
forced <- simulate_one_trial(
  n_max = 50, delta = 0, design_type = "fixed",
  bounds = always_reject_bounds
)
expect_true(
  forced$rejected,
  info = "z_upper = 0 forces rejection at n_max (sanity check on the crossing rule)"
)
expect_equal(
  forced$stop_n, 50,
  info = "single-look design stops at n_max when it rejects"
)

## run_hf_simulation ------------------------------------------------

set.seed(3)
hf_small <- run_hf_simulation(
  n_max = 40, delta = 0.5, n_reps = 50, k_values = c(3, 40)
)
expect_equal(
  nrow(hf_small), 2,
  info = "one row per k_value"
)
expect_true(
  all(hf_small$rejection_rate >= 0 & hf_small$rejection_rate <= 1),
  info = "rejection_rate is a valid probability"
)
expect_true(
  all(!is.na(hf_small$mean_n)),
  info = "mean_n is never NA (guards against a crashed/empty run)"
)
expect_true(
  all(hf_small$mean_n <= 40 & hf_small$mean_n >= 1),
  info = "mean_n is within [1, n_max]"
)
expect_true(
  all(hf_small$pct_saving >= -1e-8 & hf_small$pct_saving <= 100),
  info = "pct_saving is a percentage in [0, 100]"
)
expect_true(
  all(!is.na(hf_small$mcse_rejection)),
  info = "mcse_rejection is computed (not silently dropped)"
)

## run_simulation ---------------------------------------------------

set.seed(4)
main_small <- run_simulation(
  n_max = 40, effect_sizes = c(0, 0.8), n_reps = 50,
  designs = c("fixed", "fully_seq")
)
expect_equal(
  nrow(main_small), 4,
  info = "2 designs x 2 effect sizes = 4 rows"
)
expect_true(
  all(!is.na(main_small$rejection_rate)),
  info = "rejection_rate is never NA"
)
big_effect <- main_small |>
  dplyr::filter(effect_size == 0.8)
expect_true(
  big_effect$mean_n[big_effect$design == "Fully Seq"] <=
    big_effect$mean_n[big_effect$design == "Fixed"],
  info = paste(
    "fully sequential design stops no later, on average, than the",
    "fixed design at a large effect size"
  )
)
