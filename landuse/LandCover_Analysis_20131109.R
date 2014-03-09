library(maptools)
library(stringr)
library(RgoogleMaps)
library(rasterVis)
library(rgdal)
library(Hmisc)
library(RPostgreSQL)
library(raster)

source("/Users/tcormier/Documents/scripts/git_repos/blackosprey/landuse/LandCover_Analysis_20131109_fxns.R")
####################################################
#user input variables
#polyfile <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/buffer_analysis/vt_buff1000m.shp"
rasfile <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/area13_changeproduct5k_111907.img"
outdir <- "/Volumes/BlackOsprey/MapBook/LandUseChg/"
#watersheds or subwatershed level analysis (if sub-watershed, need group designation for subtitle)
#Enter either "watershed" or "subwatershed"
scale <- "watershed"
#if subwatershed level, enter buffer size if applicable. Otherwise, enter "". For graph labeling.
buff <- ""
#set connection to db - Only works as Jesse's user - not mine yet. Some config on db side needed.
dsn <- ("PG:dbname='blackosprey' host='192.168.1.100' user='jessebishop'")
####################################################

#read in spatial data
# Connect to database
#list spatial layers
#ogrListLayers(dsn)

#Get HUC8 layer from db - read in a spatial polygons dataframe.
poly <- readOGR(dsn, 'nhd_hu8_watersheds_with_avaricosa_albers')
# poly <- readShapePoly(polyfile)
ras <- raster(rasfile)

#i=20
#poly$ID <-as.character(poly$ID)
for (i in c(1:length(poly))) {
  print(paste("reading ", poly$hu_8_name[i], " watershed polygon. . .", sep=""))
  poly.sub <- poly[i,]
  
  outfile.chg <- paste(outdir, "huc8_", poly.sub$huc_8_num, "_", 
                       str_replace_all(poly.sub$hu_8_name, pattern=" ", repl=""), 
                       "_landUseChg_1992-2001.pdf", sep="")
  outfile.lu <- paste(outdir, "huc8_", poly.sub$huc_8_num, "_", 
                      str_replace_all(poly.sub$hu_8_name, pattern=" ", repl=""), 
                      "_landUse_2001.pdf", sep="")
  
  
  #There may be a warning here...but don't worry - the subsequent lines fix it!
  ras.clip <- crop(raster(rasfile), poly.sub)
  ras.mask <- raster::mask(ras.clip, poly.sub)
  ras.mask <- as.factor(ras.mask)
  ras.mask@data@attributes <- ras@data@attributes
  ras.mask@legend <- ras@legend
  
  print(paste("summarizing land use change"))
  LCsumm <- summarizeLC(ras.mask)
  
  #df for land cover change (lcc)
  lcc <- as.data.frame(cbind(as.character(LCsumm$class), round(LCsumm$percent_change, digits=3)), stringsAsFactors=F)
  names(lcc) <- c("class", "percent")
  lcc$percent <- as.numeric(lcc$percent)
  
  #df for 2001 land cover
  lu.percent <- round((LCsumm$area01/sum(LCsumm$area01))*100, 2)
  lc <- data.frame(cbind(as.character(LCsumm$class), lu.percent), stringsAsFactors=F)
  names(lc) <- c("class", "percent")
  lc$percent <- as.numeric(lc$percent)
  
  #Still need to perfect plotting - add titles, margins, and write to file
  #list of colors for bars in barplot - in this case, they come from the legend to match the map.
  colors <- as.vector(ras.mask@legend@colortable)[2:8]
  
  #get total watershed/buffer area:
  ha <- paste("total area: ", prettyNum(sum(round(LCsumm$area92)), big.mark=",", scientific=F), " ha", sep="")
  
  #titles and such
  #poly.main <- paste("Landuse Change 1992 - 2001", "\n",poly.sub$HUC_8_NAME, ", ID: ", poly.sub$HUC_8_NUM, sep="")
  if (scale == "subwatershed") {
    #This will have to be coded later - once we figure out the final buffer layer and name the groupings
    poly.subtitle.chg <- paste(buff, " buffer")
    #fix titles for sub-watersheds
    poly.main.chg <- paste("Land Use Change 1992 - 2001", "\n", " Good Viability Population",
                           "\n", poly.subtitle.chg, "\n", ha,sep="")
    poly.subtitle.lu <- paste(buff, " buffer")
    poly.main.lu <- paste("Land Use Change 1992 - 2001", "\n", " Good Viability Population",
                          "\n", poly.subtitle.chg, "\n", ha,sep="")
  } else if (scale == "watershed") {
    poly.subtitle.chg <- ""
    poly.main.chg <- paste("Land Use Change 1992 - 2001", "\n",poly.sub$hu_8_name, " watershed, HUC8 ID: ", 
                           poly.sub$huc_8_num, "\n", ha, sep="")
    poly.main.lu <- paste("Land Use 2001", "\n",poly.sub$hu_8_name, " watershed, HUC8 ID: ", 
                          poly.sub$huc_8_num, "\n", ha, sep="")
  } else {
    print(paste("ERROR: scale must be either 'subwatershed' or 'watershed.' You entered: ", scale, sep=""))
  }#end watershed if
  
  #png(file=outfile, 7, 4.5, units="in", res=300)
  #run hbarplot function. type arg can be "chg" or "lu"
  pdf(file=outfile.chg, 7,4.5)
  hbarplot <- hbars(lcc, poly.main.chg, colors, type="chg")
  dev.off()
  
  pdf(file=outfile.lu, 7,4.5)
  hbarplot.lu <- hbars(lc, poly.main.lu, colors, type="lu")
  #add area (ha) to end of bars.
  #text(lcc$percent_change, hbarplot, paste(round(LCsumm$diff_area), " ha", sep=""), pos=4, cex=0.75)
  dev.off()
  
}#end watershed for
