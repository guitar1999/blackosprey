#!/bin/bash
## NJ
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname BrookFloater_lines_20130605_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NJ | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_line (orig_file,last_obs,comments2,comments1,state,pop_condition,id,geom) SELECT 'BrookFloater_lines_20130605_wgs84.shp', last_obs_d,directions,feat_desc,'nj',basic_eo_r,eo_id, geom FROM avaricosa.temp_NJ;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NJ;"

## DE
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname DE_redclaycreek_EOR.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_DE | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_line (orig_file,last_obs,comments1,state,id,geom) SELECT 'DE_redclaycreek_EOR.shp', last_obs,comments,'de',id, ST_Force_2D(geom) FROM avaricosa.temp_DE;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_DE;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_line SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_line.geom);
"psql -d blackosprey -c "UPDATE avaricosa.avaricosa_line SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_line.geom);"
