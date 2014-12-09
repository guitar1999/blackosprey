CREATE TABLE prism_tmin_statistics_huc12 (
	ptns SERIAL NOT NULL PRIMARY KEY,
	huc_12 text NOT NULL REFERENCES nhd_hu12_watersheds (huc_12),
	prism_year integer NOT NULL,
	prism_month integer NOT NULL,
	num_pixels integer,
	mean numeric,
	std_dev numeric,
	max numeric,
	min numeric,
	CONSTRAINT tmin_unique_huc12 UNIQUE (huc_12ß, prism_year, prism_month)
);
