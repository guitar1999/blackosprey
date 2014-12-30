BEGIN;
DROP VIEW IF EXISTS avaricosa.avaricosa_all_as_huc12_label_view CASCADE;
CREATE OR REPLACE VIEW avaricosa.avaricosa_all_as_huc12_label_view AS (
    SELECT
        min(primary_key) AS primary_key,
        array_to_string(array_agg(ap_id), ',') AS ap_id,
        array_to_string(array_agg(distinct state), ',') AS state,
        array_to_string(array_agg(id), ',') AS id,
        a.huc_12,
        array_to_string(array_agg(distinct symbol_pop_cond), ', ') AS label,
        min(h.geom)::geometry AS geom
    FROM 
        avaricosa.avaricosa_all_as_point_view a 
        LEFT JOIN public.nhd_hu12_watersheds h
        ON a.huc_12 = h.huc_12
    GROUP BY 
        a.huc_12
);
COMMIT;