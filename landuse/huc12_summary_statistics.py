#!/usr/bin/python

import argparse, glob, math, os, psycopg2, subprocess


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
    xmin = bound_calc(math.floor, gXmin, llx)
    ymin = bound_calc(math.floor, gYmin, lly)
    xmax = bound_calc(math.ceil, gXmin, urx)
    ymax = bound_calc(math.ceil, gYmin, ury)
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
    command = """/Library/Frameworks/GDAL.framework/Programs/gdalwarp -te {0} {1} {2} {3} -tr 30 30 {4} {5}""".format(xmin, ymin, xmax, ymax, infile, outfile)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout = proc.communicate()
    return procout

def summarize_huc(huc, edir, coordlist, cursor, db):
    '''Generates summary statistics for a huc and puts them in the database.'''
    # 2011
        # Land Cover
        # Canopy
        # Impervious
        # 2001 to 2011 Change Area
        # 2001 to 2011 FromTo Change
        # 2006 to 2011 Change Area
        # 2006 to 2011 FromTo Change
        # 2006 to 2011 Impervious Change
    # NO 2006
        # NO Land Cover
        # NO Impervious
        # NO 2001 to 2006 Change Area
        # NO 2001 to 2006 FromTo Change
        # NO 2001 to 2006 Impervious Change
    # 2001
        # Land Cover
        # Canopy
        # Impervious
    # Retrofit
        # 1992 to 2001 Retrofit Landcover Change
    # 1992
        # Land Cover

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
            
    landcover_lookup = {"Open Water" : 11, "Perennial Ice/Snow" : 12, "Developed, Open Space" : 21, "Developed, Low Intensity" : 22, "Developed, Medium Intensity" : 23, "Developed, High Intensity" : 24, "Barren Land" : 31, "Deciduous Forest" : 41, "Evergreen Forest" : 42, "Mixed Forest" : 43, "Dwarf Scrub" : 51, "Shrub/Scrub" : 52, "Grassland/Herbaceous" : 71, "Sedge/Herbaceous" : 72, "Lichens" : 73, "Moss" : 74, "Pasture/Hay" : 81, "Cultivated Crops" : 82, "Woody Wetlands" : 90, "Emergent Herbaceous Wetlands" : 95}


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
