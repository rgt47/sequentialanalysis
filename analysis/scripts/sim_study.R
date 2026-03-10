library(gsDesign)
library(dplyr)
library(tidyr)
library(purrr)

compute_boundaries <- function(k, n_max, alpha = 0.05) {
  if (k == 1) {
    return(list(
      z_upper = qnorm(1 - alpha / 2),
      info_frac = 1
    ))
  }
  info_frac <- seq(1 / k, 1, length.out = k)
  des <- gsDesign(
    k = k,
    test.type = 2,
    alpha = alpha / 2,
    sfu = sfLDOF,
    timing = info_frac
  )
  list(
    z_upper = des$upper$bound,
    info_frac = info_frac
  )
}

simulate_one_trial <- function(n_max, delta, sigma = 1,
                               design_type, bounds) {
  z_upper <- bounds$z_upper
  info_frac <- bounds$info_frac
  k <- length(info_frac)
  analysis_n <- round(info_frac * n_max)
  analysis_n[k] <- n_max

  y_trt <- rnorm(n_max, mean = delta, sd = sigma)
  y_ctl <- rnorm(n_max, mean = 0, sd = sigma)

  cum_diff <- cumsum(y_trt - y_ctl)
  cum_var <- (1:n_max) * 2 * sigma^2
  cum_z <- cum_diff / sqrt(cum_var)

  rejected <- FALSE
  stop_n <- n_max
  stop_frac <- 1


  for (j in seq_along(analysis_n)) {
    idx <- analysis_n[j]
    z_val <- cum_z[idx]
    if (abs(z_val) >= z_upper[j]) {
      rejected <- TRUE
      stop_n <- idx
      stop_frac <- info_frac[j]
      break
    }
  }

  tibble(
    rejected = rejected,
    stop_n = stop_n,
    stop_fraction = stop_frac
  )
}

run_simulation <- function(n_max = 200,
                           effect_sizes = c(0, 0.2,
                             0.5, 0.8),
                           n_reps = 2000,
                           designs = c("fixed", "gs3",
                             "gs5", "fully_seq")) {
  design_specs <- list(
    fixed = list(k = 1, label = "Fixed"),
    gs3 = list(k = 3, label = "GS (K=3)"),
    gs5 = list(k = 5, label = "GS (K=5)"),
    fully_seq = list(k = n_max, label = "Fully Seq")
  )

  design_specs <- design_specs[designs]

  bounds_list <- map(design_specs, function(spec) {
    compute_boundaries(spec$k, n_max)
  })

  results <- expand_grid(
    design = designs,
    effect_size = effect_sizes
  ) |>
    mutate(sim_out = map2(design, effect_size,
      function(d, es) {
        bnd <- bounds_list[[d]]
        reps <- map_dfr(seq_len(n_reps), function(i) {
          simulate_one_trial(
            n_max = n_max,
            delta = es,
            design_type = d,
            bounds = bnd
          )
        })
        tibble(
          rejection_rate = mean(reps$rejected),
          mean_n = mean(reps$stop_n),
          median_n = median(reps$stop_n),
          stop_fractions = list(reps$stop_fraction)
        )
      })) |>
    unnest(sim_out) |>
    mutate(design = map_chr(design, function(d) {
      design_specs[[d]]$label
    }))

  results
}
