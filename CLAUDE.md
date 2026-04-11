# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`sequentialanalysis` is an R package (v0.0.0.9000) providing group sequential and adaptive design methods for clinical trial interim analyses. Currently in early development: the `R/` directory has no exported functions yet. Primary work is in `analysis/` (simulation scripts and a research report).

The core simulation study (`analysis/scripts/sim_study.R`) compares fully sequential monitoring against group sequential designs using the `gsDesign` package. The research report (`analysis/report/report.Rmd`) compiles to PDF via xelatex.

## Build and Development Commands

This project uses a Docker-first workflow via zzcollab (v2.2.0). Key Makefile targets:

```bash
make r                  # Start bash terminal in Docker container
make docker-build       # Build the Docker image
make check-renv         # Validate renv dependencies (auto-fix)
make test               # Run testthat tests (native R)
make docker-test        # Run testthat tests (in container)
make document           # Generate roxygen2 docs
make check              # R CMD check --as-cran
make docker-check       # R CMD check in container
```

To run a single test file:
```bash
Rscript -e 'testthat::test_file("tests/testthat/test-basic.R")'
```

To render the report:
```bash
cd analysis/report && Rscript -e 'rmarkdown::render("report.Rmd")'
```

Report uses knitr caching (`report_cache/`) and generates figures to `report_files/figure-latex/`. Delete these directories to force a full re-render.

## Architecture

- `R/` - Package source (empty; functions to be extracted from analysis scripts)
- `analysis/scripts/sim_study.R` - Core simulation: boundary computation via alpha spending, trial simulation, and efficiency comparison across designs and effect sizes
- `analysis/report/report.Rmd` - Research manuscript with embedded simulation results, compiled to PDF
- `analysis/data/` - Raw and derived data directories (currently empty)
- `tests/testthat/` - testthat v3 tests (single placeholder test)

### Simulation Study Functions (sim_study.R)

The simulation script defines four main functions in a specific dependency order:

1. `compute_boundaries(k, n_max, alpha)` - Computes z-statistic boundaries using `gsDesign::gsDesign()` with Lan-DeMets O'Brien-Fleming alpha spending. Handles both fixed (k=1) and group sequential designs.
2. `simulate_one_trial_detailed(n_max, delta, sigma, bounds)` - Single trial simulation with full tracking: cumulative z-statistics, stopping stage, MLE at stop vs final MLE.
3. `run_hf_simulation(n_max, delta, n_reps, k_values)` - High-fidelity comparison across k values (3, 5, 10, 20, 50, fully sequential). Returns rejection rate, mean/median N, bias, RMSE, sample size savings.
4. `run_simulation(n_max, effect_sizes, n_reps, designs)` - Factorial simulation across multiple designs and effect sizes. Returns nested tibble.

## Key Dependencies

- **In renv.lock:** renv, testthat
- **Used in scripts but not yet in renv.lock:** gsDesign, dplyr, tidyr, purrr

These missing packages are available in the Docker base image (`rocker/tidyverse`) so they work in-container, but need to be added to renv.lock via `renv::snapshot()` for proper reproducibility.

## Testing

testthat 3rd edition. CI runs via GitHub Actions (`.github/workflows/r-package.yml`) on push/PR to main, using `rocker/tidyverse:latest`.

## Docker Environment

- Base image: `rocker/tidyverse:4.5.2`
- R 4.5.2, Quarto 1.6.43
- Non-root user `analyst`, project mounted at `/home/analyst/project`
- renv auto-snapshots on container exit (skipped in CI)
- `.Rprofile` handles container detection via `ZZCOLLAB_CONTAINER` env var and configures renv accordingly; host R skips renv entirely
