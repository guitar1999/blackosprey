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
figdir <- "/Users/tcormier/Documents/misc/avaricosa/ModelRun_20160927/"
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
                  "Std dev Slope", "Max Slope", "Mean PPT Trend 1895-2012", "Std dev PPT Trend 1895-2012", "Mean Tmin Trend 1895-2012", "Std dev Tmin Trend 1895-2012",
                  "Mean Tmax Trend 1895-2012", "Std dev Tmax Trend 1895-2012", "Dist to road")
names(preds) <- better.names

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

# # STOP
# Even out the classes to see if that improves accuracy of poor class (from 9/9/2016 run)
# can comment this out to skip it.
# nsamp <- min(table(resp.fil$lumped_cond))

# random.rows <- unlist(tapply(1:nrow(resp.fil), resp.fil$lumped_cond, sample, nsamp))
# preds.fil.orig <- preds.fil
# resp.fil.orig <- resp.fil
# resp.fil <- resp.fil[random.rows,]
# preds.fil <- preds.fil[random.rows,]

# Select stratified random sample for training and testing
# set.seed(5)
mddb <- as.data.frame(cbind(resp.fil, preds.fil))

# Filter outliers?
# DO: Look for outliers in predictors - for instance, in dist to roads: - look at histograms
# mddb <- mddb[mddb$`Dist to road` < 1000,]

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
#s.cor <- cor(preds.fil, method="spearman")

# Multicolinearity testing - function from Jeffrey Evans - uses QR Decomposition to 
# determine multicollinearity. This is currently unstable in the # of variables
# it chooses I think because we don't have enough samples. I tried as many as 50,000
# trees (ntree) and it still doesn't become stable. Wavering between 9, 18, and 25. My
# guess is because when we have so few samples, a randomly different model could have one
# or two differences in the confusion matrix and cause large changes in accuracy. Hopefully
# this sorts out as we add data from other states.

# As of model runs on 1/27, only 1 collinear variable (CD-%forest (stays)), which I 
# knew. 
mc <- multi.collinear(preds.fil.orig, p=0.05)
#remove multicolinear preds
keepvars <- names(preds.fil.orig) %in% mc
preds.nomc <- preds.fil.orig[,keepvars==F]
# preds.nomc <- preds.fil[, -6]

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
# rf.nomc.sel$selvars <- c(rf.nomc.sel$selvars, "Dist to road")

# Now run rf with training and testing
resp.train <- resp.fil$lumped_cond
resp.val <- resp.val$lumped_cond
randfor.nomc <- randomForest(preds.fil[rf.nomc.sel$selvars],resp.train,importance=T, keep.forest = T, proximity=T,ntree=ntree, xtest = preds.val[rf.nomc.sel$selvars], ytest = resp.val)
# randfor.nomc <- randomForest(preds.nomc[rf.nomc.sel$selvars], as.factor(resp.fil.orig$lumped_cond),importance=T, keep.forest = T, proximity=T,ntree=ntree)
randfor.nomc

n <- length(resp.train)

# we actually do a few % better by culling variables (randfor.nomc)
# randfor.all <- randomForest(preds.fil,resp.train,importance=T, keep.forest = T, proximity=T,ntree=ntree, xtest = preds.val, ytest = resp.val)
# # varImpPlot(randfor.all, pch=16, col="blue",type=1, main=paste("Variable Importance:\nPredicting Population Viability", sep=""))
# randfor.all

#some plotting for no-multicolinear vars model
pdf(file=paste(figdir,"rf_results_buff500m_", Sys.Date(),".pdf", sep=""),family="Times", width=7, height=7)
varImpPlot(randfor.nomc, pch=16, col="blue",type=1, main=paste("Variable Importance:\nPredicting Population Viability", sep=""))
# hardcoded for the moment - subject to change with a different model!
#row.names(vip) <- c("mean tmax trend", "mean tmin trend","sd of slope", "mean slope", "1992 imp surface", 
 #                   "sd elev", "max elev", "2011 imp surface", "2011 shrub cover")

#leg.txt <- c(as.expression(bquote("error rate" == ~.(round(randfor$err.rate[length(randfor$err.rate)], digits=2)))), 
#             as.expression(bquote("confusion matrix" == .(randfor$confusion))))
# 
prediction <- (randfor.nomc$predicted)
xtab <- table(prediction, resp.train)
cm <- confusionMatrix(xtab)
kap <- round(cm$overall[2],2)
overall.acc <- round(cm$overall[1],2)

prediction.val <- (randfor.nomc$test$predicted)
xtab.val <- table(prediction.val, resp.val)
cm.val <- confusionMatrix(xtab.val)
kap.val <- round(cm.val$overall[2],2)
overall.acc.val <- round(cm.val$overall[1],2)


# cm.table <- cm$table
# cm.table$class_accuracy <- as.vector(cm$byClass[,1])

# multiclass.roc(response, prediction)


conf.nomc <- randfor.nomc$confusion
conf.nomc[,4] <- round(conf.nomc[,4], digits=2)
colnames(conf.nomc)[4] <- "class accuracy"
conf.nomc[,4] <- (1 - conf.nomc[,4]) 
addtable2plot(x=100,y= 0.5,cex=0.85, table=conf.nomc, display.rownames = T)
# leg.txt <- c(as.expression(bquote("overall accuracy" == ~.(overall.acc))))
leg.txt <- bquote(atop("bootstrapped accuracy" == ~.(overall.acc),
                       "validation accuracy" == ~.(overall.acc.val)))
legend("topleft", legend=leg.txt, bty='n', adj = c(0, 0.5), cex=0.85)

