library(weird)

get_expt1_prob <- function(y) {
  tibble(
    y = y,
    p = surprisals(y, distribution = dist_normal()),
    p_gpd = surprisals(y, distribution = dist_normal(), approximation = "gpd"),
    pt = surprisals(y, distribution = dist_student_t(4)),
    pt_gpd = surprisals(
      y,
      distribution = dist_student_t(4),
      approximation = "gpd"
    )
  )
}

create_fig_expt1 <- function(norm, t4) {
  bind_rows(
    norm |> get_expt1_prob() |> mutate(Model = "Normal"),
    t4 |> get_expt1_prob() |> mutate(Model = "t(4)")
  ) |>
    filter(y > 2.5) |>
    tidyr::pivot_longer(
      p:pt_gpd,
      names_to = "Estimate",
      values_to = "Probability"
    ) |>
    mutate(
      Estimate = factor(
        Estimate,
        levels = c("p", "p_gpd", "pt", "pt_gpd"),
        labels = c(
          "Normal",
          "Normal + GPD",
          "t(4)",
          "t(4) + GPD"
        )
      )
    ) |>
    ggplot(aes(x = y, y = Probability, col = Estimate)) +
    geom_line() +
    facet_wrap(~Model, scales = "free_x") +
    theme(legend.position = "bottom")
}
