FROM eluinstra/ebms-adapter-bin:latest
ENV POSTGRES_DRIVER postgresql-42.2.14.jar
ENV JAVA_ARGS "-Dlog4j.configurationFile=log4j2.xml"
ENV CLASSPATH "${POSTGRES_DRIVER}:"
ENV https_verifyHostnames false
ENV jms_broker_start true
ENV eventListener_type=JMS
ENV ebms_jdbc_update true
ENV ebms_jdbc_driverClassName org.postgresql.Driver
ENV ebms_jdbc_url jdbc:postgresql://postgres:5432/ebms
ENV ebms_jdbc_username ebms
ENV ebms_jdbc_password ebms
RUN wget https://jdbc.postgresql.org/download/$POSTGRES_DRIVER -O $POSTGRES_DRIVER
ENTRYPOINT ["./start.sh"]
CMD ["-ssl","-soap"]
EXPOSE 8443 8888 61616
