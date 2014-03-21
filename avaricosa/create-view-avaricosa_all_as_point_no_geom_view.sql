BEGIN;
DROP VIEW IF EXISTS avaricosa.avaricosa_all_as_point_no_geom_view CASCADE;
CREATE OR REPLACE VIEW avaricosa.avaricosa_all_as_point_no_geom_view AS (
    SELECT
        ap_id,
        town,
        state,
        orig_file,
        id,
        huc_8_num,
        huc_8_name,
        waterway,
        reachcode,
        first_obs,
        first_obs_decade,
        last_obs,
        last_obs_decade,
        last_survey,
        last_survey_decade,
        pop_condition,
        location_quality,
        update_pop_cond,
        update_pop_cond_confidence,
        update_pop_cond_author,
        update_last_survey,
        update_last_survey_decade,
        update_last_obs,
        update_last_obs_decade,
        comments1,
        comments2,
        symbol_pop_cond,
        symbol_last_survey_decade,
        symbol_last_obs_decade,
        source_geom
    FROM avaricosa.avaricosa_all_as_point_view
);
COMMIT;