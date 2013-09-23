#!/usr/bin/python

# This script computes zonal statisics for a segment raster and an input ALOS image
#
# AUTHOR: Jesse Bishop
# DATE: 2013-02-17

import scipy.ndimage, sys, psycopg2, os
import numpy as np
from osgeo import gdal

if not len(sys.argv) == 3:
	print "Usage: huc8_ppt_zone_stats_calculator.py image zone_raster hucid"
	print "Example: huc8_ppt_zone_stats_calculator.py /Volumes/BlackOsprey/GIS_Data/PRISM/4km/us_ppt_1895.01.tif mask_2020004.tif 2020004"
	print
	sys.exit(1)

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()


# Get the file paths
pathimg = sys.argv[1]
pathzone = sys.argv[2]

# Get the prism year and month from the filename
pyear, pmonth = os.path.basename(pathimg).split('_')[2].split('.')[0:2]
print pyear, pmonth

# Open the images
print "Reading input files..."
imagehandle = gdal.Open(pathimg)
zonehandle = gdal.Open(pathzone)

# Read the data
image = imagehandle.ReadAsArray()
image[image == -9999] = np.ma.masked
# Read the segments
zone = zonehandle.ReadAsArray()
# Get the unique ids
segment_id = np.unique(zone)
segment_id = segment_id[np.nonzero(segment_id)]

# Calculate the statistics
print "Processing statistics for %s zones..." % segment_id.shape[0]
names = 'segment_id,num_pixels,mean,std_dev,sum'
num_pixels = np.bincount(np.int_(zone.reshape(zone.shape[0] * zone.shape[1])))[np.int_(segment_id)]
mean = scipy.ndimage.mean(image[:,:], labels=zone, index=segment_id)
std_dev = scipy.ndimage.standard_deviation(image[:,:], labels=zone, index=segment_id)
sum = scipy.ndimage.sum(image[:,:], labels=zone, index=segment_id)

# Join the stats into one array
out = np.column_stack((segment_id,num_pixels,mean,std_dev,sum))

# Write to the database
for i in range(0,out.shape[0]):
	o = [str(this) for this in out[i]]
	sql = "INSERT INTO prism_ppt_statistics (huc_8_num, prism_year, prism_month, num_pixels, mean, std_dev, sum)  VALUES (%s,%s,%s,%s,%s)" % (int(float(o[0])), pyear, pmonth, int(float(o[1])), ','.join(o[2:]))
	cursor.execute(sql)

cursor.close()
db.commit()
db.close()
