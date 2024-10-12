#  Wrangle Js and D data
library(tidyverse)

# Load .Rdata files
load("sapflow_data/Js_daily_sum.Rdata")
load("sapflow_data/Dmean.Rdata")

# make Dmean long
Dlong <- Dmean_out |>
  pivot_longer(cols = Jordan:Upper,
               names_to = "site",
               values_to = "Dmean")

# Left join with Js data
Js <- Js_sum |>
  left_join(Dlong, by = join_by(site, date))|>
  relocate(doy, .after = date)

# Write to main folder as .csv
write_csv(Js, "riparian_sapflow.csv")
