#!/bin/bash

set -eo pipefail

# Configure MariaDB Slave
cat > /etc/mysql/mariadb.conf.d/replication.cnf << EOF
[mysqld]
log-bin
server_id = 2
EOF

exec docker-entrypoint.sh "$@"
