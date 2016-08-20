#!/bin/bash

pk=$1
tt=$(echo $pk | sed 's/\./_/g')
# Split the stream lines into segments
psql -d blackosprey -t -A -c "SELECT gid, primary_key, ST_Force2D(ST_MakeLine(sp, ep))::geometry(LineString, 4326) AS geom INTO temp_segments_${tt} FROM (SELECT gid, primary_key, ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) AS sp, ST_PointN(geom, generate_series(2, ST_NPoints(geom))) AS ep FROM (SELECT gid, primary_key, (ST_Dump(geom)).geom FROM nhd_flowline_avaricosa_1km_buffer WHERE primary_key = '$pk') AS linestrings) AS segments;"
# Add a unique id
psql -d blackosprey -t -A -c "ALTER TABLE temp_segments_${tt} ADD COLUMN id SERIAL NOT NULL PRIMARY KEY;"
# Find the segment closest to the avaricosa point (use the second query to avoid bad bbox matches but take advantage of the speed of indexed nearest neighbor to limit the number of actual distance calcs that need to be done)
#psql -d blackosprey -t -A -c "SELECT * INTO temp_segments_${tt}_split FROM temp_segments_${tt} ORDER BY geom <-> (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '$pk') LIMIT 1;"
psql -d blackosprey -t -A -c "SELECT x.* INTO temp_segments_${tt}_split FROM (SELECT * FROM temp_segments_${tt} ORDER BY geom <-> (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '$pk') LIMIT 10) AS x ORDER BY ST_Distance(x.geom::geography, (SELECT geom::geography FROM avaricosa_all_as_point_view WHERE primary_key = '$pk')) LIMIT 1;"
#psql -d blackosprey -t -A -c "SELECT * INTO temp_segments_${tt}_split FROM temp_segments_${tt} WHERE id = 38;"


# Find the upstream and downstream points
psql -d blackosprey -t -A -c "SELECT id, ST_PointN(geom, 1) AS geom INTO temp_segments_${tt}_split_point1 FROM temp_segments_${tt}_split;" # this is the upstream point
psql -d blackosprey -t -A -c "SELECT id, ST_PointN(geom, 2) AS geom INTO temp_segments_${tt}_split_point2 FROM temp_segments_${tt}_split;" # this is the downstream point
# Find the point on the segment closest to the avaricosa (sometimes this will be the same as one of the points and if it's point 2, we need to get rid of the segment below it)
psql -d blackosprey -t -A -c "SELECT t.id, ST_Line_Interpolate_Point(t.geom, ST_Line_Locate_Point(t.geom, (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '$pk'))) AS geom, ST_Intersects(ST_Line_Interpolate_Point(t.geom, ST_Line_Locate_Point(t.geom, (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '$pk'))), x1.geom) AS intersects1, ST_Intersects(ST_Line_Interpolate_Point(t.geom, ST_Line_Locate_Point(t.geom, (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '$pk'))), x2.geom) AS intersects2 INTO temp_segments_${tt}_split_split_point FROM temp_segments_${tt}_split t, temp_segments_${tt}_split_point1 x1, temp_segments_${tt}_split_point2 x2;"
# Split that segment into two parts
segmentid=$(psql -d blackosprey -t -A -c "INSERT INTO temp_segments_${tt} (gid, primary_key, geom) SELECT gid, primary_key, ST_Force2D(ST_MakeLine((SELECT geom FROM temp_segments_${tt}_split_point1), (SELECT geom FROM temp_segments_${tt}_split_split_point))) FROM temp_segments_${tt}_split RETURNING id;")
sid=$(echo $segmentid | awk -F ' ' '{print $1}');
# Add this other segment temporarily to get the topology correct
segmentid2=$(psql -d blackosprey -t -A -c "INSERT INTO temp_segments_${tt} (gid, primary_key, geom) SELECT gid, primary_key, ST_Force2D(ST_MakeLine((SELECT geom FROM temp_segments_${tt}_split_split_point), (SELECT geom FROM temp_segments_${tt}_split_point2))) FROM temp_segments_${tt}_split RETURNING id;")
sid2=$(echo $segmentid2 | awk -F ' ' '{print $1}');

