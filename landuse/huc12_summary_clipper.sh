#!/bin/bash

infile=$1
d=$(dirname $infile)
f=$(basename $infile)
e=$(echo $f | awk -F '.' '{print $NF}')

echo $f
time gdalwarp -te 851775 868245 2342655 3087885 -tr 30 30 -of GTiff -co "BIGTIFF=YES" -co "COMPRESS=LZW" $infile ${d}/$(basename $f $e)_clip.tif
