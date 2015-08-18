#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

syslogger_tag=""

if [ -n "${SYSLOGGER_TAG}" ]; then
  syslogger_tag=" -t "${SYSLOGGER_TAG}
fi

syslogger_command=""

if [ -n "${SYSLOGGER}" ]; then
  syslogger_command="logger "${syslogger_tag}
fi

source /opt/rsnapshot/rsnapshot.sh

if [ "$1" = 'rsnapshot' ]; then
  exec rsnapshot $backup_interval
fi

exec "$@"
