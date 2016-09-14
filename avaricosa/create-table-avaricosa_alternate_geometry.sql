CREATE TABLE avaricosa.avaricosa_alternate_geometry (
    aag_id SERIAL NOT NULL PRIMARY KEY,
    primary_key TEXT,
    geom GEOMETRY(Point, 4326)
);