# Purpose: This script contains functions that generate plots of % impervious surface from the 2001 NLCD 
#          impervious surface layer vs. 2000 percent forest cover from the global land cover facility 
#          (http://www.landcover.org/data/landsatTreecover/) for A.varicosa observations.  
#          Points are symbolized by their EO_Rank.  
# 
# Author: Tina Cormier
# Date: March 2, 2014
# Notes: See comments for notes on needed changes.  
# Status: In progress
#
#################################################################

#This top stuff can go into a wrapper when finished testing. Need to add in DB stuff too.
library(raster)
library(maptools)
library(rasterVis)
library(ggplot2)
library(RPostgreSQL)
library(rgdal)

#path/name of impervious surface layer
imp.file <- "/Users/tcormier/Google\ Drive/wicklow/brook_floater/testing/NLCD2001_impervious_5-4-11/nlcd2001_impervious_v2_5-4-11.img"

#path/name of forest cover layer
forest.file <- "/Users/tcormier/Google\ Drive/wicklow/brook_floater/testing/forest_cover_glcf/NH/NH_GLCF_Landsat_forestcover_2000.tif"

#EO points file
eo.file <- "/Users/tcormier/Google\ Drive/wicklow/brook_floater/testing/avaricosa_all_points.shp"

#set connection to db - Only works as Jesse's user - not mine yet. Some config on db side needed.
#dsn <- ("PG:dbname='blackosprey' host='192.168.1.100' user='jessebishop'")

#name of db table on which you want to summarize forest cover and impervious surfaces
#poly.tbl <- "baselayer_gadm_usa_state"
poly.tbl <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/NewHampshire_albers.shp"

#read in spatial data. *NOTE, before doing this analysis for real, clip to region (will be faster) once
#hard drives are back online.
imp <- raster(imp.file)
forest <- raster(forest.file)
eo <- readOGR(dirname(eo.file), unlist(strsplit(basename(eo.file), "\\."))[1])

#polygon file of the boundaries within which to summarize impervious surfaces. For now, states.
#poly <- readOGR(dsn, poly.tbl)
poly <- readOGR(dirname(poly.tbl), unlist(strsplit(basename(poly.tbl), "\\."))[1])

#for testing
poly.sub <- poly[poly$name_1=="New Hampshire",]

for (i in c(1:length(poly))){
  poly.sub <- poly[i]
  #crop and mask rasters by the state
  #FIGURE OUT WHY THERE IS AN IO ERROR HERE!
  imp.crop <- crop(imp, poly.sub)
  forest.crop <- crop(forest, poly.sub)
  imp.mask <- raster::mask(imp.crop, poly.sub)
  forest.mask <- raster::mask(forest.crop, poly.sub)
  
  hucSum <- summImp(imp.ras, poly[i,])
  
  
    
}# end poly loop

#for testing
poly <- poly[i]
imp.ras <- reg.crop

#Function to summarize impervious surfaces into a plot
summImp <- function(imp.ras, poly) {
  imp.crop <- crop(imp.ras, poly)
  imp.mask <- raster::mask(imp.crop, poly)
  
  #plot - need to do some data exploration before I can decide
  #how the plot should look.
  summary(imp.mask)
  levelplot(imp.mask)
  #calc mean impervious surface cover for the watershed
  mean.isc <- mean(as.vector(imp.mask), na.rm=T)
  sd.isc <- sd(as.vector(imp.mask), na.rm=T)
  
  #plot of impervious surface reference values
  xlim <- c(0:100)
  ticks <- c(10,25,40,60,100)
  ylim <- c(1:3)
  ylab <- c("poor", "fair", "good")
  
  
} #end summImp function
