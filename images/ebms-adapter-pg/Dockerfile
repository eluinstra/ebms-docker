FROM eluinstra/ebms-adapter-bin:2.20.4
ARG EBMS_VERSION=
ARG EBMS_CACHE_TYPE="PLUGIN"
ARG EBMS_CACHE_LIB=ebms-hazelcast-cache-plugin-${EBMS_VERSION}.jar
ARG POSTGRES_DRIVER=
ENV FLYWAY_VERSION=11.8.2
ENV FLYWAY_POSTGRES_LIB=flyway-database-postgresql-${FLYWAY_VERSION}.jar
ENV CLASSPATH="${EBMS_CACHE_LIB}:${POSTGRES_DRIVER}:${FLYWAY_POSTGRES_LIB}:"
ENV cache_type=${EBMS_CACHE_TYPE}
ENV ebms_jdbc_driverClassName=org.postgresql.Driver
ENV ebms_jdbc_url=jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username=ebms
ENV ebms_jdbc_password=ebms
RUN curl -OL https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/${EBMS_CACHE_LIB}
RUN curl -OL https://jdbc.postgresql.org/download/${POSTGRES_DRIVER}
RUN curl -OL https://repo1.maven.org/maven2/org/flywaydb/flyway-database-postgresql/${FLYWAY_VERSION}/${FLYWAY_POSTGRES_LIB}
#ENTRYPOINT ["./start.sh"]
#EXPOSE 8080 8888 5432
