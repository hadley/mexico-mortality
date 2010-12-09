library(foreign)
library(stringr)
options(stringsAsFactors = FALSE)

deaths <- read.dbf("DEF-SSA08.DBF", as.is = T)

names(deaths) <- c("yob", "mob", "dob", "sex", "age_unit", "age", "nation",
 "marital", "stateL", "countyL", "locationL", "popL", "job", "edu", "derhab",
 "statD", "countyD", "locationD", "popD", "placeD", "yod", "mod", "dod",
 "hod", "minod", "med_help", "cod", "des", "presume", "working", "injury_loc",
 "domestic_v", "autopsy", "certifier", "state_reg", "county_reg", "year_reg",
 "mon_reg", "day_reg", "weight", "year_cert", "mon_cert", "day_cert", 
 "pregnant", "labor_cod", "labor_c")

write.csv(deaths, bzfile("deaths08.csv.bz2"), row.names = FALSE)
