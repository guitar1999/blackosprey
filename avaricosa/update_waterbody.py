import psycopg2

db = psycopg2.connect(host='localhost', database='blackosprey',user='jessebishop')
cursor = db.cursor()


sql = """WITH states AS (SELECT DISTINCT state FROM avaricosa_point UNION SELECT DISTINCT state FROM avaricosa_polygon UNION SELECT DISTINCT state FROM avaricosa_line) SELECT DISTINCT state FROM states;"""
cursor.execute(sql)
states = cursor.fetchall()
for s in states:
    print s[0]
    # Update points...
    # Intersection first
    sql = """UPDATE avaricosa_point SET waterway=nhd.nhd_flowline_{0}.gnis_name FROM nhd.nhd_flowline_{0} WHERE ST_Intersects(avaricosa_point.geom, nhd.nhd_flowline_{0}.geom) AND avaricosa_point.waterway IS NULL AND avaricosa_point.state = '{0}';""".format(s[0])
    cursor.execute(sql)
    sql = """UPDATE avaricosa_point SET reachcode=nhd.nhd_flowline_{0}.reachcode FROM nhd.nhd_flowline_{0} WHERE ST_Intersects(avaricosa_point.geom, nhd.nhd_flowline_{0}.geom) AND avaricosa_point.reachcode IS NULL AND avaricosa_point.state = '{0}';""".format(s[0])
    cursor.execute(sql)
    # Then by proximity
    sql = """WITH index_query AS (SELECT st_distance(n.geom, a.geom) AS distance, ap_id, gnis_name, n.reachcode FROM avaricosa_point a, nhd.nhd_flowline_{0} n WHERE state = '{0}' ORDER BY st_distance(n.geom, a.geom)), closest_streams AS (SELECT DISTINCT ON (ap_id) ap_id, gnis_name, distance, reachcode FROM index_query ORDER BY ap_id, distance) UPDATE avaricosa_point SET waterway = CASE WHEN avaricosa_point.waterway IS NULL THEN closest_streams.gnis_name ELSE avaricosa_point.waterway END, reachcode = CASE WHEN avaricosa_point.reachcode IS NULL THEN closest_streams.reachcode ELSE avaricosa_point.reachcode END FROM closest_streams WHERE closest_streams.ap_id=avaricosa_point.ap_id AND avaricosa_point.state = '{0}' AND (avaricosa_point.waterway IS NULL OR avaricosa_point.reachcode IS NULL) RETURNING avaricosa_point.waterway, avaricosa_point.reachcode, avaricosa_point.ap_id, avaricosa_point.state;""".format(s[0])
    cursor.execute(sql)
    db.commit()
    
    # Now polygons...
    sql = """WITH poly_intersect AS (SELECT ap_id, CASE WHEN count(distinct gnis_name) > 1 THEN 'Multiple: '::text || array_to_string(array_agg(distinct gnis_name), ', ') ELSE min(distinct gnis_name) END AS gnis_name, CASE WHEN count(distinct n.reachcode) > 1 THEN 'Multiple: '::text || array_to_string(array_agg(distinct n.reachcode), ', ') ELSE min(distinct n.reachcode) END AS reachcode FROM avaricosa_polygon a, nhd_flowline_{0} n WHERE state = '{0}' and ST_Intersects(a.geom, n.geom) AND NOT gnis_name IS NULL GROUP BY ap_id order by ap_id) UPDATE avaricosa_polygon SET waterway = CASE WHEN avaricosa_polygon.waterway IS NULL THEN poly_intersect.gnis_name ELSE avaricosa_polygon.waterway END, reachcode = CASE WHEN avaricosa_polygon.reachcode IS NULL THEN poly_intersect.reachcode ELSE avaricosa_polygon.reachcode END FROM poly_intersect WHERE avaricosa_polygon.ap_id = poly_intersect.ap_id AND avaricosa_polygon.state = '{0}';""".format(s[0])
    cursor.execute(sql)
    db.commit()


