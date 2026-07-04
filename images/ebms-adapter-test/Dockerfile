ARG EBMS_VERSION=0.0.0
FROM eluinstra/ebms-adapter-bin:${EBMS_VERSION}
ARG EBMS_VERSION=0.0.0
ARG EBMS_CACHE_TYPE=DEFAULT
ARG EBMS_H2_PLUGIN=ebms-h2-db-plugin-${EBMS_VERSION}.jar
ENV CLASSPATH="${EBMS_H2_PLUGIN}"
ENV cache_type=${EBMS_CACHE_TYPE}
ENV ebms_jdbc_driverClassName=org.h2.Driver
ENV ebms_jdbc_url=jdbc:h2:file:/home/user/ebms
ENV ebms_jdbc_username=sa
RUN curl -OL https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/${EBMS_H2_PLUGIN}
#ENTRYPOINT ["./start.sh"]
#EXPOSE 8080 8888
