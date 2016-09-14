#!/bin/bash

starttime=$(date "+%s")
huc=$1
raster='/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/ppt_1895_2012_10yrTrends.tif'
echo $huc
# Dump the watershed
if [ "$huc" == '5977251020002' ]; then
    pgsql2shp -f /Volumes/BlackOsprey/GIS_Data/NHD/avaricosa_buffer_rasters/avaricosa_buffer_${huc}_climate_trend.shp blackosprey "SELECT 1 AS dumpid, ST_Union(ST_CollectionExtract(ST_MakeValid(buffer_geom), 3)) FROM avaricosa_buffer_table WHERE primary_key = '$huc';"
else
    pgsql2shp -f /Volumes/BlackOsprey/GIS_Data/NHD/avaricosa_buffer_rasters/avaricosa_buffer_${huc}_climate_trend.shp blackosprey "SELECT 1 AS dumpid, ST_Union(ST_MakeValid(buffer_geom)) FROM avaricosa_buffer_table WHERE primary_key = '$huc';"
fi

# Get the raster info
tr=$(gdalinfo $raster | grep 'Pixel Size' | awk -F ' = ' '{print $2}' | tr -d '()-' | sed 's/,/ /g')
ll=$(gdalinfo $raster | grep 'Lower Left' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')
ur=$(gdalinfo $raster | grep 'Upper Right' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')

# Rasterize the shapefile
gdal_rasterize -at -a DUMPID -a_nodata 0 -init 0 -te $ll $ur -tr $tr -co "COMPRESS=LZW" avaricosa_buffer_${huc}_climate_trend.shp mask_${huc}_climate_trend.tif

# Clean up the shapefile
/bin/rm avaricosa_buffer_${huc}_climate_trend.*


endtime=$(date "+%s")
timediff=$(echo "scale=1; ($endtime - $starttime)/60" | bc -l)
echo "Time taken for Job ${0}: $timediff minutes on $(hostname)"

