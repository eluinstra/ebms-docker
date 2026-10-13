FROM ibm-semeru-runtimes:open-21-jre
ARG EBMS_VERSION=
ARG EBMS_SERVER=ebms-server-${EBMS_VERSION}
ARG LOG4J2=log4j2.xml
ARG START=start.sh
ARG USER=user
ENV WORKDIR=/home/$USER
ENV JAVA_ARGS="-Dlog4j.configurationFile=$LOG4J2"
LABEL maintainer="eluinstra@luin.dev"
LABEL version=nl.clockwork.ebms.server.version=$EBMS_VERSION
WORKDIR $WORKDIR
RUN groupadd --system $USER && \
useradd --system -g $USER $USER && \
apt update && \
apt install zip -y && \
touch ebms-server.properties && \
curl -OL https://github.com/eluinstra/ebms-core/releases/download/ebms-core-${EBMS_VERSION}/${EBMS_SERVER}.jar && \
unzip -p ${EBMS_SERVER}.jar $LOG4J2 > $LOG4J2 && \
sed -i 's/ref="File"/ref="Console"/g' $LOG4J2 && \
printf "#!/bin/sh\n" > $START && \
printf "java \$JAVA_ARGS -cp \${CLASSPATH:+\$CLASSPATH:}${EBMS_SERVER}.jar nl.clockwork.ebms.server.embedded.startup.StartEmbedded \$@" >> $START && \
chmod u+x $START && \
chown -R $USER:$USER $WORKDIR
USER $USER:$USER
#ENTRYPOINT ["./$START"]
#EXPOSE 8080 8888
