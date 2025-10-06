read_stmf_data <- function(file) {
  file |>
    read.csv(header = TRUE) |>
    # Create time index varaible
    mutate(Week = yearweek(paste0(Year, "-W", Week))) |>
    # Consider only data to 2024, sexes combined, and omit last week due to reporting delays
    filter(Week < yearweek("2025 W01"), Sex == "b", Week < max(Week) - 1) |>
    # Fix column names
    select(Week, `X0.14.1`:`X85..1`) |>
    rename(
      "0-14" = `X0.14.1`,
      "15-64" = `X15.64.1`,
      "65-74" = `X65.74.1`,
      "75-84" = `X75.84.1`,
      "85+" = `X85..1`,
    ) |>
    # Create a tsibble object
    tidyr::pivot_longer(
      -Week,
      names_to = "Age group",
      values_to = "Mortality"
    ) |>
    as_tsibble(index = Week, key = `Age group`)
}

create_stmf_plot <- function(us_stmf) {
  us_stmf |>
    ggplot(aes(x = Week, y = Mortality)) +
    geom_line() +
    facet_grid(`Age group` ~ ., scales = "free_y") +
    labs(y = "Mortality rate")
}

us_stmf_pca <- function(us_stmf) {
  us_wide <- us_stmf |>
    as_tibble() |>
    mutate(logm = log(Mortality)) |>
    tidyr::pivot_wider(
      id_cols = Week,
      names_from = `Age group`,
      values_from = logm
    )
  # Compute 1 principal component from mortality rates
  us_wide |>
    select(-Week) |>
    prcomp(rank = 1) |>
    broom::augment(us_wide |> select(Week))
}

get_stmf_anomalies <- function(pcs) {
  pcs |>
    as_tsibble(index = Week) |>
    model(stl = STL(.fittedPC1, robust = TRUE)) |>
    augment() |>
    select(-.model, -.innov) |>
    mutate(
      prob = surprisals(
        .resid,
        distribution = dist_normal(),
        approximation = "gpd"
      )
    )
}

create_stmf_anomaly_plot <- function(pc_anomalies) {
  df <- pc_anomalies |>
    as_tibble() |>
    select(Week, prob, .fittedPC1, .resid) |>
    tidyr::pivot_longer(
      .fittedPC1:.resid,
      names_to = "Series",
      values_to = "value"
    ) |>
    mutate(
      Series = recode(Series, .fittedPC1 = "PC Score", .resid = "Remainder")
    )
  df |>
    ggplot(aes(x = Week, y = value)) +
    geom_line() +
    facet_grid(Series ~ .) +
    labs(y = "First principal component scores") +
    geom_point(data = df |> dplyr::filter(prob < 0.05), color = "red")
}
