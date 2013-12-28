#!/bin/bash
## NJ
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname BrookFloater_pts_20130605_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NJ | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,last_obs,comments2,comments1,state,pop_condition,id,geom) SELECT 'BrookFloater_pts_20130605_wgs84.shp', last_obs_d,directions,feat_desc,'nj',basic_eo_r,eo_id, geom FROM avaricosa.temp_NJ;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NJ;"

## NY
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Neversink_pts_AV_only.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NY | psql -d blackosprey
psql -d blackosprey -c "ALTER TABLE temp_ny ALTER COLUMN geom TYPE geometry(Point,4326) USING ST_GeometryN(geom, 1);" 
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,last_obs,comments1,state,last_survey,id,geom) SELECT 'Neversink_pts_AV_only.shp', sampledate,d_size,'ny',sampledate,site_id, geom FROM avaricosa.temp_NY;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NY;"

## ME
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Brook_Floaters_20131022_WGS84_joined_attributes.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_ME | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,last_obs,comments2,comments1,state,last_survey,pop_condition,id,geom) SELECT 'Brook_Floaters_20131022_WGS84_joined_attributes.shp', obsdate,notes,habitat_de,'me',obsdate,observatio,obsid, geom FROM avaricosa.temp_ME;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_ME;"

## WV
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname AtlanticSlopeAvaricosa1_24_2013_fromexcel_PRESENCEonly.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_WV | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,last_obs,comments1,state,id,geom) SELECT 'AtlanticSlopeAvaricosa1_24_2013_fromexcel_PRESENCEonly.shp', eventdate,notes,'wv',eventid, geom FROM avaricosa.temp_WV;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_WV;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_point SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_point.geom);"
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_point SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_point.geom);"
