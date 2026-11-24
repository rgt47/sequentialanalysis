library(gsDesign)
library(dplyr)
library(tidyr)
library(purrr)

look_schedule <- function(k, n_max) {
  look_n <- round(seq(1 / k, 1, length.out = k) * n_max)
  look_n[k] <- n_max
  stopifnot(!anyDuplicated(look_n), all(look_n >= 1))
  look_n
}

# Exact operating characteristics by recursive numerical integration
# (Jennison and Turnbull 2000), using the same boundaries
# as the simulation. The two-sample z-statistic after n pairs has
# mean (delta / sqrt(2 sigma^2)) sqrt(n), so theta = delta / sqrt(2)
# with information measured in pairs. gsProbability() caps k at 30,
# so the internal integrator gsprob() is called directly. A finer
# grid (r = 80, default 18) is needed at k = n_max, where r = 18
# returns invalid probabilities for large drifts. At r = 80 the
# results agree with r = 40 to within 1e-5 in rejection probability
# and 0.001 pairs in expected sample size. `overrun` is the
# number of pipeline pairs enrolled but not yet observed at each
# interim look; it inflates expected enrollment, not the decision.
exact_oc <- function(k, n_max, delta, sigma = 1, alpha = 0.05,
                     overrun = 0, r = 80) {
  bnd <- compute_boundaries(k, n_max, alpha = alpha)
  look_n <- look_schedule(k, n_max)
  b <- bnd$z_upper
  p <- gsDesign:::gsprob(
    theta = delta / (sigma * sqrt(2)), I = look_n,
    a = -b, b = b, r = r, overrun = overrun
  )
  prob_stop <- as.vector(p$probhi + p$problo)
  stopifnot(all(prob_stop >= -1e-12), sum(prob_stop) <= 1 + 1e-5)
  tibble(
    k = k,
    n_max = n_max,
    delta = delta,
    overrun = overrun,
    reject = sum(prob_stop),
    reject_lower = sum(p$problo),
    expected_n = p$en
  )
}

compute_boundaries <- function(k, n_max, alpha = 0.05) {
  if (k == 1) {
    return(list(
      z_upper = qnorm(1 - alpha / 2),
      info_frac = 1
    ))
  }
  # Boundaries are computed at the realized information fractions
  # (rounded pair counts over n_max), not the nominal 1/k grid, so
  # that each boundary matches the look at which it is applied.
  # round(info_frac * n_max) in the simulators recovers look_n.
  look_n <- look_schedule(k, n_max)
  info_frac <- look_n / n_max
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

simulate_one_trial_detailed <- function(n_max, delta,
                                       sigma = 1,
                                       bounds) {
  z_upper <- bounds$z_upper
  info_frac <- bounds$info_frac
  k <- length(info_frac)
  analysis_n <- round(info_frac * n_max)
  analysis_n[k] <- n_max

  y_trt <- rnorm(n_max, mean = delta, sd = sigma)
  y_ctl <- rnorm(n_max, mean = 0, sd = sigma)

  cum_sum_trt <- cumsum(y_trt)
  cum_sum_ctl <- cumsum(y_ctl)
  cum_diff <- cum_sum_trt - cum_sum_ctl
  cum_var <- (1:n_max) * 2 * sigma^2
  cum_z <- cum_diff / sqrt(cum_var)

  rejected <- FALSE
  stop_n <- n_max
  stop_frac <- 1
  mle_at_stop <- cum_diff[n_max] / n_max

  for (j in seq_along(analysis_n)) {
    idx <- analysis_n[j]
    z_val <- cum_z[idx]
    if (abs(z_val) >= z_upper[j]) {
      rejected <- TRUE
      stop_n <- idx
      stop_frac <- info_frac[j]
      mle_at_stop <- cum_diff[idx] / idx
      break
    }
  }

  final_mle <- cum_diff[n_max] / n_max

  tibble(
    rejected = rejected,
    stop_n = stop_n,
    stop_fraction = stop_frac,
    mle_at_stop = mle_at_stop,
    final_mle = final_mle
  )
}

run_hf_simulation <- function(n_max = 200,
                              delta = 0.5,
                              n_reps = 2000,
                              k_values = c(3, 5, 10,
                                20, 50, 200)) {
  # Morris et al. (2019) Table 6: Monte Carlo SEs accompany every
  # performance estimate. The caller sets the seed once, so the
  # replications across k_values draw from a single shared stream.
  results <- map_dfr(k_values, function(k) {
    bnd <- compute_boundaries(k, n_max)
    reps <- map_dfr(seq_len(n_reps), function(i) {
      simulate_one_trial_detailed(
        n_max = n_max,
        delta = delta,
        bounds = bnd
      )
    })

    bias_naive <- mean(reps$mle_at_stop) - delta
    rmse_naive <- sqrt(mean((reps$mle_at_stop - delta)^2))
    rej <- mean(reps$rejected)

    # Guards: mcse_rmse_naive needs rmse_naive > 0 and n_reps >= 1.
    mcse_rmse_val <- if (n_reps >= 1 && rmse_naive > 0) {
      sqrt(
        stats::var((reps$mle_at_stop - delta)^2) / n_reps
      ) / (2 * rmse_naive)
    } else NA_real_

    tibble(
      k = k,
      label = ifelse(k == n_max, "Fully Seq",
        paste0("K=", k)),
      n_reps = n_reps,
      rejection_rate = rej,
      mcse_rejection = sqrt(rej * (1 - rej) / n_reps),
      mean_n = mean(reps$stop_n),
      mcse_mean_n = stats::sd(reps$stop_n) / sqrt(n_reps),
      median_n = stats::median(reps$stop_n),
      sd_n = stats::sd(reps$stop_n),
      mean_mle = mean(reps$mle_at_stop),
      bias_naive = bias_naive,
      mcse_bias_naive = stats::sd(reps$mle_at_stop) /
        sqrt(n_reps),
      rmse_naive = rmse_naive,
      mcse_rmse_naive = mcse_rmse_val,
      pct_saving = (1 - mean(reps$stop_n) /
        n_max) * 100
    )
  })
  results
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
  # Morris et al. (2019) Table 6: Monte Carlo SEs are attached to
  # every reported performance estimate below.
  design_specs <- list(
    fixed = list(k = 1, label = "Fixed"),
    gs3 = list(k = 3, label = "GS (K=3)"),
    gs5 = list(k = 5, label = "GS (K=5)"),
    gs10 = list(k = 10, label = "GS (K=10)"),
    gs20 = list(k = 20, label = "GS (K=20)"),
    gs50 = list(k = 50, label = "GS (K=50)"),
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
        rej <- mean(reps$rejected)
        tibble(
          n_reps = n_reps,
          rejection_rate = rej,
          mcse_rejection = sqrt(rej * (1 - rej) / n_reps),
          mean_n = mean(reps$stop_n),
          mcse_mean_n = stats::sd(reps$stop_n) /
            sqrt(n_reps),
          median_n = stats::median(reps$stop_n),
          stop_fractions = list(reps$stop_fraction)
        )
      })) |>
    unnest(sim_out) |>
    mutate(design = map_chr(design, function(d) {
      design_specs[[d]]$label
    }))

  results
}
