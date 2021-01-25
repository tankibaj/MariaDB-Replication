#!/usr/bin/env bash

[[ $EUID -ne 0 ]] && echo -e "[Error] Please run as root user to execute the script!" && exit 1

if [ -f /etc/cron.d/mariadb_replication_status ]; then
  echo "[Erro] Job already exist in cron.d"
  exit 1
fi

# Check cron package
if ! dpkg -s cron >/dev/null 2>&1; then
  apt-get install cron
fi

echo
read -p "Enter username to run cron job [root]: " -e -i $USER user
until [[ $(grep -c "^$user" /etc/passwd) == 1 ]]; do
  echo -e "[Error] $user does not exist."
  read -p "Enter username to run cron job [root]: " -e -i $USER user
done

echo
read -p "Enter path to mariadb replication [/home/ubuntu/mariadb-replication]: " -e -i $PWD path
until [[ -d $path ]]; do
  echo -e "[Error] $path does not exist"
  read -p "Enter path to mariadb replication [/home/ubuntu/mariadb-replication]: " -e -i $PWD path
done

chmod +x $path/daemon.sh

echo "SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Start job every 1 minute
* * * * * $user cd $path && bash daemon.sh" >/etc/cron.d/mariadb_replication_status
