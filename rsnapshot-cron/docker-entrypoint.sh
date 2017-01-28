#!/bin/bash -x
#
# A helper script for ENTRYPOINT.
#

set -e

if [ "$1" = 'rsnapshotd' ]; then

  source /usr/bin/rsnapshot.d/rsnapshot.sh

  cron_rsnapshot_hourly="0 20 * * * *"

  if [ -n "${CRON_HOURLY}" ]; then
    cron_rsnapshot_hourly=${CRON_HOURLY}
  fi

  cron_rsnapshot_daily="0 30 1 * * *"

  if [ -n "${CRON_DAILY}" ]; then
    cron_rsnapshot_daily=${CRON_DAILY}
  fi

  cron_rsnapshot_weekly="0 40 2 * * 5"

  if [ -n "${CRON_WEEKLY}" ]; then
    cron_rsnapshot_weekly=${CRON_WEEKLY}
  fi

  cron_rsnapshot_monthly="0 50 4 1 * *"

  if [ -n "${CRON_MONTHLY}" ]; then
    cron_rsnapshot_monthly=${CRON_MONTHLY}
  fi

  configfile="/root/.jobber"

  if [ ! -f "${configfile}" ]; then
    touch ${configfile}
  fi

  cat > ${configfile} <<_EOF_
---
_EOF_
  
  [ "$hourly_times" -gt 0 ] && cat >> ${configfile} <<_EOF_
- name: Hourly
  cmd: /usr/bin/rsnapshot hourly
  time: '${cron_rsnapshot_hourly}'
  onError: Continue
  notifyOnError: false
  notifyOnFailure: false

_EOF_
  
  [ "$daily_times" -gt 0 ] && cat >> ${configfile} <<_EOF_
- name: Daily
  cmd: /usr/bin/rsnapshot daily
  time: '${cron_rsnapshot_daily}'
  onError: Continue
  notifyOnError: false
  notifyOnFailure: false

_EOF_
  
  [ "$weekly_times" -gt 0 ] && cat >> ${configfile} <<_EOF_
- name: Weekly
  cmd: /usr/bin/rsnapshot weekly
  time: '${cron_rsnapshot_weekly}'
  onError: Continue
  notifyOnError: false
  notifyOnFailure: false

_EOF_
  
  [ "$monthly_times" -gt 0 ] && cat >> ${configfile} <<_EOF_
- name: Monthly
  cmd: /usr/bin/rsnapshot monthly
  time: '${cron_rsnapshot_monthly}'
  onError: Continue
  notifyOnError: false
  notifyOnFailure: false

_EOF_

  cat $configfile

  # ----- Jobber Cron Start ------

  exec jobberd
fi

exec "$@"
