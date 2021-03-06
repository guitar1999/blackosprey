BEGIN;
DROP VIEW IF EXISTS huc_12_summary_statistics_pct_aggregated_geom CASCADE;
CREATE OR REPLACE VIEW huc_12_summary_statistics_pct_aggregated_geom AS (
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
        s2011_lcft_1 / num_pixels::numeric * 100 AS s2011_lcft_1pct,
        s2011_lcft_2 / num_pixels::numeric * 100 AS s2011_lcft_2pct,
        s2011_lcft_3 / num_pixels::numeric * 100 AS s2011_lcft_3pct,
        s2011_lcft_4 / num_pixels::numeric * 100 AS s2011_lcft_4pct,
        s2011_lcft_5 / num_pixels::numeric * 100 AS s2011_lcft_5pct,
        s2011_lcft_6 / num_pixels::numeric * 100 AS s2011_lcft_6pct,
        s2011_lcft_7 / num_pixels::numeric * 100 AS s2011_lcft_7pct,
        s2011_lcft_8 / num_pixels::numeric * 100 AS s2011_lcft_8pct,
        s2011_lcft_9 / num_pixels::numeric * 100 AS s2011_lcft_9pct,
        s2011_lcft_10 / num_pixels::numeric * 100 AS s2011_lcft_10pct,
        s2011_lcft_11 / num_pixels::numeric * 100 AS s2011_lcft_11pct,
        s2011_lcft_12 / num_pixels::numeric * 100 AS s2011_lcft_12pct,
        s2011_lcft_13 / num_pixels::numeric * 100 AS s2011_lcft_13pct,
        s2011_lcft_14 / num_pixels::numeric * 100 AS s2011_lcft_14pct,
        s2011_lcft_15 / num_pixels::numeric * 100 AS s2011_lcft_15pct,
        s2011_lcft_16 / num_pixels::numeric * 100 AS s2011_lcft_16pct,
        s2011_lcft_17 / num_pixels::numeric * 100 AS s2011_lcft_17pct,
        s2011_lcft_18 / num_pixels::numeric * 100 AS s2011_lcft_18pct,
        s2011_lcft_19 / num_pixels::numeric * 100 AS s2011_lcft_19pct,
        s2011_lcft_20 / num_pixels::numeric * 100 AS s2011_lcft_20pct,
        s2011_lcft_21 / num_pixels::numeric * 100 AS s2011_lcft_21pct,
        s2011_lcft_22 / num_pixels::numeric * 100 AS s2011_lcft_22pct,
        s2011_lcft_23 / num_pixels::numeric * 100 AS s2011_lcft_23pct,
        s2011_lcft_24 / num_pixels::numeric * 100 AS s2011_lcft_24pct,
        s2011_lcft_25 / num_pixels::numeric * 100 AS s2011_lcft_25pct,
        s2011_lcft_26 / num_pixels::numeric * 100 AS s2011_lcft_26pct,
        s2011_lcft_27 / num_pixels::numeric * 100 AS s2011_lcft_27pct,
        s2011_lcft_28 / num_pixels::numeric * 100 AS s2011_lcft_28pct,
        s2011_lcft_29 / num_pixels::numeric * 100 AS s2011_lcft_29pct,
        s2011_lcft_30 / num_pixels::numeric * 100 AS s2011_lcft_30pct,
        s2011_lcft_31 / num_pixels::numeric * 100 AS s2011_lcft_31pct,
        s2011_lcft_32 / num_pixels::numeric * 100 AS s2011_lcft_32pct,
        s2011_lcft_33 / num_pixels::numeric * 100 AS s2011_lcft_33pct,
        s2011_lcft_34 / num_pixels::numeric * 100 AS s2011_lcft_34pct,
        s2011_lcft_35 / num_pixels::numeric * 100 AS s2011_lcft_35pct,
        s2011_lcft_36 / num_pixels::numeric * 100 AS s2011_lcft_36pct,
        s2011_lcft_37 / num_pixels::numeric * 100 AS s2011_lcft_37pct,
        s2011_lcft_38 / num_pixels::numeric * 100 AS s2011_lcft_38pct,
        s2011_lcft_39 / num_pixels::numeric * 100 AS s2011_lcft_39pct,
        s2011_lcft_40 / num_pixels::numeric * 100 AS s2011_lcft_40pct,
        s2011_lcft_41 / num_pixels::numeric * 100 AS s2011_lcft_41pct,
        s2011_lcft_42 / num_pixels::numeric * 100 AS s2011_lcft_42pct,
        s2011_lcft_43 / num_pixels::numeric * 100 AS s2011_lcft_43pct,
        s2011_lcft_44 / num_pixels::numeric * 100 AS s2011_lcft_44pct,
        s2011_lcft_45 / num_pixels::numeric * 100 AS s2011_lcft_45pct,
        s2011_lcft_46 / num_pixels::numeric * 100 AS s2011_lcft_46pct,
        s2011_lcft_47 / num_pixels::numeric * 100 AS s2011_lcft_47pct,
        s2011_lcft_48 / num_pixels::numeric * 100 AS s2011_lcft_48pct,
        s2011_lcft_49 / num_pixels::numeric * 100 AS s2011_lcft_49pct,
        s2011_lcft_50 / num_pixels::numeric * 100 AS s2011_lcft_50pct,
        s2011_lcft_51 / num_pixels::numeric * 100 AS s2011_lcft_51pct,
        s2011_lcft_52 / num_pixels::numeric * 100 AS s2011_lcft_52pct,
        s2011_lcft_53 / num_pixels::numeric * 100 AS s2011_lcft_53pct,
        s2011_lcft_54 / num_pixels::numeric * 100 AS s2011_lcft_54pct,
        s2011_lcft_55 / num_pixels::numeric * 100 AS s2011_lcft_55pct,
        s2011_lcft_56 / num_pixels::numeric * 100 AS s2011_lcft_56pct,
        s2011_lcft_57 / num_pixels::numeric * 100 AS s2011_lcft_57pct,
        s2011_lcft_58 / num_pixels::numeric * 100 AS s2011_lcft_58pct,
        s2011_lcft_59 / num_pixels::numeric * 100 AS s2011_lcft_59pct,
        s2011_lcft_60 / num_pixels::numeric * 100 AS s2011_lcft_60pct,
        s2011_lcft_61 / num_pixels::numeric * 100 AS s2011_lcft_61pct,
        s2011_lcft_62 / num_pixels::numeric * 100 AS s2011_lcft_62pct,
        s2011_lcft_63 / num_pixels::numeric * 100 AS s2011_lcft_63pct,
        s2011_lcft_64 / num_pixels::numeric * 100 AS s2011_lcft_64pct,
        s2011_lcft_65 / num_pixels::numeric * 100 AS s2011_lcft_65pct,
        s2011_lcft_66 / num_pixels::numeric * 100 AS s2011_lcft_66pct,
        s2011_lcft_67 / num_pixels::numeric * 100 AS s2011_lcft_67pct,
        s2011_lcft_68 / num_pixels::numeric * 100 AS s2011_lcft_68pct,
        s2011_lcft_69 / num_pixels::numeric * 100 AS s2011_lcft_69pct,
        s2011_lcft_70 / num_pixels::numeric * 100 AS s2011_lcft_70pct,
        s2011_lcft_71 / num_pixels::numeric * 100 AS s2011_lcft_71pct,
        s2011_lcft_72 / num_pixels::numeric * 100 AS s2011_lcft_72pct,
        s2011_lcft_73 / num_pixels::numeric * 100 AS s2011_lcft_73pct,
        s2011_lcft_74 / num_pixels::numeric * 100 AS s2011_lcft_74pct,
        s2011_lcft_75 / num_pixels::numeric * 100 AS s2011_lcft_75pct,
        s2011_lcft_76 / num_pixels::numeric * 100 AS s2011_lcft_76pct,
        s2011_lcft_77 / num_pixels::numeric * 100 AS s2011_lcft_77pct,
        s2011_lcft_78 / num_pixels::numeric * 100 AS s2011_lcft_78pct,
        s2011_lcft_79 / num_pixels::numeric * 100 AS s2011_lcft_79pct,
        s2011_lcft_80 / num_pixels::numeric * 100 AS s2011_lcft_80pct,
        s2011_lcft_81 / num_pixels::numeric * 100 AS s2011_lcft_81pct,
        s2011_lcft_82 / num_pixels::numeric * 100 AS s2011_lcft_82pct,
        s2011_lcft_83 / num_pixels::numeric * 100 AS s2011_lcft_83pct,
        s2011_lcft_84 / num_pixels::numeric * 100 AS s2011_lcft_84pct,
        s2011_lcft_85 / num_pixels::numeric * 100 AS s2011_lcft_85pct,
        s2011_lcft_86 / num_pixels::numeric * 100 AS s2011_lcft_86pct,
        s2011_lcft_87 / num_pixels::numeric * 100 AS s2011_lcft_87pct,
        s2011_lcft_88 / num_pixels::numeric * 100 AS s2011_lcft_88pct,
        s2011_lcft_89 / num_pixels::numeric * 100 AS s2011_lcft_89pct,
        s2011_lcft_90 / num_pixels::numeric * 100 AS s2011_lcft_90pct,
        s2011_lcft_91 / num_pixels::numeric * 100 AS s2011_lcft_91pct,
        s2011_lcft_92 / num_pixels::numeric * 100 AS s2011_lcft_92pct,
        s2011_lcft_93 / num_pixels::numeric * 100 AS s2011_lcft_93pct,
        s2011_lcft_94 / num_pixels::numeric * 100 AS s2011_lcft_94pct,
        s2011_lcft_95 / num_pixels::numeric * 100 AS s2011_lcft_95pct,
        s2011_lcft_96 / num_pixels::numeric * 100 AS s2011_lcft_96pct,
        s2011_lcft_97 / num_pixels::numeric * 100 AS s2011_lcft_97pct,
        s2011_lcft_98 / num_pixels::numeric * 100 AS s2011_lcft_98pct,
        s2011_lcft_99 / num_pixels::numeric * 100 AS s2011_lcft_99pct,
        s2011_lcft_100 / num_pixels::numeric * 100 AS s2011_lcft_100pct,
        s2011_lcft_101 / num_pixels::numeric * 100 AS s2011_lcft_101pct,
        s2011_lcft_102 / num_pixels::numeric * 100 AS s2011_lcft_102pct,
        s2011_lcft_103 / num_pixels::numeric * 100 AS s2011_lcft_103pct,
        s2011_lcft_104 / num_pixels::numeric * 100 AS s2011_lcft_104pct,
        s2011_lcft_105 / num_pixels::numeric * 100 AS s2011_lcft_105pct,
        s2011_lcft_106 / num_pixels::numeric * 100 AS s2011_lcft_106pct,
        s2011_lcft_107 / num_pixels::numeric * 100 AS s2011_lcft_107pct,
        s2011_lcft_108 / num_pixels::numeric * 100 AS s2011_lcft_108pct,
        s2011_lcft_109 / num_pixels::numeric * 100 AS s2011_lcft_109pct,
        s2011_lcft_110 / num_pixels::numeric * 100 AS s2011_lcft_110pct,
        s2011_lcft_111 / num_pixels::numeric * 100 AS s2011_lcft_111pct,
        s2011_lcft_112 / num_pixels::numeric * 100 AS s2011_lcft_112pct,
        s2011_lcft_113 / num_pixels::numeric * 100 AS s2011_lcft_113pct,
        s2011_lcft_114 / num_pixels::numeric * 100 AS s2011_lcft_114pct,
        s2011_lcft_115 / num_pixels::numeric * 100 AS s2011_lcft_115pct,
        s2011_lcft_116 / num_pixels::numeric * 100 AS s2011_lcft_116pct,
        s2011_lcft_117 / num_pixels::numeric * 100 AS s2011_lcft_117pct,
        s2011_lcft_118 / num_pixels::numeric * 100 AS s2011_lcft_118pct,
        s2011_lcft_119 / num_pixels::numeric * 100 AS s2011_lcft_119pct,
        s2011_lcft_120 / num_pixels::numeric * 100 AS s2011_lcft_120pct,
        s2011_lcft_121 / num_pixels::numeric * 100 AS s2011_lcft_121pct,
        s2011_lcft_122 / num_pixels::numeric * 100 AS s2011_lcft_122pct,
        s2011_lcft_123 / num_pixels::numeric * 100 AS s2011_lcft_123pct,
        s2011_lcft_124 / num_pixels::numeric * 100 AS s2011_lcft_124pct,
        s2011_lcft_125 / num_pixels::numeric * 100 AS s2011_lcft_125pct,
        s2011_lcft_126 / num_pixels::numeric * 100 AS s2011_lcft_126pct,
        s2011_lcft_127 / num_pixels::numeric * 100 AS s2011_lcft_127pct,
        s2011_lcft_128 / num_pixels::numeric * 100 AS s2011_lcft_128pct,
        s2011_lcft_129 / num_pixels::numeric * 100 AS s2011_lcft_129pct,
        s2011_lcft_130 / num_pixels::numeric * 100 AS s2011_lcft_130pct,
        s2011_lcft_131 / num_pixels::numeric * 100 AS s2011_lcft_131pct,
        s2011_lcft_132 / num_pixels::numeric * 100 AS s2011_lcft_132pct,
        s2011_lcft_133 / num_pixels::numeric * 100 AS s2011_lcft_133pct,
        s2011_lcft_134 / num_pixels::numeric * 100 AS s2011_lcft_134pct,
        s2011_lcft_135 / num_pixels::numeric * 100 AS s2011_lcft_135pct,
        s2011_lcft_136 / num_pixels::numeric * 100 AS s2011_lcft_136pct,
        s2011_lcft_137 / num_pixels::numeric * 100 AS s2011_lcft_137pct,
        s2011_lcft_138 / num_pixels::numeric * 100 AS s2011_lcft_138pct,
        s2011_lcft_139 / num_pixels::numeric * 100 AS s2011_lcft_139pct,
        s2011_lcft_140 / num_pixels::numeric * 100 AS s2011_lcft_140pct,
        s2011_lcft_141 / num_pixels::numeric * 100 AS s2011_lcft_141pct,
        s2011_lcft_142 / num_pixels::numeric * 100 AS s2011_lcft_142pct,
        s2011_lcft_143 / num_pixels::numeric * 100 AS s2011_lcft_143pct,
        s2011_lcft_144 / num_pixels::numeric * 100 AS s2011_lcft_144pct,
        s2011_lcft_145 / num_pixels::numeric * 100 AS s2011_lcft_145pct,
        s2011_lcft_146 / num_pixels::numeric * 100 AS s2011_lcft_146pct,
        s2011_lcft_147 / num_pixels::numeric * 100 AS s2011_lcft_147pct,
        s2011_lcft_148 / num_pixels::numeric * 100 AS s2011_lcft_148pct,
        s2011_lcft_149 / num_pixels::numeric * 100 AS s2011_lcft_149pct,
        s2011_lcft_150 / num_pixels::numeric * 100 AS s2011_lcft_150pct,
        s2011_lcft_151 / num_pixels::numeric * 100 AS s2011_lcft_151pct,
        s2011_lcft_152 / num_pixels::numeric * 100 AS s2011_lcft_152pct,
        s2011_lcft_153 / num_pixels::numeric * 100 AS s2011_lcft_153pct,
        s2011_lcft_154 / num_pixels::numeric * 100 AS s2011_lcft_154pct,
        s2011_lcft_155 / num_pixels::numeric * 100 AS s2011_lcft_155pct,
        s2011_lcft_156 / num_pixels::numeric * 100 AS s2011_lcft_156pct,
        s2011_lcft_157 / num_pixels::numeric * 100 AS s2011_lcft_157pct,
        s2011_lcft_158 / num_pixels::numeric * 100 AS s2011_lcft_158pct,
        s2011_lcft_159 / num_pixels::numeric * 100 AS s2011_lcft_159pct,
        s2011_lcft_160 / num_pixels::numeric * 100 AS s2011_lcft_160pct,
        s2011_lcft_161 / num_pixels::numeric * 100 AS s2011_lcft_161pct,
        s2011_lcft_162 / num_pixels::numeric * 100 AS s2011_lcft_162pct,
        s2011_lcft_163 / num_pixels::numeric * 100 AS s2011_lcft_163pct,
        s2011_lcft_164 / num_pixels::numeric * 100 AS s2011_lcft_164pct,
        s2011_lcft_165 / num_pixels::numeric * 100 AS s2011_lcft_165pct,
        s2011_lcft_166 / num_pixels::numeric * 100 AS s2011_lcft_166pct,
        s2011_lcft_167 / num_pixels::numeric * 100 AS s2011_lcft_167pct,
        s2011_lcft_168 / num_pixels::numeric * 100 AS s2011_lcft_168pct,
        s2011_lcft_169 / num_pixels::numeric * 100 AS s2011_lcft_169pct,
        s2011_lcft_170 / num_pixels::numeric * 100 AS s2011_lcft_170pct,
        s2011_lcft_171 / num_pixels::numeric * 100 AS s2011_lcft_171pct,
        s2011_lcft_172 / num_pixels::numeric * 100 AS s2011_lcft_172pct,
        s2011_lcft_173 / num_pixels::numeric * 100 AS s2011_lcft_173pct,
        s2011_lcft_174 / num_pixels::numeric * 100 AS s2011_lcft_174pct,
        s2011_lcft_175 / num_pixels::numeric * 100 AS s2011_lcft_175pct,
        s2011_lcft_176 / num_pixels::numeric * 100 AS s2011_lcft_176pct,
        s2011_lcft_177 / num_pixels::numeric * 100 AS s2011_lcft_177pct,
        s2011_lcft_178 / num_pixels::numeric * 100 AS s2011_lcft_178pct,
        s2011_lcft_179 / num_pixels::numeric * 100 AS s2011_lcft_179pct,
        s2011_lcft_180 / num_pixels::numeric * 100 AS s2011_lcft_180pct,
        s2011_lcft_181 / num_pixels::numeric * 100 AS s2011_lcft_181pct,
        s2011_lcft_182 / num_pixels::numeric * 100 AS s2011_lcft_182pct,
        s2011_lcft_183 / num_pixels::numeric * 100 AS s2011_lcft_183pct,
        s2011_lcft_184 / num_pixels::numeric * 100 AS s2011_lcft_184pct,
        s2011_lcft_185 / num_pixels::numeric * 100 AS s2011_lcft_185pct,
        s2011_lcft_186 / num_pixels::numeric * 100 AS s2011_lcft_186pct,
        s2011_lcft_187 / num_pixels::numeric * 100 AS s2011_lcft_187pct,
        s2011_lcft_188 / num_pixels::numeric * 100 AS s2011_lcft_188pct,
        s2011_lcft_189 / num_pixels::numeric * 100 AS s2011_lcft_189pct,
        s2011_lcft_190 / num_pixels::numeric * 100 AS s2011_lcft_190pct,
        s2011_lcft_191 / num_pixels::numeric * 100 AS s2011_lcft_191pct,
        s2011_lcft_192 / num_pixels::numeric * 100 AS s2011_lcft_192pct,
        s2011_lcft_193 / num_pixels::numeric * 100 AS s2011_lcft_193pct,
        s2011_lcft_194 / num_pixels::numeric * 100 AS s2011_lcft_194pct,
        s2011_lcft_195 / num_pixels::numeric * 100 AS s2011_lcft_195pct,
        s2011_lcft_196 / num_pixels::numeric * 100 AS s2011_lcft_196pct,
        s2011_lcft_197 / num_pixels::numeric * 100 AS s2011_lcft_197pct,
        s2011_lcft_198 / num_pixels::numeric * 100 AS s2011_lcft_198pct,
        s2011_lcft_199 / num_pixels::numeric * 100 AS s2011_lcft_199pct,
        s2011_lcft_200 / num_pixels::numeric * 100 AS s2011_lcft_200pct,
        s2011_lcft_201 / num_pixels::numeric * 100 AS s2011_lcft_201pct,
        s2011_lcft_202 / num_pixels::numeric * 100 AS s2011_lcft_202pct,
        s2011_lcft_203 / num_pixels::numeric * 100 AS s2011_lcft_203pct,
        s2011_lcft_204 / num_pixels::numeric * 100 AS s2011_lcft_204pct,
        s2011_lcft_205 / num_pixels::numeric * 100 AS s2011_lcft_205pct,
        s2011_lcft_206 / num_pixels::numeric * 100 AS s2011_lcft_206pct,
        s2011_lcft_207 / num_pixels::numeric * 100 AS s2011_lcft_207pct,
        s2011_lcft_208 / num_pixels::numeric * 100 AS s2011_lcft_208pct,
        s2011_lcft_209 / num_pixels::numeric * 100 AS s2011_lcft_209pct,
        s2011_lcft_210 / num_pixels::numeric * 100 AS s2011_lcft_210pct,
        s2011_lcft_211 / num_pixels::numeric * 100 AS s2011_lcft_211pct,
        s2011_lcft_212 / num_pixels::numeric * 100 AS s2011_lcft_212pct,
        s2011_lcft_213 / num_pixels::numeric * 100 AS s2011_lcft_213pct,
        s2011_lcft_214 / num_pixels::numeric * 100 AS s2011_lcft_214pct,
        s2011_lcft_215 / num_pixels::numeric * 100 AS s2011_lcft_215pct,
        s2011_lcft_216 / num_pixels::numeric * 100 AS s2011_lcft_216pct,
        s2011_lcft_217 / num_pixels::numeric * 100 AS s2011_lcft_217pct,
        s2011_lcft_218 / num_pixels::numeric * 100 AS s2011_lcft_218pct,
        s2011_lcft_219 / num_pixels::numeric * 100 AS s2011_lcft_219pct,
        s2011_lcft_220 / num_pixels::numeric * 100 AS s2011_lcft_220pct,
        s2011_lcft_221 / num_pixels::numeric * 100 AS s2011_lcft_221pct,
        s2011_lcft_222 / num_pixels::numeric * 100 AS s2011_lcft_222pct,
        s2011_lcft_223 / num_pixels::numeric * 100 AS s2011_lcft_223pct,
        s2011_lcft_224 / num_pixels::numeric * 100 AS s2011_lcft_224pct,
        s2011_lcft_225 / num_pixels::numeric * 100 AS s2011_lcft_225pct,
        s2011_lcft_226 / num_pixels::numeric * 100 AS s2011_lcft_226pct,
        s2011_lcft_227 / num_pixels::numeric * 100 AS s2011_lcft_227pct,
        s2011_lcft_228 / num_pixels::numeric * 100 AS s2011_lcft_228pct,
        s2011_lcft_229 / num_pixels::numeric * 100 AS s2011_lcft_229pct,
        s2011_lcft_230 / num_pixels::numeric * 100 AS s2011_lcft_230pct,
        s2011_lcft_231 / num_pixels::numeric * 100 AS s2011_lcft_231pct,
        s2011_lcft_232 / num_pixels::numeric * 100 AS s2011_lcft_232pct,
        s2011_lcft_233 / num_pixels::numeric * 100 AS s2011_lcft_233pct,
        s2011_lcft_234 / num_pixels::numeric * 100 AS s2011_lcft_234pct,
        s2011_lcft_235 / num_pixels::numeric * 100 AS s2011_lcft_235pct,
        s2011_lcft_236 / num_pixels::numeric * 100 AS s2011_lcft_236pct,
        s2011_lcft_237 / num_pixels::numeric * 100 AS s2011_lcft_237pct,
        s2011_lcft_238 / num_pixels::numeric * 100 AS s2011_lcft_238pct,
        s2011_lcft_239 / num_pixels::numeric * 100 AS s2011_lcft_239pct,
        s2011_lcft_240 / num_pixels::numeric * 100 AS s2011_lcft_240pct,
        s2011_lcft_241 / num_pixels::numeric * 100 AS s2011_lcft_241pct,
        s2011_lcft_242 / num_pixels::numeric * 100 AS s2011_lcft_242pct,
        s2011_lcft_243 / num_pixels::numeric * 100 AS s2011_lcft_243pct,
        s2011_lcft_244 / num_pixels::numeric * 100 AS s2011_lcft_244pct,
        s2011_lcft_245 / num_pixels::numeric * 100 AS s2011_lcft_245pct,
        s2011_lcft_246 / num_pixels::numeric * 100 AS s2011_lcft_246pct,
        s2011_lcft_247 / num_pixels::numeric * 100 AS s2011_lcft_247pct,
        s2011_lcft_248 / num_pixels::numeric * 100 AS s2011_lcft_248pct,
        s2011_lcft_249 / num_pixels::numeric * 100 AS s2011_lcft_249pct,
        s2011_lcft_250 / num_pixels::numeric * 100 AS s2011_lcft_250pct,
        s2011_lcft_251 / num_pixels::numeric * 100 AS s2011_lcft_251pct,
        s2011_lcft_252 / num_pixels::numeric * 100 AS s2011_lcft_252pct,
        s2011_lcft_253 / num_pixels::numeric * 100 AS s2011_lcft_253pct,
        s2011_lcft_254 / num_pixels::numeric * 100 AS s2011_lcft_254pct,
        s2011_lcft_255 / num_pixels::numeric * 100 AS s2011_lcft_255pct,
        s2011_lcft_256 / num_pixels::numeric * 100 AS s2011_lcft_256pct,
        s2011_lcft_257 / num_pixels::numeric * 100 AS s2011_lcft_257pct,
        s2011_lcft_258 / num_pixels::numeric * 100 AS s2011_lcft_258pct,
        s2011_lcft_259 / num_pixels::numeric * 100 AS s2011_lcft_259pct,
        s2011_lcft_260 / num_pixels::numeric * 100 AS s2011_lcft_260pct,
        s2011_lcft_261 / num_pixels::numeric * 100 AS s2011_lcft_261pct,
        s2011_lcft_262 / num_pixels::numeric * 100 AS s2011_lcft_262pct,
        s2011_lcft_263 / num_pixels::numeric * 100 AS s2011_lcft_263pct,
        s2011_lcft_264 / num_pixels::numeric * 100 AS s2011_lcft_264pct,
        s2011_lcft_265 / num_pixels::numeric * 100 AS s2011_lcft_265pct,
        s2011_lcft_266 / num_pixels::numeric * 100 AS s2011_lcft_266pct,
        s2011_lcft_267 / num_pixels::numeric * 100 AS s2011_lcft_267pct,
        s2011_lcft_268 / num_pixels::numeric * 100 AS s2011_lcft_268pct,
        s2011_lcft_269 / num_pixels::numeric * 100 AS s2011_lcft_269pct,
        s2011_lcft_270 / num_pixels::numeric * 100 AS s2011_lcft_270pct,
        s2011_lcft_271 / num_pixels::numeric * 100 AS s2011_lcft_271pct,
        s2011_lcft_272 / num_pixels::numeric * 100 AS s2011_lcft_272pct,
        s2011_lcft_273 / num_pixels::numeric * 100 AS s2011_lcft_273pct,
        s2011_lcft_274 / num_pixels::numeric * 100 AS s2011_lcft_274pct,
        s2011_lcft_275 / num_pixels::numeric * 100 AS s2011_lcft_275pct,
        s2011_lcft_276 / num_pixels::numeric * 100 AS s2011_lcft_276pct,
        s2011_lcft_277 / num_pixels::numeric * 100 AS s2011_lcft_277pct,
        s2011_lcft_278 / num_pixels::numeric * 100 AS s2011_lcft_278pct,
        s2011_lcft_279 / num_pixels::numeric * 100 AS s2011_lcft_279pct,
        s2011_lcft_280 / num_pixels::numeric * 100 AS s2011_lcft_280pct,
        s2011_lcft_281 / num_pixels::numeric * 100 AS s2011_lcft_281pct,
        s2011_lcft_282 / num_pixels::numeric * 100 AS s2011_lcft_282pct,
        s2011_lcft_283 / num_pixels::numeric * 100 AS s2011_lcft_283pct,
        s2011_lcft_284 / num_pixels::numeric * 100 AS s2011_lcft_284pct,
        s2011_lcft_285 / num_pixels::numeric * 100 AS s2011_lcft_285pct,
        s2011_lcft_286 / num_pixels::numeric * 100 AS s2011_lcft_286pct,
        s2011_lcft_287 / num_pixels::numeric * 100 AS s2011_lcft_287pct,
        s2011_lcft_288 / num_pixels::numeric * 100 AS s2011_lcft_288pct,
        s2011_lcft_289 / num_pixels::numeric * 100 AS s2011_lcft_289pct,
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
        tmax_trend_max, 
        g.geom
    FROM
        huc_12_summary_statistics h INNER JOIN
        nhd_hu12_watersheds g
        ON h.huc_12=g.huc_12
    WHERE 
        g.in_study_area = 'Y'
);
COMMIT;
