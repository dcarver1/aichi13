####

# 10/15/2018

# The goal of this work is to generate a tab seperated files that contains counts of multiple paraments as

# defined by the aichi docs 

### 

library(dplyr)

data <- read.csv("C:/Users/danie/Desktop/aichiTest/aichiTest/extras/Cucurbita_total_2018_9_27_addition23values_cleanedGBIF.csv")

dataThin <- data %>%
  dplyr::select(c("Taxon_final", "latitude", "longitude", "type",  "country")) %>%
  mutate(hasLatLong = !is.na(latitude) | !is.na(longitude))


#List of existing cwr species 

CWR <- c("Cucurbita_argyrosperma_subsp._sororia",

         "Cucurbita_cordata",

         "Cucurbita_digitata", 

         "Cucurbita_ecuadorensis",

         "Cucurbita_foetidissima",

         "Cucurbita_lundelliana",

         "Cucurbita_maxima_subsp._andreana",

         "Cucurbita_okeechobeensis_subsp._martinezii",

         "Cucurbita_okeechobeensis_subsp._okeechobeensis",

         "Cucurbita_palmata",

         "Cucurbita_pedatifolia",

         "Cucurbita_pepo_subsp._fraterna",

         "Cucurbita_pepo_subsp._ovifera_var._ozarkana", 

         "Cucurbita_pepo_subsp._ovifera_var._texana",

         "Cucurbita_radicans",

         "Cucurbita_xscabridifolia")



#generate a conut of all the species. 

counts <- dataThin %>% 

  group_by(Taxon_final, type) %>%

  dplyr::summarise(total = n()) %>%

  arrange(desc(total))



# this should be changed 

local2 <- "C:/Users/danie/Desktop/aichiTest/aichiTest/gap_analysis" 



colNames <- c("totalRecords",	"totalUseful", 	"totalGRecords",	"totalGUseful",

              "totalHRecords",	"totalHUseful",	"totalPost1950",	"totalPre1950",

              "totalNoDate",	"GBIF",	"GENE")





# loop through the list of names and generate csv based on the species 

for(i in CWR){

  tbl <- filter(dataThin, Taxon_final %in% i) %>%

    dplyr::group_by(type, hasLatLong) %>%

    dplyr::summarize(total = n())

  df <- data.frame(matrix(NA, nrow = 1, ncol = 11))

  colnames(df) <- colNames

  df$totalRecords <- sum(tbl$total)

  df$totalUseful <- sum((subset(tbl, hasLatLong == TRUE))$total)

  df$totalGRecords <- sum((subset(tbl, type == "G"))$total)

  df$totalGUseful <- sum((subset(tbl, type == "G" & hasLatLong == TRUE))$total)

  df$totalHRecords <- sum((subset(tbl, type == "H"))$total)

  df$totalHUseful <- sum((subset(tbl, type == "H" & hasLatLong == TRUE))$total)

  dir.create(paste0(local2,"/",as.character(i)), showWarnings = FALSE)

  write.table(df, file = paste0(local2,"/",as.character(i),"/counts.csv"),

            sep='\t')
    } 





