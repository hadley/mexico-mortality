library(ggplot2)
library(stringr)
library(maptools)
gpclibPermit()

to_ascii <- function(x) {
  ascii <- iconv(x, "latin1", "ASCII//TRANSLIT")
  str_replace_all(ascii, ignore.case("[^A-Z ]"), "")
}

muni <- readShapeSpatial("muni.shp", delete_null_obj = TRUE)

muni_map <- fortify(muni, region = "HASC_2")
write.csv(muni_map, bzfile("muni-map.csv.bz2"), row.names = FALSE)

muni_df <- unique(as.data.frame(muni)[c("HASC_2", "NAME_2")])
names(muni_df) <- c("id", "name")
muni_df$altname <- to_ascii(muni_df$name)

muni_df[c("state", "muni")] <- str_split_fixed(muni_df$id, fixed("."), 3)[, -1]
muni_df <- subset(muni_df, state != "")

# Match map data with existing municipality codes
codes <- read.csv("muni-codes.csv")
names(codes) <- c("state_id", "state_name", "muni_id", "muni_name")
codes$altname <- to_ascii(codes$muni_name)

fixes <- c("Altzayanca" = "Atltzayanca", "Amatitlan de los Reyes" = "Amatlan de los Reyes", "Amealco de Bonfin" = "Amealco de Bonfil", "Atotonilco El Alto" = "Atotonilco el Alto", "Camaron de Tejada" = "Camaron de Tejeda", "Carichic" = "Carichi", "Chocoman" = "Chocaman", "Cosamaloapan" = "Cosamaloapan de Carpio", "Coxquihi" = "Coxquihui", "Cuatrocienegas" = "Cuatro Cienegas", "Cusihuiriachic" = "Cusihuiriachi", "Doctor Arroyo" = "Dr Arroyo", "Doctor Coss" = "Dr Coss", "Doctor Gonzalez" = "Dr Gonzalez", "Dolores Hidalgo" = "Dolores Hidalgo Cuna de la Independencia Nacional", "El Nayar" = "Del Nayar", "General Bravo" = "Gral Bravo", "General Escobedo" = "Gral Escobedo", "General Teran" = "Gral Teran", "General Trevino" = "Gral Trevino", "General Zaragoza" = "Gral Zaragoza", "General Zuazua" = "Gral Zuazua", "Guachochic" = "Guachochi", "Guemez" = "Gemez", "Indoparapeo" = "Indaparapeo", "Jalancingo" = "Jalacingo", "Magdalena Contreras" = "La Magdalena Contreras", "Maguarichic" = "Maguarichi", "Matachic" = "Matachi", "Mihuatlan" = "Miahuatlan", "Nuevo Paranguricutiro" = "Nuevo Parangaricutiro", "Ozuluama" = "Ozuluama de Mascarenas", "San Antonio La Isla" = "San Antonio la Isla", "San Luis de Cordero" = "San Luis del Cordero", "San Martin de las Piraamides" = "San Martin de las Piramides", "Soto La Marina" = "Soto la Marina", "Tancanhuitz de Santos" = "Tancanhuitz", "Temapache" = "Alamo Temapache", "Tinguindin" = "Tingindin", "Tlaquilpan" = "Tlaquilpa", "Uruachic" = "Uruachi", "Yauhquemecan" = "Yauhquemehcan", "Zacatepec de Hidalgo" = "Zacatepec", "Zitlaltepec de Trinidad Sanchez Santos" = "Ziltlaltepec de Trinidad Sanchez Santos", "Zontecomatlan" = "Zontecomatlan de Lopez y Fuentes")

fix_match <- match(muni_df$altname, names(fixes))
muni_df$altname[!is.na(fix_match)] <- fixes[na.omit(fix_match)]

matches <- match(muni_df$altname, codes$altname)
muni_df[is.na(matches), ]

meta <- join(codes, muni_df, by = "altname", type = "full")
meta <- arrange(meta, state_id, muni_id)
meta$name <- NULL
meta$muni_name <- NULL

write.csv(meta, "muni-meta.csv", row.names = FALSE)


# State level data -----------------------------------------------------------

state <- readShapeSpatial("state.shp")
state_map <- fortify(state, region = "HASC_1")
write.csv(state_map, bzfile("state-map.csv.bz2"), row.names = FALSE)


state_df <- as.data.frame(state)[c("HASC_1", "NAME_1")]
names(state_df) <- c("id", "name")
state_df$name <- to_ascii(state_df$name)

state_codes <- unique(meta[c("state_id", "state_name")])
names(state_codes)[2] <- "name"
state_codes$name <- to_ascii(state_codes$name)

state_meta <- join(state_df, state_codes, by = "name", type = "full")
write.csv(state_meta, "state-meta.csv", row.names = FALSE)
