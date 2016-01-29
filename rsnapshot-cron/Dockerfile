FROM blacklabelops/rsnapshot
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install toolset
RUN yum install -y \
    vi \
    cronie && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /usr/bin/cron.d

ENV CRON_HOURLY= \
    CRON_DAILY= \
    CRON_WEEKLY= \
    CRON_MONTHLY=

COPY docker-entrypoint.sh /usr/bin/cron.d/docker-entrypoint.sh
ENTRYPOINT ["/usr/bin/cron.d/docker-entrypoint.sh"]
VOLUME ["${VOLUME_DIRECTORY}"]
CMD ["cron"]
