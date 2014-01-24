BEGIN;
CREATE TABLE baselayer_clipped_hu8_watersheds (gid serial PRIMARY KEY, huc_8_num integer REFERENCES nhd_hu8_watersheds (huc_8_num) ON DELETE CASCADE);   
SELECT AddGeometryColumn('','baselayer_clipped_hu8_watersheds','geom','4326','MULTIPOLYGON',2);
INSERT INTO baselayer_clipped_hu8_watersheds (SELECT nextval('baselayer_clipped_hu8_watersheds_gid_seq'), huc_8_num, ST_Multi(ST_Intersection(p.geom, h.geom)) FROM baselayer_project_area p, nhd_hu8_watersheds h WHERE ST_Intersects(p.geom, h.geom) AND NOT ST_Contains(p.geom, h.geom));
INSERT INTO baselayer_clipped_hu8_watersheds (SELECT nextval('baselayer_clipped_hu8_watersheds_gid_seq'), huc_8_num, ST_Multi(h.geom) FROM baselayer_project_area p, nhd_hu8_watersheds h WHERE ST_Contains(p.geom, h.geom));
COMMIT;

BEGIN;
CREATE VIEW nhd_hu8_watersheds_clipped_view AS (SELECT n.gid, n.huc_8, n.hu_8_name, n.contains_avaricosa, n.huc_8_num, c.geom FROM nhd_hu8_watersheds n INNER JOIN baselayer_clipped_hu8_watersheds c ON n.huc_8_num=c.huc_8_num);
COMMIT;
