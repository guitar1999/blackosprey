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