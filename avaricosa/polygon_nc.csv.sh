#!/bin/bash
## NC
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Avaricosa_polygon_record8699_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NC | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,last_survey,pop_condition,location_quality,first_obs,id,geom) SELECT 'Avaricosa_polygon_record8699_wgs84.shp', last_obs,surveysite,eo_data,'nc',surveydate,eo_rank,accuracy,first_obs,eo_id, geom FROM avaricosa.temp_NC;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NC;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_polygon SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_polygon.geom) AND avaricosa.avaricosa_polygon.huc_8_num IS NULL;"
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_polygon SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_polygon.geom) AND avaricosa.avaricosa_polygon.huc_8_name IS NULL;"
