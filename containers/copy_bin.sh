#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

# export WORK_DIR=$HOME
export WORK_DIR=/workspaces

cp $WORK_DIR/ebms/ebms-admin/target/ebms-admin-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-bin/

cp $HOME/.m2/repository/org/postgresql/postgresql/${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.jar $BASE_DIR/ebms-adapter-pg/
cp $WORK_DIR/ebms/ebms-core/ignite/target/ebms-ignite-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-pg/
cp $WORK_DIR/ebms/ebms-core/ehcache/target/ebms-ehcache-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-pg/
