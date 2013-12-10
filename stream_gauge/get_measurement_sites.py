#!/usr/bin/python

import os, psycopg2, sys
from datetime import datetime

outdir = sys.argv[1]
if outdir[-1] != '/':
    outdir = outdir + '/'

# Get db connection
db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

# Get a list of huc ids that have avaricosa and gauge data
sql = "SELECT distinct huc_8_num FROM nhd_hu8_watersheds n, usgs_streamgauges u WHERE contains_avaricosa = 'Y';"
cursor.execute(sql)
hucs = [this[0] for this in cursor.fetchall()]

for huc in hucs:
    surl = """http://waterservices.usgs.gov/nwis/site/?format=rdb&huc=0%s""" % (huc)
    os.system("""wget %s -O %ssites_in_huc_%s.csv""" % (surl.replace('&','\&'), outdir, huc))
    
cursor.close()
db.close()