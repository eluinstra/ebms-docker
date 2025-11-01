#!/bin/sh

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

rm $BASE_DIR/ebms-adapter-bin/ebms-admin-*.jar

rm $BASE_DIR/ebms-adapter-pg/postgresql-*.jar
rm $BASE_DIR/ebms-adapter-pg/ebms-ignite-*.jar
rm $BASE_DIR/ebms-adapter-pg/ebms-ehcache-*.jar
