###
# script to produce the raw data for each species with iso country code. 
###
library(dplyr)
library(countrycode)

data <- read.csv("C:/Users/danie/Desktop/aichiTest/aichiTest/extras/cucurbiteCWRClean.csv")
countryCodes <- read.csv("C:/Users/danie/Desktop/aichiTest/aichiTest/extras/allCountryCodes.csv")
                         
View(data)
# generate  a list of all unique Taxon 
CWR <- unique(data$Taxon_final.x)

# pull data from the country code that is needed 
cC <- countryCodes %>%
  dplyr::select(name, alpha.2, alpha.3) %>%
  mutate(iso3 = alpha.3)

# rename coulmns for joins ***might not need to do this is can join o different col names*** 
cCfull <- cC %>%
  dplyr::rename(country = "name") %>%
  distinct( country, .keep_all = TRUE) # removed duplicated based on multiple full names (ex. United States, United States of America)

# select iso 2 values 
cC2 <- cC %>%
  dplyr::rename(country = "alpha.2") %>%
  distinct(country, .keep_all = TRUE)
# select iso 3 values 
cC3 <- cC %>%
  dplyr::rename(country = "alpha.3") %>%
  distinct(country, .keep_all = TRUE)

# this is clunky but it works for not. Need to remove NA so I can rebuild full dataframe 
# join on country column for name, iso2 and 1so3 
joinFull <- left_join(data, cCfull, by= "country") %>%
  filter(!is.na(iso3))

join2 <- left_join(data, cC2, by= "country")%>%
  filter(!is.na(iso3))

join3 <- left_join(data, cC3, by= "country") %>%
  filter(!is.na(iso3))


# rebuild and redefine country coulmn with iso3 value 
TrimCC <- bind_rows(joinFull,join2, join3)
TrimCC$country <- TrimCC$iso3

# select needed columns for the data, add native column for next aspect 
rawFiles <- TrimCC %>%
  dplyr::select(c("Taxon_final.x","Longitude", "Latitude", "country", "type.x")) %>%
  rename(Taxon_final = "Taxon_final.x", type = "type.x") %>%
  dplyr::mutate(native = 1)

View(rawFiles)
# setting write file directoy 
local2 <- "C:/Users/danie/Desktop/aichiTest/aichiTest/parameters/occurrences/raw/" 

# read in dataset for testing the nativeness 
native <- read.table("C:/Users/danie/Desktop/aichiTest/aichiTest/parameters/WEP/cucurbitas_CWR_taxonKey.txt",
                     header = TRUE)


# loop through the list of names and generate csv based on the species 
for(i in CWR){
  tbl <- filter(rawFiles, Taxon_final %in% i)
  conList <- filter(native, Species %in% i) %>%
    dplyr::select(Native)
  tbl$native <- ifelse(tbl$country %in% unique(native$Native), "N", "I")
 print(c(as.character(conList[[1]]))) 
  tbl2 <- tbl %>%
    dplyr::select("Longitude", "Latitude", "country", "type", "native")
  file <- write.csv(tbl2, 
                    file = paste0(local2,as.character(i),".csv"),
                    sep="\t")#watch out for this it is a tab seperated one now 
  print(paste(i , nrow(tbl)))
} 


