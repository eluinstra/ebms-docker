#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

docker image push -a ${REPO}ebms-adapter-bin
docker image push -a ${REPO}ebms-adapter-pg
