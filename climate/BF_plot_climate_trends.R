# Purpose: This script contains functions that generate plots showing climate trends from PRISM monthly 
#          historical observations. 
# Author: Tina Cormier
# Date: October, 2013
# Notes: See comments for notes on needed changes.  
# Status: Runs, with the exception of the mapping functions, which are still in progress.
#
#################################################################
library(zoo)

#Function to plot watershed-level PRISM-based climate trends

#df for testing
#df <- read.csv("/Users/tcormier/Documents/test/climate_plotting/prism_1070003.csv")
#outdir <- "/Users/tcormier/Documents/test/climate_plotting/plots/"

prepPRISM <- function(df) {
#divide ppt by 100,000 to get to m and temps by 100 to get to deg C.
df$ppt_mean <- df$ppt_mean/100
df$tmax_mean <- df$tmax_mean/100
df$tmin_mean <- df$tmin_mean/100
return(df)
}#end function

#calculate annual averages of ppt_mean, tmax_mean, and tmin_mean
prismAnnMean <- function(df) {
  #pdata <- prepPRISM(df)
  #pdata <- df
  years <- unique(df$prism_year)
  
  #calc annual average
  ann.mean <- as.data.frame(matrix(data=NA, nrow=length(years), ncol=4))
  names(ann.mean) <- c("Year", "mean_ppt_mean", "mean_tmax", "mean_tmin")
  ann.mean$Year <- years
  
  for (i in c(1:length(years))) {
    ppt.mean <- mean(df$ppt_mean[df$prism_year == years[i]])
    tmax.mean <- mean(df$tmax_mean[df$prism_year == years[i]])
    tmin.mean <- mean(df$tmin_mean[df$prism_year == years[i]])
    
    ann.mean[i,2:4] <- c(ppt.mean, tmax.mean, tmin.mean)
  }#end loop
  return(ann.mean)  
}#end function

#Calculate overall mean for whole time series
prism_tsMean <- function(df){
  means <- as.data.frame(matrix(data=NA, nrow=1, ncol=3))
  names(means) <- c("mean_ppt_mean_all", "mean_tmax_all", "mean_tmin_all")
  means$mean_ppt_mean_all <- mean(df$ppt_mean)
  means$mean_tmax_all <- mean(df$tmax_mean)
  means$mean_tmin_all <- mean(df$tmin_mean)
  
  return(means)
}#end function

#Calculate yearly anomalies. df is the monthly prism data.
prismAnom <- function (df) {
  #calc annual means from monthly data - df should be monthly data
  adata <- prismAnnMean(df)
  
  #calc overall mean for entire time series
  odata <- prism_tsMean(df)
  
  #prism anomalies (yrly)
  p.anom <- as.data.frame(matrix(data=NA, nrow=nrow(adata), ncol=3))
  names(p.anom) <- c("ppt_anomaly", "tmax_anomaly", "tmin_anomaly")
  p.anom$ppt_anomaly <- adata$mean_ppt_mean - odata$mean_ppt_mean_all
  p.anom$tmax_anomaly <- adata$mean_tmax - odata$mean_tmax_all
  p.anom$tmin_anomaly <- adata$mean_tmin - odata$mean_tmin_all
  
  return(p.anom)
}#end function
  
