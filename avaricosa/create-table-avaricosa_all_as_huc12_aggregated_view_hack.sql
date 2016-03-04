CREATE TABLE avaricosa.avaricosa_all_as_huc12_aggregated_view_hack AS (
    WITH init_query AS (
        SELECT
            primary_key,
            ap_id,
            state,
            id,
            source_geom,
            h.huc_12,
            symbol_pop_cond
        FROM
            avaricosa.avaricosa_all_as_point_view a,
            public.nhd_hu12_watersheds_avaricosa_relation h
        WHERE
            a.ap_id = ANY (h.avaricosa_ap_id) AND
            a.source_geom = h.avaricosa_source_geom
        ) SELECT
            min(h.gid) AS gid,
            min(i.primary_key) AS primary_key,
            array_to_string(array_agg(i.ap_id), ',') AS ap_id,
            state,
            array_to_string(array_agg(i.id), ',') AS id,
            array_to_string(array_agg(distinct i.source_geom), ',') AS source_geom,
            h.huc_12,
            array_to_string(array_agg(distinct i.symbol_pop_cond), ', ') AS symbol_pop_cond,
            array_length(array_agg(distinct i.symbol_pop_cond), 1) > 1 AS multiple_conditions,
            min(h.geom)::geometry AS geom
        FROM
            init_query i INNER JOIN
            public.nhd_hu12_watersheds h ON
                i.huc_12 = h.huc_12
        GROUP BY 
            h.huc_12,
            i.state
);
ALTER TABLE avaricosa.avaricosa_all_as_huc12_aggregated_view_hack ADD COLUMN new_pk SERIAL NOT NULL PRIMARY KEY;
