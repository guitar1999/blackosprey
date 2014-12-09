CREATE VIEW prism_unprocessed_huc12_tmax AS 
	SELECT 
		n.huc_12
	FROM 
		nhd_hu12_watersheds n 
	LEFT JOIN 
		prism_tmax_statistics_huc12 p 
	ON 
		n.huc_12=p.huc_12 
	WHERE 
		p.huc_12 IS NULL
;
