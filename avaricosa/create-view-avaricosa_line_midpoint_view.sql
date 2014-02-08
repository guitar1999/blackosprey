BEGIN;
CREATE VIEW avaricosa.avaricosa_line_midpoint_view AS (
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
        
