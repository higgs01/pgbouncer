#!/bin/bash

set -euo pipefail

PGBOUNCER_CONFIG_DIR=/etc/pgbouncer/runtime
PGBOUNCER_CONFIG_INPUT_DIR=/etc/pgbouncer/input

PGBOUNCER_CONFIG_FILE=pgbouncer.ini
PGBOUNCER_USERLIST=userlist.txt

if [ ! -f ${PGBOUNCER_CONFIG_INPUT_DIR}/${PGBOUNCER_CONFIG_FILE} ]; then
    echo "ERROR: failed to find pgbouncer.ini at ${PGBOUNCER_CONFIG_INPUT_DIR}/${PGBOUNCER_CONFIG_FILE}"
    exit 1
fi

envsubst < ${PGBOUNCER_CONFIG_INPUT_DIR}/${PGBOUNCER_CONFIG_FILE} > ${PGBOUNCER_CONFIG_DIR}/${PGBOUNCER_CONFIG_FILE}
envsubst < ${PGBOUNCER_CONFIG_INPUT_DIR}/${PGBOUNCER_USERLIST} > ${PGBOUNCER_CONFIG_DIR}/${PGBOUNCER_USERLIST}

touch /var/log/pgbouncer/pgbouncer_config_watcher.txt
tail -n 0 -f /var/log/pgbouncer/pgbouncer_config_watcher.txt &

/config-watcher.sh ${PGBOUNCER_CONFIG_INPUT_DIR}/${PGBOUNCER_CONFIG_FILE} ${PGBOUNCER_CONFIG_DIR}/${PGBOUNCER_CONFIG_FILE} >> /var/log/pgbouncer/pgbouncer_config_watcher.txt &
/config-watcher.sh ${PGBOUNCER_CONFIG_INPUT_DIR}/${PGBOUNCER_USERLIST} ${PGBOUNCER_CONFIG_DIR}/${PGBOUNCER_USERLIST} >> /var/log/pgbouncer/pgbouncer_config_watcher.txt &

echo "waiting..."
sleep 1

echo "starting pgbouncer..."
exec "$@"