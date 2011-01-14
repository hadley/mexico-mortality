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

deaths$hod[deaths$hod == 99] <- NA
deaths$hod[deaths$hod == 24] <- 0

deaths$minod[deaths$minod == 99] <- NA
qplot(minod, data = deaths, binwidth = 1)
qplot(minod, data = deaths, binwidth = 5)


qplot(hod, data = deaths, binwidth = 1, geom = "freqpoly")

code <- arrange(count(deaths, "cod"), desc(freq))

qplot(hod, ..density.., data = subset(deaths, cod %in% code$cod[1:20]), binwidth = 1, geom = "freqpoly") + facet_wrap(~ cod)

qplot(factor(hod), ..density.., data = subset(deaths, cod %in% code$cod[1:20]), binwidth = 1, geom = "freqpoly", group = 1) + facet_wrap(~ cod)

qplot(factor(hod), ..density.., data = subset(deaths, cod %in% code$cod[1:20] & !is.na(hod)), geom = "freqpoly", group = cod, colour = substr(cod, 1, 1))


head(code, 20)
names(code)[1] <- "code"

disease <- read.csv("../disease/icd-main.csv")
code <- join(code, disease)