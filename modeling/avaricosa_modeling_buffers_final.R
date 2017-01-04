library(plotrix)
library(rfUtilities)
library(plyr)
library(ggplot2)
library(reshape)
library(RColorBrewer)
library(RPostgreSQL)
library(dplyr)
library(caret) 
library(pROC)
library(randomForest)

source("/Users/tcormier/Documents/scripts/git_repos/general/R/handy_functions_TC.R")
set.seed(5)


# load("/Users/tcormier/Documents/misc/avaricosa/ModelRun_20150127/avaricosa_model_20150127.RData")
figdir <- "/Users/tcormier/Documents/misc/avaricosa/ModelRun_20161111/"
ntree <- 1000
# validation percent
val <- 20

# Connect to database to retrieve summary table for modeling
con <- dbConnect(drv="PostgreSQL", host="192.168.1.100", user="jessebishop", dbname="blackosprey")
# For HUC12
# res.query <- "SELECT * FROM huc_12_summary_statistics_pct_aggregated_modeling;"
# For Buffers
res.query <- "select * from avaricosa_buffer_summary_statistics_pct_aggregated_modeling;"
res <- dbGetQuery(con, res.query)

dbDisconnect(con)

# res$state <- as.factor(res$state)
# res$symbol_pop_cond <- as.factor(res$symbol_pop_cond)
res.fil <- res
#res.fil <- res[res$multiple_conditions == F & (res$state == "nh" | res$state == "ma" | res$state == "me" | res$state == "vt" | res$state == "ct"),]
# res.fil <- res[res$multiple_conditions == F,]
# Had to remove some pred fields if they had no variation - all same value - causes 
# random forest to error.
# for help looking up column names and numbers
lut <- cbind((1:length(names(res.fil))), names(res.fil))
# Decided to rewrite this with field names to avoid the confusion I'm having after coming back to this months later.
# Also, decided to remove 2001 landcover variables. They are incorporated in the change variables. So kept current lc, which is 2011,
# and the change variables.
#
# ALSO # manually select some variables based on a priori knowledge of what might make
# ecological sense. Looked at correlations between landcover vars and decided to get 
# rid of %water1992 and % nonWoody 1992. Kept all 2011 landcover variables. 
# The only ones that are correlated above 0.75 are CD and %forest - keeping both 
# anyway as one will get tossed in the multicollinearity step probably. Just want 
# to make sure I'm keeping vars that make sense!
#
# Looked at cor bt elev/slope/texture vars. Keep slope_mean/max/std - other elev
# vars are correlated. Even the std is correlated to the mean, but keeping it.
# 
# Climate vars: keep ppt_mean, ppt_std, tmin_mean, tmin_std, tmax_mean, tmax_std
# Got rid of 20 variables this way.
#preds <- res.fil[,c(3,5:9,11,12,30:35,37,40:46,57:84)]
keep.preds <- c("s1992_lc92_developed_pct", "s1992_lc92_barren_pct", "s1992_lc92_forest_pct", "s1992_lc92_shrub_pct", "s1992_lc92_wetland_pct", "s2011_cd_mean", 
                "s2011_cd_std_dev", "s2011_cd_max", "s2011_impervious_mean", "s2011_impervious_std_dev", "s2011_impervious_max", "s2011_lc_developed_pct", 
                "s2011_lc_barren_pct","s2011_lc_forest_pct", "s2011_lc_shrub_pct", "s2011_lc_herbaceous_pct", "s2011_lc_planted_pct", 
                "s2011_lc_wetland_pct", "s2011_lcc_developed_pct", "s2011_lcc_barren_pct", "s2011_lcc_forest_pct", "s2011_lcc_shrub_pct", "s2011_lcc_herbaceous_pct",
                "s2011_lcc_planted_pct", "s2011_lcc_wetland_pct", "slope_mean", "slope_std_dev", "slope_max", "ppt_trend_mean", "ppt_trend_std_dev", 
                "tmin_trend_mean", "tmin_trend_std_dev", "tmax_trend_mean", "tmax_trend_std_dev", "avg_road_distance")
