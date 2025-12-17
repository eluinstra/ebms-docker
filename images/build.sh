#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

cd $BASE_DIR/ebms-adapter-bin/
docker build --no-cache \
  --build-arg EBMS_VERSION=$EBMS_VERSION \
  -t $REPO/ebms-adapter-bin:$EBMS_VERSION \
  -t $REPO/ebms-adapter-bin:$EBMS_VERSION-$ARCH \
  -t $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION-$ARCH \
  -t $REPO/ebms-adapter-bin:latest-$ARCH \
  .

cd $BASE_DIR/ebms-adapter-pg/
docker build --no-cache \
  --build-arg EBMS_VERSION=${EBMS_VERSION} \
  --build-arg POSTGRES_DRIVER=postgresql-$POSTGRES_VERSION.jar \
  -t $REPO/ebms-adapter-pg:$EBMS_VERSION \
  -t $REPO/ebms-adapter-pg:$EBMS_VERSION-$ARCH \
  -t $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION-$ARCH \
  -t $REPO/ebms-adapter-pg:latest-$ARCH \
  .
