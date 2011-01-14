library(stringr)
source("read-fwf.r")

cols <- read.table(textConnection("ID            1-11   Character
LATITUDE     13-20   Real
LONGITUDE    22-30   Real
ELEVATION    32-37   Real
STATE        39-40   Character
NAME         42-71   Character
GSNFLAG      73-75   Character
HCNFLAG      77-79   Character
WMOID        81-85   Character"))
names(cols) <- c("name", "pos", "type")
cols$name <- tolower(cols$name)
pos <- str_split_fixed(cols$pos, "-", 2)
cols$pos <- NULL
cols$start <- as.numeric(pos[, 1])
cols$end <- as.numeric(pos[, 2])

stations <- read.fwf2("weather-stations.txt", cols)

mx <- subset(stations, str_sub(id, 1, 2) == "MX")[, c(1:4, 6)]
map("world", "mexico")
points(mx$longitude, mx$latitude)


write.csv(mx, "weather-stations-mx.csv", row.names = FALSE)