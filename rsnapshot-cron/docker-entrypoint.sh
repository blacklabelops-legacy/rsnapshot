#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

#!/bin/bash -x
#
# A helper script for ENTRYPOINT.
#

set -e

syslogger_tag=""

if [ -n "${SYSLOGGER_TAG}" ]; then
  syslogger_tag=" -t "${SYSLOGGER_TAG}
fi

syslogger_command=""

if [ -n "${SYSLOGGER}" ]; then
  syslogger_command="logger "${syslogger_tag}
fi

function output()
{
  if [ -n "${SYSLOGGER}" ]; then
    logger ${syslogger_tag} "$@"
  fi
  echo "$@"
}

source /opt/rsnapshot/rsnapshot.sh

cron_rsnapshot_hourly="20 * * * *"

if [ -n "${CRON_HOURLY}" ]; then
  cron_rsnapshot_hourly=${CRON_HOURLY}
fi

cron_rsnapshot_daily="30 1 * * *"

if [ -n "${CRON_DAILY}" ]; then
  cron_rsnapshot_daily=${CRON_DAILY}
fi

cron_rsnapshot_weekly="40 2 * * 5"

if [ -n "${CRON_WEEKLY}" ]; then
  cron_rsnapshot_weekly=${CRON_WEEKLY}
fi

cron_rsnapshot_monthly="50 3 1 * *"

if [ -n "${CRON_MONTHLY}" ]; then
  cron_rsnapshot_monthly=${CRON_MONTHLY}
fi

cronlog_command=""

if [ -n "${LOGROTATE_LOGFILE}" ] && [ ! -n "${SYSLOGGER}"]; then
  cronlog_command=" 2>&1 | tee -a "${logrotate_cronlogfile}${LOGROTATE_LOGFILE}
else
  if [ -n "${SYSLOGGER}" ]; then
    cronlog_command=" 2>&1 | "${syslogger_command}
  fi
fi

crontab <<EOF
PATH=/opt/rsnapshot:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
${cron_rsnapshot_hourly} /usr/bin/rsnapshot hourly ${cronlog_command}
${cron_rsnapshot_daily} /usr/bin/rsnapshot daily ${cronlog_command}
${cron_rsnapshot_weekly} /usr/bin/rsnapshot weekly ${cronlog_command}
${cron_rsnapshot_monthly} /usr/bin/rsnapshot monthly ${cronlog_command}
EOF

crontab -l

# ----- Cron Start ------

log_command=""

if [ -n "${LOG_FILE}" ] && [ ! -n "${SYSLOGGER}"]; then
 log_command=" 2>&1 | tee -a "${LOG_FILE}
 touch ${LOG_FILE}
else
  if [ -n "${SYSLOGGER}" ]; then
    log_command=" 2>&1 | "${syslogger_command}
  fi
fi

cron_debug=""

if [ -n "${CRON_DEBUG}" ]; then
  cron_debug=" -x "${CRON_DEBUG}
fi

if [ "$1" = 'cron' ]; then
  croncommand="crond -n"${cron_debug}${log_command}
  bash -c "${croncommand}"
fi

exec "$@"
