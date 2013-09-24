library(zoo)
source("/Users/tcormier/Documents/test/climate_plotting/BF_plot_climate_trends.R")

###########################################################
#Set Variables
#PRISM data file and outdir variables
df <- read.csv("/Users/tcormier/Documents/test/climate_plotting/prism_1070003.csv")
outdir <- "/Users/tcormier/Documents/test/climate_plotting/plots/"
ws <- "Tina's Awesome Watershed"
###########################################################

#format ppt, tmax, and tmin mean colums by dividing by 100 to get to mm and deg C.
df.form <- prepPRISM(df)

#Calculate yearly anomalies
p.anom <- prismAnom(df.form)

#loop over climate vars and plot
vars <- names(p.anom)
#these are the column names as output by the prismAnnMean function
ann.vars <- c("mean_ppt_mean", "mean_tmax", "mean_tmin")
counter=1

for (pvar in vars) {
  v <- unlist(strsplit(pvar, "_"))[1]
  outfile <- paste(outdir, "huc8_", df.form$huc_8_num[1], "_hxPrismTrends_", v, ".pdf", sep="")
  #png(filename=outfile, width=7.5, height=10, units="in",res=300)
  pdf(file=outfile, 7.5, 10)
  #Set up plotting layout and open graphics device
  layout(matrix(c(1,2), 2, 1))
  
  #plot annual values
  #ptrend <- PRISMtrends(, ann.vars[counter])
  plotTrends(df.form, ann.vars[counter], ws)
  
  #plot anomalies
  plotAnom(p.anom, pvar)
  dev.off()
  counter <- counter+1
  }#end loop