#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

docker image push $REPO/ebms-adapter-bin:$EBMS_VERSION-$ARCH
docker image push $REPO/ebms-adapter-pg:$EBMS_VERSION-$ARCH
