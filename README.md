

# MariaDB Replication

MariaDB is a free, open-source, and one of the most popular open-source relational database management systems. It is a drop-in replacement for MySQL intended to remain free under the GNU GPL. You will need to increase your MariaDB server's instances and replicate the data on multiple servers when your traffic grows. The Master-Slave replication provides load balancing for the databases. It doesn't use for any failover solution. Master-Slave replication data changes happen on the master server, while the slave server automatically replicates the changes from the master server. This mode will be best suited for data backups.



## Goal

- Create two docker containers with MariaDB server. One will be a Master server, and another will be a Slave server.
- A simple PHP script to test replication.
- Setup a cron job to check replica health at the one-minute interval and keep log into Syslog.
- If replication fails or stops, get a notification via email.



## Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Manage Docker as a non-root user for Linux](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)



## Command and Usage

`./replica <command>`

| Command                  | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `-S, --start, start`     | Run MariaDB master and slave containers.                     |
| `-D, --destroy, destroy` | Destroy everything related to replica.                       |
| `-s, -status, status`    | Replica status.                                              |
| `-SS, --stop-slave`      | Stop MariaDB slave container.                                |
| `-ss, --start-slave`     | Start MariaDB slave container.                               |
| `-d, --daemon, daemon`   | Setup a cron job to check replica health at the one-minute interval. |
| `-DD, --destroy-daemon`  | Destroy cron job for replica health check.                   |
| `-t, --test, test`       | Test replica by inseting data in MariaDB.                    |
| `-T, --stop-test`        | Stop test.                                                   |
| `-l, --log, log`         | Replica health staus log.                                    |
| `-h, --help, help`       | Display help list                                            |



> The test will create a new PHP docker container and a test database titled 'foobar' into the MariaDB master container. It will keep inserting data into the MariaDB master container until you stop the test.

