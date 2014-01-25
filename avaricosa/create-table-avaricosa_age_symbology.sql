BEGIN;
CREATE TABLE avaricosa.avaricosa_age_symbology (
    decade INTEGER,
    rgb_blues text
);
COMMIT;

BEGIN;
GRANT ALL ON avaricosa.avaricosa_polygon TO blackosprey;
COMMIT;
