BEGIN;
DROP VIEW IF EXISTS huc_12_summary_statistics_pct CASCADE;
CREATE OR REPLACE VIEW huc_12_summary_statistics_pct AS (
    SELECT
        huc_12,
        num_pixels,
        s1992_lc92_11 / num_pixels::numeric * 100 AS s1992_lc92_11_pct,
        s1992_lc92_12 / num_pixels::numeric * 100 AS s1992_lc92_12_pct,
        s1992_lc92_21 / num_pixels::numeric * 100 AS s1992_lc92_21_pct,
        s1992_lc92_22 / num_pixels::numeric * 100 AS s1992_lc92_22_pct,
        s1992_lc92_23 / num_pixels::numeric * 100 AS s1992_lc92_23_pct,
        s1992_lc92_31 / num_pixels::numeric * 100 AS s1992_lc92_31_pct,
        s1992_lc92_32 / num_pixels::numeric * 100 AS s1992_lc92_32_pct,
        s1992_lc92_33 / num_pixels::numeric * 100 AS s1992_lc92_33_pct,
        s1992_lc92_41 / num_pixels::numeric * 100 AS s1992_lc92_41_pct,
        s1992_lc92_42 / num_pixels::numeric * 100 AS s1992_lc92_42_pct,
        s1992_lc92_43 / num_pixels::numeric * 100 AS s1992_lc92_43_pct,
        s1992_lc92_51 / num_pixels::numeric * 100 AS s1992_lc92_51_pct,
        s1992_lc92_61 / num_pixels::numeric * 100 AS s1992_lc92_61_pct,
        s1992_lc92_71 / num_pixels::numeric * 100 AS s1992_lc92_71_pct,
        s1992_lc92_81 / num_pixels::numeric * 100 AS s1992_lc92_81_pct,
        s1992_lc92_82 / num_pixels::numeric * 100 AS s1992_lc92_82_pct,
        s1992_lc92_83 / num_pixels::numeric * 100 AS s1992_lc92_83_pct,
        s1992_lc92_84 / num_pixels::numeric * 100 AS s1992_lc92_84_pct,
        s1992_lc92_85 / num_pixels::numeric * 100 AS s1992_lc92_85_pct,
        s1992_lc92_91 / num_pixels::numeric * 100 AS s1992_lc92_91_pct,
        s1992_lc92_92 / num_pixels::numeric * 100 AS s1992_lc92_92_pct,
        s2001_cd_mean,
        s2001_cd_std_dev,
        s2001_cd_min,
        s2001_cd_max,
        s2001_impervious_mean,
        s2001_impervious_std_dev,
        s2001_impervious_min,
        s2001_impervious_max,
        s2001_lc_11 / num_pixels::numeric * 100 AS s2001_lc_11_pct,
        s2001_lc_12 / num_pixels::numeric * 100 AS s2001_lc_12_pct,
        s2001_lc_21 / num_pixels::numeric * 100 AS s2001_lc_21_pct,
        s2001_lc_22 / num_pixels::numeric * 100 AS s2001_lc_22_pct,
        s2001_lc_23 / num_pixels::numeric * 100 AS s2001_lc_23_pct,
        s2001_lc_24 / num_pixels::numeric * 100 AS s2001_lc_24_pct,
        s2001_lc_31 / num_pixels::numeric * 100 AS s2001_lc_31_pct,
        s2001_lc_32 / num_pixels::numeric * 100 AS s2001_lc_32_pct,
        s2001_lc_41 / num_pixels::numeric * 100 AS s2001_lc_41_pct,
        s2001_lc_42 / num_pixels::numeric * 100 AS s2001_lc_42_pct,
        s2001_lc_43 / num_pixels::numeric * 100 AS s2001_lc_43_pct,
        s2001_lc_51 / num_pixels::numeric * 100 AS s2001_lc_51_pct,
        s2001_lc_52 / num_pixels::numeric * 100 AS s2001_lc_52_pct,
        s2001_lc_71 / num_pixels::numeric * 100 AS s2001_lc_71_pct,
        s2001_lc_72 / num_pixels::numeric * 100 AS s2001_lc_72_pct,
        s2001_lc_73 / num_pixels::numeric * 100 AS s2001_lc_73_pct,
        s2001_lc_74 / num_pixels::numeric * 100 AS s2001_lc_74_pct,
        s2001_lc_81 / num_pixels::numeric * 100 AS s2001_lc_81_pct,
        s2001_lc_82 / num_pixels::numeric * 100 AS s2001_lc_82_pct,
        s2001_lc_90 / num_pixels::numeric * 100 AS s2001_lc_90_pct,
        s2001_lc_91 / num_pixels::numeric * 100 AS s2001_lc_91_pct,
        s2001_lc_92 / num_pixels::numeric * 100 AS s2001_lc_92_pct,
        s2001_lc_93 / num_pixels::numeric * 100 AS s2001_lc_93_pct,
        s2001_lc_94 / num_pixels::numeric * 100 AS s2001_lc_94_pct,
        s2001_lc_95 / num_pixels::numeric * 100 AS s2001_lc_95_pct,
        s2011_cd_mean,
        s2011_cd_std_dev,
        s2011_cd_min,
        s2011_cd_max,
        s2011_impervious_mean,
        s2011_impervious_std_dev,
        s2011_impervious_min,
        s2011_impervious_max,
        s2011_lc_11 / num_pixels::numeric * 100 AS s2011_lc_11_pct,
        s2011_lc_12 / num_pixels::numeric * 100 AS s2011_lc_12_pct,
        s2011_lc_21 / num_pixels::numeric * 100 AS s2011_lc_21_pct,
        s2011_lc_22 / num_pixels::numeric * 100 AS s2011_lc_22_pct,
        s2011_lc_23 / num_pixels::numeric * 100 AS s2011_lc_23_pct,
        s2011_lc_24 / num_pixels::numeric * 100 AS s2011_lc_24_pct,
        s2011_lc_31 / num_pixels::numeric * 100 AS s2011_lc_31_pct,
        s2011_lc_32 / num_pixels::numeric * 100 AS s2011_lc_32_pct,
        s2011_lc_41 / num_pixels::numeric * 100 AS s2011_lc_41_pct,
        s2011_lc_42 / num_pixels::numeric * 100 AS s2011_lc_42_pct,
        s2011_lc_43 / num_pixels::numeric * 100 AS s2011_lc_43_pct,
        s2011_lc_51 / num_pixels::numeric * 100 AS s2011_lc_51_pct,
        s2011_lc_52 / num_pixels::numeric * 100 AS s2011_lc_52_pct,
        s2011_lc_71 / num_pixels::numeric * 100 AS s2011_lc_71_pct,
        s2011_lc_72 / num_pixels::numeric * 100 AS s2011_lc_72_pct,
        s2011_lc_73 / num_pixels::numeric * 100 AS s2011_lc_73_pct,
        s2011_lc_74 / num_pixels::numeric * 100 AS s2011_lc_74_pct,
        s2011_lc_81 / num_pixels::numeric * 100 AS s2011_lc_81_pct,
        s2011_lc_82 / num_pixels::numeric * 100 AS s2011_lc_82_pct,
        s2011_lc_90 / num_pixels::numeric * 100 AS s2011_lc_90_pct,
        s2011_lc_91 / num_pixels::numeric * 100 AS s2011_lc_91_pct,
        s2011_lc_92 / num_pixels::numeric * 100 AS s2011_lc_92_pct,
        s2011_lc_93 / num_pixels::numeric * 100 AS s2011_lc_93_pct,
        s2011_lc_94 / num_pixels::numeric * 100 AS s2011_lc_94_pct,
        s2011_lc_95 / num_pixels::numeric * 100 AS s2011_lc_95_pct,
        s2011_lcc_11 / num_pixels::numeric * 100 AS s2011_lcc_11_pct,
        s2011_lcc_12 / num_pixels::numeric * 100 AS s2011_lcc_12_pct,
        s2011_lcc_21 / num_pixels::numeric * 100 AS s2011_lcc_21_pct,
        s2011_lcc_22 / num_pixels::numeric * 100 AS s2011_lcc_22_pct,
        s2011_lcc_23 / num_pixels::numeric * 100 AS s2011_lcc_23_pct,
        s2011_lcc_24 / num_pixels::numeric * 100 AS s2011_lcc_24_pct,
        s2011_lcc_31 / num_pixels::numeric * 100 AS s2011_lcc_31_pct,
        s2011_lcc_32 / num_pixels::numeric * 100 AS s2011_lcc_32_pct,
        s2011_lcc_41 / num_pixels::numeric * 100 AS s2011_lcc_41_pct,
        s2011_lcc_42 / num_pixels::numeric * 100 AS s2011_lcc_42_pct,
        s2011_lcc_43 / num_pixels::numeric * 100 AS s2011_lcc_43_pct,
        s2011_lcc_51 / num_pixels::numeric * 100 AS s2011_lcc_51_pct,
        s2011_lcc_52 / num_pixels::numeric * 100 AS s2011_lcc_52_pct,
        s2011_lcc_71 / num_pixels::numeric * 100 AS s2011_lcc_71_pct,
        s2011_lcc_72 / num_pixels::numeric * 100 AS s2011_lcc_72_pct,
        s2011_lcc_73 / num_pixels::numeric * 100 AS s2011_lcc_73_pct,
        s2011_lcc_74 / num_pixels::numeric * 100 AS s2011_lcc_74_pct,
        s2011_lcc_81 / num_pixels::numeric * 100 AS s2011_lcc_81_pct,
        s2011_lcc_82 / num_pixels::numeric * 100 AS s2011_lcc_82_pct,
        s2011_lcc_90 / num_pixels::numeric * 100 AS s2011_lcc_90_pct,
        s2011_lcc_91 / num_pixels::numeric * 100 AS s2011_lcc_91_pct,
        s2011_lcc_92 / num_pixels::numeric * 100 AS s2011_lcc_92_pct,
        s2011_lcc_93 / num_pixels::numeric * 100 AS s2011_lcc_93_pct,
        s2011_lcc_94 / num_pixels::numeric * 100 AS s2011_lcc_94_pct,
        s2011_lcc_95 / num_pixels::numeric * 100 AS s2011_lcc_95_pct,
        s2011_lcft_1 / num_pixels::numeric * 100 AS s2011_lcft_1_pct,
        s2011_lcft_2 / num_pixels::numeric * 100 AS s2011_lcft_2_pct,
        s2011_lcft_3 / num_pixels::numeric * 100 AS s2011_lcft_3_pct,
        s2011_lcft_4 / num_pixels::numeric * 100 AS s2011_lcft_4_pct,
        s2011_lcft_5 / num_pixels::numeric * 100 AS s2011_lcft_5_pct,
        s2011_lcft_6 / num_pixels::numeric * 100 AS s2011_lcft_6_pct,
        s2011_lcft_7 / num_pixels::numeric * 100 AS s2011_lcft_7_pct,
        s2011_lcft_8 / num_pixels::numeric * 100 AS s2011_lcft_8_pct,
        s2011_lcft_9 / num_pixels::numeric * 100 AS s2011_lcft_9_pct,
        s2011_lcft_10 / num_pixels::numeric * 100 AS s2011_lcft_10_pct,
        s2011_lcft_11 / num_pixels::numeric * 100 AS s2011_lcft_11_pct,
        s2011_lcft_12 / num_pixels::numeric * 100 AS s2011_lcft_12_pct,
        s2011_lcft_13 / num_pixels::numeric * 100 AS s2011_lcft_13_pct,
        s2011_lcft_14 / num_pixels::numeric * 100 AS s2011_lcft_14_pct,
        s2011_lcft_15 / num_pixels::numeric * 100 AS s2011_lcft_15_pct,
        s2011_lcft_16 / num_pixels::numeric * 100 AS s2011_lcft_16_pct,
        s2011_lcft_17 / num_pixels::numeric * 100 AS s2011_lcft_17_pct,
        s2011_lcft_18 / num_pixels::numeric * 100 AS s2011_lcft_18_pct,
        s2011_lcft_19 / num_pixels::numeric * 100 AS s2011_lcft_19_pct,
        s2011_lcft_20 / num_pixels::numeric * 100 AS s2011_lcft_20_pct,
        s2011_lcft_21 / num_pixels::numeric * 100 AS s2011_lcft_21_pct,
        s2011_lcft_22 / num_pixels::numeric * 100 AS s2011_lcft_22_pct,
        s2011_lcft_23 / num_pixels::numeric * 100 AS s2011_lcft_23_pct,
        s2011_lcft_24 / num_pixels::numeric * 100 AS s2011_lcft_24_pct,
        s2011_lcft_25 / num_pixels::numeric * 100 AS s2011_lcft_25_pct,
        s2011_lcft_26 / num_pixels::numeric * 100 AS s2011_lcft_26_pct,
        s2011_lcft_27 / num_pixels::numeric * 100 AS s2011_lcft_27_pct,
        s2011_lcft_28 / num_pixels::numeric * 100 AS s2011_lcft_28_pct,
        s2011_lcft_29 / num_pixels::numeric * 100 AS s2011_lcft_29_pct,
        s2011_lcft_30 / num_pixels::numeric * 100 AS s2011_lcft_30_pct,
        s2011_lcft_31 / num_pixels::numeric * 100 AS s2011_lcft_31_pct,
        s2011_lcft_32 / num_pixels::numeric * 100 AS s2011_lcft_32_pct,
        s2011_lcft_33 / num_pixels::numeric * 100 AS s2011_lcft_33_pct,
        s2011_lcft_34 / num_pixels::numeric * 100 AS s2011_lcft_34_pct,
        s2011_lcft_35 / num_pixels::numeric * 100 AS s2011_lcft_35_pct,
        s2011_lcft_36 / num_pixels::numeric * 100 AS s2011_lcft_36_pct,
        s2011_lcft_37 / num_pixels::numeric * 100 AS s2011_lcft_37_pct,
        s2011_lcft_38 / num_pixels::numeric * 100 AS s2011_lcft_38_pct,
        s2011_lcft_39 / num_pixels::numeric * 100 AS s2011_lcft_39_pct,
        s2011_lcft_40 / num_pixels::numeric * 100 AS s2011_lcft_40_pct,
        s2011_lcft_41 / num_pixels::numeric * 100 AS s2011_lcft_41_pct,
        s2011_lcft_42 / num_pixels::numeric * 100 AS s2011_lcft_42_pct,
        s2011_lcft_43 / num_pixels::numeric * 100 AS s2011_lcft_43_pct,
        s2011_lcft_44 / num_pixels::numeric * 100 AS s2011_lcft_44_pct,
        s2011_lcft_45 / num_pixels::numeric * 100 AS s2011_lcft_45_pct,
        s2011_lcft_46 / num_pixels::numeric * 100 AS s2011_lcft_46_pct,
        s2011_lcft_47 / num_pixels::numeric * 100 AS s2011_lcft_47_pct,
        s2011_lcft_48 / num_pixels::numeric * 100 AS s2011_lcft_48_pct,
        s2011_lcft_49 / num_pixels::numeric * 100 AS s2011_lcft_49_pct,
        s2011_lcft_50 / num_pixels::numeric * 100 AS s2011_lcft_50_pct,
        s2011_lcft_51 / num_pixels::numeric * 100 AS s2011_lcft_51_pct,
        s2011_lcft_52 / num_pixels::numeric * 100 AS s2011_lcft_52_pct,
        s2011_lcft_53 / num_pixels::numeric * 100 AS s2011_lcft_53_pct,
        s2011_lcft_54 / num_pixels::numeric * 100 AS s2011_lcft_54_pct,
        s2011_lcft_55 / num_pixels::numeric * 100 AS s2011_lcft_55_pct,
        s2011_lcft_56 / num_pixels::numeric * 100 AS s2011_lcft_56_pct,
        s2011_lcft_57 / num_pixels::numeric * 100 AS s2011_lcft_57_pct,
        s2011_lcft_58 / num_pixels::numeric * 100 AS s2011_lcft_58_pct,
        s2011_lcft_59 / num_pixels::numeric * 100 AS s2011_lcft_59_pct,
        s2011_lcft_60 / num_pixels::numeric * 100 AS s2011_lcft_60_pct,
        s2011_lcft_61 / num_pixels::numeric * 100 AS s2011_lcft_61_pct,
        s2011_lcft_62 / num_pixels::numeric * 100 AS s2011_lcft_62_pct,
        s2011_lcft_63 / num_pixels::numeric * 100 AS s2011_lcft_63_pct,
        s2011_lcft_64 / num_pixels::numeric * 100 AS s2011_lcft_64_pct,
        s2011_lcft_65 / num_pixels::numeric * 100 AS s2011_lcft_65_pct,
        s2011_lcft_66 / num_pixels::numeric * 100 AS s2011_lcft_66_pct,
        s2011_lcft_67 / num_pixels::numeric * 100 AS s2011_lcft_67_pct,
        s2011_lcft_68 / num_pixels::numeric * 100 AS s2011_lcft_68_pct,
        s2011_lcft_69 / num_pixels::numeric * 100 AS s2011_lcft_69_pct,
        s2011_lcft_70 / num_pixels::numeric * 100 AS s2011_lcft_70_pct,
        s2011_lcft_71 / num_pixels::numeric * 100 AS s2011_lcft_71_pct,
        s2011_lcft_72 / num_pixels::numeric * 100 AS s2011_lcft_72_pct,
        s2011_lcft_73 / num_pixels::numeric * 100 AS s2011_lcft_73_pct,
        s2011_lcft_74 / num_pixels::numeric * 100 AS s2011_lcft_74_pct,
        s2011_lcft_75 / num_pixels::numeric * 100 AS s2011_lcft_75_pct,
        s2011_lcft_76 / num_pixels::numeric * 100 AS s2011_lcft_76_pct,
        s2011_lcft_77 / num_pixels::numeric * 100 AS s2011_lcft_77_pct,
        s2011_lcft_78 / num_pixels::numeric * 100 AS s2011_lcft_78_pct,
        s2011_lcft_79 / num_pixels::numeric * 100 AS s2011_lcft_79_pct,
        s2011_lcft_80 / num_pixels::numeric * 100 AS s2011_lcft_80_pct,
        s2011_lcft_81 / num_pixels::numeric * 100 AS s2011_lcft_81_pct,
        s2011_lcft_82 / num_pixels::numeric * 100 AS s2011_lcft_82_pct,
        s2011_lcft_83 / num_pixels::numeric * 100 AS s2011_lcft_83_pct,
        s2011_lcft_84 / num_pixels::numeric * 100 AS s2011_lcft_84_pct,
        s2011_lcft_85 / num_pixels::numeric * 100 AS s2011_lcft_85_pct,
        s2011_lcft_86 / num_pixels::numeric * 100 AS s2011_lcft_86_pct,
        s2011_lcft_87 / num_pixels::numeric * 100 AS s2011_lcft_87_pct,
        s2011_lcft_88 / num_pixels::numeric * 100 AS s2011_lcft_88_pct,
        s2011_lcft_89 / num_pixels::numeric * 100 AS s2011_lcft_89_pct,
        s2011_lcft_90 / num_pixels::numeric * 100 AS s2011_lcft_90_pct,
        s2011_lcft_91 / num_pixels::numeric * 100 AS s2011_lcft_91_pct,
        s2011_lcft_92 / num_pixels::numeric * 100 AS s2011_lcft_92_pct,
        s2011_lcft_93 / num_pixels::numeric * 100 AS s2011_lcft_93_pct,
        s2011_lcft_94 / num_pixels::numeric * 100 AS s2011_lcft_94_pct,
        s2011_lcft_95 / num_pixels::numeric * 100 AS s2011_lcft_95_pct,
        s2011_lcft_96 / num_pixels::numeric * 100 AS s2011_lcft_96_pct,
        s2011_lcft_97 / num_pixels::numeric * 100 AS s2011_lcft_97_pct,
        s2011_lcft_98 / num_pixels::numeric * 100 AS s2011_lcft_98_pct,
        s2011_lcft_99 / num_pixels::numeric * 100 AS s2011_lcft_99_pct,
        s2011_lcft_100 / num_pixels::numeric * 100 AS s2011_lcft_100_pct,
        s2011_lcft_101 / num_pixels::numeric * 100 AS s2011_lcft_101_pct,
        s2011_lcft_102 / num_pixels::numeric * 100 AS s2011_lcft_102_pct,
        s2011_lcft_103 / num_pixels::numeric * 100 AS s2011_lcft_103_pct,
        s2011_lcft_104 / num_pixels::numeric * 100 AS s2011_lcft_104_pct,
        s2011_lcft_105 / num_pixels::numeric * 100 AS s2011_lcft_105_pct,
        s2011_lcft_106 / num_pixels::numeric * 100 AS s2011_lcft_106_pct,
        s2011_lcft_107 / num_pixels::numeric * 100 AS s2011_lcft_107_pct,
        s2011_lcft_108 / num_pixels::numeric * 100 AS s2011_lcft_108_pct,
        s2011_lcft_109 / num_pixels::numeric * 100 AS s2011_lcft_109_pct,
        s2011_lcft_110 / num_pixels::numeric * 100 AS s2011_lcft_110_pct,
        s2011_lcft_111 / num_pixels::numeric * 100 AS s2011_lcft_111_pct,
        s2011_lcft_112 / num_pixels::numeric * 100 AS s2011_lcft_112_pct,
        s2011_lcft_113 / num_pixels::numeric * 100 AS s2011_lcft_113_pct,
        s2011_lcft_114 / num_pixels::numeric * 100 AS s2011_lcft_114_pct,
        s2011_lcft_115 / num_pixels::numeric * 100 AS s2011_lcft_115_pct,
        s2011_lcft_116 / num_pixels::numeric * 100 AS s2011_lcft_116_pct,
        s2011_lcft_117 / num_pixels::numeric * 100 AS s2011_lcft_117_pct,
        s2011_lcft_118 / num_pixels::numeric * 100 AS s2011_lcft_118_pct,
        s2011_lcft_119 / num_pixels::numeric * 100 AS s2011_lcft_119_pct,
        s2011_lcft_120 / num_pixels::numeric * 100 AS s2011_lcft_120_pct,
        s2011_lcft_121 / num_pixels::numeric * 100 AS s2011_lcft_121_pct,
        s2011_lcft_122 / num_pixels::numeric * 100 AS s2011_lcft_122_pct,
        s2011_lcft_123 / num_pixels::numeric * 100 AS s2011_lcft_123_pct,
        s2011_lcft_124 / num_pixels::numeric * 100 AS s2011_lcft_124_pct,
        s2011_lcft_125 / num_pixels::numeric * 100 AS s2011_lcft_125_pct,
        s2011_lcft_126 / num_pixels::numeric * 100 AS s2011_lcft_126_pct,
        s2011_lcft_127 / num_pixels::numeric * 100 AS s2011_lcft_127_pct,
        s2011_lcft_128 / num_pixels::numeric * 100 AS s2011_lcft_128_pct,
        s2011_lcft_129 / num_pixels::numeric * 100 AS s2011_lcft_129_pct,
        s2011_lcft_130 / num_pixels::numeric * 100 AS s2011_lcft_130_pct,
        s2011_lcft_131 / num_pixels::numeric * 100 AS s2011_lcft_131_pct,
        s2011_lcft_132 / num_pixels::numeric * 100 AS s2011_lcft_132_pct,
        s2011_lcft_133 / num_pixels::numeric * 100 AS s2011_lcft_133_pct,
        s2011_lcft_134 / num_pixels::numeric * 100 AS s2011_lcft_134_pct,
        s2011_lcft_135 / num_pixels::numeric * 100 AS s2011_lcft_135_pct,
        s2011_lcft_136 / num_pixels::numeric * 100 AS s2011_lcft_136_pct,
        s2011_lcft_137 / num_pixels::numeric * 100 AS s2011_lcft_137_pct,
        s2011_lcft_138 / num_pixels::numeric * 100 AS s2011_lcft_138_pct,
        s2011_lcft_139 / num_pixels::numeric * 100 AS s2011_lcft_139_pct,
        s2011_lcft_140 / num_pixels::numeric * 100 AS s2011_lcft_140_pct,
        s2011_lcft_141 / num_pixels::numeric * 100 AS s2011_lcft_141_pct,
        s2011_lcft_142 / num_pixels::numeric * 100 AS s2011_lcft_142_pct,
        s2011_lcft_143 / num_pixels::numeric * 100 AS s2011_lcft_143_pct,
        s2011_lcft_144 / num_pixels::numeric * 100 AS s2011_lcft_144_pct,
        s2011_lcft_145 / num_pixels::numeric * 100 AS s2011_lcft_145_pct,
        s2011_lcft_146 / num_pixels::numeric * 100 AS s2011_lcft_146_pct,
        s2011_lcft_147 / num_pixels::numeric * 100 AS s2011_lcft_147_pct,
        s2011_lcft_148 / num_pixels::numeric * 100 AS s2011_lcft_148_pct,
        s2011_lcft_149 / num_pixels::numeric * 100 AS s2011_lcft_149_pct,
        s2011_lcft_150 / num_pixels::numeric * 100 AS s2011_lcft_150_pct,
        s2011_lcft_151 / num_pixels::numeric * 100 AS s2011_lcft_151_pct,
        s2011_lcft_152 / num_pixels::numeric * 100 AS s2011_lcft_152_pct,
        s2011_lcft_153 / num_pixels::numeric * 100 AS s2011_lcft_153_pct,
        s2011_lcft_154 / num_pixels::numeric * 100 AS s2011_lcft_154_pct,
        s2011_lcft_155 / num_pixels::numeric * 100 AS s2011_lcft_155_pct,
        s2011_lcft_156 / num_pixels::numeric * 100 AS s2011_lcft_156_pct,
        s2011_lcft_157 / num_pixels::numeric * 100 AS s2011_lcft_157_pct,
        s2011_lcft_158 / num_pixels::numeric * 100 AS s2011_lcft_158_pct,
        s2011_lcft_159 / num_pixels::numeric * 100 AS s2011_lcft_159_pct,
        s2011_lcft_160 / num_pixels::numeric * 100 AS s2011_lcft_160_pct,
        s2011_lcft_161 / num_pixels::numeric * 100 AS s2011_lcft_161_pct,
        s2011_lcft_162 / num_pixels::numeric * 100 AS s2011_lcft_162_pct,
        s2011_lcft_163 / num_pixels::numeric * 100 AS s2011_lcft_163_pct,
        s2011_lcft_164 / num_pixels::numeric * 100 AS s2011_lcft_164_pct,
        s2011_lcft_165 / num_pixels::numeric * 100 AS s2011_lcft_165_pct,
        s2011_lcft_166 / num_pixels::numeric * 100 AS s2011_lcft_166_pct,
        s2011_lcft_167 / num_pixels::numeric * 100 AS s2011_lcft_167_pct,
        s2011_lcft_168 / num_pixels::numeric * 100 AS s2011_lcft_168_pct,
        s2011_lcft_169 / num_pixels::numeric * 100 AS s2011_lcft_169_pct,
        s2011_lcft_170 / num_pixels::numeric * 100 AS s2011_lcft_170_pct,
        s2011_lcft_171 / num_pixels::numeric * 100 AS s2011_lcft_171_pct,
        s2011_lcft_172 / num_pixels::numeric * 100 AS s2011_lcft_172_pct,
        s2011_lcft_173 / num_pixels::numeric * 100 AS s2011_lcft_173_pct,
        s2011_lcft_174 / num_pixels::numeric * 100 AS s2011_lcft_174_pct,
        s2011_lcft_175 / num_pixels::numeric * 100 AS s2011_lcft_175_pct,
        s2011_lcft_176 / num_pixels::numeric * 100 AS s2011_lcft_176_pct,
        s2011_lcft_177 / num_pixels::numeric * 100 AS s2011_lcft_177_pct,
        s2011_lcft_178 / num_pixels::numeric * 100 AS s2011_lcft_178_pct,
        s2011_lcft_179 / num_pixels::numeric * 100 AS s2011_lcft_179_pct,
        s2011_lcft_180 / num_pixels::numeric * 100 AS s2011_lcft_180_pct,
        s2011_lcft_181 / num_pixels::numeric * 100 AS s2011_lcft_181_pct,
        s2011_lcft_182 / num_pixels::numeric * 100 AS s2011_lcft_182_pct,
        s2011_lcft_183 / num_pixels::numeric * 100 AS s2011_lcft_183_pct,
        s2011_lcft_184 / num_pixels::numeric * 100 AS s2011_lcft_184_pct,
        s2011_lcft_185 / num_pixels::numeric * 100 AS s2011_lcft_185_pct,
        s2011_lcft_186 / num_pixels::numeric * 100 AS s2011_lcft_186_pct,
        s2011_lcft_187 / num_pixels::numeric * 100 AS s2011_lcft_187_pct,
        s2011_lcft_188 / num_pixels::numeric * 100 AS s2011_lcft_188_pct,
        s2011_lcft_189 / num_pixels::numeric * 100 AS s2011_lcft_189_pct,
        s2011_lcft_190 / num_pixels::numeric * 100 AS s2011_lcft_190_pct,
        s2011_lcft_191 / num_pixels::numeric * 100 AS s2011_lcft_191_pct,
        s2011_lcft_192 / num_pixels::numeric * 100 AS s2011_lcft_192_pct,
        s2011_lcft_193 / num_pixels::numeric * 100 AS s2011_lcft_193_pct,
        s2011_lcft_194 / num_pixels::numeric * 100 AS s2011_lcft_194_pct,
        s2011_lcft_195 / num_pixels::numeric * 100 AS s2011_lcft_195_pct,
        s2011_lcft_196 / num_pixels::numeric * 100 AS s2011_lcft_196_pct,
        s2011_lcft_197 / num_pixels::numeric * 100 AS s2011_lcft_197_pct,
        s2011_lcft_198 / num_pixels::numeric * 100 AS s2011_lcft_198_pct,
        s2011_lcft_199 / num_pixels::numeric * 100 AS s2011_lcft_199_pct,
        s2011_lcft_200 / num_pixels::numeric * 100 AS s2011_lcft_200_pct,
        s2011_lcft_201 / num_pixels::numeric * 100 AS s2011_lcft_201_pct,
        s2011_lcft_202 / num_pixels::numeric * 100 AS s2011_lcft_202_pct,
        s2011_lcft_203 / num_pixels::numeric * 100 AS s2011_lcft_203_pct,
        s2011_lcft_204 / num_pixels::numeric * 100 AS s2011_lcft_204_pct,
        s2011_lcft_205 / num_pixels::numeric * 100 AS s2011_lcft_205_pct,
        s2011_lcft_206 / num_pixels::numeric * 100 AS s2011_lcft_206_pct,
        s2011_lcft_207 / num_pixels::numeric * 100 AS s2011_lcft_207_pct,
        s2011_lcft_208 / num_pixels::numeric * 100 AS s2011_lcft_208_pct,
        s2011_lcft_209 / num_pixels::numeric * 100 AS s2011_lcft_209_pct,
        s2011_lcft_210 / num_pixels::numeric * 100 AS s2011_lcft_210_pct,
        s2011_lcft_211 / num_pixels::numeric * 100 AS s2011_lcft_211_pct,
        s2011_lcft_212 / num_pixels::numeric * 100 AS s2011_lcft_212_pct,
        s2011_lcft_213 / num_pixels::numeric * 100 AS s2011_lcft_213_pct,
        s2011_lcft_214 / num_pixels::numeric * 100 AS s2011_lcft_214_pct,
        s2011_lcft_215 / num_pixels::numeric * 100 AS s2011_lcft_215_pct,
        s2011_lcft_216 / num_pixels::numeric * 100 AS s2011_lcft_216_pct,
        s2011_lcft_217 / num_pixels::numeric * 100 AS s2011_lcft_217_pct,
        s2011_lcft_218 / num_pixels::numeric * 100 AS s2011_lcft_218_pct,
        s2011_lcft_219 / num_pixels::numeric * 100 AS s2011_lcft_219_pct,
        s2011_lcft_220 / num_pixels::numeric * 100 AS s2011_lcft_220_pct,
        s2011_lcft_221 / num_pixels::numeric * 100 AS s2011_lcft_221_pct,
        s2011_lcft_222 / num_pixels::numeric * 100 AS s2011_lcft_222_pct,
        s2011_lcft_223 / num_pixels::numeric * 100 AS s2011_lcft_223_pct,
        s2011_lcft_224 / num_pixels::numeric * 100 AS s2011_lcft_224_pct,
        s2011_lcft_225 / num_pixels::numeric * 100 AS s2011_lcft_225_pct,
        s2011_lcft_226 / num_pixels::numeric * 100 AS s2011_lcft_226_pct,
        s2011_lcft_227 / num_pixels::numeric * 100 AS s2011_lcft_227_pct,
        s2011_lcft_228 / num_pixels::numeric * 100 AS s2011_lcft_228_pct,
        s2011_lcft_229 / num_pixels::numeric * 100 AS s2011_lcft_229_pct,
        s2011_lcft_230 / num_pixels::numeric * 100 AS s2011_lcft_230_pct,
        s2011_lcft_231 / num_pixels::numeric * 100 AS s2011_lcft_231_pct,
        s2011_lcft_232 / num_pixels::numeric * 100 AS s2011_lcft_232_pct,
        s2011_lcft_233 / num_pixels::numeric * 100 AS s2011_lcft_233_pct,
        s2011_lcft_234 / num_pixels::numeric * 100 AS s2011_lcft_234_pct,
        s2011_lcft_235 / num_pixels::numeric * 100 AS s2011_lcft_235_pct,
        s2011_lcft_236 / num_pixels::numeric * 100 AS s2011_lcft_236_pct,
        s2011_lcft_237 / num_pixels::numeric * 100 AS s2011_lcft_237_pct,
        s2011_lcft_238 / num_pixels::numeric * 100 AS s2011_lcft_238_pct,
        s2011_lcft_239 / num_pixels::numeric * 100 AS s2011_lcft_239_pct,
        s2011_lcft_240 / num_pixels::numeric * 100 AS s2011_lcft_240_pct,
        s2011_lcft_241 / num_pixels::numeric * 100 AS s2011_lcft_241_pct,
        s2011_lcft_242 / num_pixels::numeric * 100 AS s2011_lcft_242_pct,
        s2011_lcft_243 / num_pixels::numeric * 100 AS s2011_lcft_243_pct,
        s2011_lcft_244 / num_pixels::numeric * 100 AS s2011_lcft_244_pct,
        s2011_lcft_245 / num_pixels::numeric * 100 AS s2011_lcft_245_pct,
        s2011_lcft_246 / num_pixels::numeric * 100 AS s2011_lcft_246_pct,
        s2011_lcft_247 / num_pixels::numeric * 100 AS s2011_lcft_247_pct,
        s2011_lcft_248 / num_pixels::numeric * 100 AS s2011_lcft_248_pct,
        s2011_lcft_249 / num_pixels::numeric * 100 AS s2011_lcft_249_pct,
        s2011_lcft_250 / num_pixels::numeric * 100 AS s2011_lcft_250_pct,
        s2011_lcft_251 / num_pixels::numeric * 100 AS s2011_lcft_251_pct,
        s2011_lcft_252 / num_pixels::numeric * 100 AS s2011_lcft_252_pct,
        s2011_lcft_253 / num_pixels::numeric * 100 AS s2011_lcft_253_pct,
        s2011_lcft_254 / num_pixels::numeric * 100 AS s2011_lcft_254_pct,
        s2011_lcft_255 / num_pixels::numeric * 100 AS s2011_lcft_255_pct,
        s2011_lcft_256 / num_pixels::numeric * 100 AS s2011_lcft_256_pct,
        s2011_lcft_257 / num_pixels::numeric * 100 AS s2011_lcft_257_pct,
        s2011_lcft_258 / num_pixels::numeric * 100 AS s2011_lcft_258_pct,
        s2011_lcft_259 / num_pixels::numeric * 100 AS s2011_lcft_259_pct,
        s2011_lcft_260 / num_pixels::numeric * 100 AS s2011_lcft_260_pct,
        s2011_lcft_261 / num_pixels::numeric * 100 AS s2011_lcft_261_pct,
        s2011_lcft_262 / num_pixels::numeric * 100 AS s2011_lcft_262_pct,
        s2011_lcft_263 / num_pixels::numeric * 100 AS s2011_lcft_263_pct,
        s2011_lcft_264 / num_pixels::numeric * 100 AS s2011_lcft_264_pct,
        s2011_lcft_265 / num_pixels::numeric * 100 AS s2011_lcft_265_pct,
        s2011_lcft_266 / num_pixels::numeric * 100 AS s2011_lcft_266_pct,
        s2011_lcft_267 / num_pixels::numeric * 100 AS s2011_lcft_267_pct,
        s2011_lcft_268 / num_pixels::numeric * 100 AS s2011_lcft_268_pct,
        s2011_lcft_269 / num_pixels::numeric * 100 AS s2011_lcft_269_pct,
        s2011_lcft_270 / num_pixels::numeric * 100 AS s2011_lcft_270_pct,
        s2011_lcft_271 / num_pixels::numeric * 100 AS s2011_lcft_271_pct,
        s2011_lcft_272 / num_pixels::numeric * 100 AS s2011_lcft_272_pct,
        s2011_lcft_273 / num_pixels::numeric * 100 AS s2011_lcft_273_pct,
        s2011_lcft_274 / num_pixels::numeric * 100 AS s2011_lcft_274_pct,
        s2011_lcft_275 / num_pixels::numeric * 100 AS s2011_lcft_275_pct,
        s2011_lcft_276 / num_pixels::numeric * 100 AS s2011_lcft_276_pct,
        s2011_lcft_277 / num_pixels::numeric * 100 AS s2011_lcft_277_pct,
        s2011_lcft_278 / num_pixels::numeric * 100 AS s2011_lcft_278_pct,
        s2011_lcft_279 / num_pixels::numeric * 100 AS s2011_lcft_279_pct,
        s2011_lcft_280 / num_pixels::numeric * 100 AS s2011_lcft_280_pct,
        s2011_lcft_281 / num_pixels::numeric * 100 AS s2011_lcft_281_pct,
        s2011_lcft_282 / num_pixels::numeric * 100 AS s2011_lcft_282_pct,
        s2011_lcft_283 / num_pixels::numeric * 100 AS s2011_lcft_283_pct,
        s2011_lcft_284 / num_pixels::numeric * 100 AS s2011_lcft_284_pct,
        s2011_lcft_285 / num_pixels::numeric * 100 AS s2011_lcft_285_pct,
        s2011_lcft_286 / num_pixels::numeric * 100 AS s2011_lcft_286_pct,
        s2011_lcft_287 / num_pixels::numeric * 100 AS s2011_lcft_287_pct,
        s2011_lcft_288 / num_pixels::numeric * 100 AS s2011_lcft_288_pct,
        s2011_lcft_289 / num_pixels::numeric * 100 AS s2011_lcft_289_pct,
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
        huc_12_summary_statistics
);
COMMIT;
