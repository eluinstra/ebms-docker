FROM eluinstra/ebms-adapter-bin:latest
ENV JAVA_ARGS "-Dlog4j.configurationFile=log4j2.xml"
ENV https_verifyHostnames false
ENV ebms_jdbc_update true
RUN mkdir hsqldb
ENTRYPOINT ["./start.sh"]
CMD ["-hsqldb","-soap"]
EXPOSE 8080 8888
#VOLUME $WORKDIR/hsqldb
