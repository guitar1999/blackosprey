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
#
library(raster)
library(maptools)
library(rasterVis)
library(ggplot2)
library(RPostgreSQL)
library(sp)
#library(rgdal)

######################### USER INPUTS ########################################

#path/name of impervious surface layer
imp.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/NLCD2001_impervious_v2_5-4-11/nlcd2001_impervious_v2_5-4-11.img"

#path/name of forest cover layer
#forest.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/hansen_forest_cover/Hansen_GFC2013_treecover2000_50N_080W_albers.tif"
forest.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/forest_cover_glcf/NH/NH_GLCF_Landsat_forestcover_2000.tif"

#EO files - points and buffered to 500m, 1000m, and 3000m
eo.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/avaricosa_eo_all_20130325/Avaricosa_EOs_with_geom_albers.shp"
# eo500.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/avaricosa_eo_all_20130325/Avaricosa_EOs_with_geom_albers_buff500m.shp"
# eo1000.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/avaricosa_eo_all_20130325/Avaricosa_EOs_with_geom_albers_buff1000m.shp"
# eo3000.file <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/avaricosa_eo_all_20130325/Avaricosa_EOs_with_geom_albers_buff3000m.shp"

#set connection to db - Only works as Jesse's user - not mine yet. Some config on db side needed.
#dsn <- ("PG:dbname='blackosprey' host='192.168.1.100' user='jessebishop'")

#name of db table on which you want to summarize forest cover and impervious surfaces
#poly.tbl <- "baselayer_gadm_usa_state"
poly.tbl <- "/Users/tcormier/GoogleDrive/wicklow/brook_floater/testing/NewHampshire_albers.shp"


######################### FUNCTIONS ########################################

#Function to plot impervious surfaces vs. forested area, symbolized by EO_Rank
summImp <- function(imp.ras, for.ras, poly, eo) {
  #plot - need to do some data exploration before I can decide
  #how the plot should look.
  
  #for testing
  imp.ras <- imp.mask
  for.ras <- forest.mask
  poly <- poly.sub
  eo <- eo 
  #eobuff <- eo3000 
  
  #extract forest cover and impervious surface info to EO points.
  eo.imp <- extract(imp.ras, eo, buffer=3000, fun=mean, na.rm=T)
  eo.for <- extract(for.ras, eo, buffer=3000, fun=mean, na.rm=T)
  eo.rank <- as.data.frame(as.character(eo$UPDATE_POP))
  names(eo.rank) <- "rank"
  eo.ifr <- cbind(eo.imp, eo.for, eo.rank)
    
  #colors - create a lookup table and apply to eo.rank variable
  color <- c("green", "blue", "darkorange", "red", "darkorchid3", "tan","darkseagreen", "black", "gray58", "gray58" )
  ranks <- c("A", "B", "C", "D", "E", "H", "F", "X", "U", "NR")
  
  #for legend plotting
  labels <- c("Excellent Viability", "Good Viability", "Fair Viability", "Poor Viability", "Verified Extant", 
              "Historical", "Failed to Find", "Extirpated", "Unrankable", "Not Ranked")
  
  #apply lookup table to eo.rank
  #remove NAs first
  eo.ifr <- na.omit(eo.ifr)
  eo.ifr$color <- color[match(eo.ifr$rank, ranks)]
  
  #Make prettier, and color points based on rank
  plot(eo.ifr$eo.imp, eo.ifr$eo.for, pch=16, col=eo.ifr$color, ylab="Forest Cover (%)", xlab="Impervious Surface Cover (%)", xlim=c(0,100), ylim=c(0,100), 
       main="New Hampshire Element Occurrences: \nAdjacent Forest Cover vs. Impervious Surface Cover (3000 m buffer)")
#   plot(eo.ifr$eo.imp, eo.ifr$eo.for, pch=as.character(eo.ifr$rank), col=eo.ifr$color, ylab="Forest Cover (%)", xlab="Impervious Surface Cover (%)", xlim=c(0,100), ylim=c(0,100), 
#       main="New Hampshire Element Occurrences: \nAdjacent Forest Cover vs. Impervious Surface Cover (3000 m buffer)") 
#  
  legend("topright", legend=labels, col=colors, pch=16)
  
  #convert to vectors:  
  imp.vec <- as.vector(getValues(imp.mask))
  for.vec <- as.vector(getValues(forest.mask))
  
  #calc mean impervious surface cover for the watershed
  mean.isc <- mean(as.vector(imp.mask), na.rm=T)
  sd.isc <- sd(as.vector(imp.mask), na.rm=T)
  
  #plot of impervious surface reference values
  xlim <- c(0:100)
  ticks <- c(10,25,40,60,100)
  ylim <- c(1:3)
  ylab <- c("poor", "fair", "good")
  
  
  
} #end summImp function

