#!/usr/bin/env bash

# Source .env
export $(grep -v '^#' .docker.env | xargs)
export $(grep -v '^#' .env | xargs)

if [ ! "$(docker ps -a | grep -e ${MASTER_SERVER} -e ${SLAVE_SERVER})" ]; then
    echo 'Replication containers do not exist!!!'
    exit 1
fi

if [ ! "$(docker container inspect -f '{{.State.Status}}' ${SLAVE_SERVER})" = "running" ]; then
    code=$(docker container inspect -f '{{.State.ExitCode}}' ${SLAVE_SERVER})
    echo "Replication is not running.... Exited with code $code"
    exit 1
fi

execSQL() {
    docker exec $1 mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "$2"
}

status=$(execSQL ${SLAVE_SERVER} "SHOW SLAVE STATUS \G")
echo "$status" | egrep 'Master_Host:|Master_Port:|Slave_(IO|SQL)_Running:|Seconds_Behind_Master:|Last_.*_Error:' | grep -v "Error: $"
if echo "$status" | grep -qs "Slave_IO_Running: Yes" || echo "$status" | grep -qs "Slave_SQL_Running: Yes" || echo "$status" | grep -qs "Seconds_Behind_Master: 0"; then
    echo "[INFO]: Replication is okay!!!"
else
    echo "[WARNING]: Replication is not working!!!"
fi
