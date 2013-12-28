import sys

fname = sys.argv[1]
gtype = sys.argv[2] #polygon,point,line

f = open(fname, 'r')
o = open(fname + '.sh', 'w')
o.write('''#!/bin/bash\n''')

for i, line in enumerate(f.readlines()):
    if i == 0:
        continue
    state, shp, id, wid, wname, obs_first, obs_last, survey_last, pop_cond, loc_qual, extirp, comm1, comm2 = line.replace('\n','').split(',')
    shp = shp + '.shp'
    fielddict = dict([('state', """'%s'""" % state), ('id', id), ('first_obs', obs_first), ('last_obs', obs_last), ('last_survey', survey_last), ('pop_condition', pop_cond), ('location_quality', loc_qual), ('extirpated', extirp), ('comments1', comm1), ('comments2', comm2)])
    db_col = []
    shp_col = []
    for k in fielddict.keys():
        if fielddict[k] != '':
            db_col.append(k)
            shp_col.append(fielddict[k].lower())
    db_col_txt = ','.join(db_col)
    shp_col_txt = ','.join(shp_col)
    o.write('## %s\n' % (state))
    o.write('sf=$(find /Volumes/BlackOsprey/GIS_Data/States/ -iname %s)\n' % (shp))
    o.write('shp2pgsql -s 4326 $sf avaricosa.temp_%s | psql -d blackosprey\n' % (state))
    o.write('''psql -d blackosprey -c "INSERT INTO avaricosa.avaricosa_%s (orig_file,%s,geom) SELECT '%s', %s, geom FROM avaricosa.temp_%s;"\n''' % (gtype, db_col_txt, shp, shp_col_txt, state))
    o.write('''psql -d blackosprey -c "DROP TABLE avaricosa.temp_%s;"\n''' % (state))
    o.write('\n')

o.write('## Final updates\n')
o.write('''psql -d blackosprey -c "UPDATE avaricosa.avaricosa_%s SET huc_8_num = nhd_hu8_watersheds.huc_8_num FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_%s.geom);"\n''' % (gtype, gtype))
o.write('''psql -d blackosprey -c "UPDATE avaricosa.avaricosa_%s SET huc_8_name = nhd_hu8_watersheds.hu_8_name FROM nhd_hu8_watersheds WHERE ST_Intersects(nhd_hu8_watersheds.geom, avaricosa.avaricosa_%s.geom);"\n''' % (gtype, gtype))
o.close()
