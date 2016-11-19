#!/Volumes/BlackOsprey/GIS_Data/bo_python/bin/python

# This script computes zonal statisics for a segment raster and an input ALOS image
#
# AUTHOR: Jesse Bishop
# DATE: 2013-02-17
import socket, sys
if socket.gethostname() == 'JesseMBP-15R.local':
    sys.path.append('/usr/local/lib/python2.7/site-packages')
    srcpath = '/Users/jbishop/Workspace/Projects/av/source'
    pgpath = '/usr/local/bin/'
    gdalpath = '/usr/local/bin/'
if socket.gethostname() == 'Jesses-MacBook-Pro.local':
    sys.path.append('/usr/local/lib/python2.7/site-packages')
    srcpath = '/Users/jessebishop/Workspace/Projects/av/source'
    pgpath = '/usr/local/pgsql/bin/'
    gdalpath = '/usr/local/bin/'
else:
    srcpath = ''
    pgpath = '/usr/local/pgsql/bin/'
    gdalpath = '/Library/Frameworks/GDAL.framework/Programs/'
import scipy.ndimage, os
import numpy as np
from osgeo import gdal


# db = psycopg2.connect(host=hostname, database='blackosprey',user='jessebishop')
# cursor = db.cursor()

def do_work(pathimg, zone, segment_id, meas, huc):
    imagehandle = gdal.Open(pathimg)
     # Read the data
    image = imagehandle.ReadAsArray()
    image[image == -1.70000000e+308] = np.ma.masked
    
    # Calculate the statistics
    print "Processing statistics for %s zones..." % segment_id.shape[0]
    #num_pixels = np.bincount(np.int_(zone.reshape(zone.shape[0] * zone.shape[1])))[np.int_(segment_id)]
    mean = scipy.ndimage.mean(image, labels=zone, index=segment_id)
    #std_dev = scipy.ndimage.standard_deviation(image, labels=zone, index=segment_id)
    #smax = scipy.ndimage.maximum(image, labels=zone, index=segment_id)
    #smin = scipy.ndimage.minimum(image, labels=zone, index=segment_id)
    #sql = "INSERT INTO prism_{0}_statistics_huc12 (huc_12, prism_year, prism_month, num_pixels, mean, std_dev, max, min) VALUES ('{1}', {2}, {3}, {4}, {5}, {6}, {7}, {8});".format(meas, huc, pyear, pmonth, num_pixels, float(mean), float(std_dev), int(max), int(min))
    # sql = "UPDATE avaricosa_buffer_summary_statistics SET ({0}_trend_mean, {0}_trend_std_dev, {0}_trend_min, {0}_trend_max) = ({1}, {2}, {3}, {4}) WHERE primary_key = '{5}';".format(meas, mean[0], std_dev[0], smin[0], smax[0], huc)
    # cursor.execute(sql)
    # db.commit()
    return (meas, mean[0])


# Main code
infile = sys.argv[1]
edir = sys.argv[2]
# hostname = sys.argv[3]
outcsv = sys.argv[3]
hostname = sys.argv[4]
username = sys.argv[5]
o = open(outcsv, 'a')   
f = open(infile, 'r')
for huc in f.readlines():
    huc = huc.replace('\n','')
    print huc
    os.system("""/Volumes/BlackOsprey/GIS_Data/git/blackosprey/climate/nhd_stream_buffer_zone_dump_climate_trend_res_by_permanent.sh {0} {1} {2} {3} {4}""".format(huc, edir, hostname, username, srcpath))
    pathzone = "{0}/mask_{1}_climate_trend.tif".format(edir, huc)
    zonehandle = gdal.Open(pathzone)
    zone = zonehandle.ReadAsArray()
    # Get the unique ids
    segment_id = np.unique(zone)
    segment_id = segment_id[np.nonzero(segment_id)]
    if segment_id:
        raster_locations = {'ppt' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/ppt_1895_2012_10yrTrends.tif', 'tmin' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/tmin_1895_2012_10yrTrends.tif', 'tmax' : '/Volumes/BlackOsprey/GIS_Data/PRISM/4km/trends_10yr/tmax_1895_2012_10yrTrends.tif'}
        outdict = {}
        for meas, fileloc in raster_locations.iteritems():
            if srcpath:
                    fileloc = srcpath + '/' + os.path.basename(fileloc)
            m, mean = do_work(fileloc, zone, segment_id, meas, huc)
            outdict[m] = mean
        outline = '''{0},{1},{2},{3}\n'''.format(huc, outdict['ppt'], outdict['tmin'], outdict['tmax'])
    else:
        outline = '''{0},-9999,-9999,-9999\n'''.format(huc)
    o.write(outline)
    o.flush()
    os.system("rm -f {0}/mask_{1}_climate_trend.tif".format(edir, huc))
o.close()
f.close()
# cursor.close()
# db.commit()
# db.close()
