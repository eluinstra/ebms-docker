#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. ../env.sh

cd $BASE_DIR/../../ebms-adapter-bin/
docker build --build-arg EBMS_VERSION=${EBMS_VERSION} -t ${REPO}ebms-adapter-bin:$EBMS_VERSION -t ${REPO}ebms-adapter-bin:latest .

cd $BASE_DIR/../digipoort/
docker build -t ${REPO}ebms-adapter-digipoort:$EBMS_VERSION -t ${REPO}ebms-adapter-digipoort:latest .

cd $BASE_DIR/overheid/
docker build -t ${REPO}ebms-adapter-overheid:$EBMS_VERSION -t ${REPO}ebms-adapter-overheid:latest .

# cd $BASE_DIR
# docker-compose up

