FROM openjdk:8-jre-alpine
ARG ACTIVEMQ_VERSION=5.15.13
ARG ACTIVEMQ=apache-activemq-${ACTIVEMQ_VERSION}
ARG USER=user
ARG WORKDIR=/home/$USER
LABEL maintainer="eluinstra@luin.dev"
LABEL version=$ACTIVEMQ_VERSION
WORKDIR $WORKDIR
RUN addgroup -S $USER && \
adduser -S $USER -G $USER && \
touch ebms-admin.embedded.properties && \
wget https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ}-bin.tar.gz -O $ACTIVEMQ-bin.tar.gz && \
tar xzf ${ACTIVEMQ}-bin.tar.gz && \
rm ${ACTIVEMQ}-bin.tar.gz && \
mv $ACTIVEMQ activemq && \
chown -R $USER:$USER $WORKDIR
USER $USER:$USER
ENTRYPOINT ["activemq/bin/activemq"]
CMD ["console"]
#EXPOSE 61616 5672 61613 1883 61614 8161
#VOLUME activemq/data
