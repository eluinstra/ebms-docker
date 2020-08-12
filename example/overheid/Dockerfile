FROM ebms-adapter-bin:2.17.3-M1
ENV EBMS_VERSION 2.17.3-M1
ENV JAVA_ARGS "-Dlog4j.configurationFile=log4j2.xml"
ENV ebms_port 8088
ENV https_verifyHostnames false
ENV jms_broker_start true
ENV eventListener_type=JMS
ENV ebms_jdbc_update true
ENV ebms_jdbc_url jdbc:hsqldb:hsql://localhost:9000/ebms
RUN mkdir hsqldb && \
mkdir data
EXPOSE 8000 8088 61616
ENTRYPOINT ["./start.sh"]
CMD ["-port","8000","-ssl","-hsqldb","-soap"]
#VOLUME $WORKDIR/hsqldb
#VOLUME $WORKDIR/data
