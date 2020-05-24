FROM ebms-adapter-bin:latest
COPY . $WORKDIR
RUN chown -R user:user $WORKDIR && \
chmod u+x start.sh
USER user:user
EXPOSE 8080 8443
ENTRYPOINT ["./start.sh"]
#CMD ["-port","8000","-hsqldb","-soap"]

