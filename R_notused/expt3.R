library(weird)

mix_dist <- dist_mixture(
  dist_normal(mean = 0),
  dist_normal(mean = 8),
  weights = c(0.5, 0.5)
)
y_df <- tibble(
  y = c(4, generate(mix_dist, 999)[[1]]),
  True = surprisals_prob(
    y,
    distribution = mix_dist
  ),
  Empirical = surprisals_prob(
    y,
    distribution = dist_normal(mean = 4),
    approximation = "empirical"
  ),
  GPD = surprisals_prob(
    y,
    distribution = dist_normal(mean = 4),
    approximation = "gpd"
  ),
)

y_df |>
  tidyr::pivot_longer(
    True:GPD,
    names_to = "Surprisal probability",
    values_to = "prob"
  ) |>
  ggplot(aes(x = y, y = prob, col = `Surprisal probability`)) +
  geom_line() +
  geom_rug(aes(x = y, y = NULL), color = "grey50")
