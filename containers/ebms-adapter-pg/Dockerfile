FROM eluinstra/ebms-adapter-bin:2.20.2
ARG EBMS_VERSION=
ARG EBMS_CACHE_TYPE="EHCACHE"
ARG EBMS_CACHE_LIB=ebms-ehcache-${EBMS_VERSION}.jar
ARG POSTGRES_DRIVER=
ENV CLASSPATH="${EBMS_CACHE_LIB}:${POSTGRES_DRIVER}:"
ENV cache_type=${EBMS_CACHE_TYPE}
ENV ebms_jdbc_driverClassName=org.postgresql.Driver
ENV ebms_jdbc_url=jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username=ebms
ENV ebms_jdbc_password=ebms
COPY ${EBMS_CACHE_LIB} .
COPY ${POSTGRES_DRIVER} .
# RUN curl -OL https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/${EBMS_CACHE_LIB}
# RUN curl -OL https://jdbc.postgresql.org/download/${POSTGRES_DRIVER}
#ENTRYPOINT ["./start.sh"]
#EXPOSE 8080 8888 5432
