FROM blacklabelops/rsnapshot
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install tools
RUN yum install -y \
    epel-release && \
    yum clean all && rm -rf /var/cache/yum/*

# install supervisord
RUN yum install -y \
    supervisor \
    vi \
    cronie && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /opt/supervisord

ENV CRON_HOURLY=
ENV CRON_DAILY=
ENV CRON_WEEKLY=
ENV CRON_MONTHLY=

COPY docker-entrypoint.sh /opt/supervisord/docker-entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
COPY cron.ini /etc/supervisord.d/cron.ini
ENTRYPOINT ["/opt/supervisord/docker-entrypoint.sh"]
VOLUME ["/snapshots"]
CMD ["supervisord"]
