#!/Volumes/BlackOsprey/GIS_Data/bo_python/bin/python

import argparse, glob, math, os, psycopg2, scipy.ndimage, subprocess
import numpy as np
import pandas as pd
from osgeo import gdal




def bound_calc(func, g, l, res):
    '''Calculates the snapped coordinate, given the appropriate function.'''
    return float(g + (func(abs(l - g) / res) * res))

def huc_bounds(huc, cursor):
    '''Calculates the snapped huc bounds and returns them in a tuple.'''
    # Global extent
    gXmin, gYmin = (-86.00055555556001, 29.9994444)
    # Calculate the bounds
    query = """SELECT ST_XMin(geom) AS llx, ST_YMin(geom) AS lly, ST_XMax(geom) AS urx, ST_YMax(geom) AS ury FROM (SELECT ST_Transform(geom, 4269) AS geom FROM nhd_hu12_watersheds WHERE huc_12 = '{0}') AS tquery;""".format(huc)
    cursor.execute(query)
    llx, lly, urx, ury = cursor.fetchall()[0]
    xmin = bound_calc(math.floor, gXmin, llx, 0.000092592592593)
    ymin = bound_calc(math.floor, gYmin, lly, 0.000092592592593)
    xmax = bound_calc(math.ceil, gXmin, urx, 0.000092592592593)
    ymax = bound_calc(math.ceil, gYmin, ury, 0.000092592592593)
    return (xmin, ymin, xmax, ymax)

def rasterize_huc(huc, edir, coordlist):
    '''Rasterizes a given huc using the coordinates provided.'''
    #print 'raster1'
    #print edir
    xmin, ymin, xmax, ymax = coordlist
    # Dump the shape
    query = """SELECT dumpid, ST_Transform(geom, 4269) AS geom FROM nhd_hu12_watersheds WHERE huc_12 = '{0}';""".format(huc)
    command = """/usr/local/pgsql/bin/pgsql2shp -f {0}/huc12_{1}_ned_clip_vector.shp blackosprey "{2}" """.format(edir, huc, query)
    #print command
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout = proc.communicate() # Necessary to force wait until process completes (otherwise use subprocess.call())
    # Rasterize, remove shape, and store
    command = """/Library/Frameworks/GDAL.framework/Programs/gdal_rasterize -a dumpid -of GTiff -a_nodata 0 -te {0} {1} {2} {3} -tr 0.000092592592593 0.000092592592593 -ot Byte -co "COMPRESS=LZW" {4}/huc12_{5}_ned_clip_vector.shp {4}/huc12_{5}_ned_clip.tif""".format(xmin, ymin, xmax, ymax, edir, huc)
    #print command
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout1 = proc.communicate()
    for f in glob.glob("{0}/huc12_{1}_ned_clip_vector.*".format(edir, huc)):
        os.remove(f)
    return (procout, procout1)

def clip_data(coordlist, infile, edir, huc):
    '''Clips a national dataset down to the huc12 extent for quick analysis'''
    xmin, ymin, xmax, ymax = coordlist
    outfile = """{0}/{1}_huc{2}.vrt""".format(edir, os.path.splitext(os.path.basename(infile))[0], huc)
    if not os.path.isfile(outfile):
        command = """/Library/Frameworks/GDAL.framework/Programs/gdalwarp -of "VRT" -te {0} {1} {2} {3} -tr 0.000092592592593 0.000092592592593 -co "COMPRESS=LZW" {4} {5}""".format(xmin, ymin, xmax, ymax, infile, outfile)
        proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        procout = proc.communicate()
    return outfile

