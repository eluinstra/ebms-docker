#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

docker manifest create $REPO/ebms-adapter-bin:$EBMS_VERSION \
  --amend $REPO/ebms-adapter-bin:$EBMS_VERSION-amd64 \
  --amend $REPO/ebms-adapter-bin:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-bin:$EBMS_VERSION

docker manifest create $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION \
  $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION-amd64 \
  $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION-arm64
docker manifest push $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION

docker manifest create $REPO/ebms-adapter-bin:latest \
  $REPO/ebms-adapter-bin:latest-amd64 \
  $REPO/ebms-adapter-bin:latest-arm64
docker manifest push $REPO/ebms-adapter-bin:latest

docker manifest create $REPO/ebms-adapter-pg:$EBMS_VERSION \
  --amend $REPO/ebms-adapter-pg:$EBMS_VERSION-amd64 \
  --amend $REPO/ebms-adapter-pg:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-pg:$EBMS_VERSION

docker manifest create $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION \
  $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION-amd64 \
  $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION-arm64
docker manifest push $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION

docker manifest create $REPO/ebms-adapter-pg:latest \
  $REPO/ebms-adapter-pg:latest-amd64 \
  $REPO/ebms-adapter-pg:latest-arm64
docker manifest push $REPO/ebms-adapter-pg:latest

docker manifest create $REPO/activemq:$ACTIVEMQ_VERSION \
  --amend $REPO/activemq:$ACTIVEMQ_VERSION-amd64 \
  --amend $REPO/activemq:$ACTIVEMQ_VERSION-arm64
docker manifest push $REPO/activemq:$ACTIVEMQ_VERSION

docker manifest create $REPO/activemq:latest \
  $REPO/activemq:latest-amd64 \
  $REPO/activemq:latest-arm64
docker manifest push $REPO/activemq:latest
