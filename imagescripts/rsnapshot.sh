#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

cp /opt/rsnapshot/rsnapshot.conf /etc/rsnapshot.conf

syslogger_tag=""

if [ -n "${SYSLOGGER_TAG}" ]; then
  syslogger_tag=" -t "${SYSLOGGER_TAG}
fi

syslogger_command=""

if [ -n "${SYSLOGGER}" ]; then
  syslogger_command="/usr/bin/logger "${syslogger_tag}
fi

function output()
{
  if [ -n "${SYSLOGGER}" ]; then
    logger ${syslogger_tag} "$@"
  fi
  echo "$@"
}

if [ -n "${LOG_FILE}" ] && [ ! -n "${SYSLOGGER}"]; then
  echo -e logfile'\t'$LOG_FILE >> /etc/rsnapshot.conf
else
  if [ -n "${SYSLOGGER}" ]; then
    echo -e cmd_logger'\t'$syslogger_command >> /etc/rsnapshot.conf
  fi
fi

backup_interval="hourly"

if [ -n "${BACKUP_INTERVAL}" ]; then
  backup_interval=${BACKUP_INTERVAL}
fi

backup_dirs=""

if [ -n "${BACKUP_DIRECTORIES}" ]; then
  backup_dirs=${BACKUP_DIRECTORIES}
fi

SAVEIFS=$IFS
IFS=';'
for dir in $backup_dirs
do
  tab_dir=$(sed -e 's/ [ ]*/\t/g' <<< $dir )
  echo -e backup'\t'$tab_dir >> /etc/rsnapshot.conf
done
IFS=$SAVEIFS

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi
