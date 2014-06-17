import psycopg2, sys
from dateutil import parser
from dateutil.relativedelta import relativedelta

state = sys.argv[1]
geom = sys.argv[2]

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

if not state == 'NULL':
    sql = """SELECT ap_id, first_obs, last_obs, last_survey FROM avaricosa_{0};""".format(geom)
else:
    sql = """SELECT ap_id, first_obs, last_obs, last_survey FROM avaricosa_{0} WHERE state = '{1}';""".format(geom, state)
cursor.execute(sql)

for apid, fo, lo, ls in cursor.fetchall():
    dfo = dlo = dls = ''
    dfo = parsedate(fo)
    dlo = parsedate(lo)
    dls = parsedate(ls)
    if dfo:
        sql = """UPDATE avaricosa_{0} SET first_obs_date = '{1}' WHERE ap_id = {2};""".format(geom, dfo, apid)
        cursor.execute(sql)
    if dlo:
        sql = """UPDATE avaricosa_{0} SET last_obs_date = '{1}' WHERE ap_id = {2};""".format(geom, dlo, apid)
        cursor.execute(sql)
    if dls:
        sql = """UPDATE avaricosa_{0} SET last_survey_date = '{1}' WHERE ap_id = {2};""".format(geom, dls, apid)
        cursor.execute(sql)

db.commit()

cursor.close()
db.close()