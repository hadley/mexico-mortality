library(stringr)
options(stringsAsFactors = FALSE)

locations <- read.csv("locations-raw.csv.bz2")
locations <- locations[, c(8, 4, 1, 9:12)]
names(locations) <- c("loc", "muni", "state", "name", "lat", "long", "altitude")

# Convert latitude and longitude to decimal specifications
locations$lat <- with(locations, as.numeric(str_sub(lat, 1, 2)) + as.numeric(str_sub(lat, 3, 4)) / 60 + as.numeric(str_sub(lat, 5, 6)) / 3600)

locations$long <- format(locations$long, width = 7)
locations$long <- with(locations, -as.numeric(str_sub(long, 1, 3)) + as.numeric(str_sub(long, 4, 5)) / 60 + as.numeric(str_sub(long, 6, 7)) / 3600)

# Figure out which locations are actually used in the data
locations$id <- with(locations, str_c(state, muni, loc, sep = "-"))

deaths <- read.csv("../deaths/deaths08.csv.bz2")
locationL <- with(deaths, str_c(stateL, countyL, locationL, sep = "-"))
locationD <- with(deaths, str_c(statD, countyD, locationD, sep = "-"))

used <- sort(unique(c(locationL, locationD)))
used_locations <- locations[locations$id %in% used, ]
# Still some artifacts in locations?
with(used_locations, plot(long, lat, pch = "."))

write.csv(used_locations, bzfile("locations.csv.bz2"), row.names = FALSE)