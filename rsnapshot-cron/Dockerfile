FROM blacklabelops/rsnapshot:alpine
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

#Permissions, set the linux user id and group id
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

# install Jobber
ENV JOBBER_HOME=/opt/jobber
ENV JOBBER_LIB=$JOBBER_HOME/lib
ENV GOPATH=$JOBBER_LIB

RUN export CONTAINER_USER=jenkins && \
    export CONTAINER_GROUP=jenkins && \
    # Add user
    addgroup -g $CONTAINER_GID jobber_client && \
    adduser -u $CONTAINER_UID -G jobber_client -s /bin/bash -S jobber_client && \
    # Instll Jobber
    apk add --update \
      go \
      make \
      git && \
    mkdir -p $JOBBER_HOME && \
    mkdir -p $JOBBER_LIB && \
    cd $JOBBER_LIB && \
    go get github.com/dshearer/jobber && \
    make -C src/github.com/dshearer/jobber build DESTDIR=$JOBBER_HOME && \
    apk del \
      go \
      make \
      git && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

ENV PATH=$PATH:/opt/jobber/lib/bin \
    CRON_HOURLY= \
    CRON_DAILY= \
    CRON_WEEKLY= \
    CRON_MONTHLY=

COPY docker-entrypoint.sh /usr/bin/cron.d/docker-entrypoint.sh
ENTRYPOINT ["/usr/bin/cron.d/docker-entrypoint.sh"]
VOLUME ["${VOLUME_DIRECTORY}"]
CMD ["rsnapshotd"]
