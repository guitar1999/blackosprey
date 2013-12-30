import psycopg2
db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()
query = "SELECT ap_id, last_obs FROM avaricosa_polygon WHERE NOT last_obs IS NULL;"
cursor.execute(query)
a = cursor.fetchall()

for apid, d in a:
    print d
    if '-' in d:
        year = d.split('-')[0]
        if "s" in year:
            year = year.replace('s','')
    elif '/' in d:
        year = d.split('/')[2]
        if len(year) != 4:
            if year > 13:
                year = "19" + str(year)
            else:
                year = "20" + str(year)
    elif '?' in d:
        year = d.replace('?','')
    elif len(d) == 4 and not 'No' in d:
        year = d
    else:
        year = 'NULL'
    print year
    query = "UPDATE avaricosa_polygon SET last_obs_year = %s WHERE ap_id = %s;" % (year, apid)
    cursor.execute(query)

db.commit()
cursor.close()
db.close()


