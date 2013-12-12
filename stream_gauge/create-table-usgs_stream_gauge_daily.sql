BEGIN;
CREATE TABLE usgs_stream_gauge_daily (
    usgd SERIAL NOT NULL PRIMARY KEY,
    agency_cd TEXT,
    site_no INTEGER NOT NULL,
    datetime DATE NOT NULL,
    discharge_minimum NUMERIC,
    discharge_minimum_qual_code TEXT,
    discharge_mean NUMERIC,
    discharge_mean_qual_code TEXT,
    discharge_maximum  NUMERIC,
    discharge_maximum_qual_code TEXT,
    height_minimum NUMERIC,
    height_minimum_qual_code TEXT,
    height_mean NUMERIC,
    height_mean_qual_code TEXT,
    height_maximum NUMERIC,
    height_maximum_qual_code TEXT,
    height_sum NUMERIC,
    height_sum_qual_code TEXT
);
COMMIT;

BEGIN;
GRANT ALL ON usgs_stream_gauge_daily TO blackosprey;
COMMIT;