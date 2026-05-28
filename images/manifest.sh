#!/bin/sh

set -eu

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

create_manifest() {
  target="$1"
  amd64="$2"
  arm64="$3"

  docker buildx imagetools create \
    --tag "$target" \
    "$amd64" \
    "$arm64"
}

create_manifest \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION" \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION-amd64" \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION-arm64"

create_manifest \
  "$REPO/ebms-adapter-bin:$EBMS_MAJOR_VERSION" \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION-amd64" \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION-arm64"

create_manifest \
  "$REPO/ebms-adapter-bin:latest" \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION-amd64" \
  "$REPO/ebms-adapter-bin:$EBMS_VERSION-arm64"

create_manifest \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION" \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION-amd64" \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION-arm64"

create_manifest \
  "$REPO/ebms-adapter-pg:$EBMS_MAJOR_VERSION" \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION-amd64" \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION-arm64"

create_manifest \
  "$REPO/ebms-adapter-pg:latest" \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION-amd64" \
  "$REPO/ebms-adapter-pg:$EBMS_VERSION-arm64"
