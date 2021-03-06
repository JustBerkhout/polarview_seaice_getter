#!/bin/bash


ACQ_DATE=$1 #capture first cmd arg expected as a valid date formatted YYYY-MM-DD
ACQ_MONTH=${ACQ_DATE:0:4}${ACQ_DATE:5:2}


#capture second cmd arg, expected as valid existing detination directory, defaults to currentdir/downloads
if [ -n "$2" ]; then
  DEST_DIR=$2
else
  DEST_DIR=${BASH_SOURCE%/*}/downloads
fi
TEMP_DIR=${BASH_SOURCE%/*}/tmp


SECTOR_POLYGON_3031="Polygon ((733009.87813705112785101 1262405.90123603213578463, 2263022.56028026062995195 3909386.016730937641114, 3222916.44831687491387129 3205463.83217075373977423, 3921021.09416168462485075 2268840.0989956334233284, 4386424.19139155838638544 1198412.97536692442372441, 4543497.73670663964003325 -23270.15486149396747351, 4392241.73010693211108446 -1122784.97206707019358873, 3915203.55544631090015173 -2280475.17642637994140387, 3193828.75474000629037619 -3222916.44831687398254871, 2257205.02156488690525293 -3944291.24902317766100168, 802820.34272153209894896 -1372939.13682812638580799, 733009.87813705112785101 1262405.90123603213578463))"

echo "ACQ_DATE = $ACQ_DATE" 
echo "ACQ_MONTH = $ACQ_MONTH" 

wget "http://geos.polarview.aq/geoserver/polarview/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=polarview:vw_last200s1subsets&srsName=EPSG:4326&outputFormat=csv&cql_filter=acqtime>="$ACQ_DATE"T00:00:00.000 AND acqtime<="$ACQ_DATE"T23:59:59.999 AND INTERSECTS(geom, $SECTOR_POLYGON_3031)"  -O - | tail -n +2 | awk -F "\"*,\"*" '{print $2}' |  sed -e 's/.tif//g' > $TEMP_DIR/basenames

sed "s|$|.tif.tar.gz|g" $TEMP_DIR/basenames > $TEMP_DIR/tifs
sed "s|$|.jpg|g" $TEMP_DIR/basenames > $TEMP_DIR/jpgs

wget --timestamping --base 'http://www.polarview.aq/images/106_S1jpgsmall/'$ACQ_MONTH'/' -i $TEMP_DIR/jpgs --directory-prefix="$DEST_DIR"
wget --timestamping --base 'http://www.polarview.aq/images/104_S1geotiff/' -i $TEMP_DIR/tifs --directory-prefix="$DEST_DIR"
