#!/bin/bash

for g in point line polygon
do
    echo $g
    psql -d blackosprey -c "UPDATE nhd_hu8_watersheds SET contains_avaricosa = 'Y' WHERE contains_avaricosa IS NULL AND huc_8 IN (SELECT huc_8 FROM nhd_hu8_watersheds h, avaricosa.avaricosa_${g} a WHERE ST_Intersects(a.geom, h.geom));"
    psql -d blackosprey -c "UPDATE avaricosa.avaricosa_${g} SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_${g}.geom);"
    psql -d blackosprey -c "UPDATE avaricosa.avaricosa_${g} SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_${g}.geom);"
    psql -d blackosprey -c "UPDATE nhd_hu12_watersheds SET contains_avaricosa = 'Y' WHERE contains_avaricosa IS NULL AND huc_12 IN (SELECT h.huc_12 FROM nhd_hu12_watersheds h, avaricosa.avaricosa_${g} a WHERE ST_Intersects(a.geom, h.geom));"
    psql -d blackosprey -c "UPDATE avaricosa.avaricosa_${g} SET huc_12 = nhd_hu12_watersheds.huc_12 FROM nhd_hu12_watersheds WHERE ST_Intersects(nhd_hu12_watersheds.geom, avaricosa.avaricosa_${g}.geom);"
    psql -d blackosprey -c "UPDATE avaricosa.avaricosa_${g} SET huc_12_name = nhd_hu12_watersheds.hu_12_name FROM nhd_hu12_watersheds WHERE ST_Intersects(nhd_hu12_watersheds.geom, avaricosa.avaricosa_${g}.geom);"
    psql -d blackosprey -c "WITH agg_query AS (SELECT w.huc_12, array_agg(ap_id) AS ap_ids FROM avaricosa_${g} a, nhd_hu12_watersheds w WHERE contains_avaricosa = 'Y' AND ST_Intersects(a.geom, w.geom) GROUP BY w.huc_12) UPDATE nhd_hu12_watersheds SET (avaricosa_source_geom, avaricosa_ap_id) = ('${g}', ap_ids) FROM agg_query WHERE nhd_hu12_watersheds.huc_12 = agg_query.huc_12;"
    echo
done

psql -d blackosprey -c "UPDATE nhd_hu12_watersheds SET in_study_area = 'Y' WHERE in_study_area IS NULL AND huc_12 IN (SELECT distinct huc_12 FROM nhd_hu12_watersheds h12, nhd_hu8_watersheds h8 WHERE ST_Intersects(h12.geom, h8.geom) AND h8.contains_avaricosa = 'Y');"
