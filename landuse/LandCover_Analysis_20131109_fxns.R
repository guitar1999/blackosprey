# Purpose: This script contains functions that generate plots of landcover change from the NLCD 
#          change product (1992-2001). 
# Author: Tina Cormier
# Date: November 9, 2013
# Notes: See comments for notes on needed changes.  Also need to write a wrapper instead of having that part
#        of the script at the bottom (was done this way for testing).
# Status: Runs, but needs some work. Mapping functions not yet implemented.
#
#################################################################

#Check if necessary packages already loaded. If not, load them.
pkgs <- c("maptools", "stringr", "RgoogleMaps", "rasterVis", "rgdal", "Hmisc", "raster")
chk.pkg <- function(pkg) {
  if (! paste("package:",pkg,sep="") %in% search()) {
    library(pkg, character.only=TRUE)
  }#end if
}#end function

sapply(pkgs, chk.pkg)

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
  #these xlims work for watersheds, but will likely need to be adjusted for buffered areas.
  if (type=="chg") {
    xlims <- range(-4, 4)
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
# mapLC <- function(extentObject, ) {
#   ex <- extent(extentObject)
#   lat <- c(ex@ymin, ex@ymax)
#   lon <- c(ex@xmin, ex@ymax)
#   center <- c(mean(lat), mean(lon))
#   zoom <- 5
#   terrmap <- GetMap(center=center, zoom=zoom, maptype="terrain", destfile="/Users/tcormier/Documents/test/R-maps/test.png")
#   
# }#end function



