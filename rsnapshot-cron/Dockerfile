FROM blacklabelops/rsnapshot
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install toolset
RUN yum install -y \
    vi \
    cronie && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /usr/bin/cron.d

COPY docker-entrypoint.sh /usr/bin/cron.d/docker-entrypoint.sh

RUN chown -R $CONTAINER_UID:$CONTAINER_GID /usr/bin/cron.d && \
    chmod ug+x /usr/bin/cron.d/*.sh

ENV CRON_HOURLY=
ENV CRON_DAILY=
ENV CRON_WEEKLY=
ENV CRON_MONTHLY=

ENTRYPOINT ["/usr/bin/cron.d/docker-entrypoint.sh"]
VOLUME ["${VOLUME_DIRECTORY}"]
CMD ["cron"]
