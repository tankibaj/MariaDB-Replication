#!/usr/bin/env bash

# Source .env
export $(grep -v '^#' .docker.env | xargs)
export $(grep -v '^#' .env | xargs)

sendEmail() {
    curl --request POST \
        --url https://api.sendgrid.com/v3/mail/send \
        --header 'Authorization: Bearer ${SENDGRID_API_KEY}' \
        --header 'Content-Type: application/json' \
        --data '{"personalizations":[{"to":[{"email":"devops@example.com","name":"DevOps"}],"subject":"WARNING, REPLICATION BROKEN"}],"content": [{"type": "text/plain", "value": "Hi! Please check mariadb replication ASAP!!!"}],"from":{"email":"replication@example.com","name":"Replication"}}'
}

if [ ! "$(docker ps -a | grep -e ${MASTER_SERVER} -e ${SLAVE_SERVER})" ]; then
    logger -t REPLICATION Replication containers do not exist
    exit 1
fi

if [ ! "$(/usr/bin/docker container inspect -f '{{.State.Status}}' ${SLAVE_SERVER})" = "running" ]; then
   code=$(/usr/bin/docker container inspect -f '{{.State.ExitCode}}' ${SLAVE_SERVER})
   logger -t REPLICATION Replication is not running.... Exited with code $code
   exit 1
fi

execSQL() {
    /usr/bin/docker exec -t $1 mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "$2"
}

checkStatus() {
    status=$(execSQL ${SLAVE_SERVER} "SHOW SLAVE STATUS \G")
    if echo "$status" | grep -qs "Slave_IO_Running: Yes" || echo "$status" | grep -qs "Slave_SQL_Running: Yes" || echo "$status" | grep -qs "Seconds_Behind_Master: 0"; then
        return 0
    fi
    return 1
}

if checkStatus; then
    logger -t REPLICATION Replication status is okay
else
    logger -t REPLICATION Replication is not working
    # Please set sendgrid api key, before you enable emailing
    # sendEmail
fi
