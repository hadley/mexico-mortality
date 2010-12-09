library(stringr)

icd10 <- read.csv("icd-10.csv")
names(icd10) <- c("code", "disease")

icdmain <- subset(icd10, str_length(code) == 3)

write.csv(icdmain, "icd-main.csv", row.names = FALSE)
