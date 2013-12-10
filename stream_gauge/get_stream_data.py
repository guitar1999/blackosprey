#!/usr/bin/python

import os, psycopg2, sys
from datetime import datetime

outdir = sys.argv[1]
if outdir[-1] != '/':
    outdir = outdir + '/'

# Get db connection
db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

# Fix date function
def fx(dateobject):
    if not dateobject == -99999:
        #return datetime.strptime(str(dateobject), '%Y%m%d').strftime('%Y-%m-%d')
        return """%s-%s-%s""" % (str(dateobject)[0:4], str(dateobject)[4:6], str(dateobject)[6:])

# Get a list of huc ids that have avaricosa and gauge data
sql = "SELECT distinct huc_8_num FROM nhd_hu8_watersheds n, usgs_streamgauges u WHERE contains_avaricosa = 'Y' AND ST_Intersects(u.geom,n.geom);"
cursor.execute(sql)
hucs = [this[0] for this in cursor.fetchall()]

for huc in hucs:
    # Get site ids
    sql = """SELECT site_no, day1, dayn FROM usgs_streamgauges WHERE huc = '0%s';""" % (huc)
    cursor.execute(sql)
    for siteno, startd, endd in cursor.fetchall():
        iurl = """http://waterservices.usgs.gov/nwis/iv/?format=rdb,1.0&sites=%s&startDT=%s&endDT=%s&parameterCd=00060,00065""" % (siteno, fx(startd), '2013-12-09')
        durl = """http://waterservices.usgs.gov/nwis/dv/?format=rdb,1.0&sites=%s&startDT=%s&endDT=%s&parameterCd=00060,00065""" % (siteno, fx(startd), '2013-12-09')
        os.system("""wget %s -O %shuc_%s_site_%s_%s.csv""" % (iurl.replace('&','\&'), outdir, huc, siteno, 'instantaneous'))
        os.system("""wget %s -O %shuc_%s_site_%s_%s.csv""" % (durl.replace('&','\&'), outdir, huc, siteno, 'daily'))
    
cursor.close()
db.close()