#!/usr/bin/env bash

echo "Enter the domain for the site you are creating"

read domain

echo "Using $domain as the domain"

# Add directory for site
sudo mkdir -p /var/www/$domain/public

# Add nginx conf file
# TODO: Maybe have this come from a template file
cat <<EOT >> /etc/nginx/sites-available/$domain
server {
        listen   80; ## listen for ipv4; this line is default and implied
        #listen   [::]:80 default ipv6only=on; ## listen for ipv6

        root /var/www/$domain/public;
        index index.php;

        # Make site accessible from http://localhost/
        server_name $domain;
}
EOT

# Sym-link the nginx conf file
sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain

# Restart nginx
sudo service nginx restart