CREATE OR REPLACE VIEW prediction_geom AS (
    SELECT 
        n.permanent_,
        n.geom_buffer,
        n.state,
        p.prediction,
        p.probablity_poor,
        p.probability_fair,
        p.probability_good
    FROM
        nhd_flowline_all_no_duplicates n INNER JOIN 
        prediction p ON n.permanent_=p.permanent
);

