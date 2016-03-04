-- This is a good start from a very clean dataset
WITH end_pct AS (SELECT 1 - (1000 / ST_Length(geom)) AS end_pct FROM temp_stream_segment) SELECT id, ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), end_pct, 1), 100, 'endcap=flat join=round') AS geom INTO temp_stream_segment_buffer FROM temp_stream_segment, end_pct;

-- with avaricosa point as start (or end)
WITH pct_length AS (SELECT 1000 / ST_Length(geom) AS pct_length FROM temp_stream_segment), avaricosa_pct AS (SELECT ST_Line_Locate_Point(ST_LineMerge(l.geom), ST_Transform(p.geom, 5070)) AS avaricosa_pct FROM temp_stream_segment l, avaricosa_point p WHERE p.ap_id = 469) SELECT id, ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length, avaricosa_pct), 100, 'endcap=flat join=round') AS geom INTO temp_stream_segment_buffer FROM temp_stream_segment, pct_length, avaricosa_pct;

-- with square ends
WITH buffer_pct AS (SELECT 100 / ST_Length(geom) AS buffer_pct FROM temp_stream_segment), pct_length AS (SELECT 1000 / ST_Length(geom) AS pct_length FROM temp_stream_segment), avaricosa_pct AS (SELECT ST_Line_Locate_Point(ST_LineMerge(l.geom), ST_Transform(p.geom, 5070)) AS avaricosa_pct FROM temp_stream_segment l, avaricosa_point p WHERE p.ap_id = 469) SELECT id, ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length + buffer_pct, avaricosa_pct - buffer_pct), 100, 'endcap=square join=round') AS geom INTO temp_stream_segment_buffer_square FROM temp_stream_segment, pct_length, avaricosa_pct, buffer_pct;

-- what if we split the buffer, do the bottom with a flat end cap and the top with a round end cap and then union them back together
WITH buffer_pct AS (SELECT 100 / ST_Length(geom) AS buffer_pct FROM temp_stream_segment), pct_length AS (SELECT 900 / ST_Length(geom) AS pct_length FROM temp_stream_segment), avaricosa_pct AS (SELECT ST_Line_Locate_Point(ST_LineMerge(l.geom), ST_Transform(p.geom, 5070)) AS avaricosa_pct FROM temp_stream_segment l, avaricosa_point p WHERE p.ap_id = 469) SELECT id, ST_Union(ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length / 2, avaricosa_pct), 100, 'endcap=flat join=round'), ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length, avaricosa_pct - pct_length / 2), 100, 'endcap=round join=round')) AS geom INTO temp_stream_segment_buffer_hybrid FROM temp_stream_segment, pct_length, avaricosa_pct, buffer_pct;

--downstream
ST_Union(ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length / 2, avaricosa_pct), 100, 'endcap=flat join=round')
--upstream
ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length, avaricosa_pct - pct_length / 2), 100, 'endcap=round join=round')


-- Recursive stream selection
WITH RECURSIVE stream_join AS (SELECT s.reachcode, array[s.reachcode]||array_agg(s2.reachcode) as arr, ST_Union(s.geom, s2.geom) AS geom FROM nhd_flowline_avaricosa_1km_buffer s JOIN nhd_flowline_avaricosa_1km_buffer s2 ON s.reachcode::numeric = s2.reachcode::numeric + 1 WHERE s.primary_key = '468970726.23060107' AND s2.primary_key = '468970726.23060107' AND s.reachcode::numeric >= 03060107000085 AND s2.reachcode::numeric >= 03060107000085 AND ST_Intersects(s.geom, s2.geom) GROUP BY s.reachcode, 3) SELECT '03060107000085' AS reachcode, ST_Union(s.geom) AS geom into test1 FROM stream_join s, avaricosa_point_1km_buffer b WHERE b.primary_key = '468970726.23060107' AND ST_Intersects(s.geom, b.geom);

WITH RECURSIVE stream_join AS (SELECT s.reachcode, array[s.reachcode]||array_agg(s2.reachcode) as arr, ST_LineMerge(ST_Union(s.geom, s2.geom)) AS geom FROM nhd_flowline_avaricosa_1km_buffer s JOIN nhd_flowline_avaricosa_1km_buffer s2 ON s.reachcode::numeric = s2.reachcode::numeric + 1 WHERE s.reachcode::numeric >= 03060107000085 AND s2.reachcode::numeric >= 03060107000085 AND ST_Intersects(s.geom, s2.geom) GROUP BY s.reachcode, 3) SELECT '03060107000085' AS reachcode, ST_Union(s.geom) AS geom INTO test2 FROM stream_join s, avaricosa_point_1km_buffer b WHERE b.primary_key = '468970726.23060107' AND ST_Intersects(s.geom, b.geom);

-- Here's a thought. Group stream segments by reachcode where the touch each other (we have to throw out bits that may come back into the buffer after leaving the buffer). then do a recursive join on reachcode + 1.


WITH buffer_pct AS (SELECT 100 / ST_Length(geom) AS buffer_pct FROM temp_stream_union), pct_length AS (SELECT 900 / ST_Length(geom) AS pct_length FROM temp_stream_union), avaricosa_pct AS (SELECT ST_Line_Locate_Point(ST_LineMerge(l.geom), ST_Transform(p.geom, 5070)) AS avaricosa_pct FROM temp_stream_union l, avaricosa_all_as_point_view p WHERE p.primary_key = '468970726.23060107') SELECT '468970726.23060107'::text, ST_Union(ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length / 2, avaricosa_pct), 100, 'endcap=flat join=round'), ST_Buffer(ST_Line_Substring(ST_LineMerge(geom), avaricosa_pct - pct_length, avaricosa_pct - pct_length / 2), 100, 'endcap=round join=round')) AS geom INTO temp_stream_union_buffer_hybrid FROM temp_stream_union, pct_length, avaricosa_pct, buffer_pct;



