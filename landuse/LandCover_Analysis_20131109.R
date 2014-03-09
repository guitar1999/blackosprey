# Purpose: This script contains functions that generate plots of landcover change from the NLCD 
#          change product (1992-2001). 
# Author: Tina Cormier
# Date: November 9, 2013
# Notes: See comments for notes on needed changes.  Also need to write a wrapper instead of having that part
#        of the script at the bottom (was done this way for testing).
# Status: Runs, but needs some work. Mapping functions not yet implemented.
#
#################################################################
library(maptools)
library(stringr)
library(RgoogleMaps)
library(rasterVis)
library(rgdal)
library(Hmisc)
library(RPostgreSQL)
library(raster)


#text for acreage - save barplot as object to get yaxis values of each bar.  
#Use bar height to figure out the x??

summarizeLC <- function(LCraster) {
  #format lookup table
  lut <- as.data.frame(levels(LCraster))

  #remove empty rows
  lut <- lut[-c(10:12,20:21,23,30:31,34,40:41,45,50:51,56,60:61,67,70:71,78:256),]
  
  #putting all classes in one column (previously, change classes were in a sep column
  #from static classes)
  levels(lut$Land.Cover.Change) <- c(levels(lut$Land.Cover.Change), as.character(lut$Modified.Anderson.Level.1[1:9]))
  lut$Land.Cover.Change[1:9] <- as.character(lut$Modified.Anderson.Level.1[1:9])
  
  #freq <- as.data.frame(table(LCraster@data@values))
  freq <- as.data.frame(table(getValues(LCraster)))
  names(freq)[1] <- "ID"
  freq$ID <- as.numeric(as.character(freq$ID))
  
  #match up image values with the lookup table
  if (length(match(freq$ID, lut$ID)) == length(freq$ID)) {
    lut$pixelcount <- 0
    lut$pixelcount[match(freq$ID, lut$ID)] <- freq$Freq
    #calculate area - based on 30m or 900m2 pixels.
    lut$area_ha <- 0
    lut$area_ha <- (lut$pixelcount*900)/10000
    
    #generate separate columns for 1992 and 2001 to calc %change in classes
    #parse out lut into separate years
    lut$area01 <- lut$pixels01 <- lut$class01 <- lut$area92 <- lut$pixels92 <- lut$class92 <-  NA
    
    #fill in 92 and 01 class names by keeping non-change classes and 
    #splitting on the word "to" for the change classes
    lut$class92[1:9] <- lut$class01[1:9] <- as.character(lut$Land.Cover.Change[1:9])
    #awesomest function from stringr package to split values in a column into 2 columns!! Way easier than
    #using strsplit
    lut$class92[10:length(lut$class92)] <- str_split_fixed(lut$Land.Cover.Change[10:length(lut$class92)], " to ", 2)[,1]
    lut$class01[10:length(lut$class92)] <- str_split_fixed(lut$Land.Cover.Change[10:length(lut$class92)], " to ", 2)[,2]
 
    #set up output table
    chg.tbl <- as.data.frame(lut$ID[1:9]) 
    names(chg.tbl)[1] <- "ID"
    chg.tbl$class <- lut$Land.Cover.Change[1:9]
    chg.tbl$pixels92 <- 0
    chg.tbl$area92 <- 0
    chg.tbl$pixels01 <- 0
    chg.tbl$area01 <- 0
    
    #sum #pixels and area per class at each time period
    sum.pix92 <- as.matrix(tapply(lut$pixelcount, lut$class92, sum))
    chg.tbl$pixels92[match(row.names(sum.pix92), chg.tbl$class)] <- sum.pix92[,1]
    
    sum.area92 <- as.matrix(tapply(lut$area_ha, lut$class92, sum))
    chg.tbl$area92[match(row.names(sum.area92), chg.tbl$class)] <- sum.area92[,1]
    
    sum.pix01 <- as.matrix(tapply(lut$pixelcount, lut$class01, sum))
    chg.tbl$pixels01[match(row.names(sum.pix01), chg.tbl$class)] <- sum.pix01[,1]
    
    sum.area01 <- as.matrix(tapply(lut$area_ha, lut$class01, sum))
    chg.tbl$area01[match(row.names(sum.area01), chg.tbl$class)] <- sum.area01[,1]
    
    #calc differences between 92 and 01
    chg.tbl$diff_pixel <- chg.tbl$pixels01 - chg.tbl$pixels92
    chg.tbl$diff_area <- chg.tbl$area01 - chg.tbl$area92
    chg.tbl$percent_change <- (chg.tbl$diff_area/sum(chg.tbl$area92))*100
        
  } else {
      stop("length of lut and freq do not match up - ISSUES!")
  }#end ifelse
  
  #remove the empty row and ice/snow (not applicable in this study area)
  chg.tbl <- chg.tbl[chg.tbl$class != "",]
  chg.tbl <- chg.tbl[chg.tbl$class != "Ice/Snow",]
  return(chg.tbl)
}#end function

