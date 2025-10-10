library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("weird", "tsibble", "tibble", "feasts")
)
tar_option_set(seed = 2025)

tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  # Experiment 1
  tar_target(
    norm_data,
    rnorm(1000)
  ),
  tar_target(
    t4_data,
    rt(1000, df = 4)
  ),
  tar_target(
    fig_expt1,
    create_fig_expt1(norm_data, t4_data)
  ),
  # Experiment 2
  tar_target(
    expt2_prob,
    get_expt2_prob()
  ),
  tar_target(
    fig_expt2,
    create_fig_expt2(expt2_prob)
  ),
  tar_target(
    gpd_shape_estimates,
    get_gpd_shape()
  ),
  # French mortality
  tar_target(
    fr_mortality,
    weird::fr_mortality
  ),
  tar_target(
    fr_mortality_plot,
    create_fr_mortality_plot(fr_mortality)
  ),
  tar_target(
    fr_anomalies,
    find_fr_anomalies(fr_mortality)
  ),
  tar_target(
    fr_anomaly_plot,
    create_fr_anomaly_plot(fr_anomalies)
  ),

  # Cricket not-outs
  tar_target(
    cricket_batting,
    weird::cricket_batting
  ),
  tar_target(
    not_outs,
    cricket_batting |>
      filter(Innings > 0) |>
      mutate(prop_no = NotOuts / Innings)
  ),
  tar_target(
    fit_no,
    fit_notouts(not_outs)
  ),
  tar_target(
    notouts_aug,
    augment_notouts(fit_no, not_outs)
  ),
  tar_target(
    not_outs_plot,
    create_notouts_plot(notouts_aug)
  ),

  # Paper
  tar_quarto(
    paper,
    "surprisals.qmd",
    extra_files = c("refs.bib"),
    quiet = FALSE
  )
)