preds <- res.fil[,keep.preds]
better.names <- c("%Developed 1992", "%Barren 1992", "%Forest 1992", "%Shrub1992", "%Wetland 1992", "Mean Canopy Density 2011", "Std dev Canopy Density 2011", 
                  "Max Canopy Density 2011", "Mean Imperviousness 2011", "Std dev Imperviousness 2011", "Max Imperviousness 2011", "%Developed 2011", "%Barren 2011",
                  "%Forest 2011", "%Shrub 2011", "%Herbacious 2011", "%Ag 2011", "%Wetland 2011", "%Developed Change 2001-2011", "%Barren Change 2001-2011", 
                  "%Forest Change 2001-2011", "%Shrub Change 2001-2011", "%Herbaceous Change 2001-2011", "%Ag Change 2001-2011", "%Wetland Change 2001-2011", "Mean Slope",
                  "Std dev Slope", "Max Slope", "PPT Trend 1895-2012", "Std dev PPT Trend 1895-2012", "Tmin Trend 1895-2012", "Std dev Tmin Trend 1895-2012",
                  "Tmax Trend 1895-2012", "Std dev Tmax Trend 1895-2012", "Dist to road")
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

# First, random forest with all variables
randfor.all <- randomForest(preds.fil.orig, resp.fil$lumped_cond)
randfor.all
varImpPlot(randfor.all)

# Select stratified random sample for training and testing
# set.seed(5)
mddb <- as.data.frame(cbind(resp.fil, preds.fil))

mddb.ord <- mddb[order(mddb$lumped_cond),]
mddb.train <- stratified(mddb, "lumped_cond", 1-(val/100))
mddb.val <- mddb.ord[(row.names(mddb) %in% row.names(mddb.train))==F,]


# summary(mddb.train$`Dist to road`)
# summary(mddb.val$`Dist to road`)

resp.fil <- mddb.train[,names(mddb.train) %in% names(resp.fil.orig)]
preds.fil <- mddb.train[,names(mddb.train) %in% names(preds.fil.orig)]

resp.val <- mddb.val[,names(mddb.val) %in% names(resp.fil.orig)]
preds.val <- mddb.val[,names(mddb.val) %in% names(preds.fil.orig)]

############### Culled - Correlated and non-useful vars removed ###############
#maybe cull some variables based on how correlated they are
print("removing correlated variables")
# Multicolinearity testing - function from Jeffrey Evans - uses QR Decomposition to 
# determine multicollinearity. 

# As of model runs on 1/27, only 1 collinear variable (CD-%forest (stays)), which I 
# knew. 
mc <- multi.collinear(preds.fil.orig, p=0.05)
#remove multicolinear preds
keepvars <- names(preds.fil.orig) %in% mc
preds.nomc <- preds.fil.orig[,keepvars==F]

# The step of manually removing some of the 50 variables really helped to 
# stabilize this variable selection - now not jumping from 9 vars to 31! Sticking
# right around 8. More interpretable now! And the randomforest performance is the
# same, so removing 20 variables right off the top did not negatively affect the mod.

# Check for important variables using all records.
# response <- factor(resp.fil.orig$lumped_cond, levels=c("poor/extinct", "fair", "good"))
response <- resp.fil.orig$lumped_cond
rf.nomc.sel <- rf.modelSel(preds.nomc, response, imp.scale="se", final=TRUE, plot.imp=TRUE, ntree=ntree, parsimony = 0.03)
plot(rf.nomc.sel)
rf.nomc.sel
rf.nomc.sel$selvars

# Now run rf with training and testing - did this and the results were good! But the model
# performs slightly better when using all of the condition data for training. 
# resp.train <- resp.fil$lumped_cond
# res.val <- resp.val$lumped_cond

# RF model with validation. This is to see how well we predict an independent validation data set,
# but ultimately, I want to use all of the observations to train the model (assuming we have
# good results here with an indep validation). Given the variation in collection methods and 
# condition ranking throughout different states, we can have a lot of variation in training data, 
# so I want to use all of that to create the final model. This model behaved VERY well, with
# an OOB accuracy of 87% and a test set accuracy of 98%.
# randfor.nomc <- randomForest(preds.fil[rf.nomc.sel$selvars], resp.train,importance=T, keep.forest = T, proximity=T,ntree=ntree, xtest = preds.val[rf.nomc.sel$selvars], ytest = res.val)
# randfor.nomc <- randomForest(preds.nomc[rf.nomc.sel$selvars], as.factor(resp.fil.orig$lumped_cond),importance=T, keep.forest = T, proximity=T,ntree=ntree)
# randfor.nomc
# varImpPlot(randfor.nomc, type=1)
# n <- length(resp.train)




# without validation:
rf.noval <- randomForest(preds.fil.orig[rf.nomc.sel$selvars], resp.fil.orig$lumped_cond, importance=T, keep.forest = T, proximity=T, ntree=ntree)
varImpPlot(rf.noval, type=1)
rf.noval
n <- length(resp.fil.orig$lumped_cond)



