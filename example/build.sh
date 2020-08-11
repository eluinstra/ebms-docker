#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`

export EBMS_VERSION=2.17.3-M1

cd $BASE_DIR/../ebms-adapter-bin/
docker build -t ebms-adapter-bin:$EBMS_VERSION .

cd $BASE_DIR/digipoort/
docker build -t ebms-adapter-digipoort:$EBMS_VERSION .

cd $BASE_DIR/overheid/
docker build -t ebms-adapter-overheid:$EBMS_VERSION .

# cd ~/ebms/example/
# docker-compose up

