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

def do_work(pathimg, zone, segment_id, meas):
    # Get the prism year and month from the filename
    pyear, pmonth = os.path.basename(pathimg).split('_')[2].split('.')[0:2]
    print pyear, pmonth
    # Open the images
    print "Reading input files..."
    imagehandle = gdal.Open(pathimg)
     # Read the data
    image = imagehandle.ReadAsArray()
    image[image == -9999] = np.ma.masked
    
    # Calculate the statistics
    print "Processing statistics for %s zones..." % segment_id.shape[0]
    num_pixels = np.bincount(np.int_(zone.reshape(zone.shape[0] * zone.shape[1])))[np.int_(segment_id)]
    mean = scipy.ndimage.mean(image[:,:], labels=zone, index=segment_id)
    std_dev = scipy.ndimage.standard_deviation(image[:,:], labels=zone, index=segment_id)
    if meas == 'ppt':
        sum = scipy.ndimage.sum(image[:,:], labels=zone, index=segment_id)
        names = 'segment_id,num_pixels,mean,std_dev,sum'
    else:
        max = scipy.ndimage.maximum(image[:,:], labels=zone, index=segment_id)
        min = scipy.ndimage.minimum(image[:,:], labels=zone, index=segment_id)
        names = 'segment_id,num_pixels,mean,std_dev,max,min'

    # Join the stats into one array
    out = np.column_stack((segment_id,num_pixels,mean,std_dev,sum))

    # Write to the database
    for i in range(0,out.shape[0]):
    	o = [str(this) for this in out[i]]
    	sql = "INSERT INTO prism_ppt_statistics_huc12 (huc_12, prism_year, prism_month, num_pixels, mean, std_dev, sum)  VALUES (%s,%s,%s,%s,%s)" % (huc, pyear, pmonth, int(float(o[1])), ','.join(o[2:]))
    	cursor.execute(sql)

# Main code
pathzone = '/Volumes/BlackOsprey/GIS_Data/NHD/hu12_rasters/mask_all_climate.tif'
zonehandle = gdal.Open(pathzone)
zone = zonehandle.ReadAsArray()
# Get the unique ids
segment_id = np.unique(zone)
segment_id = segment_id[np.nonzero(segment_id)]



raster_locations = {'ppt' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/ppt/*tif', 'tmin' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/tmin/*tif', 'tmax' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/tmax/*tif'}
for meas, fileloc in raster_locations.iteritems():
    for raster in glob.glob(fileloc):
        do_work(raster, zone, segment_id, meas)


cursor.close()
db.commit()
db.close()
