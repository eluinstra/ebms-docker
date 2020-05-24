FROM openjdk:8-jdk-alpine
ARG EBMS_VERSION="2.16.6"
ENV WORKDIR="/home/user"
LABEL version=$EBMS_VERSION
WORKDIR $WORKDIR
RUN addgroup -S user && \
adduser -S user -G user && \
wget https://sourceforge.net/projects/javaebmsadmin/files/ebms-admin-${EBMS_VERSION}.jar/download -O ebms-admin-${EBMS_VERSION}.jar && \
mkdir logs
#USER user:user
#VOLUME $WORKDIR/logs
#EXPOSE 8080 8443
#ENTRYPOINT ["./start.sh"]

