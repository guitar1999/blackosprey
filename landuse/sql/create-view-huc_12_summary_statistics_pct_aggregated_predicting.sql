BEGIN;
DROP VIEW IF EXISTS huc_12_summary_statistics_pct_aggregated_predicting CASCADE;
CREATE OR REPLACE VIEW huc_12_summary_statistics_pct_aggregated_predicting AS (
    SELECT
        h.huc_12,
        num_pixels,
        s1992_lc92_11 / num_pixels::numeric * 100 AS s1992_lc92_water_pct,
        s1992_lc92_12 / num_pixels::numeric * 100 AS s1992_lc92_snow_pct,
        (s1992_lc92_21 + s1992_lc92_22 + s1992_lc92_23) / num_pixels::numeric * 100 AS s1992_lc92_developed_pct,
        (s1992_lc92_31 + s1992_lc92_32 + s1992_lc92_33) / num_pixels::numeric * 100 AS s1992_lc92_barren_pct,
        (s1992_lc92_41 + s1992_lc92_42 + s1992_lc92_43) / num_pixels::numeric * 100 AS s1992_lc92_forest_pct,
        s1992_lc92_51 / num_pixels::numeric * 100 AS s1992_lc92_shrub_pct,
        s1992_lc92_61 / num_pixels::numeric * 100 AS s1992_lc92_non_woody_pct,
        s1992_lc92_71 / num_pixels::numeric * 100 AS s1992_lc92_herbaceous_pct,
        (s1992_lc92_81 + s1992_lc92_82 + s1992_lc92_83 + s1992_lc92_84 + s1992_lc92_85) / num_pixels::numeric * 100 AS s1992_lc92_planted_pct,
        (s1992_lc92_91 + s1992_lc92_92) / num_pixels::numeric * 100 AS s1992_lc92_wetland_pct,
        s2001_cd_mean,
        s2001_cd_std_dev,
        s2001_cd_min,
        s2001_cd_max,
        s2001_impervious_mean,
        s2001_impervious_std_dev,
        s2001_impervious_min,
        s2001_impervious_max,
        s2001_lc_11 / num_pixels::numeric * 100 AS s2001_lc_water,
        s2001_lc_12 / num_pixels::numeric * 100 AS s2001_lc_snow,
        (s2001_lc_21 + s2001_lc_22 + s2001_lc_23 + s2001_lc_24 )/ num_pixels::numeric * 100 AS s2001_lc_developed_pct,
        s2001_lc_31 / num_pixels::numeric * 100 AS s2001_lc_barren_pct,
        (s2001_lc_41 + s2001_lc_42 + s2001_lc_43) / num_pixels::numeric * 100 AS s2001_lc_forest_pct,
        (s2001_lc_51 + s2001_lc_52) / num_pixels::numeric * 100 AS s2001_lc_shrub_pct,
        (s2001_lc_71 + s2001_lc_72 + s2001_lc_73 + s2001_lc_74) / num_pixels::numeric * 100 AS s2001_lc_herbaceous_pct,
        (s2001_lc_81 + s2001_lc_82) / num_pixels::numeric * 100 AS s2001_lc_planted_pct,
        (s2001_lc_90 + s2001_lc_95) / num_pixels::numeric * 100 AS s2001_lc_wetland_pct,
        s2011_cd_mean,
        s2011_cd_std_dev,
        s2011_cd_min,
        s2011_cd_max,
        s2011_impervious_mean,
        s2011_impervious_std_dev,
        s2011_impervious_min,
        s2011_impervious_max,
        s2011_lc_11 / num_pixels::numeric * 100 AS s2011_lc_water,
        s2011_lc_12 / num_pixels::numeric * 100 AS s2011_lc_snow,
        (s2011_lc_21 + s2011_lc_22 + s2011_lc_23 + s2011_lc_24 )/ num_pixels::numeric * 100 AS s2011_lc_developed_pct,
        s2011_lc_31 / num_pixels::numeric * 100 AS s2011_lc_barren_pct,
        (s2011_lc_41 + s2011_lc_42 + s2011_lc_43) / num_pixels::numeric * 100 AS s2011_lc_forest_pct,
        (s2011_lc_51 + s2011_lc_52) / num_pixels::numeric * 100 AS s2011_lc_shrub_pct,
        (s2011_lc_71 + s2011_lc_72 + s2011_lc_73 + s2011_lc_74) / num_pixels::numeric * 100 AS s2011_lc_herbaceous_pct,
        (s2011_lc_81 + s2011_lc_82) / num_pixels::numeric * 100 AS s2011_lc_planted_pct,
        (s2011_lc_90 + s2011_lc_95) / num_pixels::numeric * 100 AS s2011_lc_wetland_pct,
        s2011_lcc_11 / num_pixels::numeric * 100 AS s2011_lcc_water,
        s2011_lcc_12 / num_pixels::numeric * 100 AS s2011_lcc_snow,
        (s2011_lcc_21 + s2011_lcc_22 + s2011_lcc_23 + s2011_lcc_24 )/ num_pixels::numeric * 100 AS s2011_lcc_developed_pct,
        s2011_lcc_31 / num_pixels::numeric * 100 AS s2011_lcc_barren_pct,
        (s2011_lcc_41 + s2011_lcc_42 + s2011_lcc_43) / num_pixels::numeric * 100 AS s2011_lcc_forest_pct,
        (s2011_lcc_51 + s2011_lcc_52) / num_pixels::numeric * 100 AS s2011_lcc_shrub_pct,
        (s2011_lcc_71 + s2011_lcc_72 + s2011_lcc_73 + s2011_lcc_74) / num_pixels::numeric * 100 AS s2011_lcc_herbaceous_pct,
        (s2011_lcc_81 + s2011_lcc_82) / num_pixels::numeric * 100 AS s2011_lcc_planted_pct,
        (s2011_lcc_90 + s2011_lcc_95) / num_pixels::numeric * 100 AS s2011_lcc_wetland_pct,
        processed_time,
        ned_mean,
        ned_std_dev,
        ned_min,
        ned_max,
        slope_mean,
        slope_std_dev,
        slope_min,
        slope_max,
        tri_mean,
        tri_std_dev,
        tri_min,
        tri_max,
        roughness_mean,
        roughness_std_dev,
        roughness_min,
        roughness_max,
        ppt_trend_mean,
        ppt_trend_std_dev,
        ppt_trend_min,
        ppt_trend_max,
        tmin_trend_mean,
        tmin_trend_std_dev,
        tmin_trend_min,
        tmin_trend_max,
        tmax_trend_mean,
        tmax_trend_std_dev,
        tmax_trend_min,
        tmax_trend_max
    FROM
        huc_12_summary_statistics h 
    WHERE 
        NOT num_pixels = 0
);
COMMIT;
