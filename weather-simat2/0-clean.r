# 2008 data downloaded "Sistema de Monitoreo Atmosférico de la Ciudad de
#' México", the Atmospheric Monitoring System Mexico City.
# http://www.sma.df.gob.mx/simat2/informaciontecnica/
#  index.php?opcion=5&opciondifusion_bd=10

library(plyr)
library(stringr)
library(lubridate)

files <- setdiff(dir(pattern = "\\.csv"), "weather-daily.csv")
names(files) <- str_replace(files, fixed(".csv"), "")
contents <- llply(files, read.csv)

three <- llply(contents, function(x) x[, 1:3])
three <- llply(three, transform, FECHA = dmy(FECHA))

for(var in names(three)) {
  names(three[[var]])[3] <- var
}

hourly <- Reduce(function(x, y) merge(x, y, by = c("FECHA", "HORA"), all = T),
  three[-1], three[[1]])
names(hourly)[1:2] <- c("day", "hour")
hourly[hourly < 0] <- NA

daily <- ddply(hourly, "day", summarise,
  temp_min = min(temp, na.rm = TRUE), 
  temp_max = max(temp, na.rm = TRUE), 
  temp_mean = mean(temp, na.rm = TRUE),
  humidity = mean(humidity), 
  wind = mean(`wind-speed`, na.rm = TRUE), 
  NO = mean(NO), NO2 = mean(NO2), NOX = mean(NOX), 
  O3 = mean(o3), CO = mean(CO), SO2 = mean(SO2),
  PM10 = mean(PM10), PM25 = mean(PM10))

daily[daily == Inf | daily == -Inf] <- NA
write.csv(daily, "weather-daily.csv", row.names = F)