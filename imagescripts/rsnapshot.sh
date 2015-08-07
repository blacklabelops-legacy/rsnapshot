#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

cp /opt/rsnapshot/rsnapshot.conf /etc/rsnapshot.conf

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
  exec sleep ${DELAYED_START}
fi
