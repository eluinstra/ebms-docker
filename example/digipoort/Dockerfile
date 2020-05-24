FROM ebms-adapter-bin:latest
COPY . $WORKDIR
RUN chown -R user:user $WORKDIR
RUN chmod u+x start.sh
USER user:user
EXPOSE 8080 8443
ENTRYPOINT ["./start.sh"]
#CMD ["-hsqldb","-soap"]

