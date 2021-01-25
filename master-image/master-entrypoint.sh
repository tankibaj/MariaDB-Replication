#!/bin/bash

set -eo pipefail

# Configure MariaDB Master
cat > /etc/mysql/mariadb.conf.d/replication.cnf << EOF
[mysqld]
log-bin
server_id = 1
log-basename = master1
EOF

exec docker-entrypoint.sh "$@"
