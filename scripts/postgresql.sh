#!/usr/bin/env bash

SQLUSER="ranch"
SQLPASS="secret"

# Argument 1 is a username
[ ! -z "$1" ] && SQLUSER=$1

# Argument 2 is a password
[ ! -z "$2" ] && SQLPASS=$2

# Install Postgres

apt-get install -y postgresql-9.5 postgresql-contrib-9.5

# Configure Postgres Remote Access

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.5/main/postgresql.conf
#echo "host    all             all             10.0.2.2/32               md5" | tee -a /etc/postgresql/9.5/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE $SQLUSER LOGIN UNENCRYPTED PASSWORD '$SQLPASS' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=$SQLUSER $SQLUSER
service postgresql restart