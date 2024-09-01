#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

cd $BASE_DIR/ebms-adapter-bin/
docker build \
  --build-arg EBMS_VERSION=${EBMS_VERSION} \
  -t ${REPO}ebms-adapter-bin:$EBMS_VERSION \
  -t ${REPO}ebms-adapter-bin:$EBMS_MAJOR_VERSION \
  -t ${REPO}ebms-adapter-bin:latest \
  .

cd $BASE_DIR/ebms-adapter-pg/
docker build \
  --build-arg POSTGRES_DRIVER=postgresql-42.7.4.jar \
  -t ${REPO}ebms-adapter-pg:$EBMS_VERSION \
  -t ${REPO}ebms-adapter-pg:$EBMS_MAJOR_VERSION \
  -t ${REPO}ebms-adapter-pg:latest \
  .

cd $BASE_DIR/activemq/
docker build \
  --build-arg ACTIVEMQ_VERSION=5.15.13 \
  -t ${REPO}activemq:5.15.13 \
  -t ${REPO}activemq:latest \
  .
