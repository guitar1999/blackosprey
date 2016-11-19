#!/bin/bash

# starttime=$(date "+%s")

huc=$1
edir=$2
hostname=$3
username=$4
srcpath=$5
if [ "$srcpath" == '' ]; then
    raster='/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/ppt_1895_2012_10yrTrends.tif'
else
    raster=${srcpath}'/ppt_1895_2012_10yrTrends.tif'
fi

#echo $huc
# Dump the watershed
pgsql2shp -h $hostname -u $username -f ${edir}/avaricosa_buffer_${huc}_climate_trend.shp blackosprey "SELECT 1 as dumpid, ST_Transform(ST_Union(ST_MakeValid(geom_buffer)), 4326) AS geom FROM public.nhd_flowline_all_no_duplicates WHERE permanent_ = '$huc';"

# Get the raster info
tr=$(gdalinfo $raster | grep 'Pixel Size' | awk -F ' = ' '{print $2}' | tr -d '()-' | sed 's/,/ /g')
ll=$(gdalinfo $raster | grep 'Lower Left' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')
ur=$(gdalinfo $raster | grep 'Upper Right' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')

# Rasterize the shapefile
gdal_rasterize -at -a DUMPID -a_nodata 0 -init 0 -te $ll $ur -tr $tr -co "COMPRESS=LZW" ${edir}/avaricosa_buffer_${huc}_climate_trend.shp ${edir}/mask_${huc}_climate_trend.tif

# Clean up the shapefile
/bin/rm ${edir}/avaricosa_buffer_${huc}_climate_trend.*


# endtime=$(date "+%s")
# timediff=$(echo "scale=1; ($endtime - $starttime)/60" | bc -l)
# echo "Time taken for Job ${0}: $timediff minutes on $(hostname)"

