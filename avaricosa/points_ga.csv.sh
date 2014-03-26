#!/bin/bash
## GA
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname A.varicosa_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_GA | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,last_obs,comments2,comments1,state,pop_condition,id,geom) SELECT 'A.varicosa_wgs84.shp', date,waterbody,site_desc,'ga',relative_a,site_num, geom FROM avaricosa.temp_GA;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_GA;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_point SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_point.geom) AND avaricosa.avaricosa_point.huc_8_num IS NULL;"
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_point SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_point.geom) AND avaricosa.avaricosa_point.huc_8_name IS NULL;"
