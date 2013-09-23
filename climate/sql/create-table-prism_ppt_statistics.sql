CREATE TABLE prism_ppt_statistics (
	pps SERIAL NOT NULL PRIMARY KEY,
	huc_8_num integer NOT NULL REFERENCES nhd_hu8_watersheds (huc_8_num),
	prism_year integer NOT NULL,
	prism_month integer NOT NULL,
	num_pixels integer,
	mean numeric,
	std_dev numeric,
	sum numeric,
	UNIQUE (huc_8_num, prism_year, prism_month)
);
