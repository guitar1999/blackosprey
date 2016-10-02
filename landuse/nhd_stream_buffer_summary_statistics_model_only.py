#!/Volumes/BlackOsprey/GIS_Data/bo_python/bin/python

import argparse, glob, math, os, psycopg2, scipy.ndimage, subprocess
import numpy as np
import pandas as pd
from osgeo import gdal


def get_val(dict, key):
    try:
        a = dict[key]
    except KeyError:
        a = 0
    return a

def bound_calc(func, g, l, res):
    '''Calculates the snapped coordinate, given the appropriate function.'''
    return int(g + (func(abs(l - g) / res) * res))

def huc_bounds(huc, cursor):
    '''Calculates the snapped huc bounds and returns them in a tuple.'''
    # Global extent
    gXmin, gYmin, gXmax, gYmax = (851775, 868245, 2342655, 3087885)
    # Calculate the bounds
    query = """SELECT ST_XMin(geom) AS llx, ST_YMin(geom) AS lly, ST_XMax(geom) AS urx, ST_YMax(geom) AS ury FROM (SELECT geom_buffer AS geom FROM nhd_flowline_all_no_duplicates_100m_segments_exploded WHERE newid = '{0}') AS tquery;""".format(huc)
    cursor.execute(query)
    llx, lly, urx, ury = cursor.fetchall()[0]
    xmin = bound_calc(math.floor, gXmin, llx, 30)
    ymin = bound_calc(math.floor, gYmin, lly, 30)
    xmax = bound_calc(math.ceil, gXmin, urx, 30)
    ymax = bound_calc(math.ceil, gYmin, ury, 30)
    return (xmin, ymin, xmax, ymax)

def rasterize_huc(huc, edir, coordlist):
    '''Rasterizes a given huc using the coordinates provided.'''
    xmin, ymin, xmax, ymax = coordlist
    # Dump the shape
    query = """SELECT 1 as dumpid, geom_buffer AS geom FROM nhd_flowline_all_no_duplicates_100m_segments_exploded WHERE newid = '{0}';""".format(huc)
    command = """/usr/local/pgsql/bin/pgsql2shp -f {0}/nhd_stream_buffer_{1}_clip_vector.shp blackosprey "{2}" """.format(edir, huc, query)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout = proc.communicate() # Necessary to force wait until process completes (otherwise use subprocess.call())
    # Rasterize, remove shape, and store
    command = """/Library/Frameworks/GDAL.framework/Programs/gdal_rasterize -a dumpid -of GTiff -a_nodata 0 -te {0} {1} {2} {3} -tr 30 30 -ot Byte -co "COMPRESS=LZW" {4}/nhd_stream_buffer_{5}_clip_vector.shp {4}/nhd_stream_buffer_{5}_clip.tif""".format(xmin, ymin, xmax, ymax, edir, huc)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout1 = proc.communicate()
    for f in glob.glob("{0}/nhd_stream_buffer_{1}_clip_vector.*".format(edir, huc)):
        os.remove(f)
    return (procout, procout1)

def clip_data(coordlist, infile, edir, huc):
    '''Clips a national dataset down to the huc12 extent for quick analysis'''
    xmin, ymin, xmax, ymax = coordlist
    outfile = """{0}/{1}_avaricosa_buffer{2}.tif""".format(edir, os.path.splitext(os.path.basename(infile))[0], huc)
    if not os.path.isfile(outfile):
        command = """/Library/Frameworks/GDAL.framework/Programs/gdalwarp -te {0} {1} {2} {3} -tr 30 30 -co "COMPRESS=LZW" {4} {5}""".format(xmin, ymin, xmax, ymax, infile, outfile)
        proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        procout = proc.communicate()
    return outfile

