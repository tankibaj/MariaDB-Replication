#!/usr/bin/env bash

# Source .env
export $(grep -v '^#' .docker.env | xargs)
export $(grep -v '^#' .env | xargs)

if [ "$(docker ps -a | grep -e ${MASTER_SERVER} -e ${SLAVE_SERVER})" ]; then
    echo '[Warning] Replication containers already exist!!!'
    exit 1
fi

# Docker
docker-compose build
echo
echo
docker-compose up -d
echo
echo

getIP() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1
}

execSQL() {
    docker exec $1 mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "$2"
}

importSQL() {
    docker exec -i $1 mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD}
}

until execSQL ${MASTER_SERVER} ";" 2>nul; do
    echo "[Info] Please wait!!! ${MASTER_SERVER} is getting ready!!!"
    sleep 10
done

# Create a new database user for replication
execSQL ${MASTER_SERVER} "CREATE USER '${REPLICATION_USER}'@'%' IDENTIFIED BY '${REPLICATION_PASSWORD}'; FLUSH PRIVILEGES;"

# Grant the replication user full access to the slave server
execSQL ${MASTER_SERVER} "GRANT REPLICATION SLAVE ON *.* TO '${REPLICATION_USER}'@'%'; FLUSH PRIVILEGES;"

echo "[Info] Master has been set up successfully!!!"

until execSQL ${SLAVE_SERVER} ";" 2>nul; do
    echo "[Info] Please wait!!! ${SLAVE_SERVER} is getting ready!!!"
    sleep 10
done

# Configure the slave server to communicate with the master server
execSQL ${SLAVE_SERVER} "RESET MASTER; CHANGE MASTER TO
MASTER_HOST='$(getIP ${MASTER_SERVER})',
MASTER_USER='${REPLICATION_USER}',
MASTER_PASSWORD='${REPLICATION_PASSWORD}',
MASTER_LOG_FILE='$(execSQL ${MASTER_SERVER} "SHOW MASTER STATUS;" | grep -w master1-bin | cut -f 1)',
MASTER_LOG_POS=$(execSQL ${MASTER_SERVER} "SHOW MASTER STATUS;" | grep -w master1-bin | cut -f 2); START SLAVE;"

# Import test SQL file
cat dump.sql | importSQL ${MASTER_SERVER}

echo "[Info] Slave has been set up successfully!!!"

execSQL ${SLAVE_SERVER} "SHOW SLAVE STATUS \G" | egrep 'Master_Host:|Master_Port:|Slave_(IO|SQL)_Running:|Seconds_Behind_Master:|Last_.*_Error:' | grep -v "Error: $"
