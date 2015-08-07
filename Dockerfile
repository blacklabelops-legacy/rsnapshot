FROM blacklabelops/centos
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install dev tools
RUN yum install -y \
    epel-release && \
    yum clean all && rm -rf /var/cache/yum/*

# install rsnapshot
COPY configuration/rsnapshot.conf /etc/rsnapshot.conf
RUN yum install -y \
    rsnapshot && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir /opt/rsnapshot && \
    cp /etc/rsnapshot.conf /opt/rsnapshot/rsnapshot.conf

ENV BACKUP_INTERVAL=
ENV BACKUP_DIRECTORIES=

COPY imagescripts/docker-entrypoint.sh /opt/rsnapshot/docker-entrypoint.sh
COPY imagescripts/rsnapshot.sh /opt/rsnapshot/rsnapshot.sh
ENTRYPOINT ["/opt/rsnapshot/docker-entrypoint.sh"]
VOLUME ["/snapshots"]
CMD ["rsnapshot"]
