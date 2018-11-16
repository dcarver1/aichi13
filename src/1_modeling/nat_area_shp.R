# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): shapefile with native area


# species <- species1

nat_area_shp <- function(species) {
  #load packages
  require(shapefiles); require(raster)
  require(rgeos); require(rgdal)
  
  # redefine species within because we are using character not numbers. x <- subset(tkdist, tkdist$Species==species) 
  # was not working with factor value for species 
  species <- as.character(species)
  #load config
  config(dirs=T, premodeling=T)
  
  #load species list
  splist <- unique(tkdist$Species) #alter column name
  x <- subset(tkdist, tkdist$Species==species)  #alter column name
  countries <- factor(as.character(unique(x$Native)))  #alter column name
  shp_NA3 <- subset(countries_sh, ISO %in% countries) ### DC added dissolve 
  

  
  # # # load in biome and Eco list 
  bioEco <- read.csv(paste0( folder_EcoBio,"/", species, ".csv"))
  # # read in shp
  biomes <- readOGR(paste0(shpFolder,"/wwf_terr_ecos.shp"),verbose = FALSE)
  # # 
  # # # subset the feature based on the biome and ecoregion 
  # shp_Bio <- subset(biomes, BIOME %in% bioEco$BIOME)
  shp_Eco <- subset(biomes, ECO_ID %in% bioEco$ECO_ID)
  # # 

  
    # Clip feature to native area countries 
  # shp_Clip <-gIntersection(shp_Bio, shp_NA3)
  # shp_NA4 <- SpatialPolygonsDataFrame(shp_Clip, data.frame(ID=1:length(shp_Clip)))
  # 
  shp_Clip2 <-gIntersection(shp_Eco, shp_NA3)
  shp_NA5 <- SpatialPolygonsDataFrame(shp_Clip2, data.frame(ID=1:length(shp_Clip2)))
  # 


  # 
  # # this raster is so big... making it really hard to work with 
  # elu <- raster(paste0(eluFolder, "/World_ELU_2015.tif"))
  # ras_clip <- mask(elu, shp_NA3)
  # ras_ELU <- elu %in%  bioEco$ELU_ID
  # shp_ELU <- rasterToPolygons(elu, fun=function(x){x %in% bioEco$ELU_ID}, na.rm=TRUE, digits=12, dissolve=TRUE)
  # 
  # shp_Clip3 <-gIntersection(shp_ELU, shp_NA3)
  # shp_NA6 <- SpatialPolygonsDataFrame(shp_Clip3, data.frame(ID=1:length(shp_Clip3)))
  # 

  
  ##DC 
  #using this to define the current shapefile used to define the native area. Keep me from switching these around all the time. 
  current_shp <- shp_NA5
  #define output directory for native area shp
  output_dir <- paste0(gap_dir,"/",species,"/",run_version,"/bioclim")

  if (!file.exists(paste0(output_dir, "/narea.shp"))) {
    #cat("Doing", species, "\n")
    gwd <- getwd(); setwd(output_dir)
    writeOGR(obj=current_shp, dsn="narea.shp", layer="narea", driver="ESRI Shapefile") # this is in geographical projection
    setwd(gwd)
    
    #cat("Writing png image for ",species,"\n")
    if (!file.exists(paste0(output_dir,"/",species,"_COUNTRY.png"))) {
      png(filename=paste0(output_dir,"/",species,"_COUNTRY.png"), width = 800, height = 800,unit="px")
      plot(current_shp,col="red")
      dev.off()
    }
    rm(list = c("species", "x", "countries"))
  } else {
    gwd <- getwd(); setwd(output_dir)
    current_shp <- shapefile(paste0(output_dir, "/narea.shp"))
    setwd(gwd)
  }
  #rm(biomes)
  return(current_shp)
}
