#!/usr/bin/python

import argparse, glob, math, os, psycopg2, scipy.ndimage, subprocess
import numpy as np
import pandas as pd
from osgeo import gdal




def bound_calc(func, g, l, res):
    '''Calculates the snapped coordinate, given the appropriate function.'''
    return int(g + (func(abs(l - g) / res) * res))

def huc_bounds(huc, cursor):
    '''Calculates the snapped huc bounds and returns them in a tuple.'''
    # Global extent
    gXmin, gYmin, gXmax, gYmax = (851775, 868245, 2342655, 3087885)
    # Calculate the bounds
    query = """SELECT ST_XMin(geom) AS llx, ST_YMin(geom) AS lly, ST_XMax(geom) AS urx, ST_YMax(geom) AS ury FROM (SELECT ST_Transform(geom, 5070) AS geom FROM nhd_hu12_watersheds WHERE huc_12 = '{0}') AS tquery;""".format(huc)
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
    query = """SELECT dumpid, ST_Transform(geom, 5070) AS geom FROM nhd_hu12_watersheds WHERE huc_12 = '{0}';""".format(huc)
    command = """/usr/local/pgsql/bin/pgsql2shp -f {0}/huc12_{1}_clip_vector.shp blackosprey "{2}" """.format(edir, huc, query)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout = proc.communicate() # Necessary to force wait until process completes (otherwise use subprocess.call())
    # Rasterize, remove shape, and store
    command = """/Library/Frameworks/GDAL.framework/Programs/gdal_rasterize -a dumpid -of GTiff -a_nodata 0 -te {0} {1} {2} {3} -tr 30 30 -ot Byte -co "COMPRESS=LZW" {4}/huc12_{5}_clip_vector.shp {4}/huc12_{5}_clip.tif""".format(xmin, ymin, xmax, ymax, edir, huc)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout1 = proc.communicate()
    for f in glob.glob("{0}/huc12_{1}_clip_vector.*".format(edir, huc)):
        os.remove(f)
    return (procout, procout1)

def clip_data(coordlist, infile, edir, huc):
    '''Clips a national dataset down to the huc12 extent for quick analysis'''
    xmin, ymin, xmax, ymax = coordlist
    outfile = """{0}/{1}_huc{2}.tif""".format(edir, os.path.splitext(os.path.basename(infile))[0], huc)
    command = """/Library/Frameworks/GDAL.framework/Programs/gdalwarp -te {0} {1} {2} {3} -tr 30 30 -co "COMPRESS=LZW" {4} {5}""".format(xmin, ymin, xmax, ymax, infile, outfile)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout = proc.communicate()
    return outfile

