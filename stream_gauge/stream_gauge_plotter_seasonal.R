#site <- '01173500'
#huc <- '01080204'
#site <- '01073260'
site <- '01073000'
huc <- '01060003'


library(RPostgreSQL)

# Connect to database
con <- dbConnect(drv="PostgreSQL", host="127.0.0.1", user="jessebishop", dbname="blackosprey")

# Get information about the site
query <- paste("SELECT station_nm FROM usgs_streamgauges WHERE site_no = '", site, "';", sep="")
stationname <- dbGetQuery(con, query)
query <- paste("SELECT hu_8_name FROM nhd_hu8_watersheds WHERE huc_8_num = ", huc, ";", sep="")
hucname <- dbGetQuery(con, query)

# Data getting
query <- paste("SELECT avg(discharge_mean::numeric) AS avg, min(datetime) AS mdate, date_part('year', datetime) AS year, date_part('month', datetime) AS month FROM usgs_stream_gauge_daily where huc_8_num = ", huc, " AND site_no = '", site, "' GROUP BY date_part('year', datetime), date_part('month', datetime) order by date_part('year', datetime), date_part('month', datetime);", sep="")

df.avg <- dbGetQuery(con, query)

#query <- paste("SELECT min(discharge_mean::numeric) AS min, avg(discharge_mean::numeric) AS avg, max(discharge_mean::numeric) AS max, min(datetime) AS mdate, year, season FROM usgs_stream_gauge_seasons  WHERE huc_8_num = ", huc, " AND site_no = '", site, "' GROUP BY year, season ORDER BY year, CASE WHEN season = 'winter' THEN 1 WHEN season = 'spring' THEN 2 WHEN season = 'summer' THEN 3 ELSE 4 END;", sep='')

query <- paste("SELECT min(discharge_mean::numeric) AS min, max(discharge_mean::numeric) AS max, min(datetime) AS mdate, date_part('year', datetime) AS year, flow FROM usgs_stream_gauge_minmax_flow WHERE huc_8_num = ", huc, " AND site_no = '", site, "' AND NOT flow = 'other' GROUP BY year, flow ORDER BY year, flow;", sep='')

df <- dbGetQuery(con, query)
df.min <- subset(df, df$flow == 'min')
df.max <- subset(df, df$flow == 'max')


# Plotting (for mapbook, we may want to arrange these in a layout on one page)
setwd('/Volumes/BlackOsprey/MapBook/StreamGauge/')
fname.avg <- paste('huc_', huc, '_site_', site, '_seasonal_average.pdf', sep='')
fname.min <- paste('huc_', huc, '_site_', site, '_summer_minimum.pdf', sep='')
fname.max <- paste('huc_', huc, '_site_', site, '_spring_maximum.pdf', sep='')

main <- paste("Watershed: ", hucname$hu_8_name, " (", huc, ")\nSite: ", stationname$station_nm, " (", site, ")\n\n", sep="")

minyear <- min(as.POSIXlt(paste(format(df.avg$mdate, "%Y"), "-01-01", sep="")))
maxyear <- max(as.POSIXlt(paste(format(df.avg$mdate, "%Y"), "-01-01", sep="")))

pdf(file=fname.avg, 10, 7.5)
plot(df.avg$mdate, df.avg$avg, type='l', col='black', main=paste(main,"Mean Monthly Stream Flow Measurement (USGS)", sep=""), xlab='Measurement Date', ylab='Mean Discharge (cfs)', cex.main=0.90, cex.lab=0.80, cex.axis=0.80, cex=0.80, las=2)
lm <- lm(df.avg$avg ~ df.avg$mdate)
abline(lm, col='deepskyblue')
legend("topright", paste("Trend",round(lm$coefficients[2] * 10, 3), "(cfs/decade)", sep=" "), lty=1, col="deepskyblue",bty="n", cex=0.80)
dev.off()

pdf(file=fname.min, 10, 7.5)
plot(df.min$mdate, df.min$min, type='l', col='black', main=paste(main,"Minimum Late Summer Stream Flow Measurement (USGS)", sep=""), xlab='Measurement Date', ylab='Mean Discharge (cfs)', cex.main=0.90, cex.lab=0.80, cex.axis=0.80, cex=0.80)
lm <- lm(df.min$min ~ df.min$mdate)
abline(lm, col='deepskyblue')
legend("topright", paste("Trend",round(lm$coefficients[2] * 10, 3), "(cfs/decade)", sep=" "), lty=1, col="deepskyblue",bty="n", cex=0.80)
dev.off()

pdf(file=fname.max, 10, 7.5)
plot(df.max$mdate, df.max$max, type='l', col='black', main=paste(main,"Maximum Spring Stream Flow Measurement (USGS)", sep=""), xlab='Measurement Date', ylab='Mean Discharge (cfs)', cex.main=0.90, cex.lab=0.80, cex.axis=0.80, cex=0.80)
lm <- lm(df.max$max ~ df.max$mdate)
abline(lm, col='deepskyblue')
legend("topright", paste("Trend",round(lm$coefficients[2] * 10, 3), "(cfs/decade)", sep=" "), lty=1, col="deepskyblue",bty="n", cex=0.80)
dev.off()

pdf(file=paste('barplot_', fname.min, sep=''), 10, 7.5)
barplot(df.min$min, main=paste(main,"Minimum Late Summer Stream Flow Measurement (USGS)", sep=""), xlab='Measurement Date', ylab='Mean Discharge (cfs)', cex.main=0.90, cex.lab=0.80, cex.axis=0.80, cex=0.80, col='dodgerblue3', names.arg=df.min$year, las=2)
abline(h=mean(df.min$min), col='darkblue')
legend("topright", paste("Average Minimum Flow",round(mean(df.min$min),2), "cfs", sep=" "), lty=1, col="darkblue",bty="n", cex=0.80)
dev.off()

pdf(file=paste('barplot_', fname.max, sep=''), 10, 7.5)
barplot(df.max$max, main=paste(main,"Maximum Late Summer Stream Flow Measurement (USGS)", sep=""), xlab='Measurement Date', ylab='Mean Discharge (cfs)', cex.main=0.90, cex.lab=0.80, cex.axis=0.80, cex=0.80, col='dodgerblue3', names.arg=df.max$year, las=2)
abline(h=mean(df.max$max), col='darkblue')
legend("topright", paste("Average Maximum Flow",round(mean(df.max$max),2), "cfs", sep=" "), lty=1, col="darkblue",bty="n", cex=0.80)
dev.off()
