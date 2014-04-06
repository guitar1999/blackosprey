# library(raster)
# library(maptools)
# library(rasterVis)
# library(RColorBrewer)
# library(RPostgreSQL)
# library(rgdal)

############## Importing Data #################
#annualgrid function accepts a directory of monthly PRISM tifs, calculates annual means from them, and writes it to a file.
annualgrid <- function(var, workspace, outdir) {
  #var is text - either "ppt", "tmax", "tmean", or "tmin". workspace is directory to find images.  
  #outdir is directory to which annual grids will be written
  
  #calc means from monthly data.
  #list var files from BeginYear to EndYear **For now just listing all - will come back to this.
  var.list <- list.files(workspace, pattern="*.tif$", full.names=T)

  #calc num of iterations - minus 1 because doing the first iteration outside of loop.
  n <- length(var.list)
  
  #calc first year
  #t0 <- proc.time()
  outras1 <- paste(outdir, "/", unlist(strsplit(basename(var.list[1]), "\\."))[1], ".tif", sep="")
  yr.mean <- mean(stack(var.list[1:12]))
  writeRaster(yr.mean, outras1, overwrite=T)
  #calc rest of the years and stack
  #k <- 13
  j <- 13
  while (j < n) {
    t0 <- proc.time()
    #prints for debugging
    print("year list:")
    print(var.list[j:(j+11)])
    print ("##################")
    outras <- paste(outdir, "/", unlist(strsplit(basename(var.list[j]), "\\."))[1], ".tif", sep="")
    yr.mean <- mean(stack(var.list[j:(j+11)]))
    writeRaster(yr.mean, outras, overwrite=T)
    #yr.mean <- stack(yr.mean, yr.mean2)
    t0 <- proc.time()-t0
    print(t0)
    j <- j+12
    #garbage collection to flush memory?
    gc()
  }# end while
  #t0 <- proc.time()-t0
  
  #return(yr.mean)
}#end function
  

############# Analysis Functions ###############

#calculates overall mean (single layer) from annual data - will be used to calculate anomalies
climatemean <- function(adata) {
  periodmean <- mean(adata)
  return(periodmean)
}#end function

#calculates annual mean
annMean <- function(adata) {
  ann.mean <- vector(mode="numeric",length=nlayers(adata))
  
  for (i in c(1:nlayers(adata))) {
    ann.mean[i] <- mean(as.vector(adata[[i]]))
    #make raster stack from ann.mean - with same value for every year
  }#end loop
  
  return(ann.mean)
}#end function

#least squares fit of annual data at individual cell level
lstfit <- function(adata, b.year, e.year){
  nrows <- nrow(adata)
  ncols <- ncol(adata)
  n <- nlayers(adata)
  years <- c(b.year:e.year)
  mu <- as.matrix(mean(adata))
    
  df <- matrix(data=0, nrow=nrows, ncol=ncols)
  tmu <- df
  tmu[,] <- sum(c(1:n))/n
  Sxx <- Sxy <- SST <- SSW <- df
  
  for (i in c(1:n)) {
    dt <- as.matrix(adata[[i]])
    Sxx[,] <- ((i-tmu)**2) + Sxx
    i.df <- df
    i.df[,] <- i
    Sxy <- ((dt - mu)*(i.df-tmu)) + Sxy
  }#end for
  
  beta1 <- Sxy/Sxx
  beta0 <- mu - (beta1*tmu)
  return(list(beta1,beta0))  
}#end function



#takes annual data and returns rate of change at the ind cell level
temporalgradient <- function(adata, b.year, e.year) {
  trend <- lstfit(adata, b.year, e.year)
  return(trend[[1]])
}

calcAnomaly <- function(adata) {
  #calculate overall time series mean
  data_mu <- mean(adata)
  nyears <- nlayers(adata)
  
  #take difference between each yearly average and the overall average
  anom <- adata - data_mu
  
  #average each layer(year) to get single yearly anomaly.
  yr.anom <- as.vector(c(1:nlayers(anom)))
  for (n in c(1:nlayers(adata))) {
    yr.anom[n] <- mean(as.vector(anom[[n]]))
  }#end loop
  return(yr.anom)
}#end fucntion




