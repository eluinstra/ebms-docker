#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

cp ~/ebms/ebms-admin/target/ebms-admin-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-bin/

cp ~/.m2/repository/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar  $BASE_DIR/ebms-adapter-pg/
cp ~/ebms/ebms-core/ignite/target/ebms-ignite-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-pg/
cp ~/ebms/ebms-core/ehcache/target/ebms-ehcache-${EBMS_VERSION}.jar $BASE_DIR/ebms-adapter-pg/
