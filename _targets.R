library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("weird", "tsibble", "tibble")
)

# tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_quarto(
    paper,
    "surprisals.qmd",
    extra_files = c("refs.bib"),
    quiet = FALSE
  )
)
