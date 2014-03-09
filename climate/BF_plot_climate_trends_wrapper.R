# Purpose: This script calls functions that generate plots showing climate trends from PRISM monthly 
#          historical observations. Connects to psql database to get boundaries within which to 
#          calculate trends. In this case, HUC8 watersheds within the study area.
# Author: Tina Cormier
# Date: October, 2013
# Notes: See comments for notes on needed changes.  
# Status: Runs
#################################################################

library(zoo)
library(RPostgreSQL)
#source("/Users/tcormier/Documents/test/climate_plotting/BF_plot_climate_trends.R")
source("/Volumes/BlackOsprey/GIS_Data/git/blackosprey/climate/BF_plot_climate_trends.R")

# Connect to database
con <- dbConnect(drv="PostgreSQL", host="127.0.0.1", user="jessebishop", dbname="blackosprey")

###########################################################
#Set Variables
#PRISM data file and outdir variables
#df <- read.csv("/Users/tcormier/Documents/test/climate_plotting/prism_1070003.csv")
#outdir <- "/Users/tcormier/Documents/test/climate_plotting/plots/"
outdir <- "/Volumes/BlackOsprey/MapBook/Climate/"
#ws <- "Tina's Awesome Watershed"
###########################################################


# Get a list of huc8 Watersheds to loop over
query <- "SELECT huc_8_num FROM nhd_hu8_watersheds WHERE contains_avaricosa = 'Y';"
hucs <- dbGetQuery(con, query)

# Loop over each watershed and do stuff
for (huc in hucs$huc_8_num) {
    dfquery <- paste("SELECT * FROM prism_combined_statistics WHERE huc_8_num = ", huc, ";", sep='')
    df <- dbGetQuery(con, dfquery)
    wsquery <- paste("SELECT hu_8_name FROM nhd_hu8_watersheds WHERE huc_8_num = ", huc, ";", sep='')
    ws <- dbGetQuery(con, wsquery)

    print(paste("Working on huc ", huc, " - ", ws, sep=""))

    #format ppt, tmax, and tmin mean colums by dividing by 100 to get to mm and deg C.
    df.form <- prepPRISM(df)
    
    #Calculate yearly anomalies
    p.anom <- prismAnom(df.form)
    
    #Calculate yearly means
    p.ann <- prismAnnMean(df.form)
    
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
      plotAnom(p.anom, p.ann, pvar)
      dev.off()
      counter <- counter+1
      }#end loop
}#end loop

# Close the database connection
dbDisconnect(con)
    
