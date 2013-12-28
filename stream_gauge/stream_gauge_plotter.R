site <- '01173500'
huc <- '01080204'

library(RPostgreSQL)

# Connect to database
con <- dbConnect(drv="PostgreSQL", host="127.0.0.1", user="jessebishop", dbname="blackosprey")

query <- "SELECT avg(discharge_mean::numeric) AS avg, min(datetime) AS mdate, date_part('year', datetime) AS year, date_part('month', datetime) AS month FROM usgs_stream_gauge_daily where huc_8_num = 1080204 and site_no = 01173500 GROUP BY date_part('year', datetime), date_part('month', datetime) order by date_part('year', datetime), date_part('month', datetime); "

df <- dbGetQuery(con, query)

plot(df$mdate, df$avg, type='l')

