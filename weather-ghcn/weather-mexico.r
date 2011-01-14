library(stringr)
library(reshape2)
library(plyr)
source("read-fwf.r")
options(stringsAsFactors = FALSE)

# Define format for fixed width file

cols <- data.frame(
  name =  c("id", "year", "month", "element"),
  start = c(1,     12,    16,      18),
  end =   c(11,    15,    17,      21))


names <- str_c(c("value", "mflag", "qflag", "sflag"), rep(1:31, each = 4), sep = "_")
starts <- cumsum(c(22, rep(c(5, 1, 1, 1), 31)))
starts <- starts[-length(starts)]
ends <- c(starts[-1], starts[length(starts)] + 1) - 1

values <- data.frame(name = names, start = starts, end = ends)
cols <- rbind(cols, values)


# Find maximum year for each station
mx <- read.csv("weather-stations-mx.csv")
base_url <- "http://www1.ncdc.noaa.gov/pub/data/ghcn/daily/all/"
mx$url <- str_c(base_url, mx$id, ".dly")

mx$year <- unlist(llply(1:nrow(mx), function(i) max(read.fwf2(mx$url[i], subset(cols, name == "year"))$year), .progress = "text"))

write.csv(mx, "weather-stations-mx.csv", row.names = FALSE)
# Only 16 stations with data up to 2010

# Collect all data

raw <- ldply(mx$url[mx$year == 2010], read.fwf2,  cols)
raw <- subset(raw, year >= 2005) 
weatherm <- melt(raw, id = 1:4)
weatherm$day <- as.numeric(str_replace_all(weatherm$variable, "[^0-9]",""))
weatherm$variable <- str_replace_all(weatherm$variable, "[^a-z]","")

weatherm <- subset(weatherm, variable == "value" && value != -9999)
weatherm$variable <- NULL
weatherm$element <- tolower(weatherm$element)
weatherm$value <- as.numeric(weatherm$value)

weather <- dcast(weatherm, ... ~ element)
weather$snwd <- NULL # remove snow because so rare
weather$tmin <- weather$tmin / 10 # convert to C
weather$tmax <- weather$tmax / 10 # convert to C
weather$prcp <- weather$prcp / 100 # convert to cm

write.csv(weather, "weather-mx.csv", row.names = FALSE)