# With help from Diego Valle - thanks!
options(stringsAsFactors = FALSE)
library(ggplot2)
library(stringr)
library(rgdal)
library(maptools)
gpclibPermit()

# The maps come from INEGI: http://mapserver.inegi.org.mx/data/mgm/
#  * States: 
#    http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=ESTADOS41
#  * Municipalities: 
#    http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=MUNICIPIOS41
# 
# These are saved as maps/ESTADOS-orig and maps/MUNICIPIOS-orig.
# Polygon generalisation performed by mapshaper.org to produce
# maps/ESTADOS and maps/MUNICIPIOS.
state <- readOGR("maps/ESTADOS.shp", "ESTADOS")
muni <- readOGR("maps/MUNICIPIOS.shp", "MUNICIPIOS")

# Tranform the weird coordinates system the INEGI uses to something standard
# Projection information described in "Norma Técnica NTG - 013 - 2006 Edición
# de Cartografía Topográfica", saved as projection-info.pdf 

state <- spTransform(state, CRS("+proj=longlat +ellps=WGS84"))
muni <- spTransform(muni, CRS("+proj=longlat +ellps=WGS84"))

# Extract and clean meta data -----------------------------------------------

to_ascii <- function(x) {
  ascii <- iconv(x, "latin1", "ASCII//TRANSLIT")
  str_replace_all(ascii, ignore.case("[^A-Z ]"), "")
}

state_meta <- as.data.frame(state)
names(state_meta) <- c("state", "name")
state_meta$name <- to_ascii(state_meta$name)
state_meta$state <- as.numeric(state_meta$state)

write.csv(state_meta, "state-meta.csv", row.names = FALSE)
state@data <- state_meta

muni_meta <- as.data.frame(muni)
names(muni_meta) <- c("state", "muni", "name")
muni_meta$name <- to_ascii(muni_meta$name)
muni_meta$state <- as.numeric(muni_meta$state)
muni_meta$muni <- as.numeric(muni_meta$muni)
muni_meta$muni <- with(muni_meta, paste(state, muni, sep = "-"))
write.csv(muni_meta, "muni-meta.csv", row.names = FALSE)
muni@data <- muni_meta

# Convert maps to csv --------------------------------------------------------

state_map <- fortify(state, region = "state")
muni_map <- fortify(muni, region = "muni")

write.csv(state_map, bzfile("state-map.csv.bz2"), row.names = FALSE)
write.csv(muni_map, bzfile("muni-map.csv.bz2"), row.names = FALSE)

