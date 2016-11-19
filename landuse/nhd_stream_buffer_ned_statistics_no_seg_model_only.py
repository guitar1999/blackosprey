#!/Volumes/BlackOsprey/GIS_Data/bo_python/bin/python

import socket, sys
if socket.gethostname() == 'JesseMBP-15R.local':
    sys.path.append('/usr/local/lib/python2.7/site-packages')
    srcpath = '/Users/jbishop/Workspace/Projects/av/source'
    pgpath = '/usr/local/bin/'
    gdalpath = '/usr/local/bin/'
elif socket.gethostname() == 'Jesses-MacBook-Pro.local':
    sys.path.append('/usr/local/lib/python2.7/site-packages')
    srcpath = '/Users/jessebishop/Workspace/Projects/av/source'
    pgpath = '/usr/local/pgsql/bin/'
    gdalpath = '/usr/local/bin/'
else:
    srcpath = ''
    pgpath = '/usr/local/pgsql/bin/'
    gdalpath = '/Library/Frameworks/GDAL.framework/Programs/'
import argparse, glob, math, os, psycopg2, scipy.ndimage, subprocess
import numpy as np
import pandas as pd
from osgeo import gdal




def bound_calc(func, g, l, res):
    '''Calculates the snapped coordinate, given the appropriate function.'''
    return float(g + (func(abs(l - g) / res) * res))

def huc_bounds(huc, db):
    '''Calculates the snapped huc bounds and returns them in a tuple.'''
    # Global extent
    gXmin, gYmin = (-86.00055555556001, 29.9994444)
    # Calculate the bounds
    #query = """SELECT ST_XMin(geom) AS llx, ST_YMin(geom) AS lly, ST_XMax(geom) AS urx, ST_YMax(geom) AS ury FROM (SELECT ST_Transform(ST_Union(ST_MakeValid(buffer_geom)), 4269) AS geom FROM avaricosa_buffer_table WHERE primary_key = '{0}') AS tquery;""".format(huc)
    query = """SELECT ST_XMin(geom) AS llx, ST_YMin(geom) AS lly, ST_XMax(geom) AS urx, ST_YMax(geom) AS ury FROM (SELECT ST_Transform(geom_buffer, 4269) AS geom FROM public.nhd_flowline_all_no_duplicates WHERE permanent_ = '{0}') AS tquery;""".format(huc)
    cursor = db.cursor()
    cursor.execute(query)
    llx, lly, urx, ury = cursor.fetchall()[0]
    cursor.close()
    xmin = bound_calc(math.floor, gXmin, llx, 0.000092592592593)
    ymin = bound_calc(math.floor, gYmin, lly, 0.000092592592593)
    xmax = bound_calc(math.ceil, gXmin, urx, 0.000092592592593)
    ymax = bound_calc(math.ceil, gYmin, ury, 0.000092592592593)
    return (xmin, ymin, xmax, ymax)

def rasterize_huc(huc, edir, coordlist, hostname):
    '''Rasterizes a given huc using the coordinates provided.'''
    #print 'raster1'
    #print edir
    xmin, ymin, xmax, ymax = coordlist
    # Dump the shape
    if hostname == '192.168.1.100':
        dbadd = '-h 192.168.1.100 -u jessebishop'
    else:
        dbadd = ''
    query = """SELECT 1 as dumpid, ST_Transform(ST_Union(ST_MakeValid(geom_buffer)), 4269) AS geom FROM public.nhd_flowline_all_no_duplicates WHERE permanent_ = '{0}';""".format(huc)
    command = """{4}pgsql2shp {3} -f {0}/avaricosa_buffer_{1}_ned_clip_vector.shp blackosprey "{2}" """.format(edir, huc, query, dbadd, pgpath)
    #print command
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout = proc.communicate() # Necessary to force wait until process completes (otherwise use subprocess.call())
    # Rasterize, remove shape, and store
    command = """{6}gdal_rasterize -a dumpid -of GTiff -a_nodata 0 -te {0} {1} {2} {3} -tr 0.000092592592593 0.000092592592593 -ot Byte -co "COMPRESS=LZW" {4}/avaricosa_buffer_{5}_ned_clip_vector.shp {4}/avaricosa_buffer_{5}_ned_clip.tif""".format(xmin, ymin, xmax, ymax, edir, huc, gdalpath)
    #print command
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout1 = proc.communicate()
    for f in glob.glob("{0}/avaricosa_buffer_{1}_ned_clip_vector.*".format(edir, huc)):
        os.remove(f)
    return (procout, procout1)

def clip_data(coordlist, infile, edir, huc):
    '''Clips a national dataset down to the huc12 extent for quick analysis'''
    xmin, ymin, xmax, ymax = coordlist
    outfile = """{0}/{1}_avaricosa_buffer{2}.vrt""".format(edir, os.path.splitext(os.path.basename(infile))[0], huc)
    if not os.path.isfile(outfile):
        command = """{6}gdalwarp -of "VRT" -te {0} {1} {2} {3} -tr 0.000092592592593 0.000092592592593 -co "COMPRESS=LZW" {4} {5}""".format(xmin, ymin, xmax, ymax, infile, outfile, gdalpath)
        proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        procout = proc.communicate()
    return outfile

