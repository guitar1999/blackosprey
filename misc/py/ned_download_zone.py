lon = [-84, -80, -75, -70, -66]
lat = [36, 40, 45, 47.5]

for i in range(len(lon)-1):
	for j in range(len(lat)-1):
		sql = "INSERT INTO ned_download_zone (geom) VALUES (ST_GeomFromText('POLYGON((%s %s, %s %s, %s %s, %s %s, %s %s))',4326));" % (lon[i], lat[j], lon[i], lat[j+1], lon[i+1], lat[j+1], lon[i+1], lat[j], lon[i], lat[j])
		print sql
