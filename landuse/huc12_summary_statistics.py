#!/usr/bin/python

import argparse, glob, math, os, psycopg2, subprocess

p = argparse.ArgumentParser(prog="huc_12_summary_statistics.py")
p.add_argument("huc12", type=str, help="The huc_12 id to process.")
p.add_argument("exportdir", help="The directory that holds the rasterized huc12s.")
p.add_argument("-r", "--regen", dest="regen", required=False, action="store_true", help="Force regeneration of rasterized huc12 even if it exists.")
args = p.parse_args()

huc = args.huc12
edir = args.exportdir

# Connect to db
db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

def bound_calc(func, g, l):
    '''Calculates the snapped coordinate, given the appropriate function.'''
    return int(g + (func(abs(l - g) / 30) * 30))

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
    procout = proc.communicate()
    # Rasterize, remove shape, and store
    command = """/Library/Frameworks/GDAL.framework/Programs/gdal_rasterize -a dumpid -of GTiff -a_nodata 0 -te {0} {1} {2} {3} -tr 30 30 -ot Byte -co "COMPRESS=LZW" {4}/huc12_{5}_clip_vector.shp {4}/huc12_{5}_clip.tif""".format(xmin, ymin, xmax, ymax, edir, huc)
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    procout1 = proc.communicate()
    for f in glob.glob("{0}/huc12_{1}_clip_vector.*".format(edir, huc)):
        os.remove(f)
    return (procout, procout1)

########
# MAIN #
########

huc_coords = huc_bounds(huc, cursor)
rasterize_huc(huc, edir, huc_coords)
