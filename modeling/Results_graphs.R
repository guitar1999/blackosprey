library(ggplot2)

load("/Users/tcormier/Documents/misc/avaricosa/ModelRun_20161111/avaricosa_RF_model_final.Rdata")
fig.dir <- "/Users/tcormier/Documents/misc/avaricosa/final_report/figures/all_potential/"

# Some work on the original inputs (keep state so we can sumamrize training)
# data condition by state
#preds <- res.fil[,c(3,5:9,11,12,30:35,37,40:46,57:84)]
keep.preds <- c("s1992_lc92_developed_pct", "s1992_lc92_barren_pct", "s1992_lc92_forest_pct", "s1992_lc92_shrub_pct", "s1992_lc92_wetland_pct", "s2011_cd_mean", 
                "s2011_cd_std_dev", "s2011_cd_max", "s2011_impervious_mean", "s2011_impervious_std_dev", "s2011_impervious_max", "s2011_lc_developed_pct", 
                "s2011_lc_barren_pct","s2011_lc_forest_pct", "s2011_lc_shrub_pct", "s2011_lc_herbaceous_pct", "s2011_lc_planted_pct", 
                "s2011_lc_wetland_pct", "s2011_lcc_developed_pct", "s2011_lcc_barren_pct", "s2011_lcc_forest_pct", "s2011_lcc_shrub_pct", "s2011_lcc_herbaceous_pct",
                "s2011_lcc_planted_pct", "s2011_lcc_wetland_pct", "slope_mean", "slope_std_dev", "slope_max", "ppt_trend_mean", "ppt_trend_std_dev", 
                "tmin_trend_mean", "tmin_trend_std_dev", "tmax_trend_mean", "tmax_trend_std_dev", "avg_road_distance", "state")
preds <- res.fil[,keep.preds]
better.names <- c("%Developed 1992", "%Barren 1992", "%Forest 1992", "%Shrub1992", "%Wetland 1992", "Mean Canopy Density 2011", "Std dev Canopy Density 2011", 
                  "Max Canopy Density 2011", "Mean Imperviousness 2011", "Std dev Imperviousness 2011", "Max Imperviousness 2011", "%Developed 2011", "%Barren 2011",
                  "%Forest 2011", "%Shrub 2011", "%Herbacious 2011", "%Ag 2011", "%Wetland 2011", "%Developed Change 2001-2011", "%Barren Change 2001-2011", 
                  "%Forest Change 2001-2011", "%Shrub Change 2001-2011", "%Herbaceous Change 2001-2011", "%Ag Change 2001-2011", "%Wetland Change 2001-2011", "Mean Slope",
                  "Std dev Slope", "Max Slope", "PPT Trend 1895-2012", "Std dev PPT Trend 1895-2012", "Tmin Trend 1895-2012", "Std dev Tmin Trend 1895-2012",
                  "Tmax Trend 1895-2012", "Std dev Tmax Trend 1895-2012", "Dist to road", "state")
names(preds) <- better.names

# Take out distance to roads
preds <- preds[,-c(35)]

resp <- as.data.frame(res.fil$symbol_pop_cond, stringsAsFactors = F)
names(resp) <- "orig_cond"

#some data exploration 
# tab <- table(resp)
# tab
# let's lump some classes because we don't have enough samples in each class. Did not include AC (too broad), E, U, NR, or F per conversations with Barry.
# If a HUC12 has multiple pops with different conditions, need to exclude from training data.
resp$lumped_cond[(resp$orig_cond == "A" | resp$orig_cond == "AB" | resp$orig_cond == "B" )] <- "good"
resp$lumped_cond[(resp$orig_cond == "BC" | resp$orig_cond == "C")] <- "fair"
resp$lumped_cond[(resp$orig_cond == "CD" | resp$orig_cond == "D" | resp$orig_cond == "X" | resp$orig_cond == "H")] <- "poor/extinct"

#testing
# resp$lumped_cond[(resp$orig_cond == "A" | resp$orig_cond == "AB" | resp$orig_cond == "AC" | resp$orig_cond == "B" | resp$orig_cond == "BC")] <- "good"
# resp$lumped_cond[(resp$orig_cond == "C" | resp$orig_cond == "CD")] <- "fair"
# resp$lumped_cond[(resp$orig_cond == "D" | resp$orig_cond == "X")] <- "poor/extinct"

resp$lumped_cond <- factor(resp$lumped_cond, levels=c("poor/extinct", "fair", "good"), ordered = T)
preds.fil <- preds[!(is.na(resp$lumped_cond)),]
resp.fil <- na.omit(resp)

resp.fil.orig <- resp.fil
preds.fil.orig <- preds.fil

#############
# New code for figs
#
# EO condition by state
res.state <- data.frame(resp.fil, toupper(preds.fil$state))
names(res.state) <- c("orig", "condition", "state")
# res.state <- res.state[ order(res.state[,3]), ]
gbar <- ggplot(res.state, aes(state, fill=condition)) + 
  geom_bar() + scale_fill_manual(values=c("#F8766D", "#00BA38", "#619CFF")) +
  guides(fill=guide_legend(title=NULL, reverse=TRUE)) +
  xlab("State") + ylab("count") +
  ggtitle("EO Condition by State")
print(gbar)

outgbar <- paste0(fig.dir, "StreamCondition_byState.pdf")
pdf(outgbar, height=6, width=5.5)
print(gbar)
dev.off()

# Same graph for HUC12 could not be generated because watersheds
# often contained EOs from multiple states.


# More model stats
library(rfUtilities)
??rfUtilities


####
# Streams prediction
s.pred <- read.csv("/Users/tcormier/Documents/misc/avaricosa/ModelRun_20161111/prediction.csv")
dim(s.pred)
table(s.pred$prediction)

