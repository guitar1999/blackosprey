BEGIN;
CREATE VIEW prism_combined_statistics AS
	select p.huc_8_num, p.prism_year, p.prism_month, p.num_pixels AS ppt_num_pixels, p.mean AS ppt_mean, p.std_dev AS ppt_std_dev, p.sum AS ppt_sum, x.num_pixels AS tmax_num_pixels, x.mean AS tmax_mean, x.std_dev AS tmax_std_dev, x.max AS tmax_max, x.min AS tmax_min, n.num_pixels AS tmin_num_pixels, n.mean AS tmin_mean, n.std_dev AS tmin_std_dev, n.max AS tmin_max, n.min AS tmin_min FROM (prism_ppt_statistics p INNER JOIN prism_tmax_statistics x ON p.huc_8_num=x.huc_8_num AND p.prism_year=x.prism_year AND p.prism_month=x.prism_month) INNER JOIN prism_tmin_statistics n ON p.huc_8_num=n.huc_8_num AND p.prism_year=n.prism_year AND p.prism_month=n.prism_month;
COMMIT;
BEGIN;
GRANT ALL ON prism_combined_statistics TO tinacormier;
COMMIT
