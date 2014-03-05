# Purpose: This script contains functions that generate plots of % impervious surface from the NLCD 
#          impervious surface layers.  
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

#path/name of impervious surface layer
imp <- "/Users/tcormier/Google\ Drive/wicklow/brook_floater/testing/NLCD2006_impervious_5-4-11/nlcd2006_impervious_5-4-11.img"

#path/name of polygon file of the boundaries within which to summarize impervious surfaces.
polyfile <- "/Users/tcormier/Google\ Drive/wicklow/brook_floater/testing/nhd_hu8_watersheds_clipped_avY_albers.shp"

#read in imp.ras and poly *NOTE, before doing this analysis for real, clip to region (will be faster) once
#hard drives are back online.
imp.ras <- raster(imp)
poly <- readShapePoly(polyfile)
reg.crop <- crop(imp.ras, poly)

for (i in c(1:length(poly))){
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
