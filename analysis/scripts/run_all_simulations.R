## Standalone driver for the report's simulation results.
##
## Remediation for whitepaper M6: knitr's cache=TRUE chunks do not
## replay RNG state, so a cached `sim-run` combined with a fresh
## `hf-sim` (or vice versa) silently changes the random stream that
## generated the appendix results. This script removes that
## dependency: it sets the seed once, runs every simulation the
## report uses, and writes versioned .rds files that the Rmd reads
## with plain `readRDS()` (no cache). Re-running this script is the
## only way to regenerate the report's numbers; the Rmd itself no
## longer draws any random numbers.
##
## Usage: Rscript analysis/scripts/run_all_simulations.R

suppressMessages({
  library(gsDesign)
  library(dplyr)
  library(tidyr)
  library(purrr)
})

here_root <- rprojroot::find_root(rprojroot::has_file("DESCRIPTION"))
source(file.path(here_root, "analysis", "scripts", "sim_study.R"))

seed <- 20260309
RNGkind("L'Ecuyer-CMRG")
set.seed(seed)

out_dir <- file.path(
  here_root, "analysis", "data", "derived_data"
)
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## Main factorial simulation (Methods: Simulation Procedure).
sim_results <- run_simulation(
  n_max = 200,
  effect_sizes = c(0, 0.2, 0.5, 0.8),
  n_reps = 2000,
  designs = c("fixed", "gs3", "gs5", "fully_seq")
)

## Whitepaper M4: the type I error table used the same n_rep = 2000
## null-scenario draws as the power scenarios, giving an MCSE of
## about 0.0049 at p = 0.05, too wide to distinguish the fully
## sequential design's 0.039 from nominal. Rerun delta = 0 alone at
## n_rep = 20000 (MCSE about 0.0015) so the type I error table is
## precise enough to support a "held within tolerance" claim (or to
## show that it does not hold).
sim_results_null <- run_simulation(
  n_max = 200,
  effect_sizes = 0,
  n_reps = 20000,
  designs = c("fixed", "gs3", "gs5", "fully_seq")
)

## Whitepaper M1: the main grid at n_max = 200 gives essentially
## saturated power (0.999-1.000) at delta = 0.5 and 0.8, a regime
## that mechanically inflates ASN savings for sequential designs.
## Add a scenario sized so the fixed design has approximately 90%
## power at delta = 0.5 (n_max chosen from the two-sample normal
## mean formula: n = 2 * (z_(alpha/2) + z_beta)^2 / delta^2).
za <- qnorm(1 - 0.05 / 2)
zb <- qnorm(0.9)
n90 <- ceiling(2 * (za + zb)^2 / 0.5^2)

sim_results_90pow <- run_simulation(
  n_max = n90,
  effect_sizes = 0.5,
  n_reps = 2000,
  designs = c("fixed", "gs3", "gs5", "fully_seq")
)

## High-frequency (K-grid) appendix simulation, at the original
## overpowered n_max = 200 and at the 90%-power n_max for
## comparison, per M1.
hf_results <- run_hf_simulation(
  n_max = 200,
  delta = 0.5,
  n_reps = 2000,
  k_values = c(3, 5, 10, 20, 50, 200)
)

hf_results_90pow <- run_hf_simulation(
  n_max = n90,
  delta = 0.5,
  n_reps = 2000,
  k_values = c(3, 5, 10, 20, 50, n90)
)

metadata <- list(
  seed = seed,
  rngkind = RNGkind(),
  n90 = n90,
  r_version = R.version.string,
  package_versions = vapply(
    c(
      "gsDesign", "dplyr", "tidyr", "purrr", "ggplot2",
      "knitr", "kableExtra", "rmarkdown"
    ),
    function(p) as.character(utils::packageVersion(p)),
    character(1)
  ),
  generated_at = Sys.time()
)

saveRDS(sim_results, file.path(out_dir, "sim_results.rds"))
saveRDS(sim_results_null, file.path(out_dir, "sim_results_null.rds"))
saveRDS(
  sim_results_90pow, file.path(out_dir, "sim_results_90pow.rds")
)
saveRDS(hf_results, file.path(out_dir, "hf_results.rds"))
saveRDS(
  hf_results_90pow, file.path(out_dir, "hf_results_90pow.rds")
)
saveRDS(metadata, file.path(out_dir, "sim_metadata.rds"))

cat("Wrote simulation outputs to", out_dir, "\n")
cat("n90 (90% power design point) =", n90, "\n")
