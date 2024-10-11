# Grab PRISM data for student use
library(prism)
library(tidyverse)

# Set directory for PRISM downloads
prism_set_dl_dir("prism_data/")

# Normals from 1981-2010
# get_prism_normals(type = "tmean",
#                   resolution = "4km",
#                   mon = 1:12,
#                   annual = FALSE,
#                   keepZip = FALSE)
# 
# get_prism_normals(type = "ppt",
#                   resolution = "4km",
#                   mon = 1:12,
#                   annual = FALSE,
#                   keepZip = FALSE)
# 
# get_prism_normals(type = "tmin",
#                   resolution = "4km",
#                   mon = 1:12,
#                   annual = FALSE,
#                   keepZip = FALSE)
# 
# get_prism_normals(type = "tmax",
#                   resolution = "4km",
#                   mon = 1:12,
#                   annual = FALSE,
#                   keepZip = FALSE)

# Stack products
pd_ras <- pd_stack(prism_archive_ls())
raster::crs(pd_ras)


# Import lat/lons

neon <- read_csv("NEON_Field_Site_Metadata_20241010.csv") |>
  select(field_site_id, field_latitude, field_longitude) |>
  rename(lat = field_latitude, lon = field_longitude) |>
  relocate(field_site_id, lon, lat) |>
  as_tibble() |>
  tibble::column_to_rownames(var = "field_site_id")

# Extract
env <- raster::extract(pd_ras, neon) |>
  data.frame() |>
  cbind(neon) |>
  tibble::rownames_to_column("field_site_id") |>
  pivot_longer(starts_with("PRISM"),
               names_to = "temp",
               values_to = "value") |>
  mutate(var = str_extract(temp, "_([^_]+)_"),
         month = str_extract(temp, "(\\d{2})_bil"),
         var = str_extract(var, "(?<=_)[a-zA-Z]+(?=_)"),
         month = str_extract(month, "\\d{2}") |>
           as.numeric()) |>
  filter(var %in% c("ppt", "tmean"))

# Save
write_csv(env, "PRISM_env_NEON.csv")
