FROM blacklabelops/rsnapshot
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install supervisord
RUN yum install -y \
    vi \
    cronie && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /opt/cron

ENV CRON_HOURLY=
ENV CRON_DAILY=
ENV CRON_WEEKLY=
ENV CRON_MONTHLY=

COPY docker-entrypoint.sh /opt/cron/docker-entrypoint.sh
ENTRYPOINT ["/opt/cron/docker-entrypoint.sh"]
VOLUME ["/snapshots"]
CMD ["cron"]
