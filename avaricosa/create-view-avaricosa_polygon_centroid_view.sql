BEGIN;
CREATE VIEW avaricosa.avaricosa_polygon_centroid_view AS (
    SELECT 
        ap_id,
        state,
        orig_file,
        id,
        huc_8_num,
        huc_8_name,
        first_obs,
        last_obs,
        last_survey,
        pop_condition,
        location_quality,
        update_pop_cond,
        update_pop_cond_confidence,
        update_pop_cond_author,
        update_last_survey,
        update_last_obs,
        comments1,
        comments2,
        last_obs_year,
        ST_Centroid(geom) AS geom
    FROM
        avaricosa.avaricosa_polygon
);
COMMIT;
        
