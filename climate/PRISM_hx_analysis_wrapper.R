library(raster)
library(maptools)
library(rasterVis)
library(RColorBrewer)
library(RPostgreSQL)
library(rgdal)

#From mini
#source("/Users/tinacormier/Documents/scripts/git_repos/blackosprey/climate/PRISM_hx_analysis.R")
#wd <- "/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/"

#From laptop
source("/Users/tcormier/Documents/scripts/git_repos/blackosprey/climate/PRISM_hx_analysis.R")
wd <- "/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/"
setwd(wd)
#####################################
#Set variables here
#vars <- c("tmin")
vars <- c("ppt", "tmax", "tmin")
#PACE.path <- "C:/Share/LCC-VP/ALCC_PACE_Park_boundaries/GRSM_pace_wgs72.shp"
#park.path <- "C:/Share/LCC-VP/ALCC_PACE_Park_boundaries/GRSM_boundary_wgs72.shp"
#hsPath <- "C:/Share/LCC-VP/RangeWide/ned/clipped/GRSM_pace_ned_hillshade_120m_wgs72.tif"
out.mapsdir <- "/Volumes/BlackOsprey/MapBook/Climate/maps/"
#if applicable
out.anngriddir <- "/Volumes/BlackOsprey/GIS_Data/PRISM/4km/annual/"

b.year <- 1895
e.year <- 2012
#moving window size (in years) for plotting trends
#mws <- 3

#optional - climate station points to plot over maps
#c.stations <- "C:/Share/LCC-VP/ClimateStation/GRSM_climate_db_updated_2011/GRSM_Climate_stations_Fridley_wgs72.shp"
#####################################
#Connect to blackosprey db
# Connect to database
#dsn <- ("PG:dbname='blackosprey' host='127.0.0.1' user='jessebishop'")
#From other computer than mini
dsn <- ("PG:dbname='blackosprey' host='192.168.1.100' user='tinacormier'")

#see everything that's available
ogrListLayers(dsn) 

#other way of connecting to db, but doesn't recognize geom field (GRRR)
# con <- dbConnect(drv="PostgreSQL", host="192.168.1.100", user="jessebishop", dbname="blackosprey")
# query <- "select * from avaricosa.avaricosa_all_as_point_no_geom_view limit 1;"
# a <- dbGetQuery(con, query)
# str(a)

#studyarea
poly <- readOGR(dsn, "baselayer_project_area")
#transform poly to wgs72 to match PRISM
poly72 <- spTransform(poly, CRS("+proj=longlat +ellps=WGS72 +towgs84=0,0,4.5,0,0,0.554,0.2263 +no_defs"))

#calculate annual grids from monthly data - hopefully a one-time thing and can comment out ann.mean line when finished.
vars <- "tmin"
for (var in vars){
  #out.anngrid <- paste(out.anngriddir, var, sep="/")
  #workspace <- paste(wd, var, sep="")
  #annualgrid(var=var, workspace=workspace, outdir=out.anngrid)
  
  #test when script finishes****
  #stack all annual grids and crop to study area
  ann.grids <- list.files(paste(out.anngriddir, var, sep=""), pattern="*.tif$", full.names=T)
  adata <- crop(stack(ann.grids), poly72)
  
  #least squares fit of annual data at individual cell level
  #takes annual data and returns rate of change at the ind cell level
  trend.ras <- temporalgradient(adata, b.year, e.year) 
  
  
  
  
}#end vars for



#THEN don't forget at some point to mult all PRISM 4km products by 100 and get rid of float.



