#!/usr/bin/python

# This script computes zonal statisics for a segment raster and an input ALOS image
#
# AUTHOR: Jesse Bishop
# DATE: 2013-02-17

import scipy.ndimage, sys, psycopg2, os
import numpy as np
from osgeo import gdal

if not len(sys.argv) == 4:
	print "Usage: huc12_tmax_zone_stats_calculator.py image zone_raster temp"
	print "Example: huc12_tmax_zone_stats_calculator.py /Volumes/BlackOsprey/GIS_Data/PRISM/4km/temperature/tmax/us_tmax_1895.01.tif mask_2020004.tif tmax"
	print
	sys.exit(1)

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()


# Get the file paths
pathimg = sys.argv[1]
pathzone = sys.argv[2]
temp = sys.argv[3]

# Get the prism year and month from the filename
pyear, pmonth = os.path.basename(pathimg).split('_')[2].split('.')[0:2]
print pyear, pmonth

# Open the images
print "Reading input files..."
imagehandle = gdal.Open(pathimg)
zonehandle = gdal.Open(pathzone)

# Read the data
image = imagehandle.ReadAsArray()
# Set the image no data to masked
image[image == -9999] = np.ma.masked
# Read the segments
zone = zonehandle.ReadAsArray()
# Get the unique ids
segment_id = np.unique(zone)
segment_id = segment_id[np.nonzero(segment_id)]

# Calculate the statistics
print "Processing statistics for %s zones..." % segment_id.shape[0]
names = 'segment_id,num_pixels,mean,std_dev,max,min'
num_pixels = np.bincount(np.int_(zone.reshape(zone.shape[0] * zone.shape[1])))[np.int_(segment_id)]
mean = scipy.ndimage.mean(image[:,:], labels=zone, index=segment_id)
std_dev = scipy.ndimage.standard_deviation(image[:,:], labels=zone, index=segment_id)
max = scipy.ndimage.maximum(image[:,:], labels=zone, index=segment_id)
min = scipy.ndimage.minimum(image[:,:], labels=zone, index=segment_id)

# Join the stats into one array
out = np.column_stack((segment_id,num_pixels,mean,std_dev,max,min))

# Write to the database
for i in range(0,out.shape[0]):
	o = [str(this) for this in out[i]]
	sql = "INSERT INTO prism_%s_statistics_huc12 (huc_12, prism_year, prism_month, num_pixels, mean, std_dev, max, min)  VALUES (%s,%s,%s,%s,%s)" % (temp, int(float(o[0])), pyear, pmonth, int(float(o[1])), ','.join(o[2:]))
	cursor.execute(sql)

cursor.close()
db.commit()
db.close()
