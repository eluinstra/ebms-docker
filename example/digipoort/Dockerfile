FROM ebms-adapter-bin:2.17.2
ENV EBMS_VERSION 2.17.2
ENV https.verifyHostnames false
ENV ebms.jdbc.update true
RUN mkdir hsqldb && \
printf "" > ebms-admin.embedded.properties && \
printf "#!/bin/sh\n" > start.sh && \
printf "java -cp ebms-admin-${EBMS_VERSION}.jar nl.clockwork.ebms.admin.StartEmbedded \$@" >> start.sh && \
#printf "java -Dlog4j.configurationFile=log4j2.xml -cp ebms-admin-${EBMS_VERSION}.jar nl.clockwork.ebms.admin.StartEmbedded \$@" >> start.sh && \
chmod u+x start.sh
EXPOSE 8080 8888
ENTRYPOINT ["./start.sh"]
CMD ["-hsqldb","-soap"]
#VOLUME $WORKDIR/hsqldb