# FIX this - seems like the points are garbled - might have to do with factor levels
# and not keeping them straight all the way though.
# MDS plot is a PCA of the proximity matrix. The proximity matrix in a rf is:
# A matrix of proximity measures among the input (based on the frequency that 
# pairs of data points are in the same terminal nodes).
# the proximity matrix quantifies sample similarity.
MDSplot(randfor.nomc, response, palette=c("purple", "green", "red"), main=
          "EO Sample Similarity", xlab="dimension 1", ylab="dimension 2")
legend("topright", levels(response), col=c("red", "green", "blue"), pch=19, bty='n', cex=0.9)

#dev.off()

# Some box plots
model.vars <- cbind(response, preds.fil.orig[rf.nomc.sel$selvars])

## Rescale each column to range between 0 and 1 so we can display all on same graph.
range01 <- as.data.frame(apply(model.vars[2:dim(model.vars)[2]], MARGIN = 2, FUN = function(X) (X - min(X))/diff(range(X))))
model.vars.sc <- cbind(model.vars[,1], range01)
names(model.vars.sc)[1] <- "condition"
#for unscaled
#names(model.vars)[1] <- "condition"

melted <- melt(model.vars.sc, id.vars="condition")

# Try a boxplot
p <- ggplot(melted, aes(variable, value))
bp <- p + geom_boxplot(aes(colour = condition)) + 
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))
print(bp)



# Find out the names of the chosen variables and re-name them to something helpful!
# orig.names <- unique(melted$variable)
# xnames <- c("% Forest 1992", "% Ag 1992", "Mean Canopy Density 2011", "% Developed 2011", 
#             "% Forest 2011", "% Herbaceous 2011", "Std dev slope", "Mean PPT Trend")
# Rename them manually here

# Further data exploration - should really happen first, buuuut...
# histograms - by condition
# head(mddb)
hist <- ggplot(melted,aes(x = value, fill=condition)) + 
  facet_wrap(~variable,scales = "free_x") + 
  geom_histogram(bins=50) 

hist


# separate box plots
# compare different sample populations across various temperatures
sts <- boxplot.stats(melted$value)$stats
ggplot(melted, aes(x= condition, y = value, fill = condition)) +
  geom_boxplot() +
  facet_wrap(~variable, scales="free") 



#for unscaled
#melted <- melt(model.vars, id.vars="condition")

# means <- ddply(melted, c("condition", "variable"), summarise,
#                mean=mean(value))
# 
# # means.barplot <- qplot(x=condition, y=mean, fill=variable,
# #                        data=means, geom="bar", stat="identity",
# #                        position="dodge")
# cp <- c("#5AAE61","#80B1D3","#D6604D")
# cp <- rev(brewer.pal(3, "Set1"))
# 
# means.barplot <- qplot(x=variable, y=mean, fill=condition, alpha=I(0.7),
#                        data=means, geom="bar", stat="identity",
#                        position="dodge")
# means.barplot <- means.barplot + scale_fill_manual(values = cp) + theme_bw() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1))
# 
# print(means.barplot)
dev.off()

# Prediction of HUC 12s
# huc.query <- "SELECT * FROM huc_12_summary_statistics_pct_aggregated_predicting;"
# huc <- dbGetQuery(con, huc.query)
# 
# huc.pred <- huc[,keep.preds]
# huc.pred <- data.frame(huc$huc_12, huc.pred, stringsAsFactors=F)
# names(huc.pred)[1] <- "huc_12"
# huc.pred <- huc.pred[complete.cases(huc.pred),]
# names(huc.pred)[-1] <- better.names
# prediction <- as.character(predict(randfor.nomc, huc.pred))
# pred.table <- data.frame(huc.pred$huc_12, prediction, stringsAsFactors=F)
# names(pred.table) <- c("huc_12", "prediction")
# write.csv(pred.table, file=paste0(figdir, "huc12_predictions.csv"), quote=F, row.names=F)
# 

dbDisconnect(con)


############### Kitchen Sink Model - non-useful vars removed ###############
# #kitchen sink model - multicollinear variables included, but non-useful variables are not
# rf.ks.sel <- rf.modelSel(preds.fil, as.factor(resp.fil$lumped_cond), imp.scale="mir", final=TRUE, plot.imp=TRUE, parsimony=0.03, ntree=500)
# randfor.ks <- randomForest(preds.fil[rf.ks.sel$SELVARS],as.factor(resp.fil$lumped_cond),importance=T, keep.forest = T)
# 
# #some plotting for kitchen sink model
# varImpPlot(randfor.ks, pch=16, col="blue",type=1,main=paste("Variable Importance:\nPredicting Population Viability", sep=""))
# #leg.txt <- c(as.expression(bquote("error rate" == ~.(round(randfor$err.rate[length(randfor$err.rate)], digits=2)))), 
# #             as.expression(bquote("confusion matrix" == .(randfor$confusion))))
# conf.ks <- randfor.ks$confusion
# conf.ks[,4] <- round(conf.ks[,4], digits=2)
# addtable2plot(x=13,y= 1,cex=0.75, table=conf.ks, display.rownames = T)
# leg.txt <- c(as.expression(bquote("error rate" == ~.(round(randfor.ks$err.rate[dim(randfor.ks$err.rate)[1],1], digits=2)))))
# legend("topleft", legend=leg.txt, bty='n', cex=0.85)
# 
# # MDS plot is a PCA of the proximity matrix. The proximity matrix in a rf is:
# # A matrix of proximity measures among the input (based on the frequency that 
# # pairs of data points are in the same terminal nodes).
# 
# MDSplot(randfor.nomc, as.factor(resp.fil$lumped_cond), palette=c("blue", "green", "red"))
# legend("topleft", levels(resp.fil$lumped_cond), col=c("blue", "green", "red"), pch=19)
# 
# 
