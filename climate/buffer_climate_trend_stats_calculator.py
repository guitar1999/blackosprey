#!/usr/bin/python

# This script computes zonal statisics for a segment raster and an input ALOS image
#
# AUTHOR: Jesse Bishop
# DATE: 2013-02-17

import glob, scipy.ndimage, sys, psycopg2, os
import numpy as np
from osgeo import gdal


db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

def do_work(pathimg, zone, segment_id, meas, huc):
    imagehandle = gdal.Open(pathimg)
     # Read the data
    image = imagehandle.ReadAsArray()
    image[image == -1.70000000e+308] = np.ma.masked
    
    # Calculate the statistics
    print "Processing statistics for %s zones..." % segment_id.shape[0]
    #num_pixels = np.bincount(np.int_(zone.reshape(zone.shape[0] * zone.shape[1])))[np.int_(segment_id)]
    mean = scipy.ndimage.mean(image, labels=zone, index=segment_id)
    std_dev = scipy.ndimage.standard_deviation(image, labels=zone, index=segment_id)
    smax = scipy.ndimage.maximum(image, labels=zone, index=segment_id)
    smin = scipy.ndimage.minimum(image, labels=zone, index=segment_id)
    #sql = "INSERT INTO prism_{0}_statistics_huc12 (huc_12, prism_year, prism_month, num_pixels, mean, std_dev, max, min) VALUES ('{1}', {2}, {3}, {4}, {5}, {6}, {7}, {8});".format(meas, huc, pyear, pmonth, num_pixels, float(mean), float(std_dev), int(max), int(min))
    sql = "UPDATE avaricosa_buffer_summary_statistics SET ({0}_trend_mean, {0}_trend_std_dev, {0}_trend_min, {0}_trend_max) = ({1}, {2}, {3}, {4}) WHERE primary_key = '{5}';".format(meas, mean[0], std_dev[0], smin[0], smax[0], huc)
    cursor.execute(sql)
    db.commit()


# Main code
huc = sys.argv[1]
pathzone = "/Volumes/BlackOsprey/GIS_Data/NHD/avaricosa_buffer_rasters/mask_{0}_climate_trend.tif".format(huc)
zonehandle = gdal.Open(pathzone)
zone = zonehandle.ReadAsArray()
# Get the unique ids
segment_id = np.unique(zone)
segment_id = segment_id[np.nonzero(segment_id)]
print huc
raster_locations = {'ppt' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/ppt_1895_2012_10yrTrends.tif', 'tmin' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/tmin_1895_2012_10yrTrends.tif', 'tmax' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/tmax_1895_2012_10yrTrends.tif'}
for meas, fileloc in raster_locations.iteritems():
    do_work(fileloc, zone, segment_id, meas, huc)


cursor.close()
db.commit()
db.close()
