import psycopg2

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()


for g in ['point', 'line', 'polygon']:
    print g
    # Update points...
    # Intersection first
    sql = """WITH name_query AS (SELECT ap_id, CASE WHEN char_length(name) = 1 THEN namelsad WHEN name LIKE '%,%' THEN regexp_replace(split_part(name, ', ', 2), '^ ', '') ELSE name END AS outname FROM baselayer_tiger_subcounty b, avaricosa_{0} a WHERE ST_Intersects(b.geom, a.geom) AND a.town IS NULL ORDER BY ap_id), list_query AS (SELECT ap_id, CASE WHEN count(distinct outname) > 1 THEN array_to_string(array_agg(distinct outname), ', ') ELSE min(outname) END AS townname FROM name_query GROUP BY ap_id) UPDATE avaricosa_{0} SET town = townname FROM list_query WHERE avaricosa_{0}.ap_id = list_query.ap_id AND avaricosa_{0}.town IS NULL;""".format(g)
    #cursor.execute(sql)
    #db.commit()
    print(sql)
 