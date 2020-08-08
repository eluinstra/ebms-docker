FROM openjdk:8-jre-alpine
ARG EBMS_VERSION=2.17.2
ENV WORKDIR /home/user
LABEL maintainer="eluinstra@luin.dev" \
version=$EBMS_VERSION
WORKDIR $WORKDIR
#COPY log4j2.xml $WORKDIR
RUN addgroup -S user && \
adduser -S user -G user && \
wget https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${EBMS_VERSION}/ebms-admin-${EBMS_VERSION}.jar -O ebms-admin-${EBMS_VERSION}.jar && \
mkdir logs && \
chown -R user:user $WORKDIR
USER user:user
#VOLUME $WORKDIR/logs
#EXPOSE 8080 8888
#ENTRYPOINT ["./start.sh"]

