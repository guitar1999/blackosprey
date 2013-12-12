#!/usr/bin/python

import psycopg2, sys

infile = sys.argv[1]
print infile
huc = infile.split('_')[1]

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

measuretype = dict([('00060', 'discharge'), ('00065', 'height')])
measurestat = dict([('00001', 'maximum'), ('00002', 'minimum'), ('00003', 'mean'), ('00006', 'sum')])

f = open(infile, 'r')
i = 0 # Can't enumerate because of a variable number of comment lines
for line in f.readlines():
    # Skip the comments
    if not "#" in line:
        if i == 0:
            # Figure out the columns
            headline = line
            headlinelist = headline.replace('\n','').split('\t')
            dbcol = ['huc_8_num']
            for h in headlinelist:
                if h == 'agency_cd' or h == 'site_no' or h == 'datetime':
                    dbcol.append(h)
                else:
                    mtypecode, mstatcode = h.split('_')[1:3]
                    mtype = measuretype[mtypecode]
                    mstat = measurestat[mstatcode]
                    if "_cd" in h:
                        cd = '_qual_code'
                    else:
                        cd = ''
                    dbcol.append("""%s_%s%s""" % (mtype, mstat, cd))
                    #print dbcol
        elif i == 1:
            # this is a mystery line, do nothing
            pass
        else:
            # do the database loading
            dbvalues = """','""".join(line.replace('\n','').split('\t'))
            sql = """INSERT INTO usgs_stream_gauge_daily (%s) VALUES (%s,'%s');""" % (','.join(dbcol), huc, dbvalues)
            cursor.execute(sql)
        i += 1

f.close()
db.commit()
cursor.close()
db.close()
