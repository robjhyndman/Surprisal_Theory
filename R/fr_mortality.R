library(weird)


create_fr_mortality_plot <- function(fr_mortality) {
  fr_mortality |>
    ggplot(aes(x = Year, y = Mortality, color = Age, group = Age)) +
    geom_line() +
    facet_grid(. ~ Sex) +
    scale_y_log10(labels = scales::comma)
}

find_fr_anomalies <- function(fr_mortality) {
  fr_mortality |>
    group_by(Age, Sex) |>
    mutate(hampel = hampel_anomalies(Mortality, bandwidth = 7, k = 6)) |>
    ungroup() |>
    filter(hampel) |>
    arrange(Year, Age)
}

create_fr_anomaly_plot <- function(fr_anomalies) {
  yrs <- fr_anomalies |>
    select(Year, Sex) |>
    distinct()

  fr_anomalies_plot_male2 <- fr_anomalies |>
    filter(Sex == "Male") |>
    ggplot(aes(x = Year, y = Age)) +
    facet_grid(. ~ Sex) +
    scale_x_continuous(
      breaks = seq(1820, 2000, by = 20),
      limits = range(yrs$Year)
    ) +
    geom_vline(
      xintercept = unique(yrs$Year[yrs$Sex == "Male"]),
      alpha = 0.5,
      color = "grey"
    ) +
    geom_point(col = "#478cb2") +
    ggrepel::geom_text_repel(
      data = yrs |>
        filter(Sex == "Male", !Year %in% 1915:1918),
      aes(y = 75, label = Year),
      col = "#478cb2",
      size = 3,
      seed = 1967
    ) +
    ylim(4, 85)
  fr_anomalies_plot_female2 <- fr_anomalies |>
    filter(Sex == "Female") |>
    ggplot(aes(x = Year, y = Age)) +
    facet_grid(. ~ Sex) +
    scale_x_continuous(
      breaks = seq(1820, 2000, by = 20),
      limits = range(yrs$Year)
    ) +
    geom_vline(
      xintercept = unique(yrs$Year[yrs$Sex == "Female"]),
      alpha = 0.5,
      color = "grey"
    ) +
    labs(title = "French mortality anomalies") +
    geom_point(col = "#c1653a") +
    ggrepel::geom_text_repel(
      data = yrs[yrs$Sex == "Female", ],
      aes(y = 75, label = Year),
      col = "#c1653a",
      size = 3,
      seed = 1967
    ) +
    ylim(4, 85)
  patchwork::wrap_plots(
    fr_anomalies_plot_female2,
    fr_anomalies_plot_male2,
    nrow = 1
  )
}
