library(randomForest)
library(plotrix)
library(rfUtilities)
library(plyr)
library(ggplot2)
library(reshape)
library(RColorBrewer)
library(RPostgreSQL)



# load("/Users/tcormier/Documents/misc/avaricosa/ModelRun_20150127/avaricosa_model_20150127.RData")
figdir <- "/Users/tcormier/Documents/misc/avaricosa/ModelRun_20160410/"
ntree <- 10000

# Connect to database to retrieve summary table for modeling
con <- dbConnect(drv="PostgreSQL", host="192.168.1.100", user="jessebishop", dbname="blackosprey")
res.query <- "SELECT * FROM huc_12_summary_statistics_pct_aggregated_modeling;"
res <- dbGetQuery(con, res.query)

res$state <- as.factor(res$state)
res$symbol_pop_cond <- as.factor(res$symbol_pop_cond)
#res.fil <- res[res$multiple_conditions == F & (res$state == "nh" | res$state == "ma" | res$state == "me" | res$state == "vt" | res$state == "ct"),]
res.fil <- res[res$multiple_conditions == F,]
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
                "tmin_trend_mean", "tmin_trend_std_dev", "tmax_trend_mean", "tmax_trend_std_dev")
preds <- res.fil[,keep.preds]
better.names <- c("%Developed 1992", "%Barren 1992", "%Forest 1992", "%Shrub1992", "%Wetland 1992", "Mean Canopy Density 2011", "Std dev Canopy Density 2011", 
                  "Max Canopy Density 2011", "Mean Imperviousness 2011", "Std dev Imperviousness 2011", "Max Imperviousness 2011", "%Developed 2011", "%Barren 2011",
                  "%Forest 2011", "%Shrub 2011", "%Herbacious 2011", "%Ag 2011", "%Wetland 2011", "%Developed Change 2001-2011", "%Barren Change 2001-2011", 
                  "%Forest Change 2001-2011", "%Shrub Change 2001-2011", "%Herbaceous Change 2001-2011", "%Ag Change 2001-2011", "%Wetland Change 2001-2011", "Mean Slope",
                  "Std dev Slope", "Max Slope", "Mean PPT Trend 1895-2012", "Std dev PPT Trend 1895-2012", "Mean Tmin Trend 1895-2012", "Std dev Tmin Trend 1895-2012",
                  "Mean Tmax Trend 1895-2012", "Std dev Tmax Trend 1895-2012")
names(preds) <- better.names

resp <- as.data.frame(droplevels(res.fil$symbol_pop_cond))
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

resp$lumped_cond <- factor(resp$lumped_cond, levels=c("good","fair","poor/extinct"))
preds.fil <- preds[!(is.na(resp$lumped_cond)),]
resp.fil <- na.omit(resp)

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
mc <- multi.collinear(preds.fil, p=0.05)
#remove multicolinear preds
keepvars <- names(preds.fil) %in% mc
preds.nomc <- preds.fil[,keepvars==F]
# preds.nomc <- preds.fil[, -6]

# Try stratified sampling because very unbalanced - many poor/extinct observations and few
# good and fair.



# The step of manually removing some of the 50 variables really helped to 
# stabilize this variable selection - now not jumping from 9 vars to 31! Sticking
# right around 8. More interpretable now! And the randomforest performance is the
# same, so removing 20 variables right off the top did not negatively affect the mod.
rf.nomc.sel <- rf.modelSel(preds.nomc, as.factor(resp.fil$lumped_cond), imp.scale="mir", final=TRUE, plot.imp=TRUE, parsimony=0.03, ntree=ntree)
randfor.nomc <- randomForest(preds.fil[rf.nomc.sel$selvars],as.factor(resp.fil$lumped_cond),importance=T, keep.forest = T, proximity=T,ntree=ntree)

# With stratified sampling (Better for two rare classes, a bit worse for poor class) - upped ntrees to try to ensure each sample
# from every class appears in a models at least a few times:
rf.nomc.sel.strat <- rf.modelSel(preds.nomc, as.factor(resp.fil$lumped_cond),strata=as.factor(resp.fil$lumped_cond), sampsize=c(29,29,29), imp.scale="mir", final=TRUE, plot.imp=TRUE, parsimony=0.03, ntree=ntree)
randfor.nomc.strat <- randomForest(preds.fil[rf.nomc.sel$selvars],as.factor(resp.fil$lumped_cond),strata=as.factor(resp.fil$lumped_cond), sampsize=c(29,29,29),importance=T, keep.forest = T, proximity=T,ntree=ntree)

# With class weights - WORSE!
# rf.nomc.sel.wt <- rf.modelSel(preds.nomc, as.factor(resp.fil$lumped_cond), classwt=c(80, 80, 10), imp.scale="mir", final=TRUE, plot.imp=TRUE, parsimony=0.03, ntree=ntree)
# randfor.nomc.wt <- randomForest(preds.fil[rf.nomc.sel$selvars],as.factor(resp.fil$lumped_cond), classwt=c(80,80,10), importance=T, keep.forest = T, proximity=T,ntree=ntree)