-- New test pk 468970726.23060107

############################
--trying with topolgy again
--468970726.23060107

-- Split the stream lines into segments
SELECT gid, primary_key, ST_Force2D(ST_MakeLine(sp, ep))::geometry(LineString, 4326) AS geom INTO temp_segments_468a FROM (SELECT gid, primary_key, ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) AS sp, ST_PointN(geom, generate_series(2, ST_NPoints(geom))) AS ep FROM (SELECT gid, primary_key, (ST_Dump(geom)).geom FROM nhd_flowline_avaricosa_1km_buffer WHERE primary_key = '468970726.23060107') AS linestrings) AS segments;
-- Let's get the full intersection instead so we can generate end targets later
SELECT gid, primary_key, ST_Force2D(ST_MakeLine(sp, ep))::geometry(LineString, 4326) AS geom INTO temp_segments_468 FROM (SELECT gid, primary_key, ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) AS sp, ST_PointN(geom, generate_series(2, ST_NPoints(geom))) AS ep FROM (SELECT gid, primary_key, (ST_Dump(n.geom)).geom FROM nhd_flowline_avaricosa n, avaricosa_point_1km_buffer a WHERE ST_Intersects(n.geom, a.geom) AND a.primary_key = '468970726.23060107') AS linestrings) AS segments;
-- Add a unique id
ALTER TABLE temp_segments_468 ADD COLUMN id SERIAL NOT NULL PRIMARY KEY;
-- Find the segment closest to the avaricosa point
SELECT * INTO temp_segments_468_split FROM temp_segments_468 ORDER BY geom <-> (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '468970726.23060107') LIMIT 1;
-- Find the upstream and downstream points
SELECT id, ST_PointN(geom, 1) AS geom INTO temp_segments_468_split_point1 FROM temp_segments_468_split; -- this is the upstream point
SELECT id, ST_PointN(geom, 2) AS geom INTO temp_segments_468_split_point2 FROM temp_segments_468_split; -- this is the downstream point
-- Find the point on the segment closest to the avaricosa
SELECT id, ST_Line_Interpolate_Point(geom, ST_Line_Locate_Point(geom, (SELECT geom FROM avaricosa_all_as_point_view WHERE primary_key = '468970726.23060107'))) AS geom INTO temp_segments_468_split_split_point FROM temp_segments_468_split;
-- Split that segment into two parts
INSERT INTO temp_segments_468 (gid, primary_key, geom) SELECT gid, primary_key, ST_Force2D(ST_MakeLine((SELECT geom FROM temp_segments_468_split_point1), (SELECT geom FROM temp_segments_468_split_split_point))) FROM temp_segments_468_split;
INSERT INTO temp_segments_468 (gid, primary_key, geom) SELECT gid, primary_key, ST_Force2D(ST_MakeLine((SELECT geom FROM temp_segments_468_split_split_point), (SELECT geom FROM temp_segments_468_split_point2))) FROM temp_segments_468_split;
DELETE FROM temp_segments_468 WHERE id = (SELECT id FROM temp_segments_468_split);
ALTER TABLE temp_segments_468 ADD COLUMN source int4;
ALTER TABLE temp_segments_468 ADD COLUMN target int4;
ALTER TABLE temp_segments_468 ADD COLUMN cost float8 DEFAULT 1;

SELECT pgr_createTopology('temp_segments_468', 0.00001, 'geom', 'id'); -- must be run as postgres user!

-- let's do some routing!
SELECT id1 as path, st_astext(st_linemerge(st_union(b.geom))) as geom
  FROM pgr_kdijkstraPath(
                  'SELECT id, source::int4, target::int4, cost::float8 FROM temp_segments_468',
                  324, (SELECT array_agg(id) FROM temp_segments_468 WHERE ST_Intersects(geom, (SELECT ST_ExteriorRing(ST_Buffer(geom::geography, 0.000001)::geometry) FROM avaricosa_point_1km_buffer WHERE primary_key = '468970726.23060107'))), false, false
            ) a,
            temp_segments_468 b
WHERE a.id3=b.id
GROUP by id1
ORDER by id1;

-- now make the hybrid buffer with the routes
WITH pct_length AS (SELECT abt_id, 900 / ST_Length(ST_Transform(route, 5070)) AS pct_length FROM avaricosa_buffer_table), avaricosa_pct AS (SELECT abt_id, ST_Line_Locate_Point(route, start_point) AS avaricosa_pct FROM avaricosa_buffer_table) SELECT l.abt_id, ST_Union(ST_Buffer(ST_Line_Substring(ST_LineMerge(route), 1 - pct_length / 2, 1), 100, 'endcap=flat join=round'), ST_Buffer(ST_Line_Substring(ST_LineMerge(route), 1 - pct_length, 1 - pct_length / 2), 100, 'endcap=round join=round')) AS geom INTO temp_stream_union_buffer_hybrid_test FROM avaricosa_buffer_table a, pct_length l WHERE ST_GeometryType(ST_LineMerge(route)) = 'ST_LineString';

