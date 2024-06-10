#!/bin/bash

# Define variables for the Nginx configuration file paths
CONFIG_FILE="/etc/nginx/sites-available/your-site.conf"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"

# Add configuration for WordPress default page
cat <<EOL >> $CONFIG_FILE
location / {
    try_files $uri $uri/ /index.php?$args;
}

location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
}

EOL

# Add configuration for wp-admin access
cat <<EOL >> $CONFIG_FILE
location /wp-admin {
    index index.php;
    try_files $uri $uri/ /wp-admin/index.php?$args;
}

location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires max;
    log_not_found off;
}

EOL

# Symlink the configuration file to the sites-enabled directory
ln -s $CONFIG_FILE $NGINX_SITES_ENABLED

# Reload Nginx to apply the changes
systemctl reload nginx
