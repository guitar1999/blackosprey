BEGIN;
CREATE VIEW usgs_stream_gauge_minmax_flow AS (
    SELECT  
        *,
        CASE
            WHEN date_part('month', datetime) IN (3,4,5) THEN
                'max'
            WHEN date_part('month', datetime) IN (8,9) THEN
                'min'
            ELSE
                'other'
        END AS flow
    FROM usgs_stream_gauge_daily
);
COMMIT;
