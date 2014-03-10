WITH index_query AS (
        SELECT 
            st_distance(n.geom, a.geom) AS distance, 
            ap_id, 
            gnis_name, 
            n.reachcode 
        FROM 
            avaricosa_point a, 
            nhd.nhd_flowline_nh n 
        WHERE 
            state = 'nh' 
        ORDER BY 
            st_distance(n.geom, a.geom)
    ),  closest_streams AS (
        SELECT DISTINCT ON (ap_id) 
            ap_id, 
            gnis_name, 
            distance, 
            reachcode 
        FROM 
            index_query 
        ORDER BY 
            ap_id, 
            distance
    ) 
UPDATE 
    avaricosa_point
SET 
    waterway = 
        CASE 
            WHEN 
                avaricosa_point.waterway IS NULL THEN closest_streams.gnis_name 
            ELSE 
                avaricosa_point.waterway 
        END, 
    reachcode = 
        CASE 
            WHEN 
                avaricosa_point.reachcode IS NULL THEN closest_streams.reachcode 
            ELSE 
                avaricosa_point.reachcode 
        END
FROM 
    closest_streams 
WHERE 
    closest_streams.ap_id=avaricosa_point.ap_id AND 
    avaricosa_point.state = 'nh' AND 
    (
        avaricosa_point.waterway IS NULL OR 
        avaricosa_point.reachcode IS NULL
    ) 
RETURNING 
    avaricosa_point.waterway, 
    avaricosa_point.reachcode, 
    avaricosa_point.ap_id, 
    avaricosa_point.state;
