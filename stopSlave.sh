#!/usr/bin/env bash

# Source .env
export $(grep -v '^#' .docker.env | xargs)
export $(grep -v '^#' .env | xargs)

if [ ! "$(docker ps -a | grep -e ${MASTER_SERVER} -e ${SLAVE_SERVER})" ]; then
    echo 'Replication containers do not exist!!!'
    exit 1
fi

docker stop ${SLAVE_SERVER}