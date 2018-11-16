###
# currently the background point generation within the Aichi code it not tied to the study area extent.
# the goal here is to write out a process that will 1
# 1. generate random points within the native area 
# 2. extract values from predictor layers to those point locations. 
### 


library(raster)
library(maptools)
library(rgdal)
library(ff)
library(data.table)
library(gtools)
library(velox)
library(PresenceAbsence)
library(rJava)
library(dismo)
library(tidyverse)
library(SDMTools)
library(rgeos)
library(shapefiles)
library(sp)
library(plyr)

# native area shp 
natArea <- readOGR("C:/Users/danie/Desktop/aichiTest/aichiTest/gap_analysis/Cucurbita_cordata/v1/bioclim/narea.shp")

# presence points 
occCsv<- read.csv("C:/Users/danie/Desktop/aichiTest/aichiTest/parameters/occurrences/no_sea/original/Cucurbita_cordata_original.csv")
coords <- occCsv %>%
  select(lon,lat)
data <- occCsv %>%
  select(country, type, native)
occPnt <- SpatialPointsDataFrame(coords = coords, data = data, proj4string = crs(natArea))

# generate pnts within th native area shp
## Set number of background back on area 
## goal is to sample 1/10 of all cells in the native area as long as that does not excide 10,000
## at 2.5 arc sec/ 1 degee = 60 sec; (60/2.5)^2 * 0.10 = 57.6   so 58 times the area in square degrees 
numberBackground <- function(area){
  n <- gArea(area)*58
  ifelse( n <= 10000, n, 10000)
  return(n)
}



n <- numberBackground(natArea)
backXY <- spsample(natArea, n = n, type = "random" )

#read in raster values 
rst_vx <- readRDS("C:/Users/danie/Desktop/aichiTest/aichiTest/parameters/biolayer_2.5/climate_vx.RDS")

#extract values to background points 
backGroundPnt <- raster::extract(rst_vx,backXY)

xy_data_bio <- cbind(backXY@coords, rst_vx$extract_points(backXY))
xy_data_bio
head(xy_data_bio)
backXY
