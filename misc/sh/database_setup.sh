#!/bin/bash

echo "blackosprey"
createuser -U postgres -l -D -i -R -S -P blackosprey
echo "jessebishop"
createuser -U postgres -l -D -i -R -S -P jessebishop
echo "tinacormier"
createuser -U postgres -l -D -i -R -S -P tinacormier

psql -U postgres -d postgres -c "GRANT blackosprey TO jessebishop;"
psql -U postgres -d postgres -c "GRANT blackosprey TO tinacormier;"

createdb -U postgres -O blackosprey blackosprey

psql -U postgres -d blackosprey -c "CREATE EXTENSION postgis;"
psql -U postgres -d blackosprey -c "CREATE EXTENSION postgis_topology;"

psql -U postgres -d blackosprey -c "GRANT SELECT, INSERT, UPDATE, DELETE ON spatial_ref_sys TO blackosprey;"
psql -U postgres -d blackosprey -c "GRANT SELECT, INSERT, UPDATE, DELETE ON geography_columns TO blackosprey;"
psql -U postgres -d blackosprey -c "GRANT SELECT, INSERT, UPDATE, DELETE ON geometry_columns TO blackosprey;"
psql -U postgres -d blackosprey -c "GRANT SELECT, INSERT, UPDATE, DELETE ON raster_columns TO blackosprey;"
psql -U postgres -d blackosprey -c "GRANT SELECT, INSERT, UPDATE, DELETE ON raster_overviews TO blackosprey;"

psql -U postgres -d blackosprey -c "ALTER DATABASE blackosoprey SET search_path TO public,avaricosa,extent;"
