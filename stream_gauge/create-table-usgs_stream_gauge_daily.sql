BEGIN;
CREATE TABLE usgs_stream_gauge_daily (
    usgd SERIAL NOT NULL PRIMARY KEY,
    huc_8_num INTEGER,
    agency_cd TEXT,
    site_no INTEGER NOT NULL,
    datetime DATE NOT NULL,
    discharge_minimum TEXT,
    discharge_minimum_qual_code TEXT,
    discharge_mean TEXT,
    discharge_mean_qual_code TEXT,
    discharge_maximum  TEXT,
    discharge_maximum_qual_code TEXT,
    height_minimum TEXT,
    height_minimum_qual_code TEXT,
    height_mean TEXT,
    height_mean_qual_code TEXT,
    height_maximum TEXT,
    height_maximum_qual_code TEXT,
    height_sum TEXT,
    height_sum_qual_code TEXT
);
COMMIT;

BEGIN;
GRANT ALL ON usgs_stream_gauge_daily TO blackosprey;
COMMIT;