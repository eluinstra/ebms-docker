ARG EBMS_VERSION=2.17.1.1
FROM ebms/ebms-adapter-bin:${EBMS_VERSION}
ENV EBMS_VERSION=2.17.1.1
RUN mkdir hsqldb && \
printf "ebms.ssl=true\nkeystore.type=PKCS12\nhttps.verifyHostnames=false" > ebms-admin.embedded.properties && \
printf "#!/bin/sh\n" > start.sh && \
printf "java -cp ebms-admin-${EBMS_VERSION}.jar nl.clockwork.ebms.admin.StartEmbedded \$@" >> start.sh && \
#printf "java -Dlog4j.configurationFile=log4j2.xml -cp ebms-admin-${EBMS_VERSION}.jar nl.clockwork.ebms.admin.StartEmbedded \$@" >> start.sh && \
chmod u+x start.sh
EXPOSE 8080 8888
ENTRYPOINT ["./start.sh"]
CMD ["-hsqldb","-updateDb","-soap"]
#VOLUME $WORKDIR/hsqldb
