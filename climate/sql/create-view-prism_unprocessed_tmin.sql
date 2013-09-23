CREATE VIEW prism_unprocessed_tmin AS 
	SELECT 
		n.huc_8_num 
	FROM 
		nhd_hu8_watersheds n 
	LEFT JOIN 
		prism_tmin_statistics p 
	ON 
		n.huc_8_num=p.huc_8_num 
	WHERE 
		n.contains_avaricosa = 'Y' AND 
		p.huc_8_num IS NULL
;
