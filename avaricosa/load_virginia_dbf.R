require('foreign')
require(RPostgreSQL)

setwd('/Volumes/BlackOsprey/GIS_Data/States/Virginia/Data/shape/BrookFloater/Virginia')

con <- dbConnect(drv="PostgreSQL", host="127.0.0.1", user="jessebishop", dbname="blackosprey")

a <- read.dbf('VARICOSA.DBF')

for (i in 1:nrow(a)) {
    rec <- a[i,]
    state <- 'va'
    origfile <- 'VARICOSA.DBF'
    id <- rec$SITE_NO
    date <- rec$DATE
    waterway <- rec$WATERWAY
    popcond <- rec$ABUNDANCE
    comment1 <- rec$COMMENTS
    comment2 <- paste("numlive: ", rec$NUM_LIVE, " | numrelic: ", rec$NUM_RELIC, sep="")
    geom <- paste("ST_GeomFromText('POINT(", rec$LONGITUDE, " ", rec$LATITUDE, ")', 4326)", sep="")
    if (is.na(rec$LATITUDE)) {
        sql <- paste("INSERT INTO avaricosa.avaricosa_point (state, orig_file, id, last_obs, last_obs_date, last_survey, last_survey_date, pop_condition, comments1, comments2, waterway) VALUES ('", state, "', '", origfile, "', '", id, "', '", date, "', '", date, "', '", date, "', '", date, "', '", popcond, "', '", comment1, "', '", comment2, "', '", waterway, "');", sep="")
    } else {
        sql <- paste("INSERT INTO avaricosa.avaricosa_point (state, orig_file, id, last_obs, last_obs_date, last_survey, last_survey_date, pop_condition, comments1, comments2, geom, waterway) VALUES ('", state, "', '", origfile, "', '", id, "', '", date, "', '", date, "', '", date, "', '", date, "', '", popcond, "', '", comment1, "', '", comment2, "', ", geom, ", '", waterway, "');", sep="")
    }
    dbSendQuery(con,sql)
}

dbDisconnect(con)

