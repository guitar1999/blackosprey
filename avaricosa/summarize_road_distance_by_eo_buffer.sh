#!/bin/bash

for i in $(psql -h localhost -d blackosprey -t -A -c "SELECT DISTINCT primary_key FROM avaricosa_buffer_table;")
do
    psql -h localhost -d blackosprey -c "WITH buff AS (SELECT primary_key, ST_Union(ST_MakeValid(buffer_geom)) AS buffer_geom FROM avaricosa_buffer_table WHERE primary_key = '$i' GROUP BY primary_key),  h8 AS (SELECT array_agg(DISTINCT huc_8) AS huc_8 FROM nhd_hu8_watersheds h8, buff b WHERE ST_Intersects(h8.geom, b.buffer_geom)) INSERT INTO avaricosa.avaricosa_buffer_road_distance_summary (primary_key, avg_road_distance) SELECT '$i', SUM(distance_to_road * ST_Length(geom_5070)) / SUM(ST_Length(geom_5070)) FROM nhd_flowline_all_no_duplicates_100m_segments_exploded, h8, buff WHERE substring(reachcode from 1 for 8) = ANY (h8.huc_8) AND ST_Intersects(buff.buffer_geom, geom);"
    if [ "$?" != '0' ]; then 
        echo "ERROR: $i"
        echo $i >> error.log
    else
        echo $i
    fi  
done