### This generates two files. The contents of those files can be copied and pasted
### into the appropriate areas of a QGIS qml file. This generates all 60 cases of
### avaricosa symbology.

years = {'2010':('circle', 3), '2000':('rectangle', 2.5), '1990':('diamond', 3), '1980':('pentagon', '3'), '1970':('triangle', 3), 'Unknown':('regular_star', 3)}
classes = {'A':('0,128,0,255', "Excellent Viability"), 'B':('0,0,200,255', "Good Viability"), 'C':('255,255,0,255', "Fair Viability"), 'D':('215,125,0,255', "Poor Viability"), 'E':('154,50,205,255', "Verified Extant"), 'H':('210,180,140,255', "Historical"), 'X':('255,0,0,255', "Extirpated"), 'F':('255,111,207,255', "Failed to Find"), 'U':('10,10,10,255', "Unrankable"), 'NR':('110,110,110,255', "Not Ranked")}
yord = ['2010', '2000', '1990', '1980', '1970', 'Unknown']
cord = ['A', 'B', 'C', 'D', 'E', 'H', 'F', 'X', 'U', 'NR']
rankfile = '/Volumes/BlackOsprey/GIS_Data/Styles/rank.txt'
symfile = '/Volumes/BlackOsprey/GIS_Data/Styles/sym.txt'
r = open(rankfile, 'w')
s = open(symfile, 'w')
symbol = 0
for y in yord:
    for c in cord:
        if c in ['A', 'B', 'C', 'D']:
            cq = "LIKE '{0}%'".format(c)
        else:
            cq = "= '{0}'".format(c)
        if y == '1970':
        	yq = "&lt;= 1970"
        elif y == 'Unknown':
        	yq = "IS NULL"
        else:
        	yq = "= {0}".format(y)
        ruleout = """<rule filter=" &quot;symbol_last_survey_decade&quot; {0} AND &quot;symbol_pop_cond&quot; {1}" symbol="{2}" label="{3} - {4} ({5})"/>\n""".format(yq, cq, symbol, y, classes[c][1], c)
        #print ruleout
        symout = """\t<symbol alpha="1" type="marker" name="{0}">
\t\t<layer pass="0" class="SimpleMarker" locked="0">
\t\t\t<prop k="angle" v="0"/>
\t\t\t<prop k="color" v="{1}"/>
\t\t\t<prop k="color_border" v="0,0,0,255"/>
\t\t\t<prop k="name" v="{2}"/>
\t\t\t<prop k="offset" v="0,0"/>
\t\t\t<prop k="offset_unit" v="MM"/>
\t\t\t<prop k="outline_width" v="0"/>
\t\t\t<prop k="outline_width_unit" v="MM"/>
\t\t\t<prop k="scale_method" v="area"/>
\t\t\t<prop k="size" v="{3}"/>
\t\t\t<prop k="size_unit" v="MM"/>
\t\t</layer>
\t</symbol>\n""".format(symbol, classes[c][0], years[y][0], years[y][1])
        #print symout
        r.write(ruleout)
        s.write(symout)
        symbol += 1
r.close()
s.close()
