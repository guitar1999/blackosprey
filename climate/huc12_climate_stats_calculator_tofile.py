#!/usr/bin/python

# This script computes zonal statisics for a segment raster and an input ALOS image
#
# AUTHOR: Jesse Bishop
# DATE: 2013-02-17

import glob, scipy.ndimage, sys, os
import numpy as np
from osgeo import gdal


def do_work(pathimg, zone, segment_id, meas, huc, f):
    # Get the prism year and month from the filename
    pyear, pmonth = os.path.basename(pathimg).split('_')[2].split('.')[0:2]
    print pyear, pmonth, meas
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
        txt = "'{0}',{1},{2},{3},{4},{5},{6}\n".format(huc, pyear, pmonth, num_pixels, float(mean), float(std_dev), int(sum))
    else:
        max = scipy.ndimage.maximum(image[:,:], labels=zone, index=segment_id)
        min = scipy.ndimage.minimum(image[:,:], labels=zone, index=segment_id)
        txt = "'{0}',{1},{2},{3},{4},{5},{6},{7}\n".format(huc, pyear, pmonth, num_pixels, float(mean), float(std_dev), int(max), int(min))
    f.write(txt)


# Main code
pathzone = sys.argv[1]
huc = os.path.basename(pathzone).split('_')[1]
zonehandle = gdal.Open(pathzone)
zone = zonehandle.ReadAsArray()
# Get the unique ids
segment_id = np.unique(zone)
segment_id = segment_id[np.nonzero(segment_id)]

raster_locations = {'ppt' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/ppt/*tif', 'tmin' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/tmin/*tif', 'tmax' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/monthly/tmax/*tif'}
for meas, fileloc in raster_locations.iteritems():
    fn = '/usr/local/pgsql-9.3/copy/huc12_{0}_{1}.csv'.format(huc, meas)
    f = open(fn, 'w')
    for raster in glob.glob(fileloc):
        do_work(raster, zone, segment_id, meas, huc, f)
    f.close()
    os.system("""/usr/local/pgsql/bin/psql -d blackosprey -C "COPY my_table FROM '{0}' DELIMITERS ',' CSV QUOTE E'\'';" """.format(fn))

