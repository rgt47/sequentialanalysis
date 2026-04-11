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

## Architecture

- `R/` - Package source (empty; functions to be extracted from analysis scripts)
- `analysis/scripts/sim_study.R` - Core simulation: boundary computation via alpha spending, trial simulation, and efficiency comparison across designs and effect sizes
- `analysis/report/report.Rmd` - Research manuscript with embedded simulation results, compiled to PDF
- `analysis/data/` - Raw and derived data directories (currently empty)
- `tests/testthat/` - testthat v3 tests (single placeholder test)

## Key Dependencies

- **In renv.lock:** renv, testthat
- **Used in scripts but not yet in renv.lock:** gsDesign, dplyr, tidyr, purrr

## Testing

testthat 3rd edition. CI runs via GitHub Actions (`.github/workflows/r-package.yml`) on push/PR to main, using `rocker/tidyverse:latest`.

## Docker Environment

- Base image: `rocker/tidyverse:4.5.2`
- R 4.5.2, Quarto 1.6.43
- Non-root user `analyst`, project mounted at `/home/analyst/project`
- renv auto-snapshots on container exit
