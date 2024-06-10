#!/bin/bash

# Stop Nginx service
sudo systemctl stop nginx

# Remove Nginx packages
sudo apt-get purge nginx nginx-common -y

# Remove Nginx configuration files
sudo apt-get purge nginx-* -y
sudo rm -rf /etc/nginx

# Clean up dependencies
sudo apt-get autoremove -y

# Verify removal
nginx -v
systemctl status nginx

# Optional: Remove Nginx logs and data
sudo rm -rf /var/log/nginx
sudo rm -rf /var/www/html
