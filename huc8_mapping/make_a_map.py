#!/usr/bin/python

import matplotlib, psycopg2, sys
matplotlib.use('Agg')
from mpl_toolkits.basemap import Basemap
from osgeo import ogr
from shapely.wkb import loads
import numpy as np
from matplotlib.patches import Polygon
from matplotlib.path import Path
from matplotlib.collections import PatchCollection
from matplotlib.collections import PathCollection
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

huc = sys.argv[1]
#huc = 4100010 #huc = 1070003

def btf(byte):
    """Takes an 8-bit color value and returns the float for matplotlib """
    f = float(byte) / 255
    return f

# Get the bounding box and center of the watershed polygon
sql = "SELECT ST_XMin(geom) AS llx, ST_YMin(geom) AS lly, ST_XMax(geom) AS urx, ST_YMax(geom) AS ury, ST_X(ST_Centroid(geom)) AS cenx, ST_Y(ST_Centroid(geom)) AS ceny, ST_Xmax(ST_Transform(geom, 962)) - ST_Xmin(ST_Transform(geom, 962)) AS xdist, ST_YMax(ST_Transform(geom, 962)) - ST_Ymin(ST_Transform(geom, 962)) AS ydist, hu_8_name FROM nhd_hu8_watersheds WHERE huc_8_num = %s;" % (huc)
cursor.execute(sql)
llx, lly, urx, ury, cenx, ceny, xdist, ydist, wname = cursor.fetchall()[0]
print xdist, ydist, xdist/ydist

# Figure out if we're landscape or portrait
if urx - llx > ury - lly:
    figsz = (11,8.5)
else:
    figsz = (8.5,11)

# Generate the figure object
fig = plt.figure(figsize=figsz)
plt.axis('off')
fig.suptitle('%s Watershed (%s): x = %s, y = %s, ratio = %s' % (wname, huc, xdist, ydist, xdist/ydist))

# Add axes
#ax = fig.add_subplot(111) # ax = plt.axes()
# Start to divide the plot (more to come later)
ax1 = plt.subplot2grid((3,3), (0,0), colspan=3, rowspan=2)
#ax = plt.gca()
# Add a basemap (use wgs84 for now, until we figure out what projection we want to use
#m = Basemap(projection='merc', llcrnrlat=lly, urcrnrlat=ury, llcrnrlon=llx, urcrnrlon=urx, lat_ts=20, resolution='f') # need to figure out transforming poly to use this basemap
m = Basemap(llcrnrlat=lly*0.999, urcrnrlat=ury*1.001, llcrnrlon=llx*1.001, urcrnrlon=urx*0.999, resolution='h')

# For testing purposes
m.fillcontinents(color='white',zorder=0)
m.drawmapboundary(fill_color=(btf(189), btf(215), btf(231)))
#m.drawcoastlines()
#m.drawcounties(color='r')
#m.drawrivers(color='b')


######################
# Adding Data to map #
######################

def addPGdata(query, alpha, edgecolor, facecolor, fill, label, linewidth, zorder, mapobject=None):
    # Set an empty list to hold patches
    patches = []
    # Connect to DB with ogr
    source = ogr.Open("PG:host=localhost dbname=blackosprey user=jessebishop")
    # Get the geometry from the database
    data = source.ExecuteSQL(query)
    if data.GetFeatureCount() > 0:
        while 1:
        # Get the feature
            feature = data.GetNextFeature()
            if not feature:
                break
            # Use shapely.loads to get the geometry
            geom = loads(feature.GetGeometryRef().ExportToWkb())
            if geom.geometryType() == 'Polygon' or geom.geometryType() == 'MultiPolygon':
                for polygon in geom:
                    a = np.asarray(polygon.exterior)
                    if "geom1" in query:
                        lon, lat = a[:,0], a[:,1]
                        x, y = mapobject(lon,lat)
                        b = zip(x,y)
                    else:
                        b = zip(a[:,0], a[:,1])
                    p = Polygon(b, alpha=alpha, edgecolor=edgecolor, facecolor=facecolor, fill=fill, label=label, linewidth=linewidth, zorder=zorder) 
                    plt.gca().add_patch(p)
            elif geom.geometryType() == 'Point':
                x,y = geom.xy
                m.plot(x,y, color=edgecolor, markerfacecolor=facecolor, marker='o', markersize=linewidth, zorder=zorder)
            elif geom.geometryType() == 'LineString' or geom.geometryType() == 'MultiLineString':
                for line in geom:
                    a = np.asarray(line.xy)
                    b = zip(a[:,0], a[:,1])
                    p = Path(b, alpha=alpha, color=edgecolor, facecolor=facecolor, fill=fill, label=label, linewidth=linewidth, zorder=zorder)
                    plt.gca().add_path(p)
            else:
                print "I don't handle %s geometry yet!" % (geom.geometryType())


