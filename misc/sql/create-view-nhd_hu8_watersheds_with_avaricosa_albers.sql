BEGIN;
CREATE VIEW nhd_hu8_watersheds_with_avaricosa_albers AS 
SELECT 
    gid,
    states,
    huc_8,
    hu_8_name,
    shape_leng,
    shape_area,
    contains_avaricosa,
    huc_8_num,
    ST_Transform(geom, 96703) AS geom
FROM 
    nhd_hu8_watersheds
WHERE
    contains_avaricosa = 'Y';
COMMIT;

GRANT SELECT ON nhd_hu8_watersheds_with_avaricosa_albers TO blackosprey;
