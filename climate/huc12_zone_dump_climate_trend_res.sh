#!/bin/bash

starttime=$(date "+%s")

huclist=$(psql -d blackosprey -t -A -c "SELECT distinct huc_12 FROM nhd_hu12_watersheds WHERE in_study_area = 'Y';")
raster='/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/ppt_1895_2012_10yrTrends.tif'
for huc in $huclist
do
	echo $huc
	# Dump the watershed
	pgsql2shp -f /Volumes/BlackOsprey/GIS_Data/NHD/hu12_rasters/huc_${huc}_climate_trend.shp blackosprey "SELECT dumpid, geom FROM nhd_hu12_watersheds WHERE huc_12 = '$huc';"

	# Get the raster info
	tr=$(gdalinfo $raster | grep 'Pixel Size' | awk -F ' = ' '{print $2}' | tr -d '()-' | sed 's/,/ /g')
	ll=$(gdalinfo $raster | grep 'Lower Left' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')
	ur=$(gdalinfo $raster | grep 'Upper Right' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')

	# Rasterize the shapefile
	gdal_rasterize -at -a DUMPID -a_nodata 0 -init 0 -te $ll $ur -tr $tr -co "COMPRESS=LZW" huc_${huc}_climate_trend.shp mask_${huc}_climate_trend.tif

	# Clean up the shapefile
	/bin/rm huc_${huc}_climate_trend.*

done

endtime=$(date "+%s")
timediff=$(echo "scale=1; ($endtime - $starttime)/60" | bc -l)
echo "Time taken for Job ${0}: $timediff minutes on $(hostname)"

