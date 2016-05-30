#!/usr/bin/env bash

SQLUSER="ranch"
SQLPASS="secret"

# Argument 1 is a username
[ ! -z "$1" ] && SQLUSER=$1

# Argument 2 is a password
[ ! -z "$2" ] && SQLPASS=$2

# Install MySQL

debconf-set-selections <<< "mysql-community-server mysql-community-server/data-dir select ''"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password $SQLPASS"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password $SQLPASS"
apt-get install -y mysql-server

# Configure MySQL Password Lifetime

echo "default_password_lifetime = 0" >> /etc/mysql/my.cnf

# Configure MySQL Remote Access

sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

mysql --user="root" --password="$SQLPASS" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY '$SQLPASS' WITH GRANT OPTION;"
service mysql restart

mysql --user="root" --password="$SQLPASS" -e "CREATE USER '$SQLUSER'@'0.0.0.0' IDENTIFIED BY '$SQLPASS';"
mysql --user="root" --password="$SQLPASS" -e "GRANT ALL ON *.* TO '$SQLUSER'@'0.0.0.0' IDENTIFIED BY '$SQLPASS' WITH GRANT OPTION;"
mysql --user="root" --password="$SQLPASS" -e "GRANT ALL ON *.* TO '$SQLUSER'@'%' IDENTIFIED BY '$SQLPASS' WITH GRANT OPTION;"
mysql --user="root" --password="$SQLPASS" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="$SQLPASS" -e "CREATE DATABASE $SQLUSER;"
service mysql restart

# Add Timezone Support To MySQL

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=$SQLPASS mysql