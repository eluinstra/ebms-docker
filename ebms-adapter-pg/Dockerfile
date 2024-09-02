FROM eluinstra/ebms-adapter-bin:2.17.5
ARG POSTGRES_DRIVER=postgresql-42.2.14.jar
ENV CLASSPATH "${POSTGRES_DRIVER}:"
ENV ebms_jdbc_driverClassName org.postgresql.Driver
ENV ebms_jdbc_url jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username ebms
ENV ebms_jdbc_password ebms
RUN wget https://jdbc.postgresql.org/download/$POSTGRES_DRIVER -O $POSTGRES_DRIVER
#ENTRYPOINT ["./start.sh"]
#EXPOSE 8080 8888 5432
