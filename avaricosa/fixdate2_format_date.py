import psycopg2
from dateutil import parser
from dateutil.relativedelta import relativedelta

def parsedate(f):
    try:
        d = parser.parse(f).date()
        if d.year > 2014:
            d = d - relativedelta(years=100)
        return d
    except Exception, msg:
        print msg

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

sql = """SELECT ap_id, first_obs, last_obs, last_survey FROM avaricosa_polygon;"""
cursor.execute(sql)

for apid, fo, lo, ls in cursor.fetchall():
    dfo = dlo = dls = ''
    dfo = parsedate(fo)
    dlo = parsedate(lo)
    dls = parsedate(ls)
    if dfo:
        sql = """UPDATE avaricosa_polygon SET first_obs_date = '{0}' WHERE ap_id = {1};""".format(dfo, apid)
        cursor.execute(sql)
    if dlo:
        sql = """UPDATE avaricosa_polygon SET last_obs_date = '{0}' WHERE ap_id = {1};""".format(dlo, apid)
        cursor.execute(sql)
    if dls:
        sql = """UPDATE avaricosa_polygon SET last_survey_date = '{0}' WHERE ap_id = {1};""".format(dls, apid)
        cursor.execute(sql)

db.commit()

cursor.close()
db.close()