# Add these arguments to both lines above to add stratified sampling
# strata=as.factor(resp.fil$lumped_cond)
# sampsize=c(25,25,25)
#some plotting for no-multicolinear vars model
pdf(file=paste(figdir,"rf_results_HUC12_", Sys.Date(),".pdf", sep=""),family="Times", width=7, height=7)
varImpPlot(randfor.nomc, pch=16, col="blue",type=1, main=paste("Variable Importance:\nPredicting Population Viability", sep=""))
# hardcoded for the moment - subject to change with a different model!
#row.names(vip) <- c("mean tmax trend", "mean tmin trend","sd of slope", "mean slope", "1992 imp surface", 
 #                   "sd elev", "max elev", "2011 imp surface", "2011 shrub cover")

#leg.txt <- c(as.expression(bquote("error rate" == ~.(round(randfor$err.rate[length(randfor$err.rate)], digits=2)))), 
#             as.expression(bquote("confusion matrix" == .(randfor$confusion))))
conf.nomc <- randfor.nomc$confusion
conf.nomc[,4] <- round(conf.nomc[,4], digits=2)
addtable2plot(x=53,y= 0.5,cex=0.85, table=conf.nomc, display.rownames = T)
leg.txt <- c(as.expression(bquote("accuracy" == ~.(1-round(randfor.nomc$err.rate[dim(randfor.nomc$err.rate)[1],1], digits=2)))))
legend("topleft", legend=leg.txt, bty='n')

# MDS plot is a PCA of the proximity matrix. The proximity matrix in a rf is:
# A matrix of proximity measures among the input (based on the frequency that 
# pairs of data points are in the same terminal nodes).
# the proximity matrix quantifies sample similarity.
MDSplot(randfor.nomc, as.factor(resp.fil$lumped_cond), palette=c("green", "blue", "red"), main=
          "EO Sample Similarity", xlab="dimension 1", ylab="dimension 2")
legend("topleft", levels(resp.fil$lumped_cond), col=c("green", "blue", "red"), pch=19, bty='n', cex=0.9)

#dev.off()

# Some box plots
model.vars <- cbind(as.factor(resp.fil$lumped_cond), preds.fil[rf.nomc.sel$selvars])

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
dev.off()


# Find out the names of the chosen variables and re-name them to something helpful!
# orig.names <- unique(melted$variable)
# xnames <- c("% Forest 1992", "% Ag 1992", "Mean Canopy Density 2011", "% Developed 2011", 
#             "% Forest 2011", "% Herbaceous 2011", "Std dev slope", "Mean PPT Trend")
# Rename them manually here


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


# Prediction of HUC 12s
huc.query <- "SELECT * FROM huc_12_summary_statistics_pct_aggregated_predicting;"
huc <- dbGetQuery(con, huc.query)

huc.pred <- huc[,keep.preds]
huc.pred <- data.frame(huc$huc_12, huc.pred, stringsAsFactors=F)
names(huc.pred)[1] <- "huc_12"
huc.pred <- huc.pred[complete.cases(huc.pred),]
names(huc.pred)[-1] <- better.names
prediction <- as.character(predict(randfor.nomc, huc.pred))
pred.table <- data.frame(huc.pred$huc_12, prediction, stringsAsFactors=F)
names(pred.table) <- c("huc_12", "prediction")
write.csv(pred.table, file=paste0(figdir, "huc12_predictions.csv"), quote=F, row.names=F)





dbDisconnect(con)


############### Kitchen Sink Model - non-useful vars removed ###############
#kitchen sink model - multicollinear variables included, but non-useful variables are not
rf.ks.sel <- rf.modelSel(preds.fil, as.factor(resp.fil$lumped_cond), imp.scale="mir", final=TRUE, plot.imp=TRUE, parsimony=0.03, ntree=500)
randfor.ks <- randomForest(preds.fil[rf.ks.sel$SELVARS],as.factor(resp.fil$lumped_cond),importance=T, keep.forest = T)

#some plotting for kitchen sink model
varImpPlot(randfor.ks, pch=16, col="blue",type=1,main=paste("Variable Importance:\nPredicting Population Viability", sep=""))
#leg.txt <- c(as.expression(bquote("error rate" == ~.(round(randfor$err.rate[length(randfor$err.rate)], digits=2)))), 
#             as.expression(bquote("confusion matrix" == .(randfor$confusion))))
conf.ks <- randfor.ks$confusion
conf.ks[,4] <- round(conf.ks[,4], digits=2)
addtable2plot(x=13,y= 1,cex=0.75, table=conf.ks, display.rownames = T)
leg.txt <- c(as.expression(bquote("error rate" == ~.(round(randfor.ks$err.rate[dim(randfor.ks$err.rate)[1],1], digits=2)))))
legend("topleft", legend=leg.txt, bty='n', cex=0.85)

# MDS plot is a PCA of the proximity matrix. The proximity matrix in a rf is:
# A matrix of proximity measures among the input (based on the frequency that 
# pairs of data points are in the same terminal nodes).

MDSplot(randfor.nomc, as.factor(resp.fil$lumped_cond), palette=c("blue", "green", "red"))
legend("topleft", levels(resp.fil$lumped_cond), col=c("blue", "green", "red"), pch=19)


