#!/bin/bash
## CT
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname ct_av_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_CT | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments1,state,pop_condition,location_quality,id,geom) SELECT 'ct_av_wgs84.shp', last_obs_d,mgmt_com,'ct',basic_eo_r,est_acc,eo_id, geom FROM avaricosa.temp_CT;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_CT;"

## MD
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname MDDNR_Alasvari_ALL_2013_04_08_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_MD | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,last_survey,pop_condition,location_quality,first_obs,id,geom) SELECT 'MDDNR_Alasvari_ALL_2013_04_08_wgs84.shp', last_obs_d,eorank_com,mgmt_com,'md',survey_dat,eorank,precision,first_obs_,eo_id, geom FROM avaricosa.temp_MD;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_MD;"

## MA
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname A_varicosa_EOs_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_MA | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,last_survey,first_obs,id,geom) SELECT 'A_varicosa_EOs_wgs84.shp', last_obs_y,general_co,mgmt_com,'ma',survey_dat,first_obs_,eo_id, geom FROM avaricosa.temp_MA;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_MA;"

## NH
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname nhb_rep_wgs84_Qccomplete.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NH | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments1,state,last_survey,pop_condition,location_quality,first_obs,id,geom) SELECT 'nhb_rep_wgs84_Qccomplete.shp', lastobs,surveysite,'nh',surveydate,eorank,precision,firstobs,eo_id, geom FROM avaricosa.temp_NH;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NH;"

## NJ
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname BrookFloater_polys_20130605_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NJ | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,pop_condition,id,geom) SELECT 'BrookFloater_polys_20130605_wgs84.shp', last_obs_d,directions,feat_desc,'nj',basic_eo_r,eo_id, geom FROM avaricosa.temp_NJ;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NJ;"

## NY
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname A_varicosa_NY_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NY | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,last_survey,pop_condition,location_quality,first_obs,id,geom) SELECT 'A_varicosa_NY_wgs84.shp', last_obs,gen_desc_1,obseodata,'ny',surveydate,eo_rank,loq_qual,first_obs,eo_id, geom FROM avaricosa.temp_NY;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NY;"

## PA
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname PA_Element_Occurrences_joined.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_PA | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments1,state,pop_condition,location_quality,first_obs,id,geom) SELECT 'PA_Element_Occurrences_joined.shp', last_obser,eo_rank_co,'pa',eo_rank,loq_qual,first_obse,eo_id, geom FROM avaricosa.temp_PA;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_PA;"

## VT
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Brook_Floater_EOs_VT_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_VT | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,last_survey,pop_condition,first_obs,id,geom) SELECT 'Brook_Floater_EOs_VT_wgs84.shp', last_obs,eorankcom1,eo_data1,'vt',surveydate,eo_rank,first_obs,eo_id, geom FROM avaricosa.temp_VT;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_VT;"

## VA
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Barry_Wicklow_20130123_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_VA | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments1,state,id,geom) SELECT 'Barry_Wicklow_20130123_wgs84.shp', obsdate,comments,'va',obsid, geom FROM avaricosa.temp_VA;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_VA;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_polygon SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_polygon.geom);
"psql -d blackosprey -c "UPDATE avaricosa.avaricosa_polygon SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_polygon.geom);"
