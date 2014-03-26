#!/bin/bash
## SC
sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname SAC_Alas_vari_SC_wgs84.shp)
shp2pgsql -s 4326 $sf avaricosa.temp_SC | psql -d blackosprey
psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_polygon (orig_file,last_obs,comments2,comments1,state,pop_condition,first_obs,id,geom) SELECT 'SAC_Alas_vari_SC_wgs84.shp', last_obser,directions,comment1,'sc',eo_rank1,zst_observ,eo_id, geom FROM avaricosa.temp_SC;"
psql -d blackosprey -c "DROP TABLE avaricosa.temp_SC;"

## Final updates
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_polygon SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_polygon.geom) AND avaricosa.avaricosa_polygon.huc_8_num IS NULL;"
psql -d blackosprey -c "UPDATE avaricosa.avaricosa_polygon SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_polygon.geom) AND avaricosa.avaricosa_polygon.huc_8_name IS NULL;"