def summarize_huc(huc, edir, coordlist, cursor, db):
    '''Generates summary statistics for a huc and puts them in the database.'''
    # A lookup dictionary for landcover
    landcover_lookup = {"Open Water" : 11, "Perennial Ice/Snow" : 12, "Developed, Open Space" : 21, "Developed, Low Intensity" : 22, "Developed, Medium Intensity" : 23, "Developed, High Intensity" : 24, "Barren Land" : 31, "Deciduous Forest" : 41, "Evergreen Forest" : 42, "Mixed Forest" : 43, "Dwarf Scrub" : 51, "Shrub/Scrub" : 52, "Grassland/Herbaceous" : 71, "Sedge/Herbaceous" : 72, "Lichens" : 73, "Moss" : 74, "Pasture/Hay" : 81, "Cultivated Crops" : 82, "Woody Wetlands" : 90, "Emergent Herbaceous Wetlands" : 95}
    # The files to be processed
    files = {2011 : {"lcc" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2001_to_2011_landcover_change_pixels/nlcd_2001_to_2011_landcover_change_pixels_2011_edition_2014_03_31/nlcd_2001_to_2011_landcover_change_pixels_2011_edition_2014_03_31_clip.tif", "lcft" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2001_to_2011_landcover_fromto_change_index/nlcd_2001_to_2011_landcover_fromto_change_index_2011_edition_2014_04_09/nlcd_2001_to_2011_landcover_fromto_change_index_2011_edition_2014_04_09_clip.tif", "impervious" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_impervious/nlcd_2011_impervious_2011_edition_2014_03_31/nlcd_2011_impervious_2011_edition_2014_03_31_clip.tif", "lc" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_landcover/nlcd_2011_landcover_2011_edition_2014_03_31/nlcd_2011_landcover_2011_edition_2014_03_31_clip.tif", "cd": "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2011/nlcd_2011_treecover_analytical/nlcd_2011_USFS_tree_canopy_2011_edition_2014_03_31/analytical_product/nlcd2011_usfs_treecanopy_analytical_3-31-2014_clip.tif"}, 2001 : {"lcc" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2001/change/merged_changeproduct5k_111907_clip.tif", "cd" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2001/canopy/nlcd2001_canopy_mosaic_1-29-08/nlcd_canopy_mosaic_1-29-08_clip.tif", "impervious" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2001/impervious/nlcd_2001_impervious_2011_edition_2014_03_31/nlcd_2001_impervious_2011_edition_2014_03_31_clip.tif", "lc" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/2001/landcover/nlcd_2001_landcover_2011_edition_2014_03_31/nlcd_2001_landcover_2011_edition_2014_03_31_clip.tif"}, 1992 : {"lc92" : "/Volumes/BlackOsprey/GIS_Data/NLCD/new/1992/NLCD92_wall_to_wall_landcover/nlcd92mosaic_clip.tif"}}
    # Set up the db record for the huc
    try:
        query = "INSERT INTO huc_12_summary_statistics (huc) VALUES ({0});".format(huc)
        cursor.execute(query)
    except IntegrityError, msg:
        print "HUC {0} is already in the table".format(huc)
        db.rollback()
    except Exception, msg:
        print "There was an unhandled error with HUC {0}".format(huc)
        print str(msg) + "\n"
        db.rollback()
    else:
        db.commit()

    # Read the huc
    huc_handle = gdal.Open("{0}/huc12_{1}_clip.tif".format(edir, huc))
    hucdata = huc_handle.ReadAsArray()
    # Loop through the files and do it
    for year in files.keys():
        for dt in files[year]:
            f = files[year][dt]
            # Clip the file
            data_file = clip_data(coordlist, f, edir, huc)
            # Process
            if dt == "impervious" or dt == "cd":
                # Zone is the huc
                zoneid = np.unique(hucdata)
                zoneid = zoneid[np.nonzero(zoneid)]
                image_handle = gdal.Open(data_file)
                image = image_handle.ReadAsArray()
                mean = scipy.ndimage.mean(image, labels=hucdata, index=zoneid)
                std_dev = scipy.ndimage.standard_deviation(image, labels=hucdata, index=zoneid)
                zmin = scipy.ndimage.minimum(image, labels=hucdata, index=zoneid)
                zmax = scipy.ndimage.maximum(image, labels=hucdata, index=zoneid)
                query = "UPDATE huc_12_summary_statistics SET ({0}_{1}_mean, {0}_{1}_std_dev, {0}_{1}_min, {0}_{1}_max) = ({2}, {3}, {4}, {5});".format(year, dt, mean, std_dev, zmin, zmax)
            else:
                # For DB table, need every value that exists in any of these rasters!
                lc_handle = gdal.Open(data_file)
                lcdata = lc_handle.ReadAsArray()
                # Make a mask of the huc
                hucmask = hucdata == 0
                np.putmask(lcdata, hucmask, 0)
                pzone = pd.Series(lcdata.reshape(lcdata.shape[0] * lcdata.shape[1]))
                num_pixels = pzone.value_counts()
                num_pixels.name = 'num_pixels'
                # Convert this into a query statement somehow?
                cols = []
                vals = []
                for k in num_pixels.keys():
                    cols.append("{0}_{1}_{2}".format(year, dt, k))
                    vals.append(num_pixels[k])


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
    if not os.path.isfile("{0}/huc12_{1}_clip.tif".format(edir, huc)) or regen:
        rasterize_huc(huc, edir, huc_coords)
    # Generate the huc12 summary statistics
    #summarize_huc(huc, edir, huc_coords, cursor, db)




########
# MAIN #
########

# Parse the arguments
p = argparse.ArgumentParser(prog="huc_12_summary_statistics.py")
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
