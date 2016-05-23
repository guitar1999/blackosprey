#!/bin/bash

for t in $1
#for t in $(psql -d blackosprey -t -A -c "SELECT huc_8 FROM nhd_hu8_watersheds h, states_project_area s WHERE ST_Intersects(h.geom, s.geom);")
do
    if [ ! -f huc8_${t}_stream_buffer.shp ]; then 
        echo $t
        state=$(psql -d blackosprey -t -A -c "SELECT state FROM states_project_area s, nhd_hu8_watersheds h WHERE ST_Intersects(s.geom, h.geom) AND h.huc_8 = '${t}' LIMIT 1;")
        time pgsql2shp -f huc8_${t}_stream_buffer.shp blackosprey "SELECT 1 AS id, ST_Union(ST_MakeValid(ST_Buffer(ST_Transform(s.geom, 5070), 100))) FROM nhd.nhd_flowline_${state} s WHERE substring(reachcode from 1 for 8) = '${t}';"
        #time pgsql2shp -f huc8_${t}_stream_buffer.shp blackosprey "SELECT 1 AS id, ST_Buffer(ST_Transform(s.geom, 5070), 100) FROM nhd_flowline_avaricosa s, nhd_hu8_watersheds h WHERE h.huc_8 = '${t}' AND ST_Intersects(s.geom::geography, ST_Buffer(h.geom::geography, 2000));"
    else
        echo skipping $t
    fi
done
