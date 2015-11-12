CREATE TABLE avaricosa.avaricosa_buffer_table (
    abt_id serial not null primary key,
    ap_id integer,
    id text,
    source_geom text,
    nhd_permanent_ text,
    start_point geometry(POINT,4326),
    end_point geometry(POINT,4326),
    buffer_geom geometry(POLYGON,4326)
);
