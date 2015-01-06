BEGIN;
DROP VIEW IF EXISTS avaricosa.avaricosa_all_as_huc8_aggregated_view CASCADE;
CREATE OR REPLACE VIEW avaricosa.avaricosa_all_as_huc8_aggregated_view AS (
    SELECT
        min(gid) AS gid,
        min(primary_key) AS primary_key,
        array_to_string(array_agg(ap_id), ',') AS ap_id,
        array_to_string(array_agg(distinct state), ',') AS state,
        array_to_string(array_agg(id), ',') AS id,
        array_to_string(array_agg(distinct source_geom), ',') AS source_geom,
        h.huc_8_num,
        array_to_string(array_agg(distinct symbol_pop_cond), ', ') AS symbol_pop_cond,
        array_length(array_agg(distinct symbol_pop_cond), 1) > 1 AS multiple_conditions,
        min(h.geom)::geometry AS geom
    FROM 
        avaricosa.avaricosa_all_as_point_view a,
        public.nhd_hu12_watersheds h
    WHERE
        a.ap_id = ANY (h.avaricosa_ap_id) AND
        a.source_geom = h.avaricosa_source_geom
    GROUP BY 
        h.huc_8_num
);
COMMIT;