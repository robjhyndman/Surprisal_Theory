library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("weird", "tsibble", "tibble")
)
tar_option_set(seed = 2025)

tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
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
  tar_quarto(
    paper,
    "surprisals.qmd",
    extra_files = c("refs.bib"),
    quiet = FALSE
  )
)
