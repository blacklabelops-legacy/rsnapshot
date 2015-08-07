#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

source /opt/rsnapshot/rsnapshot.sh

if [ "$1" = 'rsnapshot' ]; then
  exec rsnapshot $backup_interval
fi

exec "$@"
