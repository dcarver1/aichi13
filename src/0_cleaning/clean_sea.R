# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (data.frame): data.frame with filtered species records
#-------------------------------------
#Function for removing coordinates falling in the ocean rather than on land
#Jonatan Soto
#Based on Jeison & Alejandra advice
#-------------------------------------
clean_sea <- function(species) {
  
  #load packages
  require(raster)
  require(maptools)
  require(rgdal)
  
  ##source config
  config(dirs=T, cleaning=T)

  #check if raw occurrences exist
  if (file.exists(paste0(folderin_raw,"/",species,".csv"))) {
    #load raw species occurrences
    spp <- read.csv(paste0(folderin_raw,"/",species,".csv"), header = TRUE) ##read file
    colnames(spp) <- c("index" ,"lon", "lat", "country", "type", "native")
    #cat("loading species ID=", species, "file", "\n")
    
    #transform spp data.frame into SpatialPointsDataFrame
    coordinates(spp) <- ~lon+lat ###to SpatialPointsDataFrame
    crs(spp) <- crs(countries_sh) ####add to mask
    over_spp <- over(spp, countries_sh) ### over() #overlay
    
    
    ###DC 
    # extract values to points location for all the biomes and ecoregions 
    biomes <- readOGR(paste0(shpFolder,"/wwf_terr_ecos.shp"), verbose = FALSE)
    crs(biomes) <- crs(countries_sh)
    v <- over(spp, biomes)
    biomeNames <- unique(v$BIOME)
    ecoRegion <- unique(v$ECO_ID)
    
    # extract values to point location from the ELU layer 
    elu <- raster(paste0(eluFolder, "/World_ELU_2015.tif"))
    crs(elu)<- crs(countries_sh)
    e <- raster::extract(elu, spp)
    eluValues <- unique(e) #can add a buffer=100 parameter here to try to encompass more ELUs. again these are not distinct boundaries. 
  
    # match the length of features by adding NA as needed. 
    max.len = max(length(biomeNames), length(ecoRegion), length(eluValues))
    biomeNames = c(biomeNames, rep(NA, max.len - length(biomeNames)))
    ecoRegion = c(ecoRegion, rep(NA, max.len - length(ecoRegion)))
    # this is adding a NA value and messing with the dataframe. I'm going to assume that ELu values will always be the highest until I can trouble shoot this more. 
    # eluValues = c(eluValues, rep(NA, max.len = length(eluValues)))
    
    
    df1 = data.frame(BIOME = biomeNames, ECO_ID = ecoRegion, ELU_ID =eluValues) 
    
    write.csv(df1, paste0( folder_EcoBio,"/", species, ".csv"), row.names = TRUE)
    
    
    ###remove NAs
    #cat("Removing NA's for species ID", species, "file", "\n")
    spp1 <- as.data.frame(spp)
    spp1 <- cbind(spp1, over_spp)
    spp1 <- spp1[which(!is.na(spp1$ISO)),]
    spp1$ISO <- NULL
    
    #cat("writing new", files, "file", "\n")
    write.csv(spp1, paste0(folder_nosea,"/original/",species,"_original.csv"), row.names = FALSE)
    #cat("DONE", "\n")
    
    rm(spp)
    rm(biomes)
    rm(e)
    rm(v)
  } else {
    spp1 <- NULL
  }
  
  #return object
  return(spp1)
}

# #--------------Run in parallel---------------
# ncores <- detectCores()-12 #change according available server resources
# c1 <- makeCluster(ncores)
# clusterEvalQ(c1, lapply(c("raster", "maptools"), library, character.only= TRUE))
# clusterExport(c1, c("folderin", "countries_sh", "files", "folderout", "sum_count", "count_spp"))
# microbenchmark(parLapply(c1, files, cleansea),times = 1L) 
# 

