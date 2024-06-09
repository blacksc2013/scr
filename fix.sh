#!/bin/bash

# Exit on any error
set -e

# Define variables
DOMAIN="your_domain.com"
WEB_ROOT="/var/www/html"
PHP_VERSION="7.4"

# Install Nginx
echo "Installing Nginx..."
sudo apt-get update
sudo apt-get install -y nginx

# Install PHP and necessary extensions
echo "Installing PHP and necessary extensions..."
sudo apt-get install -y php$PHP_VERSION php$PHP_VERSION-fpm php$PHP_VERSION-mysql

# Configure Nginx for WordPress
echo "Configuring Nginx for WordPress..."
cat <<EOL | sudo tee /etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    server_name $DOMAIN;

    root $WEB_ROOT;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$PHP_VERSION-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    # Log files
    access_log /var/log/nginx/$DOMAIN.access.log;
    error_log /var/log/nginx/$DOMAIN.error.log;
}
EOL

# Enable the Nginx configuration
echo "Enabling the Nginx configuration..."
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Test Nginx configuration and restart
echo "Testing Nginx configuration and restarting..."
sudo nginx -t
sudo systemctl restart nginx

# Ensure PHP-FPM is running
echo "Ensuring PHP-FPM is running..."
sudo systemctl start php$PHP_VERSION-fpm
sudo systemctl enable php$PHP_VERSION-fpm

# Set correct permissions for the web root
echo "Setting correct permissions for the web root..."
sudo chown -R www-data:www-data $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT

echo "Nginx configuration for WordPress has been completed successfully."
