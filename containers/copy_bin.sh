#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

export WORK_DIR=$HOME
export WORK_DIR=/workspaces/ebms-2.19.x

cp $WORK_DIR/ebms-admin/target/ebms-admin-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-bin/

cp $HOME/.m2/repository/org/postgresql/postgresql/${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.jar $BASE_DIR/ebms-adapter-pg/
