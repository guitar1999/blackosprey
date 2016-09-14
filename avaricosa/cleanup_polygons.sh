#!/bin/bash

apid=$1
pk=$(psql -h localhost -d blackosprey -t -A -c "SELECT primary_key FROM avaricosa_all_as_point_view WHERE source_geom = 'polygon' AND ap_id = $apid;")
echo $pk

psql -h localhost -d blackosprey -c "DELETE FROM avaricosa_point_1km_buffer WHERE primary_key = '$pk'; INSERT INTO avaricosa_point_1km_buffer (primary_key, geom) SELECT primary_key, geom FROM avaricosa.avaricosa_all_as_point_1km_buffer_view WHERE primary_key = '$pk';"

psql -h localhost -d blackosprey -c "DELETE FROM nhd_flowline_avaricosa_1km_buffer WHERE primary_key = '$pk'; INSERT INTO nhd_flowline_avaricosa_1km_buffer (primary_key, gid, comid, permanent_, fdate, resolution, gnis_id, gnis_name, lengthkm, reachcode, flowdir, wbareacomi, wbarea_per, ftype, fcode, shape_leng, enabled, state, in_huc_12, geom) SELECT a.primary_key, n.gid, n.comid, n.permanent_, n.fdate, n.resolution, n.gnis_id, n.gnis_name, n.lengthkm, n.reachcode, n.flowdir, n.wbareacomi, n.wbarea_per, n.ftype, n.fcode, n.shape_leng, n.enabled, n.state, n.in_huc_12, ST_Force2D(ST_Multi(ST_Intersection(a.geom, n.geom))) FROM avaricosa.avaricosa_point_1km_buffer a, public.nhd_flowline_avaricosa n WHERE a.primary_key = '${pk}' AND ST_Intersects(a.geom, n.geom);"