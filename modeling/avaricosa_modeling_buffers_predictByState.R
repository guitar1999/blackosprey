# Predict random forest model for avaricosa
library(RPostgreSQL)
library(randomForest)
# Load modeling session
load("/Users/tcormier/Documents/misc/avaricosa/ModelRun_20161111/avaricosa_RF_model_final.Rdata")

# List of states (missing GA for now because it's not extracted yet - and RI is not in the list
# but it is covered by streams in neighboring states)
# states <- c("nh", "ct",	"de",	"md",	"ma", "me",	"nj",	"ny",	"pa",	"vt",	"va",	"wv",	"sc",	"nc")
states <- c("ga")
# Connect to database to retrieve summary table for modeling
con <- dbConnect(drv="PostgreSQL", host="192.168.1.100", user="jessebishop", dbname="blackosprey")

# head(con)

for (st in states) {
  print(st)
  # For Buffers
  preds.query <- paste0("(SELECT 
    nl.huc,
  nl.num_pixels AS num_nlcd_pixels,
  nl.pct_forest_1992,
  nl.pct_forest_2011,
  nl.pct_wetland_2011,
  nl.mean_cd_2011,
  ne.num_pixels AS num_ned_pixels,
  ne.mean_slope,
  ne.max_slope,
  ne.std_dev_slope,
  c.ppt_mean,
  c.tmin_mean,
  c.tmax_mean
  FROM
  nhd_stream_buffer_nlcd_statistics_", st, " nl FULL OUTER JOIN 
  nhd_stream_buffer_ned_statistics_", st, " ne ON nl.huc=ne.huc FULL OUTER JOIN 
  nhd_stream_buffer_climate_statistics_", st, " c ON nl.huc=c.huc AND ne.huc=c.huc
  WHERE
  NOT nl.huc IS NULL AND
  NOT ne.huc IS NULL AND
  NOT c.huc IS NULL);")
  # res.query <- "(SELECT 
  #   nl.huc,
  # nl.num_pixels AS num_nlcd_pixels,
  # nl.pct_forest_1992,
  # nl.pct_forest_2011,
  # nl.pct_wetland_2011,
  # nl.mean_cd_2011,
  # ne.num_pixels AS num_ned_pixels,
  # ne.mean_slope,
  # ne.max_slope,
  # ne.std_dev_slope,
  # c.ppt_mean,
  # c.tmin_mean,
  # c.tmax_mean
  # FROM
  # nhd_stream_buffer_nlcd_statistics_ct nl FULL OUTER JOIN 
  # nhd_stream_buffer_ned_statistics_ct ne ON nl.huc=ne.huc FULL OUTER JOIN 
  # nhd_stream_buffer_climate_statistics_ct c ON nl.huc=c.huc AND ne.huc=c.huc
  # WHERE
  # NOT nl.huc IS NULL AND
  # NOT ne.huc IS NULL AND
  # NOT c.huc IS NULL);"
  st.preds <- dbGetQuery(con, preds.query)
  
  # First need to multiply landcover fields by 100 to match the training data.
  st.preds[,3:5] <- st.preds[,3:5]*100
  
  # Deal with field names - manual
  # names from training data
  names(preds.fil.orig[rf.nomc.sel$selvars])
  names(st.preds)[3:13] <- c("%Forest 1992", "%Forest 2011", "%Wetland 2011", "Mean Canopy Density 2011", "num_ned_pixels", "Mean Slope", 
                             "max_slope", "Std dev Slope", "PPT Trend 1895-2012", "Tmin Trend 1895-2012", "Tmax Trend 1895-2012" )
  
  system.time(rf.pred <- predict(rf.noval, st.preds))
  system.time(rf.prob <- predict(rf.noval, st.preds, type='prob'))
  
  preds.all <- data.frame(permanent=st.preds$huc, prediction=rf.pred, probability_poor=rf.prob[,1], 
                          probability_fair=rf.prob[,2], probability_good=rf.prob[,3], stringsAsFactors = F)
  dbWriteTable(con, "prediction", preds.all, row.names=FALSE, append=TRUE)
  
  # Hist of prediction probability
  # pred.melt <- melt(rf.pred)
  # names(pred.melt) <- c("index", "prediction", "probability")
  # preds.df <- as.data.frame(rf.pred)
  # names(preds.df) <- "prediction"
  # hist.predprob <- ggplot(preds.df,aes(fill=prediction)) +
  #   geom_histogram(bins=50)
  # # 
  # print(hist.predprob)
  
}
dbDisconnect(con)

# Load final prediction table
predtbl.query <- "SELECT * FROM prediction;"
pred <- dbGetQuery(con, predtbl.query)
