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