#some plotting for no-multicolinear vars model
pdf(file=paste(figdir,"rf_results_buff100m_", Sys.Date(),".pdf", sep=""),family="Times", width=7, height=7)
varImpPlot(rf.noval, pch=16, col="blue",type=1, main=paste("Variable Importance:\nPredicting Population Viability", sep=""))

# Some model stats
prediction <- (rf.noval$predicted)
xtab <- table(prediction, resp.fil.orig$lumped_cond)
cm <- confusionMatrix(xtab)
kap <- round(cm$overall[2],2)
overall.acc <- round(cm$overall[1],2)

# validation set
# prediction.val <- (randfor.nomc$test$predicted)
# xtab.val <- table(prediction.val, res.val)
# cm.val <- confusionMatrix(xtab.val)
# kap.val <- round(cm.val$overall[2],2)
# overall.acc.val <- round(cm.val$overall[1],2)

# Add some info to the varimpplot
conf.nomc <- rf.noval$confusion
conf.nomc[,4] <- round(conf.nomc[,4], digits=2)
colnames(conf.nomc)[4] <- "class accuracy"
conf.nomc[,4] <- (1 - conf.nomc[,4]) 
addtable2plot(x=50,y= 0.5,cex=0.85, table=conf.nomc, display.rownames = T)

# leg.txt <- bquote(atop("bootstrapped model accuracy" == ~.(overall.acc),
                       # "n" == ~.(n)))

bma <- paste0("bootstrapped model accuracy = ",overall.acc)
n.txt <- paste0("n = ", n)
# leg.txt <- bquote("bootstrapped accuracy" == ~.(overall.acc))
legend("topleft", legend=c(bma, n.txt), bty='n', cex=0.85, xjust=0, yjust=1)
# adj = c(0, 0.5),


# MDS plot is a PCA of the proximity matrix. The proximity matrix in a rf is:
# A matrix of proximity measures among the input (based on the frequency that 
# pairs of data points are in the same terminal nodes).
# the proximity matrix quantifies sample similarity.
ggplotColours <- function(n = 6, h = c(0, 360) + 15){
  if ((diff(h) %% 360) < 1) h[2] <- h[2] - 360/n
  hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}

# Get ggplot colors for MDS plot
# library(scales)
# show_col(ggplotColours(n=3))

MDSplot(rf.noval, resp.fil.orig$lumped_cond, palette=c("#F8766D", "#00BA38", "#619CFF"), main="EO Sample Similarity", 
        xlab="dimension 1", ylab="dimension 2")
legend("topleft", levels(resp.fil.orig$lumped_cond), col=c("#F8766D", "#00BA38", "#619CFF"), pch=19, bty='n', cex=0.9)

# palette=c("red", "green", "blue"), 
# col=c("red", "green", "blue"), 

# Boxplots
# Some box plots
model.vars <- cbind(resp.fil.orig$lumped_cond, preds.fil.orig[rf.nomc.sel$selvars])
## Rescale each column to range between 0 and 1 so we can display all on same graph.
range01 <- as.data.frame(apply(model.vars[2:dim(model.vars)[2]], MARGIN = 2, FUN = function(X) (X - min(X))/diff(range(X))))
model.vars.sc <- cbind(model.vars[,1], range01)
names(model.vars.sc)[1] <- "condition"
#for unscaled
#names(model.vars)[1] <- "condition"

melted <- melt(model.vars.sc, id.vars="condition")

# Try a boxplot
# For the purposes of making a meaningful figure, I removed 0's from the 
# melted object, which largely affects the wetland 2011 variable. But because I'm 
# plotting the box plots and histograms with the same Y axis, it's skewing everything
# and making it difficult to see trends (esp with the histograms). Removing 0 here does not
# change the data from the model and is only for visualization. Trends are the same.
melted.no0 <- melted[melted$value !=0,]
p <- ggplot(melted.no0, aes(variable, value))
bp <- p + geom_boxplot(aes(colour = condition), lwd=0.3, outlier.size=0.5) + 
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))
print(bp)


# Further data exploration - should really happen first, buuuut...
# histograms - by condition
# head(mddb)

hist.gg <- ggplot(melted.no0,aes(x = value, fill=condition)) + 
  facet_wrap(~variable,scales = "free_x") + 
  geom_histogram(bins=50) 

print(hist.gg)

sts <- boxplot.stats(melted.no0$value)$stats
sts.gg <- ggplot(melted.no0, aes(x= condition, y = value, fill = condition)) +
  geom_boxplot(lwd=0.3, outlier.size=0.5) +
  facet_wrap(~variable, scales="free") 
print(sts.gg)

dev.off()

save.image(paste0(figdir, "avaricosa_RF_model_final.Rdata"))
############################