############# Map Building Functions ##############
rasExtract <- function(rasPath, AOA) {
  #RasPath <- "C:/Share/LCC-VP/RangeWide/ned/clipped/GRSM_pace_ned.tif"
  if (class(AOA) == "SpatialPolygonsDataFrame") {
    ras <- raster(rasPath)
    ras.crop <- crop(ras, AOA)
  } else if (class(AOA) == "character") {
    poly <- readShapePoly(AOA)
    ras <- raster(rasPath)
    ras.crop <- crop(ras, poly)
  } else {
    stop(paste("AOA must be a polygon or a filepath to a polygon"))
  }#endif

  return(ras.crop)
} #end function


#creates map of climate gradient
plotPRISMgrad <- function(trend.ras, studyareaPoly, hsPath, cvar, c.points=NULL){
  #don't have a hillshade currently
  #first crop, then plot hillshade
  hs <- rasExtract(hsPath, PACE)
  
  #trying some filtering to smooth out the hs
  hs.fil3 <- focal(hs, w=matrix(1/9,nrow=3,ncol=3))
  #hs.fil5 <- focal(hs, w=matrix(1/25,nrow=5,ncol=5))
  #hs.fil9 <- focal(hs, w=matrix(1/81, nrow=9, ncol=9))
  
  #set colors for hillshade
  cols.hs <- gray.colors(100, 0.6, 0.9)
  
  #set colors for trend ras
  cols.trend <- rev(brewer.pal(11, "Spectral"))
  pal.trend <- colorRampPalette(cols.trend)(1000)
  
  #Create plain white raster - need to trick rasterVis into plotting legend for trend ras, not hillshade.
  #There is probably a better, easier way of doing this - but it's currently escaping me :)
  white.ras <- setValues(trend.ras, 1)
  
  #legend text
  if (cvar == "tmax" | cvar == "tmin" | cvar == "tmean") {
    #deg F/decade
    leg <- expression(paste("Temperature Trend (",italic(degree),italic("F/decade"),")"))
  } else if (cvar == "ppt") {
    #mm/decade
    leg <- expression(paste("Precipitation Trend (", italic("mm/decade"), ")"))
  } else {
    stop(paste("invalid 'cvar': ", cvar, ". Must be one of 'ppt', 'tmax', 'tmean', or 'tmin.'", sep=""))
  }#end if
  
  #for plotting pretty legend and more continuous raster plot
  maxz <- max(abs(as.matrix(trend.ras)))
  
  
  #Background trickery to get a plot with the correct legend
  l0 <- levelplot(trend.ras, alpha.regions=0.6, col.regions=pal.trend, at=seq(-maxz, maxz, length=1000), colorkey=TRUE, margin=FALSE, ylab.right=leg, 
                  par.settings = list(layout.widths = list(axis.key.padding = 0,ylab.right = 2)))
  l0.1 <- levelplot(white.ras, alpha.regions=1.0, col.regions="white", colorkey=FALSE, margin=FALSE)
  
  #Now "real" plot over l0 layers
  l1 <- levelplot(hs.fil3, col.regions=cols.hs, maxpixels=500000, margin=FALSE, colorkey=FALSE, 
                  alpha.regions=0.6)
  l2 <- levelplot(trend.ras, alpha.regions=0.6, col.regions=pal.trend, at=seq(-maxz, maxz, length=1000), colorkey=T, margin=FALSE, 
                  maxpixels=500000)
  l3 <- layer(sp.polygons(PACE, lwd=0.5))
  l4 <- layer(sp.polygons(park, lwd=0.5))
  
  if (is.null(c.points) == FALSE) {
    #plot station data
    l5 <- layer(sp.points(c.points,col="black", pch=20, cex=0.3))
    #Put all layers together
    l0+l0.1+l1+l2+l3+l4+l5
  } else {
      #Put all layers together
      l0+l0.1+l1+l2+l3+l4
  }#end if
}#end function



