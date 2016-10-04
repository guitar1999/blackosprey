#!/bin/bash

state=$1

# Create a subset table of the buffers that we're interested in
time psql -h localhost -d blackosprey -c "SELECT * INTO nhd.nhd_flowline_all_no_duplicates_100m_segments_exploded_${state} FROM public.nhd_flowline_all_no_duplicates_100m_segments_exploded WHERE permanent_ IN (SELECT permanent_ FROM nhd.nhd_flowline_${state});"


# Albers Layers
# alb_coords=$(psql -X -h localhost -d blackosprey -t -A -c "WITH bbox AS (SELECT ST_Buffer(ST_Envelope(ST_Union(ST_Transform(geom, 5070))), 150) AS geom FROM nhd.nhd_flowline_${state}) SELECT concat_ws(' ', ST_XMin(geom), ST_Ymin(geom), ST_Xmax(geom), ST_YMax(geom)) FROM bbox;")
alb_coords='1842735 2356455 2065365 2740545'
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $alb_coords -tr 30 30 -co "COMPRESS=LZW" /Volumes/BlackOsprey/GIS_Data/NLCD/new/1992/NLCD92_wall_to_wall_landcover/nlcd92mosaic_clip.tif /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/nlcd92mosaic_clip_${state}.tif
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $alb_coords -tr 30 30 -co "COMPRESS=LZW" /Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_treecover_analytical/nlcd_2011_USFS_tree_canopy_2011_edition_2014_03_31/analytical_product/nlcd2011_usfs_treecanopy_analytical_3-31-2014_clip.tif /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/nlcd2011_usfs_treecanopy_analytical_3-31-2014_clip_${state}.tif
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $alb_coords -tr 30 30 -co "COMPRESS=LZW" /Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_landcover/nlcd_2011_landcover_2011_edition_2014_03_31/nlcd_2011_landcover_2011_edition_2014_03_31_clip.tif /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/nlcd_2011_landcover_2011_edition_2014_03_31_clip_${state}.tif

# NAD83
nad83_coords=$(psql -X -h localhost -d blackosprey -t -A -c "WITH bbox AS (SELECT ST_Transform(ST_Buffer(ST_Transform(ST_Envelope(ST_Union(ST_Transform(geom, 4269))), 5070), 150), 4269) AS geom FROM nhd.nhd_flowline_${state}) SELECT concat_ws(' ', ST_XMin(geom), ST_Ymin(geom), ST_Xmax(geom), ST_YMax(geom)) FROM bbox;")
WITH bbox AS (SELECT ST_Transform(ST_Buffer(ST_Transform(ST_Envelope(ST_Union(ST_Transform(geom, 4269))), 5070), 150), 4269) AS geom FROM nhd.nhd_flowline_nh) SELECT concat_ws(' ', ST_XMin(geom), ST_Ymin(geom), ST_Xmax(geom), ST_YMax(geom)) FROM bbox;
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $nad83_coords -tr 0.000092592592593 0.000092592592593 -of "HFA" /Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/slope_study_area_1arcsec.img /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/slope_study_area_1arcsec_${state}.img

# WGS84
wgs84_coords=$(psql -X -h localhost -d blackosprey -t -A -c "WITH bbox AS (SELECT ST_Transform(ST_Buffer(ST_Transform(ST_Envelope(ST_Union(geom)), 5070), 8000), 4269) AS geom FROM nhd.nhd_flowline_${state}) SELECT concat_ws(' ', ST_XMin(geom), ST_Ymin(geom), ST_Xmax(geom), ST_YMax(geom)) FROM bbox;")
WITH bbox AS (SELECT ST_Transform(ST_Buffer(ST_Transform(ST_Envelope(ST_Union(geom)), 5070), 8000), 4269) AS geom FROM nhd.nhd_flowline_nh) SELECT concat_ws(' ', ST_XMin(geom), ST_Ymin(geom), ST_Xmax(geom), ST_YMax(geom)) FROM bbox;
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $nad83_coords -tr 0.0417 0.0417 -co "COMPRESS=LZW" /Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/ppt_1895_2012_10yrTrends.tif /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/ppt_1895_2012_10yrTrends_${state}.tif
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $nad83_coords -tr 0.0417 0.0417 -co "COMPRESS=LZW" /Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/tmin_1895_2012_10yrTrends.tif /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/tmin_1895_2012_10yrTrends_${state}.tif
time /Library/Frameworks/GDAL.framework/Programs/gdalwarp -te $nad83_coords -tr 0.0417 0.0417 -co "COMPRESS=LZW" /Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/tmax_1895_2012_10yrTrends.tif /Volumes/BlackOsprey/GIS_Data/modeling/predictor_stacks/${state}/tmax_1895_2012_10yrTrends_${state}.tif
