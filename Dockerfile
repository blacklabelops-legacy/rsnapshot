FROM blacklabelops/centos
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install rsnapshot
COPY configuration/rsnapshot.conf /etc/rsnapshot.conf
COPY imagescripts/docker-entrypoint.sh /usr/bin/rsnapshot.d/docker-entrypoint.sh
COPY imagescripts/rsnapshot.sh /usr/bin/rsnapshot.d/rsnapshot.sh
RUN yum install -y epel-release && \
    yum install -y rsnapshot && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /usr/bin/rsnapshot.d && \
    cp /etc/rsnapshot.conf /usr/bin/rsnapshot.d/rsnapshot.conf && \
    chmod ug+x /usr/bin/rsnapshot.d/*.sh

ENV BACKUP_INTERVAL= \
    BACKUP_DIRECTORIES= \
    DELAYED_START= \
    VOLUME_DIRECTORY=/snapshots \

ENTRYPOINT ["/usr/bin/rsnapshot.d/docker-entrypoint.sh"]
VOLUME ["${VOLUME_DIRECTORY}"]
CMD ["rsnapshot"]
