FROM eluinstra/ebms-adapter-bin:2.19.5
ARG POSTGRES_DRIVER=
ENV CLASSPATH="${POSTGRES_DRIVER}:"
ENV ebms_jdbc_driverClassName=org.postgresql.Driver
ENV ebms_jdbc_url=jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username=ebms
ENV ebms_jdbc_password=ebms
COPY ${POSTGRES_DRIVER} .
# RUN curl -OL https://jdbc.postgresql.org/download/$POSTGRES_DRIVER
# RUN curl -OL https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/${EBMS_CACHE_LIB}
#ENTRYPOINT ["./start.sh"]
#EXPOSE 8080 8888 5432