######################### SCRIPT ########################################
#read in spatial data. *NOTE, before doing this analysis for real, clip to region (will be faster) once
#hard drives are back online.
imp <- raster(imp.file)
forest <- raster(forest.file)
eo <- readOGR(dirname(eo.file), unlist(strsplit(basename(eo.file), "\\."))[1])
# eo500 <- readOGR(dirname(eo500.file), unlist(strsplit(basename(eo500.file), "\\."))[1])
# eo1000 <- readOGR(dirname(eo1000.file), unlist(strsplit(basename(eo1000.file), "\\."))[1])
# eo3000 <- readOGR(dirname(eo3000.file), unlist(strsplit(basename(eo3000.file), "\\."))[1])

#polygon file of the boundaries within which to summarize impervious surfaces. For now, states.
#poly <- readOGR(dsn, poly.tbl)
poly <- readOGR(dirname(poly.tbl), unlist(strsplit(basename(poly.tbl), "\\."))[1])

#for testing
poly.sub <- poly[poly$name_1=="New Hampshire",]

for (i in c(1:length(poly))){
  #i=1
  #poly.sub <- poly[i]
  #crop and mask rasters by the state
  print(paste(poly.sub$name_1))
  print(date())
  print("cropping impervious and forest cover layers. . .")
  imp.crop <- crop(imp, poly.sub)
  #forest.crop <- crop(forest, poly.sub)
  forest.crop <- crop(forest,imp.crop, snap="in")
  
  #Sort of a work-around for snapping one grid to the other. Since we have an impervious
  #surface layer for the whole US, we'll just use that as the reference. It's arbitrary, really.
  #SO, once the layers are cropped down to a reasonable size (and assuming they are the
  #same resolution and projection), we'll write out the impervious surface grid and use that
  #to write the forest cover values to.
  #Since this will ultimately be the snapped forest cover layer, we'll call it that!
  
  #write out the cropped layers:
  #NEED TO FIGURE THIS ABBR BIT OUT
  #abbr <- unlist(strsplit(poly.sub$varname_1, "\\|"))[1]
  
  for.cropname <- paste(dirname(forest.file), "/", unlist(strsplit(basename(forest.file), "\\."))[1], "_cropNH.tif", sep="")
  for.snapname <- paste(dirname(forest.file), "/", unlist(strsplit(basename(forest.file), "\\."))[1], "_SnapToImp_NH.tif", sep="")
  
  #THIS IS KEY - if for.cropname and for.snapname files exist, delete them:
  if (file.exists(for.cropname)) {
    file.remove(for.cropname)
  }#end file remove if
  if (file.exists(for.snapname)) {
    file.remove(for.snapname)
  }#end file remove if
  #once I figure out how to extract state abbreviation, imp.name will be this:
  #imp.name <- paste(dirname(forest.file), unlist(strsplit(forest.file, "\\."))[1], "_SnapToImp_", abbr, ".tif", sep="")
  print(date())
  print("snapping forest layer to impervious layer . . .")
  writeRaster(forest.crop, filename=for.cropname, format="GTiff",overwrite=T)
  #note here we are writing out imp.crop here..ref grid for snapping in next step. This will become the snapped forest cover grid.
  writeRaster(imp.crop, filename=for.snapname, format="GTiff", overwrite=T) 
  
  #Here's where we paste in the forest cover grid to the imp surface grid=snapping
  #use Nearest bc these should be the same resolution/projection. Just need slight alignment,
  #so I don't want to start averaging with bilinear.
  system(paste("/Library/Frameworks/GDAL.framework/Versions/Current/Programs/gdalwarp", for.cropname, for.snapname, "-r near -multi", sep=" "))
  
  #now read snapped forest layer back in
  for.cropsnap <- raster(for.snapname)
  
  #and mask to state boundary
  print(date())
  print("masking impervious and forest cover layers . . .")
  imp.mask <- raster::mask(imp.crop, poly.sub)
  forest.mask <- raster::mask(for.cropsnap, poly.sub)
  
  #Set values >100 to NA in both datasets - clouds, water, nodata?  See metadata from glcf data.
  #for some reason, this break imp.mask
  #for testing - keep this variable so we don't have to redo the masking (time consuming):
#   imp.mask2 <- imp.mask
#   forest.mask2 <- forest.mask
  imp.mask <- imp.mask2
  forest.mask <- forest.mask2
  
  imp.mask[forest.mask > 100 | imp.mask > 100 | is.na(forest.mask)] <- NA
  forest.mask[forest.mask > 100 | imp.mask > 100 | is.na(imp.mask)] <- NA
  
  hucSum <- summImp(imp.ras, poly[i,])
  
  
    
}# end poly loop