# Watershed
query = "SELECT geom FROM nhd_hu8_watersheds WHERE NOT huc_8_num = %s" % (huc)
addPGdata(query, 0.4, (btf(42), btf(42), btf(42)), 'gray', True, huc, 1, 20)
query = "SELECT geom FROM nhd_hu8_watersheds WHERE huc_8_num = %s" % (huc)
addPGdata(query, 1, 'black', 'white', False, huc, 1.5, 30)
# NHD Baselayer
query = "SELECT ST_Force_2D(b.geom) AS geom FROM baselayer_nhd_area b, nhd_hu8_watersheds w WHERE ST_Intersects(ST_Buffer(ST_Envelope(w.geom), 1), b.geom) AND w.huc_8_num = %s" % (huc)
addPGdata(query, 1, (btf(189), btf(215), btf(231)), (btf(189), btf(215), btf(231)), True, huc, 1.5, 10)
query = "SELECT ST_Force_2D(b.geom) AS geom FROM baselayer_nhd_waterbody b, nhd_hu8_watersheds w WHERE ST_Intersects(ST_Buffer(ST_Envelope(w.geom), 1), b.geom) AND w.huc_8_num = %s" % (huc)
addPGdata(query, 1, (btf(189), btf(215), btf(231)), (btf(189), btf(215), btf(231)), True, huc, 1.5, 10)
# States
query = "SELECT geom FROM states_project_area"
addPGdata(query, 1, (btf(42), btf(42), btf(42)), (btf(222), btf(222), btf(222)), True, '', 0.5, 5)
# A. varicosa data
query = "SELECT a.geom FROM avaricosa.polys a WHERE a.huc_8_num = %s" % (huc)
addPGdata(query, 1, 'red', 'red', True, huc, 1, 100)
query = "SELECT a.geom FROM avaricosa.points a WHERE a.huc_8_num = %s" % (huc)
addPGdata(query, 1, 'red', 'red', True, huc, 1, 100)
query = "SELECT a.geom FROM avaricosa.lines a WHERE a.huc_8_num = %s" % (huc)
addPGdata(query, 1, 'red', 'red', True, huc, 1, 100)

ax2 = plt.subplot2grid((3,3), (2,0))
m1 = Basemap(projection='merc',llcrnrlat=36,urcrnrlat=48,\
            llcrnrlon=-84,urcrnrlon=-66,lat_ts=42,resolution='l')
m1.drawcoastlines()    
m1.fillcontinents(color=(btf(222), btf(222), btf(222)),lake_color=(btf(189), btf(215), btf(231)))
m1.drawcountries()
m1.drawstates()
m1.drawmapboundary(fill_color=(btf(189), btf(215), btf(231)))
query = "SELECT geom AS geom1 FROM nhd_hu8_watersheds WHERE huc_8_num = %s" % (huc)
addPGdata(query, 1, 'red', 'white', False, huc, 1.5, 30, mapobject=m1)
#ax2.text(0.5, 0.5, 'locus', va="center", ha="center")
#plt.gca().text(0.5, 0.5, 'locus', va="center", ha="center")
ax3 = plt.subplot2grid((3,3), (2,1), colspan=2)
#ax3.text(0.5, 0,5, 'legend', va="center", ha="center")

#plt.show()
plt.savefig('/Volumes/BlackOsprey/GIS_Data/TEMP/h%s.png' % (huc), bbox_inches='tight')
