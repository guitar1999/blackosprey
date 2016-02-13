CREATE TABLE nhd_flowline_avaricosa_1km_buffer_table (
    primary_key text,
    gid integer,
    comid integer,
    permanent_ text,
    fdate date,
    resolution integer,
    gnis_id text,
    gnis_name text,
    lengthkm numeric,
    reachcode text,
    flowdir integer,
    wbareacomi integer,
    wbarea_per text,
    ftype integer,
    fcode integer,
    shape_leng numeric,
    enabled smallint,
    state text,
    in_huc_12 text,
    geom geometry(MultiLineString, 4326)
);


INSERT INTO nhd_flowline_avaricosa_1km_buffer_table (primary_key, gid, comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, state, in_huc_12, geom) SELECT a.primary_key, n.gid, n.comid, n.permanent_, n.fdate, n.resolution, n.gnis_id, n.gnis_name, n.lengthkm, n.reachcode, n.flowdir, n.wbareacomi, n.wbarea_per, n.ftype, n.fcode, n.shape_leng, n.enabled, n.state, n.in_huc_12, ST_Multi(ST_Intersection(a.geom, n.geom)) FROM avaricosa.avaricosa_all_as_point_1km_buffer_view a, public.nhd_flowline_avaricosa n;
