#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

docker manifest create $REPO/ebms-adapter-bin:$EBMS_VERSION \
  --amend $REPO/ebms-adapter-bin:$EBMS_VERSION-amd64 \
  --amend $REPO/ebms-adapter-bin:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-bin:$EBMS_VERSION

docker manifest rm $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION
docker manifest create $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION \
  $REPO/ebms-adapter-bin:$EBMS_VERSION-amd64 \
  $REPO/ebms-adapter-bin:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION

docker manifest rm $REPO/ebms-adapter-bin:latest
docker manifest create $REPO/ebms-adapter-bin:latest \
  $REPO/ebms-adapter-bin:$EBMS_VERSION-amd64 \
  $REPO/ebms-adapter-bin:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-bin:latest

docker manifest create $REPO/ebms-adapter-pg:$EBMS_VERSION \
  --amend $REPO/ebms-adapter-pg:$EBMS_VERSION-amd64 \
  --amend $REPO/ebms-adapter-pg:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-pg:$EBMS_VERSION

docker manifest rm $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION
docker manifest create $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION \
  $REPO/ebms-adapter-pg:$EBMS_VERSION-amd64 \
  $REPO/ebms-adapter-pg:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION

docker manifest rm $REPO/ebms-adapter-pg:latest
docker manifest create $REPO/ebms-adapter-pg:latest \
  $REPO/ebms-adapter-pg:$EBMS_VERSION-amd64 \
  $REPO/ebms-adapter-pg:$EBMS_VERSION-arm64
docker manifest push $REPO/ebms-adapter-pg:latest