#horizontal barplot function where chg.df is a 2-column data frame containing
#land cover class and percent change - function assumes column names are "class"
#and "percent".
#type arg can be "chg" or "lu"
hbars <- function(lcc, main.title, colors, type) {
  #function for adding transparency to plots (from: http://stackoverflow.com/questions/12995683/any-way-to-make-plot-points-in-scatterplot-more-transparent-in-r)
  addTrans <- function(color,trans)
  {
    # This function adds transparancy to a color.
    # Define transparancy with an integer between 0 and 255
    # 0 being fully transparant and 255 being fully visable
    # Works with either color and trans a vector of equal length,
    # or one of the two of length 1.
    
    if (length(color)!=length(trans)&!any(c(length(color),length(trans))==1)) stop("Vector lengths not correct")
    if (length(color)==1 & length(trans)>1) color <- rep(color,length(trans))
    if (length(trans)==1 & length(color)>1) trans <- rep(trans,length(color))
    
    num2hex <- function(x)
    {
      hex <- unlist(strsplit("0123456789ABCDEF",split=""))
      return(paste(hex[(x-x%%16)/16+1],hex[x%%16+1],sep=""))
    }
    rgb <- rbind(col2rgb(color),trans)
    res <- paste("#",apply(apply(rgb,2,num2hex),2,paste,collapse=""),sep="")
    return(res)
  }#end addTrans function
  
  #plot settings
  par(mar=c(5,8,4,2))
  #xlims <- range(pretty(c(min(lcc$percent_change), max(lcc$percent_change))))
  if (type=="chg") {
  xlims <- range(-10, 10)
  xlab <- "Percent Change (%)"
  } else if (type=="lu") {
    xlims <- range(0,100)
    xlab <- "Percent (%)"
  } #end lu/chg if
  
  #colors <- c("blue4", "cyan", "khaki2", "darkgreen", "springgreen2", "tomato2","skyblue1")

  #main <- paste(main.title, ":", "\n", sub.title, sep="")
  bp <- barplot(lcc$percent, horiz=TRUE, legend.text=T, names.arg=lcc$class, las=1, 
          cex.names=0.75, cex.axis=0.75,cex.lab=0.8, space=.1, width=0.5, xlim=xlims, 
          col=addTrans(colors,125),xlab=xlab, ylab="", main=main.title, 
          cex.main=0.90)
  mtext(side=2, "NLCD Landcover Class", line=6, cex=0.8)
  return(bp)
  
}#end function

#INCOMPLETE: Landcover Mapping Function
mapLC <- function(extentObject, ) {
  ex <- extent(extentObject)
  lat <- c(ex@ymin, ex@ymax)
  lon <- c(ex@xmin, ex@ymax)
  center <- c(mean(lat), mean(lon))
  zoom <- 5
  terrmap <- GetMap(center=center, zoom=zoom, maptype="terrain", destfile="/Users/tcormier/Documents/test/R-maps/test.png")
  
}#end function

#PUT THIS STUFF INTO A WRAPPER SCRIPT WHEN FINISHED TESTING.

####################################################
#user input variables
polyfile <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/buffer_analysis/vt_buff1000m.shp"
rasfile <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/area13_changeproduct5k_111907.img"
outdir <- "/Volumes/BlackOsprey/MapBook/LandUseChg/"
#watersheds or subwatershed level analysis (if sub-watershed, need group designation for subtitle)
#Enter either "watershed" or "subwatershed"
scale <- "watershed"
#if subwatershed level, enter buffer size if applicable. Otherwise, enter "". For graph labeling.
buff <- ""

# # Get a list of huc8 Watersheds to loop over
# query <- "huc_8_num, hu_8_name FROM nhd_hu8_watersheds WHERE contains_avaricosa = 'Y';"
# hucs <- dbGetQuery(con, query)

#outfile <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/buffer_analysis/test_VT_landuse_change_Good.pdf"
#outfile1 <- "/Users/tcormier/Google Drive/wicklow/brook_floater/testing/buffer_analysis/test_landuse_change_ID157.pdf"


#read in spatial data
# Connect to database
#con <- dbConnect(drv="PostgreSQL", host="192.168.1.100", user="tinacormier", dbname="blackosprey")
#Get HUC8 layer from db.  Only works as Jesse's user - not mine yet. Some config on db side needed.
dsn <- ("PG:dbname='blackosprey' host='192.168.1.100' user='jessebishop'")
#list spatial layers
#ogrListLayers(dsn)
#get table as spatial object
poly <- readOGR(dsn, 'nhd_hu8_watersheds_with_avaricosa_albers')
# poly <- readShapePoly(polyfile)
ras <- raster(rasfile)


# #specify watersheds that contain avaricosa
# polys <- polys[is.na(polys$contains_avaricosa),]

i=20
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

