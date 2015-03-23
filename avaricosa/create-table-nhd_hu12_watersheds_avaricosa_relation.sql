CREATE TABLE nhd_hu12_watersheds_avaricosa_relation (
    nhwar_id serial not null primary key,
    huc_12 text,
    avaricosa_source_geom text,
    avaricosa_ap_id integer[]
);