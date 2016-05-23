CREATE TABLE avaricosa.avaricosa_buffer_table (
    abt_id serial not null primary key,
    primary_key text,
    ap_id integer,
    id text,
    source_geom text,
    nhd_permanent_ text,
    start_point geometry(POINT,4326),
    route_source integer,
    route_target integer,
    route geometry(MultiLineString,4326),
    buffer_geom geometry(MultiPolygon,4326),
    quality_flag text DEFAULT 'N'
);
