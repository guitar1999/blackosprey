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
# Find the point on the segment closest to the avaricosa
psql -d blackosprey -t -A -c "SELECT id, ST_Line_Interpolate_Point(geom, ST_Line_Locate_Point(geom, (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '$pk'))) AS geom INTO temp_segments_${tt}_split_split_point FROM temp_segments_${tt}_split;"
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
# The old way
# targets_old=$(psql -d blackosprey -t -A -c "SELECT target FROM temp_segments_${tt} WHERE ST_Intersects(geom, (SELECT ST_Buffer(ST_ExteriorRing(geom)::geography, 0.00001)::geometry FROM avaricosa_point_1km_buffer WHERE primary_key = '$pk'));")
targetstring="array[$(echo $targets | sed 's/ /,/g')]"

psql -d blackosprey -t -A -c "INSERT INTO avaricosa_buffer_table (primary_key, start_point, route_target, route) SELECT '$pk', (SELECT geom FROM temp_segments_${tt}_split_split_point), id1 as path, ST_Multi(st_linemerge(st_union(b.geom))) as geom FROM pgr_kdijkstraPath('SELECT id, source::int4, target::int4, cost::float8 FROM temp_segments_${tt}', $sourceid, $targetstring, false, false ) a, temp_segments_${tt} b WHERE a.id3=b.id GROUP by id1 ORDER by id1;" 
psql -d blackosprey -t -A -c "DELETE FROM avaricosa_buffer_table WHERE primary_key = '$pk' AND NOT ST_Intersects(route, (SELECT the_geom FROM temp_segments_${tt}_vertices_pgr WHERE id = $sourceid));"
 



# this one's bad but not sourceid 11321412050306


