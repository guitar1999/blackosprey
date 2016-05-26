#!/bin/bash

abtid=$1

psql -d blackosprey -c "WITH pct_length AS (SELECT abt_id, 900 / ST_Length(ST_Transform(route, 5070)) AS pct_length FROM avaricosa_buffer_table WHERE abt_id = $abtid) UPDATE avaricosa_buffer_table SET buffer_geom = (SELECT ST_Transform(ST_Multi(ST_Union(ST_Buffer(ST_Line_Substring(ST_LineMerge(ST_Transform(route, 5070)), 1 - CASE WHEN pct_length > 1 THEN 1 ELSE pct_length END / 2, 1), 100, 'endcap=flat join=round'), ST_Buffer(ST_Line_Substring(ST_LineMerge(ST_Transform(route, 5070)), 1 - CASE WHEN pct_length > 1 THEN 1 ELSE pct_length END, 1 - CASE WHEN pct_length > 1 THEN 1 ELSE pct_length END / 2), 100, 'endcap=round join=round'))), 4326) AS geom FROM avaricosa_buffer_table a, pct_length l WHERE ST_GeometryType(ST_LineMerge(route)) = 'ST_LineString' AND a.abt_id = $abtid) WHERE abt_id = $abtid;"
