# Marvel Ultimate Alliance 3 team optimizer

## Dependencies

```R
install.packages(c(
  "magrittr", "janitor", "assertthat",
  "dplyr", "tidyr", "purrr", "readr",
  "shiny", "shinythemes", "DT"
))
```

## Setup

1. Run [misc/data.R](misc/data.R) first to populate mua3-app/data directory with the required rds files.
2. `shiny::runApp("mua3-app")`

## Structure

- The aforementioned data script processes [raw data](misc/raw/)
- [utils.R](mua3-app/utils.R) has the following functions:
  - `calculate_bonuses` accepts a character vector of **4** names and outputs a data frame of stats and their bonuses
  - `potential_bonuses` accepts a character vector of **3** names and runs `calculate_bonuses` with each of the remaining heroes
  - `produce_recommendations` accepts a character vector of **3** names and produces recommendations based on their potential bonuses
