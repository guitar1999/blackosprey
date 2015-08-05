BEGIN;
DROP VIEW IF EXISTS avaricosa.avaricosa_line_midpoint_view CASCADE;
CREATE OR REPLACE VIEW avaricosa.avaricosa_line_midpoint_view AS (
    SELECT 
        ap_id,
        town,
        state,
        orig_file,
        id,
        huc_8_num,
        huc_8_name,
        huc_12,
        huc_12_name,
        waterway,
        reachcode,
        nhd_permanent_,
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
                CASE
                    WHEN pop_condition IN ('A', 'B', 'C', 'D', 'AB', 'AC', 'AD', 'BC', 'BD', 'CD', 'E', 'H', 'X', 'F', 'U', 'NR')
                    THEN
                        pop_condition
                    ELSE
                        'NR'::text
                END
            ELSE
                CASE
                    WHEN update_pop_cond IN ('A', 'B', 'C', 'D', 'AB', 'AC', 'AD', 'BC', 'BD', 'CD', 'E', 'H', 'X', 'F', 'U', 'NR')
                    THEN
                        update_pop_cond
                    ELSE
                        'NR'::text
                END
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
        CASE 
            WHEN 
                id = '13653' 
            THEN 
                ST_GeomFromText('POINT(-74.902326810394 41.1328710507476)', 4326) --Hand calculated because of self-intersecting segments in the MULTILINESTRING
            ELSE 
                ST_Line_Interpolate_Point(ST_LineMerge(geom), 0.5) 
        END AS geom
    FROM
        avaricosa.avaricosa_line
);
COMMIT;
        
