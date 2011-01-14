library(sp)
library(stringr)
library(plyr)
library(lubridate)

locations <- read.csv("../locations/locations.csv.bz2")
weather <- read.csv("weather-daily.csv")
weather$day <- ymd(weather$day)

deaths <- read.csv("../deaths/deaths08.csv.bz2")
deaths$locD <- with(deaths, str_c(statD, countyD, locationD, sep = "-"))
deaths <- merge(deaths, locations, by.x = "locD", by.y = "id", all.x = TRUE)
deaths <- subset(deaths, !is.na(lat))

# Find locations close (< 50 k) to simat
mmx_loc <- cbind(-99.06, 19.54)
death_loc <- cbind(deaths$long, deaths$lat)
dists <- spDistsN1(death_loc, mmx_loc, TRUE)

close <- deaths[dists < 50, ]
close <- subset(close, mod > 0 & dod > 0)
# 100,266  / 532,235 deaths.

# Create daily time series and merge with weather data -----------------------

daily <- count(close, c("mod", "dod"))
weather <- transform(weather, mod = month(day), dod = mday(day))
daily <- join(daily, weather)

daily <- daily[c("day", "mod", "dod", "freq", "temp_min", "temp_max", "temp_mean", "humidity", "wind", "NO", "NO2", "NOX", "O3", "CO", "SO2", "PM10", "PM25")]
names(daily)[4] <- "deaths"
write.csv(daily, "deaths-weather.csv", row.names = F)
