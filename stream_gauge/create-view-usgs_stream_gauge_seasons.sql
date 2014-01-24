BEGIN;
CREATE VIEW usgs_stream_gauge_seasons AS (
    SELECT  *,
        CASE WHEN date_part('month', datetime) = 12 THEN
            date_part('year', datetime) + 1
        ELSE
            date_part('year', datetime)
        END AS year,
        CASE WHEN date_part('month', datetime) IN (12,1,2) THEN
            'winter'
        WHEN date_part('month', datetime) IN (3,4,5) THEN
            'spring'
        WHEN date_part('month', datetime) IN (6,7,8) THEN
            'summer'
        ELSE
            'fall'
        END AS season
    FROM usgs_stream_gauge_daily
);
COMMIT;
