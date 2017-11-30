#!/bin/bash


ACQ_DATE=$1 #capture first cmd arg expected as a valid date formatted YYYY-MM-DD

ACQ_MONTH=${ACQ_DATE:0:4}${ACQ_DATE:5:2}
TEMP_DIR=${BASH_SOURCE%/*}/tmp
DEST_DIR=${BASH_SOURCE%/*}/downloads

echo "ACQ_DATE = $ACQ_DATE" 
echo "ACQ_MONTH = $ACQ_MONTH" 

wget "http://geos.polarview.aq/geoserver/polarview/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=polarview:vw_last200s1subsets&srsName=EPSG:4326&outputFormat=csv&cql_filter=acqtime>="$ACQ_DATE"T00:00:00.000 AND acqtime<="$ACQ_DATE"T23:59:59.999 AND BBOX(geom, 819391.62, 1419227.92, 2262268.85, -3918364.59)"  -O - | tail -n +2 | awk -F "\"*,\"*" '{print $2}' |  sed -e 's/.tif//g' > $TEMP_DIR/basenames

sed "s|$|.tif.tar.gz|g" $TEMP_DIR/basenames > $TEMP_DIR/tifs
sed "s|$|.jpg|g" $TEMP_DIR/basenames > $TEMP_DIR/jpgs


wget --base 'http://www.polarview.aq/images/104_S1geotiff/' -i $TEMP_DIR/tifs --directory-prefix=$DEST_DIR
wget --base 'http://www.polarview.aq/images/106_S1jpgsmall/'$ACQ_MONTH'/' -i $TEMP_DIR/jpgs --directory-prefix=$DEST_DIR
