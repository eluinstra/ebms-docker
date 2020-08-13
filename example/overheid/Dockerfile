FROM ebms-adapter-bin:2.17.3-M1
ENV EBMS_VERSION 2.17.3-M1
ENV POSTGRES_DRIVER postgresql-42.2.14.jar
ENV JAVA_ARGS "-Dlog4j.configurationFile=log4j2.xml"
ENV CLASSPATH "postgresql-42.2.14.jar:"
ENV ebms_port 8088
ENV https_verifyHostnames false
ENV jms_broker_start true
ENV eventListener_type=JMS
ENV ebms_jdbc_update true
ENV ebms_jdbc_driverClassName org.postgresql.Driver
ENV ebms_jdbc_url jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username postgres
ENV ebms_jdbc_password posrgres
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.14.jar -O postgresql-42.2.14.jar && \
mkdir data
EXPOSE 8000 8088 61616
ENTRYPOINT ["./start.sh"]
CMD ["-port","8000","-ssl","-soap"]
#VOLUME $WORKDIR/data
