FROM ibm-semeru-runtimes:open-11-jre
ARG EBMS_VERSION=
ARG EBMS_ADMIN=ebms-admin-${EBMS_VERSION}
ARG LOG4J2=log4j2.xml
ARG START=start.sh
ARG USER=user
ENV WORKDIR=/home/$USER
ENV JAVA_ARGS="-Dlog4j.configurationFile=$LOG4J2"
LABEL maintainer="eluinstra@luin.dev"
LABEL version=nl.clockwork.ebms.admin.version=$EBMS_VERSION
WORKDIR $WORKDIR
RUN addgroup --system $USER && \
adduser --system --ingroup $USER $USER && \
apt update && \
apt install zip -y && \
touch ebms-admin.embedded.properties && \
curl -OL https://github.com/eluinstra/ebms-admin/releases/download/${EBMS_ADMIN}/${EBMS_ADMIN}.jar && \
unzip -p ${EBMS_ADMIN}.jar $LOG4J2 > $LOG4J2 && \
sed -i 's/ref="File"/ref="Console"/g' $LOG4J2 && \
printf "#!/bin/sh\n" > $START && \
printf "java \$JAVA_ARGS -cp \${CLASSPATH}${EBMS_ADMIN}.jar nl.clockwork.ebms.admin.StartEmbedded \$@" >> $START && \
chmod u+x $START && \
chown -R $USER:$USER $WORKDIR
USER $USER:$USER
#ENTRYPOINT ["./$START"]
#EXPOSE 8080 8888