def summarize_huc(huc, edir, coordlist, cursor, db):
    '''Generates summary statistics for a huc and puts them in the database.'''
    # A lookup dictionary for landcover
    landcover_lookup = {"Open Water" : 11, "Perennial Ice/Snow" : 12, "Developed, Open Space" : 21, "Developed, Low Intensity" : 22, "Developed, Medium Intensity" : 23, "Developed, High Intensity" : 24, "Barren Land" : 31, "Deciduous Forest" : 41, "Evergreen Forest" : 42, "Mixed Forest" : 43, "Dwarf Scrub" : 51, "Shrub/Scrub" : 52, "Grassland/Herbaceous" : 71, "Sedge/Herbaceous" : 72, "Lichens" : 73, "Moss" : 74, "Pasture/Hay" : 81, "Cultivated Crops" : 82, "Woody Wetlands" : 90, "Emergent Herbaceous Wetlands" : 95}
    # The files to be processed
    files = {2011 : {"lc" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_landcover/nlcd_2011_landcover_2011_edition_2014_03_31/nlcd_2011_landcover_2011_edition_2014_03_31_clip.tif", "cd" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_treecover_analytical/nlcd_2011_USFS_tree_canopy_2011_edition_2014_03_31/analytical_product/nlcd2011_usfs_treecanopy_analytical_3-31-2014_clip.tif"}, 1992 : {"lc92" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/1992/NLCD92_wall_to_wall_landcover/nlcd92mosaic_clip.tif"}}
    # Set up the db record for the huc
    # try:
    #     query = "INSERT INTO nhd_stream_buffer_summary_statistics (primary_key) VALUES ('{0}');".format(huc)
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
    huc_handle = gdal.Open("{0}/nhd_stream_buffer_{1}_clip.tif".format(edir, huc))
    hucdata = huc_handle.ReadAsArray()
    zoneid = np.unique(hucdata)
    zoneid = zoneid[np.nonzero(zoneid)]
    num_pixels = np.bincount(np.int_(hucdata.reshape(hucdata.shape[0] * hucdata.shape[1])))[np.int_(zoneid)]
    if not num_pixels:
        df = pd.concat([pd.Series(huc, name='huc'), pd.Series(0, name='num_pixels'), pd.Series(0, name='pct_forest_1992'), pd.Series(0, name='pct_forest_2011'), pd.Series(0, name='pct_wetland_2011'), pd.Series(0, name='mean_cd_2011')], axis=1)
        return df
    # query = "UPDATE nhd_stream_buffer_summary_statistics SET (num_pixels) = ({0}) WHERE primary_key = '{1}'".format(num_pixels, huc)
    # cursor.execute(query)
    # db.commit()
    # Loop through the files and do it
    for year in files.keys():
        # print year
        for dt in files[year]:
            # print dt
            f = files[year][dt]
            # Clip the file
            data_file = clip_data(coordlist, f, edir, huc)
            # Process
            if dt == "cd":
                # Zone is the huc
                image_handle = gdal.Open(data_file)
                image = image_handle.ReadAsArray()
                if dt == 'cd' and year == 2011:
                    image = image[0,:,:]
                if not hucdata.shape == image.shape:
                    print "Shape error with pk {0}!".format(huc)
                    ef = open("{0}/{1}.error".format(edir, huc), 'w')
                    ef.write(huc + '\n')
                    ef.close()
                    return
                mean = scipy.ndimage.mean(image, labels=hucdata, index=zoneid)
                # std_dev = scipy.ndimage.standard_deviation(image, labels=hucdata, index=zoneid)
                # zmin = scipy.ndimage.minimum(image, labels=hucdata, index=zoneid)
                # zmax = scipy.ndimage.maximum(image, labels=hucdata, index=zoneid)
                # query = "UPDATE nhd_stream_buffer_summary_statistics SET (s{0}_{1}_mean, s{0}_{1}_std_dev, s{0}_{1}_min, s{0}_{1}_max) = ({2}, {3}, {4}, {5}) WHERE primary_key = '{6}';".format(year, dt, mean[0], std_dev[0], zmin[0], zmax[0], huc)
            else:
                # For DB table, need every value that exists in any of these rasters!
                lc_handle = gdal.Open(data_file)
                lcdata = lc_handle.ReadAsArray()
                if not hucdata.shape == lcdata.shape:
                    print "Shape error with huc {0}!".format(huc)
                    ef = open("{0}/{1}.error".format(edir, huc), 'w')
                    ef.write(huc + '\n')
                    ef.close()
                    return
                # Make a mask of the huc
                hucmask = hucdata == 0
                np.putmask(lcdata, hucmask, 0)
                pzone = pd.Series(lcdata.reshape(lcdata.shape[0] * lcdata.shape[1]))
                num_pixels_lc = pzone.value_counts()
                num_pixels_lc.name = 'num_pixels_lc'
                pix_dict = num_pixels_lc.to_dict()
                if year == 2011:
                    pct_forest_11 = (get_val(pix_dict, 41) + get_val(pix_dict, 42) + get_val(pix_dict, 43)) / float(num_pixels)
                    pct_wetland = (get_val(pix_dict, 90) + get_val(pix_dict, 95)) / float(num_pixels)
                else:
                    pct_forest_92 = (get_val(pix_dict, 41) + get_val(pix_dict, 42) + get_val(pix_dict, 43)) / float(num_pixels)
    #outline = """{0},{1},{2},{3},{4}\n""".format(huc, num_pixels, pct_forest, pct_wetland, mean[0])
    #oc.write(outline)
    #oc.flush()
    df = pd.concat([pd.Series(huc, name='huc'), pd.Series(num_pixels, name='num_pixels'), pd.Series(pct_forest_92, name='pct_forest_1992'), pd.Series(pct_forest_11, name='pct_forest_2011'), pd.Series(pct_wetland, name='pct_wetland_2011'), pd.Series(mean[0], name='mean_cd_2011')], axis=1)
    return df
            #     cols = []
            #     vals = []
            #     for k,v in pix_dict.items():
            #         if k == 0 or ((dt == 'lc' or dt == 'lcc') and (k < 11 or k > 95)) or (dt == 'lcft' and k > 289):
            #             continue
            #         cols.append("s{0}_{1}_{2}".format(year, dt, k))
            #         vals.append(str(pix_dict[k]))
            #     if cols:
            #         query = "UPDATE nhd_stream_buffer_summary_statistics SET ({0}) = ({1}) WHERE primary_key = '{2}';".format(','.join(cols), ','.join(vals), huc)
            #     else:
            #         query = "SELECT CURRENT_TIMESTAMP;"
            # #print query
            # cursor.execute(query)
            # db.commit()



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
    print "Primary Key is {0}".format(huc)  
    # Get the snapped raster coordinates
    huc_coords = huc_bounds(huc, cursor)
    # Process the huc raster if necessary
    if not os.path.isfile("{0}/nhd_stream_buffer_{1}_clip.tif".format(edir, huc)) or regen:
        rasterize_huc(huc, edir, huc_coords)
    # Generate the huc12 summary statistics
    try:
        df = summarize_huc(huc, edir, huc_coords, cursor, db)
    except Exception, msg:
        print "ERROR with huc {0}".format(huc)
        print str(msg)
        db.rollback()
    return df




########
# MAIN #
########

# Parse the arguments
p = argparse.ArgumentParser(prog="nhd_stream_buffer_summary_statistics.py")
p.add_argument("huc12", type=str, help="The primary_key id to process.")
p.add_argument("exportdir", help="The directory that holds the rasterized huc12s.")
p.add_argument("outcsv", help="The csv to write.")
p.add_argument("-r", "--regen", dest="regen", required=False, action="store_true", help="Force regeneration of rasterized huc12 even if it exists.")
p.add_argument("-l", "--list", dest="inlist", required=False, action="store_true", help="Providing a list of hucs instead of an individual huc.")
args = p.parse_args()

huc = args.huc12
edir = args.exportdir

# Connect to db
db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

# Run it
# outcsv = edir + '/landcover_variables.csv'
outcsv = args.outcsv
# oc = open(outcsv, 'w')
# oc.write('key,num_pixels,pct_forest_2011,pct_wetland_2011,mean_cd_2011\n')
oc = pd.concat([pd.Series(0, name='huc'), pd.Series(0, name='num_pixels'), pd.Series(0, name='pct_forest_1992'), pd.Series(0, name='pct_forest_2011'), pd.Series(0, name='pct_wetland_2011'), pd.Series(0, name='mean_cd_2011')], axis=1)
if args.inlist:
    for h in open(huc, 'r'):
        df = main(h.strip(), edir, cursor, args.regen)
        # print df
        oc = oc.append(df)
else:
    df = main(huc, edir, cursor, args.regen)
    oc = oc.append(df)
# oc.close()
oc.to_csv(outcsv, index=False)

# Close the db connection.
cursor.close()
db.close()
