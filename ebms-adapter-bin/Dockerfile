FROM openjdk:8-jre-alpine
ARG EBMS_VERSION=2.17.3
ENV WORKDIR /home/user
LABEL maintainer="eluinstra@luin.dev"
LABEL version=$EBMS_VERSION
WORKDIR $WORKDIR
RUN addgroup -S user && \
adduser -S user -G user && \
touch ebms-admin.embedded.properties && \
wget https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/ebms-admin-${EBMS_VERSION}.jar -O ebms-admin-${EBMS_VERSION}.jar && \
unzip -p ebms-admin-${EBMS_VERSION}.jar log4j2.xml > log4j2.xml && \
sed -i 's/ref="File"/ref="Console"/g' log4j2.xml && \
printf "#!/bin/sh\n" > start.sh && \
printf "java \$JAVA_ARGS -cp ebms-admin-${EBMS_VERSION}.jar nl.clockwork.ebms.admin.StartEmbedded \$@" >> start.sh && \
chmod u+x start.sh && \
chown -R user:user $WORKDIR
USER user:user
#VOLUME $WORKDIR/logs
#EXPOSE 8080 8888
#ENTRYPOINT ["./start.sh"]