plotAnom <- function(p.anom, adata, colname) {
  #setting up for plotting
  pos <- as.data.frame(matrix(data=NA, nrow=nrow(p.anom), ncol=3))
  names(pos) <- names(p.anom)
  neg <- as.data.frame(matrix(data=NA, nrow=nrow(p.anom), ncol=3))
  names(neg) <- names(p.anom)
  
  pos[[colname]][p.anom[[colname]] >= 0] <- p.anom[[colname]][p.anom[[colname]] >= 0]
  neg[[colname]][p.anom[[colname]] < 0] <- p.anom[[colname]][p.anom[[colname]] < 0]
  #for checking to make sure it all adds up properly
  n.pos <- length(pos[[colname]][!is.na(pos[[colname]])])
  n.neg <- length(neg[[colname]][!is.na(neg[[colname]])])
  
  if (n.pos+n.neg != nrow(p.anom)) {
    stop("problem calculating pos and neg vals. Numbers don't add up to nrows(p.anom)")
  }#end if
  
  #Calc 3-year moving average to plot over bars - consider using lag tools in zoo
  run.avg <- c(NA, NA, NA) #to fill in the first three years - easier plotting
  lag <- 3
  
  for (j in c((lag+1):nrow(p.anom))) {
    run.avg[j] <- mean(p.anom[[colname]][c((j-lag):(j-1))])
    #run.avg <- append(run.avg, avg)
  }
  
  #calc limits such that 0 is in the middle
  lim <- max(abs(p.anom[[colname]]))
  buff <- .1*lim
  lim <- c(-lim-buff, lim+buff)
  
  # Titles
  if (colname == "ppt_anomaly") {
    main <- "Historical Precipitation Anomalies"
    ylab <- expression(paste(Delta,"PPT (mm)", sep=""))
  } else if (colname == "tmax_anomaly") {
      #fix this - make pretty with italics and such from WHRC script
      main <- "Historical Maximum Temperature Anomalies"
      ylab <- expression(paste(Delta,"T ",~(degree~C), sep=""))
  } else {
      main <- "Historical Minimum Temperature Anomalies"
      ylab <- expression(paste(Delta,"T ",~(degree~C), sep=""))
  }#end if
  
  #plotting - barplots - see labeling
  #plot barplot with nothing, then set background to gray, then plot for real.
  bp0 <- barplot(pos[[colname]], ylim=lim, width=2, border=NA, xaxt="n", yaxt="n")
  rec <- rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "white", 
              border="black", lwd=2)
  bp1 <- barplot(pos[[colname]], ylim=lim, col="firebrick3", width=2, border=NA, 
                       xaxt="n", add=TRUE, main=main, xlab="Year", ylab=ylab, 
                       cex.lab=0.80, cex.axis=0.80, cex.main=0.90)
  bp2 <- barplot(neg[[colname]], col="blue", add=TRUE, width=2, border=NA, yaxt="n")    
  ab <- abline(0, 0)
  avg <- lines(bp1, run.avg, col="forestgreen", lwd=1.5)
  
  #Labels every 10 years
  lab <- seq(1895, 2013, 1)%%20==0
  label <- adata$Year[lab]
  at <- bp1[lab]
  ax <- axis(1, at=at, labels=label, cex.axis=0.80)
  
  #Legend
  leg.text <- "Three-year moving window"
  leg <- legend("bottomright", leg.text, lwd=1.5, col="forestgreen", bty="n", cex=0.8)
}#end function

PRISMtrends <- function(df, colname) {
  #df is the prism monthly data frame
  adata <- prismAnnMean(df)
  #calculate trend - two ways you can do it - should come out to same answer.
  #lstfit <- lsfit(adata$Year, adata[[colname]])
  lm <- lm(adata[[colname]] ~ adata$Year)
   
  return(lm)
}#end function

plotTrends <- function(pdata, colname, ws.name) {
  #output file
  #need query to get watershed name
  #ws.name <- "test"
  huc <- paste(ws.name, ", ID:", pdata$huc_8_num[1], sep="")
  #outplot <- paste(outdir, "PRISM_trends_Huc8ID", pdata$huc_8_num[1], "_", ws.name, ".pdf", sep="")
  
  trends <- PRISMtrends(pdata, colname)
  #trends$coefficients  

  #Set up yearly data for plotting
  adata <- prismAnnMean(pdata)
  
  xlim <- range(c(1895,2015))
  ylim <- range(pretty(c(min(adata[[colname]]),max(adata[[colname]]))))
  
  if (colname == "mean_ppt_mean") {
    main <- paste(huc, "\n\nMean Annual Prism-modeled Precipitation", sep="")
    ylab <- "PPT (mm)"
    leg.text <- paste("Trend ", round(trends$coefficients[2]*10, digits=2), " (mm/decade)", sep="")
  } else if (colname == "mean_tmax") {
      main <- paste(huc, "\n\nMean Annual Prism-modeled Maximum Temperature", sep="")
      ylab <- expression(paste("Temperature (",degree~C,")" ))
      coeff <- round(trends$coefficients[2]*10, digits=2)
      leg.text <-as.expression(bquote(Trend ~ .(coeff) ~ (degree~C/decade)))      
  } else {
      main <- paste(huc, "\n\nMean Annual Prism-modeled Minimum Temperature", sep="")
      ylab <- expression(paste("Temperature (",degree~C,")" ))
      coeff <- round(trends$coefficients[2]*10, digits=2)
      leg.text <-as.expression(bquote(Trend ~ .(coeff) ~ (degree~C/decade)))
  }#end if else

  #make plot
  plot(adata$Year,adata[[colname]], main=main, 
       xlab="Year", ylab=ylab, type="l", xlim=xlim, ylim=ylim,
       cex=0.80, cex.main=0.90, cex.lab=0.80, cex.axis=0.80)
  abline(trends, col="deepskyblue")
  legend("bottomright", leg.text, lty=1, col="deepskyblue",bty="n", cex=0.80)
  
  
}#end function

#NOTES from 9/22. X axis labels - to PPT?






