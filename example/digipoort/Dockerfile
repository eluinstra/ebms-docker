FROM ebms-adapter-bin:2.17.3-M1
ENV EBMS_VERSION 2.17.3-M1
ENV JAVA_ARGS "-Dlog4j.configurationFile=log4j2.xml"
ENV https_verifyHostnames false
ENV ebms_jdbc_update true
RUN mkdir hsqldb
EXPOSE 8080 8888
ENTRYPOINT ["./start.sh"]
CMD ["-hsqldb","-soap"]
#VOLUME $WORKDIR/hsqldb
