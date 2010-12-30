library(stringr)
options(stringsAsFactors = FALSE)

# Data from census
locations <- read.csv("locations-raw.csv.bz2")
locations <- locations[, c("LOC", "MUN", "ENT", "NOMLOC", "LAT",
  "LONG", "ALTITUD")]
names(locations) <- c("loc", "muni", "state", "name", "lat", "long", "altitude")

# Figure out which locations are actually used in the data
locations$id <- with(locations, str_c(state, muni, loc, sep = "-"))

deaths <- read.csv("../deaths/deaths08.csv.bz2")
locationL <- with(deaths, str_c(stateL, countyL, locationL, sep = "-"))
locationD <- with(deaths, str_c(statD, countyD, locationD, sep = "-"))

used <- sort(unique(c(locationL, locationD)))
used_locations <- locations[locations$id %in% used, ]

write.csv(used_locations, bzfile("locations.csv.bz2"), row.names = FALSE)