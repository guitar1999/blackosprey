BEGIN;
CREATE OR REPLACE VIEW avaricosa.avaricosa_polygon_centroid_view AS (
    SELECT 
        ap_id,
        state,
        orig_file,
        id,
        huc_8_num,
        huc_8_name,
        waterway,
        first_obs,
        date_part('decade', first_obs_date) * 10 AS first_obs_decade,
        last_obs,
        date_part('decade', last_obs_date) * 10 AS last_obs_decade,
        last_survey,
        date_part('decade', last_survey_date) * 10 AS last_survey_decade,
        pop_condition,
        location_quality,
        update_pop_cond,
        update_pop_cond_confidence,
        update_pop_cond_author,
        update_last_survey,
        date_part('decade', update_last_survey) * 10 AS update_last_survey_decade,
        update_last_obs,
        date_part('decade', update_last_obs) * 10 AS update_last_obs_decade,
        comments1,
        comments2,
        CASE
            WHEN
                update_pop_cond IS NULL
            THEN
                pop_condition
            ELSE
                update_pop_cond
        END AS symbol_pop_cond,
        CASE
            WHEN
                update_last_survey IS NULL
            THEN
                date_part('decade', last_survey_date) * 10
            ELSE
                date_part('decade', update_last_survey) * 10
        END AS symbol_last_survey_decade,
        CASE
            WHEN
                update_last_obs IS NULL
            THEN
                date_part('decade', last_obs_date) * 10
            ELSE
                date_part('decade', update_last_obs) * 10
        END AS symbol_last_obs_decade,
        ST_Centroid(geom) AS geom
    FROM
        avaricosa.avaricosa_polygon
);
COMMIT;
        
