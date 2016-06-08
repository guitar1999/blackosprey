CREATE VIEW nhd.nhd_flowline_all_view AS (SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_ct UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_de UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_ga UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_md UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_ma UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_me UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_nc UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_nh UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_nj UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_ny UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_pa UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_ri UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_sc UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_wv UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_va UNION 
SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, geom FROM nhd_flowline_vt
); 

SELECT DISTINCT ON (permanent_) * INTO nhd_flowline_all_no_duplicates FROM nhd_flowline_all_view ORDER BY permanent_;

SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, ST_Segmentize(geom::geography, 100)::geometry AS geom INTO nhd_flowline_all_no_duplicates_100m_segments FROM nhd_flowline_all_no_duplicates;


SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, ST_Force2D(ST_MakeLine(sp, ep))::geometry(LineString, 4326) AS geom INTO nhd_flowline_all_no_duplicates_100m_segments_exploded FROM (SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) AS sp, ST_PointN(geom, generate_series(2, ST_NPoints(geom))) AS ep FROM (SELECT comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, (ST_Dump(geom)).geom AS geom FROM nhd_flowline_all_no_duplicates_100m_segments ) AS linestrings) AS segments;

ALTER TABLE nhd_flowline_all_no_duplicates_100m_segments_exploded ADD COLUMN newid SERIAL NOT NULL PRIMARY KEY;
ALTER TABLE nhd_flowline_all_no_duplicates_100m_segments_exploded ADD COLUMN distance_to_road NUMERIC;
ALTER TABLE nhd_flowline_all_no_duplicates_100m_segments_exploded ADD COLUMN roadid INTEGER;


DROP TABLE nhd_flowline_all_no_duplicates; 
DROP TABLE nhd_flowline_all_no_duplicates_100m_segments;

CREATE INDEX nhd_flowline_all_no_duplicates_100m_segments_exploded_geom_idx ON nhd_flowline_all_no_duplicates_100m_segments_exploded USING GIST (geom);

SELECT gid, ST_Force2D(ST_MakeLine(sp, ep))::geometry(LineString, 4326) AS geom INTO roads.tiger_roads_segments FROM (SELECT gid, ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) AS sp, ST_PointN(geom, generate_series(2, ST_NPoints(geom))) AS ep FROM (SELECT gid, (ST_Dump(geom)).geom AS geom FROM tiger_roads ) AS linestrings) AS segments;
ALTER TABLE tiger_roads_segments ADD COLUMN newid SERIAL NOT NULL PRIMARY KEY;

CREATE INDEX tiger_roads_segments_geom_idx ON tiger_roads_segments USING GIST (geom);

-- Do the distance calc (zzz)
WITH ds AS (SELECT h.newid, l.roadid, ST_Distance(ST_Centroid(h.geom)::geography, ST_ClosestPoint(l.geom, h.geom)::geography) AS distance_meters FROM nhd_flowline_all_no_duplicates_100m_segments_exploded h CROSS JOIN LATERAL (SELECT newid as roadid, geom FROM tiger_roads_segments ORDER BY h.geom <-> geom LIMIT 10) AS l), d AS (SELECT DISTINCT ON (newid) * FROM ds ORDER BY newid, distance_meters) UPDATE nhd_flowline_all_no_duplicates_100m_segments_exploded AS n SET (distance_to_road, roadid) = (d.distance_meters, d.roadid) FROM d WHERE d.newid = n.newid;

-- Buffer the stream segments for extraction
ALTER TABLE nhd_flowline_all_no_duplicates_100m_segments_exploded ADD COLUMN geom_5070 GEOMETRY(LineString, 5070);
UPDATE nhd_flowline_all_no_duplicates_100m_segments_exploded SET geom_5070 = ST_Transform(geom, 5070);
SELECT permanent_, newid, ST_Transform(ST_Buffer(ST_Transform(geom, 5070), 100, 'endcap=flat join=round'), 4326) AS geom INTO nhd_flowline_all_no_duplicates_100m_segments_exploded_buffers FROM nhd_flowline_all_no_duplicates_100m_segments_exploded;

SELECT permanent_, newid, ST_Transform(ST_MakeValid(ST_Buffer(ST_MakeValid(ST_Transform(ST_MakeValid(geom), 5070)), 100, 'endcap=flat join=round')), 4326) AS geom INTO nhd_flowline_all_no_duplicates_100m_segments_exploded_buffers FROM nhd_flowline_all_no_duplicates_100m_segments_exploded;