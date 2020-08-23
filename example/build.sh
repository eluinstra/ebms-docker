#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
# export REPO=eluinstra/
export EBMS_VERSION=2.17.3

cd $BASE_DIR/../ebms-adapter-bin/
docker build -t ${REPO}ebms-adapter-bin:$EBMS_VERSION .

cd $BASE_DIR/digipoort/
docker build -t ${REPO}ebms-adapter-digipoort:$EBMS_VERSION .

cd $BASE_DIR/overheid/
docker build -t ${REPO}ebms-adapter-overheid:$EBMS_VERSION .

# docker run -i --rm postgres cat /usr/share/postgresql/postgresql.conf.sample > postgres.conf
# enable max_prepared_transactions and set to 64

# cd ~/ebms/example/
# docker-compose up

