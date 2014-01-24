#site <- '01173500'
#huc <- '01080204'
#site <- '01073260'
site <- '01073600'
huc <- '01060003'


library(RPostgreSQL)

# Connect to database
con <- dbConnect(drv="PostgreSQL", host="127.0.0.1", user="jessebishop", dbname="blackosprey")

query <- "SELECT avg(discharge_mean::numeric) AS avg, min(datetime) AS mdate, date_part('year', datetime) AS year, date_part('month', datetime) AS month FROM usgs_stream_gauge_daily where huc_8_num = 1080204 and site_no = 01173500 GROUP BY date_part('year', datetime), date_part('month', datetime) order by date_part('year', datetime), date_part('month', datetime); "

query <- paste("SELECT min(discharge_mean::numeric) AS min, avg(discharge_mean::numeric) AS avg, max(discharge_mean::numeric) AS max, min(datetime) AS mdate, year, season FROM usgs_stream_gauge_seasons  WHERE huc_8_num = ", huc, " AND site_no = '", site, "' GROUP BY year, season ORDER BY year, CASE WHEN season = 'winter' THEN 1 WHEN season = 'spring' THEN 2 WHEN season = 'summer' THEN 3 ELSE 4 END;", sep='')

df <- dbGetQuery(con, query)

setwd('/Volumes/BlackOsprey/MapBook/StreamGauge/')
fname <- 'huc_01080204_site_01173500_manual.pdf'

pdf(file=fname, 10, 7.5)
plot(df$mdate, df$avg, type='l', col='black', main='Watershed: Chicopee (1080204)\nSite: WARE RIVER AT GIBBS CROSSING, MA (01173500)\n\nMean Montly Stream Flow Measurement (USGS)', xlab='Measurement Date', ylab='Mean Discharge (cfs)', cex.main=0.90, cex.lab=0.80, cex.axis=0.80, cex=0.80)
lm <- lm(df$avg ~ df$mdate)
abline(lm, col='deepskyblue')
legend("topright", paste("Trend",round(lm$coefficients[2] * 10, 3), "(cfs/decade)", sep=" "), lty=1, col="deepskyblue",bty="n", cex=0.80)
dev.off()
