import psycopg2, sys

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()

if len(sys.argv) > 1:
    states = [(sys.argv[1],)]
else:
    sql = """WITH states AS (SELECT DISTINCT state FROM avaricosa_point UNION SELECT DISTINCT state FROM avaricosa_polygon UNION SELECT DISTINCT state FROM avaricosa_line) SELECT DISTINCT state FROM states;"""
    cursor.execute(sql)
    states = cursor.fetchall()
for s in states:
    print s[0]
    # Update points...
    # Intersection first
    # sql = """UPDATE avaricosa_point SET nhd_permanent_=nhd.nhd_flowline_{0}.gnis_name FROM nhd.nhd_flowline_{0} WHERE ST_Intersects(avaricosa_point.geom, nhd.nhd_flowline_{0}.geom) AND avaricosa_point.waterway IS NULL AND avaricosa_point.state = '{0}';""".format(s[0])
    # cursor.execute(sql)
    sql = """UPDATE avaricosa_point SET nhd_permanent_=nhd.nhd_flowline_{0}.permanent_ FROM nhd.nhd_flowline_{0} WHERE ST_Intersects(avaricosa_point.geom, nhd.nhd_flowline_{0}.geom) AND avaricosa_point.nhd_permanent_ IS NULL AND avaricosa_point.state = '{0}';""".format(s[0])
    cursor.execute(sql)
    # Then by proximity
    sql = """WITH index_query AS (SELECT st_distance(n.geom, a.geom) AS distance, ap_id, gnis_name, n.permanent_ FROM avaricosa_point a, nhd.nhd_flowline_{0} n WHERE state = '{0}' and a.nhd_permanent_ IS NULL ORDER BY st_distance(n.geom, a.geom)), closest_streams AS (SELECT DISTINCT ON (ap_id) ap_id, gnis_name, distance, permanent_ FROM index_query ORDER BY ap_id, distance) UPDATE avaricosa_point SET nhd_permanent_ = CASE WHEN avaricosa_point.nhd_permanent_ IS NULL THEN closest_streams.permanent_ ELSE avaricosa_point.nhd_permanent_ END FROM closest_streams WHERE closest_streams.ap_id=avaricosa_point.ap_id AND avaricosa_point.state = '{0}' AND avaricosa_point.nhd_permanent_ IS NULL RETURNING avaricosa_point.nhd_permanent_, avaricosa_point.ap_id, avaricosa_point.state;""".format(s[0])
    cursor.execute(sql)
    db.commit()
    
    # Now polygons...
    sql = """WITH poly_intersect AS (SELECT ap_id, CASE WHEN count(distinct n.permanent_) > 1 THEN 'Multiple: '::text || array_to_string(array_agg(distinct n.permanent_), ', ') ELSE min(distinct n.permanent_) END AS nhd_permanent_ FROM avaricosa_polygon a, nhd_flowline_{0} n WHERE state = '{0}' and ST_Intersects(a.geom, n.geom) GROUP BY ap_id order by ap_id) UPDATE avaricosa_polygon SET nhd_permanent_ = CASE WHEN avaricosa_polygon.nhd_permanent_ IS NULL THEN poly_intersect.nhd_permanent_ ELSE avaricosa_polygon.nhd_permanent_ END FROM poly_intersect WHERE avaricosa_polygon.ap_id = poly_intersect.ap_id AND avaricosa_polygon.state = '{0}';""".format(s[0])
    cursor.execute(sql)
    sql = """WITH index_query AS (SELECT st_distance(n.geom, a.geom) AS distance, ap_id, gnis_name, n.permanent_ FROM avaricosa_polygon a, nhd.nhd_flowline_{0} n WHERE state = '{0}' and a.nhd_permanent_ IS NULL ORDER BY st_distance(n.geom, a.geom)), closest_streams AS (SELECT DISTINCT ON (ap_id) ap_id, gnis_name, distance, permanent_ FROM index_query ORDER BY ap_id, distance) UPDATE avaricosa_polygon SET nhd_permanent_ = CASE WHEN avaricosa_polygon.nhd_permanent_ IS NULL THEN closest_streams.permanent_ ELSE avaricosa_polygon.nhd_permanent_ END FROM closest_streams WHERE closest_streams.ap_id=avaricosa_polygon.ap_id AND avaricosa_polygon.state = '{0}' AND avaricosa_polygon.nhd_permanent_ IS NULL RETURNING avaricosa_polygon.nhd_permanent_, avaricosa_polygon.ap_id, avaricosa_polygon.state;""".format(s[0])
    cursor.execute(sql)
    db.commit()


