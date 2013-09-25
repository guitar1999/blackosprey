BEGIN;
CREATE TABLE avaricosa.avaricosa_point (
    ap_id SERIAL NOT NULL PRIMARY KEY,
    state TEXT NOT NULL,
    orig_file TEXT,
    id INTEGER,
    huc_8_num INTEGER,
    huc_8_name TEXT,
    first_obs TEXT,
    last_obs TEXT,
    last_survey TEXT,
    pop_condition TEXT,
    location_quality TEXT,
    extirpated TEXT,
    comments1 TEXT,
    comments2 TEXT
);
SELECT AddGeometryColumn('avaricosa', 'avaricosa_point', 'geom', 4326, 'POINT', 2);
COMMIT;
BEGIN;
GRANT ALL ON avaricosa.avaricosa_point TO blackosprey;
COMMIT;

