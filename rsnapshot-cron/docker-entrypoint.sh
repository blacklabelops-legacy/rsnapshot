#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

#!/bin/bash -x
#
# A helper script for ENTRYPOINT.
#

set -e

source /opt/rsnapshot/rsnapshot.sh

cron_rsnapshot_hourly="@hourly"

if [ -n "${CRON_HOURLY}" ]; then
  cron_rsnapshot_hourly=${CRON_HOURLY}
fi

cron_rsnapshot_daily="@daily"

if [ -n "${CRON_DAILY}" ]; then
  cron_rsnapshot_daily=${CRON_DAILY}
fi

cron_rsnapshot_weekly="@weekly"

if [ -n "${CRON_WEEKLY}" ]; then
  cron_rsnapshot_weekly=${CRON_WEEKLY}
fi

cron_rsnapshot_monthly="@monthly"

if [ -n "${CRON_MONTHLY}" ]; then
  cron_rsnapshot_monthly=${CRON_MONTHLY}
fi

cron_debug="sch"

if [ -n "${CRON_DEBUG}" ]; then
  cron_debug=${CRON_DEBUG}
fi

cronlog_command=""

if [ -n "${CRON_LOG_FILE}" ]; then
  cronlog_command=" 2>&1 | tee -a "${CRON_LOG_FILE}
fi

crontab <<EOF
PATH=/opt/rsnapshot:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
${cron_rsnapshot_hourly} /usr/bin/rsnapshot hourly ${cronlog_command}
${cron_rsnapshot_daily} /usr/bin/rsnapshot daily ${cronlog_command}
${cron_rsnapshot_weekly} /usr/bin/rsnapshot weekly ${cronlog_command}
${cron_rsnapshot_monthly} /usr/bin/rsnapshot monthly ${cronlog_command}
EOF

crontab -l

log_command=""

if [ -n "${LOG_FILE}" ]; then
  log_command=" 2>&1 | tee -a "${LOG_FILE}
fi

if [ "$1" = 'cron' ]; then
  croncommand="crond -n -x "${cron_debug}${log_command}
  bash -c "${croncommand}"
fi

exec "$@"
