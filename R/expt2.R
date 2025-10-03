get_expt2_prob_single <- function(n) {
  data <- matrix(rgamma(2 * n, 2, 2), n, 2)
  tibble(
    s1 = -dgamma(data[, 1], 2, 2, log = TRUE) -
      dgamma(data[, 2], 2, 2, log = TRUE),
    s2 = -dnorm(data[, 1], 1, 1 / sqrt(2), log = TRUE) -
      dnorm(data[, 2], 1, 1 / sqrt(2), log = TRUE),
    Empirical1 = rank(-s1) / n,
    GDP1 = weird:::surprisal_gpd_prob(s1, 0.10),
    Empirical2 = rank(-s2) / n,
    GDP2 = weird:::surprisal_gpd_prob(s2, 0.10),
  ) |>
    select(-s1, -s2) |>
    tidyr::pivot_longer(
      everything(),
      names_to = "Method",
      values_to = "prob"
    ) |>
    filter(prob <= 0.01) |>
    count(Method) |>
    rename(count = n)
}

get_expt2_prob <- function(n = 10^seq(2, 5, by = 0.1), nrep = 500) {
  purrr::pmap_dfr(
    tidyr::expand_grid(n = n, rep = seq(nrep)),
    function(n, rep) {
      get_expt2_prob_single(n) |> mutate(rep = rep, n = n)
    }
  )
}

create_fig_expt2 <- function(expt2_prob) {
  expt2_prob |>
    mutate(anomaly_rate = count / n) |>
    group_by(Method, n) |>
    summarise(anomaly_rate = mean(anomaly_rate), .groups = "drop") |>
    mutate(Method = recode(Method,
      Empirical1 = "Empirical (Gamma)",
      GDP1 = "GDP (Gamma)",
      Empirical2 = "Empirical (Gaussian)",
      GDP2 = "GDP (Gaussian)"
    )) |>
    ggplot(aes(x = n, y = anomaly_rate * 100, col = Method)) +
    geom_line() +
    geom_hline(aes(yintercept = 1)) +
    scale_x_log10() +
    labs(x = "Sample size n", y = "Anomaly rate")
}