psql -d blackosprey -t -A -c "DELETE FROM temp_segments_${tt} WHERE id = (SELECT id FROM temp_segments_${tt}_split);"
psql -d blackosprey -t -A -c "ALTER TABLE temp_segments_${tt} ADD COLUMN source int4;"
psql -d blackosprey -t -A -c "ALTER TABLE temp_segments_${tt} ADD COLUMN target int4;"
psql -d blackosprey -t -A -c "ALTER TABLE temp_segments_${tt} ADD COLUMN cost float8 DEFAULT 1;"

psql -d blackosprey -t -A -c "SELECT pgr_createTopology('temp_segments_${tt}', 0.00001, 'geom', 'id');" # must be run as postgres user if you haven't made yourself the owner of the public schema!

# Now delete the extra segment so we only route upstream
psql -d blackosprey -t -A -c "DELETE FROM temp_segments_${tt} WHERE id = $sid2;"
# Check to see if we have matching points and delete necessary segments
if [ $(psql -d blackosprey -t -A -c "SELECT intersects1 FROM temp_segments_${tt}_split_split_point;") == 't' ]; then psql -d blackosprey -t -A -c "DELETE FROM temp_segments_${tt} WHERE id = $sid;"; fi
if [ $(psql -d blackosprey -t -A -c "SELECT intersects2 FROM temp_segments_${tt}_split_split_point;") == 't' ]; then psql -d blackosprey -c "DELETE FROM temp_segments_${tt} WHERE id = (SELECT id FROM temp_segments_${tt} WHERE ST_Intersects(geom, (SELECT geom FROM temp_segments_${tt}_split_split_point)) AND not ST_Intersects(geom, (SELECT geom FROM temp_segments_${tt}_split_point1)));"; fi

#sourceid=$(psql -d blackosprey -t -A -c "SELECT source FROM temp_segments_${tt} WHERE id = $sid")
sourceid=$(psql -d blackosprey -t -A -c "SELECT id FROM temp_segments_${tt}_vertices_pgr WHERE ST_Intersects(the_geom, (SELECT geom FROM temp_segments_${tt}_split_split_point));")
# If you can't get a sourceid, get fuzzier with the matching until you do.
if [ "$sourceid" == "" ]
then
    echo $pk >> empty_sourceid.list
    sourceid=$(psql -d blackosprey -t -A -c "SELECT id FROM temp_segments_${tt}_vertices_pgr WHERE ST_Intersects(the_geom, (SELECT ST_Buffer(geom::geography, 0.1)::geometry FROM temp_segments_${tt}_split_split_point));")
fi
if [ "$sourceid" = "" ]
then
    sourceid=$(psql -d blackosprey -t -A -c "SELECT id FROM temp_segments_${tt}_vertices_pgr ORDER BY the_geom <-> (SELECT geom FROM temp_segments_${tt}_split_split_point) LIMIT 1;")
fi

#### let's do some routing!
# Find some targets
psql -d blackosprey -t -A -c "SELECT id, ST_StartPoint(geom) AS geom INTO temp_segments_${tt}_start_points FROM temp_segments_${tt};"
psql -d blackosprey -t -A -c "SELECT id, ST_EndPoint(geom) AS geom INTO temp_segments_${tt}_end_points FROM temp_segments_${tt};"
targets=$(psql -d blackosprey -t -A -c "SELECT source FROM temp_segments_${tt} WHERE id IN (SELECT s.id from temp_segments_${tt}_start_points s LEFT JOIN temp_segments_${tt}_end_points e ON ST_Intersects(s.geom, e.geom) WHERE e.id IS NULL);") # use source rather than target column to get at whole first segment
if [ "$pk" == "10100442030105" ]; then 
    targets='366 642 759'
elif [ "$pk" == "224992030105" ]; then
    targets='8 216 218 219 460 919 1006 1041 1301 1305 1400 1408 1601 1605 1896 1972'
fi
# The old way
# targets_old=$(psql -d blackosprey -t -A -c "SELECT target FROM temp_segments_${tt} WHERE ST_Intersects(geom, (SELECT ST_Buffer(ST_ExteriorRing(geom)::geography, 0.00001)::geometry FROM avaricosa_point_1km_buffer WHERE primary_key = '$pk'));")
targetstring="array[$(echo $targets | sed 's/ /,/g')]"

