#!/bin/bash

starttime=$(date "+%s")

#huclist=$(psql -d blackosprey -t -A -c "SELECT distinct(huc_12) FROM nhd_hu8_watersheds WHERE contains_avaricosa = 'Y';")
huclist=$(psql -d blackosprey -t -A -c "SELECT distinct huc_12 FROM prism_unprocessed_huc12_ppt;")
rasterlist=$(ls /Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/ppt/*tif)

for huc in $huclist
do
	# Dump the watershed
	pgsql2shp -f huc_${huc}.shp blackosprey "SELECT huc_12, ST_Transform(geom, 4322) FROM nhd_hu12_watersheds WHERE huc_12 = '$huc';"

	for raster in $rasterlist
	do

		# Get the raster info
		tr=$(gdalinfo $raster | grep 'Pixel Size' | awk -F ' = ' '{print $2}' | tr -d '()-' | sed 's/,/ /g')
		ll=$(gdalinfo $raster | grep 'Lower Left' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')
		ur=$(gdalinfo $raster | grep 'Upper Right' | grep  -o "\( \?-\?[0-9]\{1,3\}\.[0-9]*,[ ]*-\?[0-9]\{1,2\}\.[0-9]*\)" | tr -d '() ' | sed 's/,/ /g')

		# Rasterize the shapefile
		gdal_rasterize -at -a HUC_12 -a_nodata 0 -init 0 -te $ll $ur -tr $tr huc_${huc}.shp mask_${huc}.tif

		# Get the zonal stats
		/Volumes/BlackOsprey/GIS_Data/git/blackosprey/climate/huc12_ppt_zone_stats_calculator.py $raster mask_${huc}.tif $huc
		
		# Clean up the rasterized file
		/bin/rm mask_${huc}.tif
	done

	# Clean up the shapefile
	/bin/rm huc_${huc}.*

done

endtime=$(date "+%s")
timediff=$(echo "scale=1; ($endtime - $starttime)/60" | bc -l)
echo "Time taken for Job ${0}: $timediff minutes on $(hostname)"