def summarize_huc(huc, edir, coordlist, srcpath):
    '''Generates summary statistics for a huc and puts them in the database.'''
    # The files to be processed
    #files = {'ned' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/ned_study_area_1arcsec.img', 'slope' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/slope_study_area_1arcsec.img', 'tri' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/tri_study_area_1arcsec.img', 'roughness' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/roughness_study_area_1arcsec.img'}
    files = {'slope' : '/Volumes/BlackOsprey/GIS_Data/USGS/NED/1arcsec_processed/slope_study_area_1arcsec.img'}
    # Set up the db record for the huc
    # try:
    #     query = "INSERT INTO avaricosa_buffer_summary_statistics (primary_key) VALUES ('{0}');".format(huc)
    #     cursor.execute(query)
    # except psycopg2.IntegrityError, msg:
    #     print "Primary Key {0} is already in the table".format(huc)
    #     db.rollback()
    # except Exception, msg:
    #     print "There was an unhandled error with Primary Key {0}".format(huc)
    #     print str(msg) + "\n"
    #     db.rollback()
    # else:
    #     db.commit()

    # Read the huc
    huc_handle = gdal.Open("{0}/avaricosa_buffer_{1}_ned_clip.tif".format(edir, huc))
    hucdata = huc_handle.ReadAsArray()
    zoneid = np.unique(hucdata)
    zoneid = zoneid[np.nonzero(zoneid)]
    num_pixels = np.bincount(np.int_(hucdata.reshape(hucdata.shape[0] * hucdata.shape[1])))[np.int_(zoneid)]
    if not num_pixels:
        df = pd.concat([pd.Series(huc, name='huc'), pd.Series(0, name='num_pixels'), pd.Series(0, name='mean_slope'), pd.Series(0, name='max_slope'), pd.Series(0, name='std_dev_slope')], axis=1)
        return df
    # Loop through the files and do it
    # for dt in files.keys():
    #     print dt
    f = files['slope']
    if srcpath:
        f = srcpath + '/' + os.path.basename(f) 
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
    #zmin = scipy.ndimage.minimum(image, labels=hucdata, index=zoneid)
    zmax = scipy.ndimage.maximum(image, labels=hucdata, index=zoneid)
    # query = "UPDATE avaricosa_buffer_summary_statistics SET ({0}_mean, {0}_std_dev, {0}_min, {0}_max) = ({1}, {2}, {3}, {4}) WHERE primary_key = '{5}';".format(dt, mean[0], std_dev[0], zmin[0], zmax[0], huc)
    # cursor.execute(query)
    # db.commit()
    df = pd.concat([pd.Series(huc, name='huc'), pd.Series(num_pixels, name='num_pixels'), pd.Series(mean, name='mean_slope'), pd.Series(zmax, name='max_slope'), pd.Series(std_dev, name='std_dev_slope')], axis=1)
    os.system("""rm -f {0}/slope_study_area_1arcsec_avaricosa_buffer{1}.vrt""".format(edir, huc))
    os.system("rm -f {0}/avaricosa_buffer_{1}_ned_clip.tif".format(edir, huc))
    return df



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
            
    


def main(huc, edir, db, regen, hostname):
    '''The work gets done here.'''
    print "HUC12 is {0}".format(huc)  
    # Get the snapped raster coordinates
    huc_coords = huc_bounds(huc, db)
    # Process the huc raster if necessary
    if not os.path.isfile("{0}/avaricosa_buffer_{1}_ned_clip.tif".format(edir, huc)) or regen:
        rasterize_huc(huc, edir, huc_coords, hostname)
    # Generate the huc12 summary statistics
    try:
        df = summarize_huc(huc, edir, huc_coords, srcpath)
    except Exception, msg:
        print "ERROR with huc {0}".format(huc)
        print str(msg)
        db.rollback()
    else:
        return df




########
# MAIN #
########

# Parse the arguments
p = argparse.ArgumentParser(prog="huc_12_ned_statistics.py")
p.add_argument("huc12", type=str, help="The huc_12 id to process.")
p.add_argument("exportdir", help="The directory that holds the rasterized huc12s.")
p.add_argument("outcsv", help="The csv to write.")
p.add_argument("hostname", help="The database host.")
p.add_argument("-r", "--regen", dest="regen", required=False, action="store_true", help="Force regeneration of rasterized huc12 even if it exists.")
p.add_argument("-l", "--list", dest="inlist", required=False, action="store_true", help="Providing a list of hucs instead of an individual huc.")
args = p.parse_args()

huc = args.huc12
edir = args.exportdir

# Connect to db
db = psycopg2.connect(host=args.hostname, database='blackosprey',user='jessebishop')
#cursor = db.cursor()

# Run it
outcsv = args.outcsv
oc = pd.concat([pd.Series(huc, name='huc'), pd.Series(0, name='num_pixels'), pd.Series(0, name='mean_slope'), pd.Series(0, name='max_slope'), pd.Series(0, name='std_dev_slope')], axis=1)

if args.inlist:
    for h in open(huc, 'r'):
        df = main(h.strip(), edir, db, args.regen, args.hostname)
        oc = oc.append(df)
else:
    df = main(huc, edir, db, args.regen, args.hostname)
    oc = oc.append(df)

oc.to_csv(outcsv, index=False)

# Close the db connection.
#cursor.close()
db.close()
