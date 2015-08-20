FROM blacklabelops/centos
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# Propert permissions
ENV CONTAINER_USER rsnapshot
ENV CONTAINER_UID 1000
ENV CONTAINER_GROUP rsnapshot
ENV CONTAINER_GID 1000
ENV VOLUME_DIRECTORY=/snapshots

RUN /usr/sbin/groupadd --gid $CONTAINER_GID $CONTAINER_GROUP && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --create-home --home-dir $VOLUME_DIRECTORY --shell /bin/bash $CONTAINER_GROUP && \
    chown -R $CONTAINER_UID:$CONTAINER_GID $VOLUME_DIRECTORY

# install dev tools
RUN yum install -y \
    epel-release && \
    yum clean all && rm -rf /var/cache/yum/*

# install rsnapshot
COPY configuration/rsnapshot.conf /etc/rsnapshot.conf
COPY imagescripts/docker-entrypoint.sh /usr/bin/rsnapshot.d/docker-entrypoint.sh
COPY imagescripts/rsnapshot.sh /usr/bin/rsnapshot.d/rsnapshot.sh
RUN yum install -y \
    rsnapshot && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /usr/bin/rsnapshot.d && \
    cp /etc/rsnapshot.conf /usr/bin/rsnapshot.d/rsnapshot.conf && \
    chown -R $CONTAINER_UID:$CONTAINER_GID /usr/bin/rsnapshot.d && \
    chown $CONTAINER_UID:$CONTAINER_GID /etc/rsnapshot.conf && \
    chmod ug+x /usr/bin/rsnapshot.d/*.sh

ENV BACKUP_INTERVAL=
ENV BACKUP_DIRECTORIES=
ENV DELAYED_START=

USER $CONTAINER_UID
ENTRYPOINT ["/usr/bin/rsnapshot.d/docker-entrypoint.sh"]
VOLUME ["${VOLUME_DIRECTORY}"]
CMD ["rsnapshot"]
