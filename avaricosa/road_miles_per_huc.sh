#!/bin/bash

for h in $(bodb -t -A -c "SELECT huc_12 FROM nhd_hu12_watersheds ORDER BY in_study_area;")
do
    bodb -c "INSERT INTO nhd_hu12_watersheds_roadmiles (hu12, roadmiles, area_sqmi) SELECT '$h', SUM(ST_Length(ST_Intersection(r.geom, h.geom)::geography) * 0.000621371), SUM(ST_Area(h.geom::geography) * 3.86102e-7) FROM nhd_hu12_watersheds h, roads.tiger_roads r WHERE h.huc_12 = '$h' AND ST_Intersects(h.geom, r.geom);"
done