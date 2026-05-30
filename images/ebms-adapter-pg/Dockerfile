ARG EBMS_VERSION=
FROM eluinstra/ebms-adapter-bin:${EBMS_VERSION}
ARG EBMS_VERSION=
ARG EBMS_CACHE_TYPE="PLUGIN"
ARG EBMS_CACHE_PLUGIN=ebms-hazelcast-cache-plugin-${EBMS_VERSION}.jar
ARG EBMS_POSTGRES_PLUGIN=ebms-postgres-db-plugin-${EBMS_VERSION}.jar
ENV CLASSPATH="${EBMS_CACHE_PLUGIN}:${EBMS_POSTGRES_PLUGIN}"
ENV cache_type=${EBMS_CACHE_TYPE}
ENV ebms_jdbc_driverClassName=org.postgresql.Driver
ENV ebms_jdbc_url=jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username=ebms
ENV ebms_jdbc_password=ebms
RUN curl -OL https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/${EBMS_CACHE_PLUGIN} && \
curl -OL https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/${EBMS_POSTGRES_PLUGIN}
#ENTRYPOINT ["./start.sh"]
#EXPOSE 8080 8888 5432
