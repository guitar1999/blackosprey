#!/bin/bash
## NC
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Avaricosa_NC_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_NC | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,comments2,comments1,state,id,geom) SELECT 'Avaricosa_NC_wgs84.shp', habitat,comments,'nc',station, geom FROM avaricosa.temp_NC;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_NC;"

## SC
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname Avaricosa_SC_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_SC | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_point (orig_file,comments2,comments1,state,id,geom) SELECT 'Avaricosa_SC_wgs84.shp', habitat,comments,'sc',station, geom FROM avaricosa.temp_SC;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_SC;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_point SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_point.geom);"
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_point SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_point.geom);"