psql -d blackosprey -t -A -c "INSERT INTO avaricosa_buffer_table (primary_key, start_point, route_target, route) SELECT '$pk', (SELECT geom FROM temp_segments_${tt}_split_split_point), id1 as path, ST_Multi(st_linemerge(st_union(b.geom))) as geom FROM pgr_kdijkstraPath('SELECT id, source::int4, target::int4, cost::float8 FROM temp_segments_${tt}', $sourceid, $targetstring, false, false ) a, temp_segments_${tt} b WHERE a.id3=b.id GROUP by id1 ORDER by id1;" 
psql -d blackosprey -t -A -c "DELETE FROM avaricosa_buffer_table WHERE primary_key = '$pk' AND NOT ST_Intersects(route, (SELECT the_geom FROM temp_segments_${tt}_vertices_pgr WHERE id = $sourceid));"
 
# Now buffer the routes
for abtid in $(psql -d blackosprey -t -A -c "SELECT abt_id FROM avaricosa_buffer_table WHERE primary_key = '$pk';")
do
    if [ $(psql -d blackosprey -t -A -c "SELECT ST_GeometryType(ST_LineMerge(route)) FROM avaricosa_buffer_table WHERE abt_id = $abtid;") != 'ST_LineString' ]
    then
        # This probably means that there's a gap in the route.
        # Dump the route 
        psql -d blackosprey -c "WITH l AS (SELECT (ST_Dump(route)).geom AS geom FROM avaricosa_buffer_table WHERE abt_id = $abtid), p AS (SELECT ST_Collect(ST_Transform(ST_StartPoint(geom), 5070)) AS geom FROM l), new_route AS (SELECT ST_LineMerge(ST_Union(ST_Transform(ST_Snap(ST_Transform(l.geom, 5070), ST_Transform(p.geom, 5070), 2), 4326))) AS route FROM l, p) UPDATE avaricosa_buffer_table SET route = ST_Multi(n.route) FROM new_route n WHERE abt_id = $abtid;"
    fi    
    psql -d blackosprey -c "WITH pct_length AS (SELECT abt_id, 900 / ST_Length(ST_Transform(route, 5070)) AS pct_length FROM avaricosa_buffer_table WHERE abt_id = $abtid) UPDATE avaricosa_buffer_table SET buffer_geom = (SELECT ST_Transform(ST_Multi(ST_Union(ST_Buffer(ST_Line_Substring(ST_LineMerge(ST_Transform(route, 5070)), 1 - CASE WHEN pct_length > 1 THEN 1 ELSE pct_length END / 2, 1), 100, 'endcap=flat join=round'), ST_Buffer(ST_Line_Substring(ST_LineMerge(ST_Transform(route, 5070)), 1 - CASE WHEN pct_length > 1 THEN 1 ELSE pct_length END, 1 - CASE WHEN pct_length > 1 THEN 1 ELSE pct_length END / 2), 100, 'endcap=round join=round'))), 4326) AS geom FROM avaricosa_buffer_table a, pct_length l WHERE ST_GeometryType(ST_LineMerge(route)) = 'ST_LineString' AND a.abt_id = $abtid) WHERE abt_id = $abtid;"
done
psql -d blackosprey -t -A -c "DELETE FROM avaricosa_buffer_table WHERE primary_key = '$pk' AND NOT ST_Intersects(ST_Transform(buffer_geom, 5070), (SELECT ST_Buffer(ST_Transform(the_geom, 5070), 0.001) FROM temp_segments_${tt}_vertices_pgr WHERE id = $sourceid));"

if [ "$2" != "yes" ]; then
# Clean up the temp tables
    for i in $(psql -d blackosprey -t -A -c "SELECT tablename FROM pg_tables WHERE tablename LIKE 'temp_segments_${tt}%';"); do psql -d blackosprey -c "DROP TABLE $i;"; done
else
    echo sourceid is $sourceid
    echo targets are $targets
    echo $pk
    echo $tt
fi

# this one's bad but not sourceid 11321412050306