def summarize_huc(huc, edir, coordlist, cursor, db):
    '''Generates summary statistics for a huc and puts them in the database.'''
    # The files to be processed
    files = {'ned' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/ned_study_area_1arcsec.img', 'slope' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/slope_study_area_1arcsec.img', 'tri' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/tri_study_area_1arcsec.img', 'roughness' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/roughness_study_area_1arcsec.img'}
    # Set up the db record for the huc
    try:
        query = "INSERT INTO huc_12_summary_statistics (huc_12) VALUES ('{0}');".format(huc)
        cursor.execute(query)
    except psycopg2.IntegrityError, msg:
        print "HUC {0} is already in the table".format(huc)
        db.rollback()
    except Exception, msg:
        print "There was an unhandled error with HUC {0}".format(huc)
        print str(msg) + "\n"
        db.rollback()
    else:
        db.commit()

    # Read the huc
    huc_handle = gdal.Open("{0}/huc12_{1}_ned_clip.tif".format(edir, huc))
    hucdata = huc_handle.ReadAsArray()
    zoneid = np.unique(hucdata)
    zoneid = zoneid[np.nonzero(zoneid)]
    #num_pixels = np.bincount(np.int_(hucdata.reshape(hucdata.shape[0] * hucdata.shape[1])))[np.int_(zoneid)]
    #query = "UPDATE huc_12_summary_statistics SET (num_pixels) = ({0}) WHERE huc_12 = '{1}'".format(num_pixels, huc)
    #cursor.execute(query)
    #db.commit()
    # Loop through the files and do it
    for dt in files.keys():
        print dt
        f = files[dt]
        # Clip the file
        data_file = clip_data(coordlist, f, edir, huc)
        # Process
        # Zone is the huc
        image_handle = gdal.Open(data_file)
        image = image_handle.ReadAsArray()
        if not hucdata.shape == image.shape:
            print "Shape error with huc {0}!".format(huc)
            ef = open("{0}/{1}_ned.error".format(edir, huc), 'w')
            ef.write(huc + '\n')
            ef.close()
            return
        mean = scipy.ndimage.mean(image, labels=hucdata, index=zoneid)
        std_dev = scipy.ndimage.standard_deviation(image, labels=hucdata, index=zoneid)
        zmin = scipy.ndimage.minimum(image, labels=hucdata, index=zoneid)
        zmax = scipy.ndimage.maximum(image, labels=hucdata, index=zoneid)
        query = "UPDATE huc_12_summary_statistics SET ({0}_mean, {0}_std_dev, {0}_min, {0}_max) = ({1}, {2}, {3}, {4}) WHERE huc_12 = '{5}';".format(dt, mean[0], std_dev[0], zmin[0], zmax[0], huc)
        cursor.execute(query)
        db.commit()



    # Statistics 
        # Land Cover
            # Pixels / Class
        # Impervious
            # Mean
            # Median
            # Min
            # Max 
            # Standard Deviation
        # Canopy Cover
            # Mean
            # Median
            # Min
            # Max 
            # Standard Deviation
            
    


def main(huc, edir, cursor, regen):
    '''The work gets done here.'''
    print "HUC12 is {0}".format(huc)  
    # Get the snapped raster coordinates
    huc_coords = huc_bounds(huc, cursor)
    # Process the huc raster if necessary
    if not os.path.isfile("{0}/huc12_{1}_ned_clip.tif".format(edir, huc)) or regen:
        rasterize_huc(huc, edir, huc_coords)
    # Generate the huc12 summary statistics
    try:
        summarize_huc(huc, edir, huc_coords, cursor, db)
    except Exception, msg:
        print "ERROR with huc {0}".format(huc)
        print str(msg)
        db.rollback()




########
# MAIN #
########

# Parse the arguments
p = argparse.ArgumentParser(prog="huc_12_ned_statistics.py")
p.add_argument("huc12", type=str, help="The huc_12 id to process.")
p.add_argument("exportdir", help="The directory that holds the rasterized huc12s.")
p.add_argument("-r", "--regen", dest="regen", required=False, action="store_true", help="Force regeneration of rasterized huc12 even if it exists.")
p.add_argument("-l", "--list", dest="inlist", required=False, action="store_true", help="Providing a list of hucs instead of an individual huc.")
args = p.parse_args()

huc = args.huc12
edir = args.exportdir

# Connect to db
db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

# Run it
if args.inlist:
    for h in open(huc, 'r'):
        main(h.strip(), edir, cursor, args.regen)
else:
    main(huc, edir, cursor, args.regen)

# Close the db connection.
cursor.close()
db.close()
