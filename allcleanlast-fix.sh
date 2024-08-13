#!/bin/bash

# Stop services
echo "Stopping MySQL and Apache services..."
sudo systemctl stop mysql
sudo systemctl stop apache2

# Remove MySQL
echo "Removing MySQL..."
sudo apt-get purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql /var/log/mysql.*
sudo deluser --remove-home mysql
sudo delgroup mysql

# Remove WordPress
echo "Removing WordPress..."
sudo rm -rf /var/www/html/wordpress
sudo rm -rf /var/www/html/wp-content
sudo rm -rf /var/www/html/wp-includes
sudo rm -rf /var/www/html/wp-admin
sudo rm -rf /var/www/html/*.php
sudo rm -rf /var/www/html/*.html

# Remove WooCommerce (already removed with WordPress)

# Remove Apache
echo "Removing Apache..."
sudo apt-get purge -y apache2 apache2-utils apache2-bin apache2.2-common
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf /etc/apache2

# Remove Nginx (if applicable)
echo "Removing Nginx..."
sudo apt-get purge -y nginx nginx-common
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf /etc/nginx

# Remove remaining files in web directory
echo "Removing remaining web files..."
sudo rm -rf /var/www/html

# Remove any additional MySQL databases and users
echo "Removing MySQL databases and users..."
sudo mysql -e "DROP DATABASE IF EXISTS your_database_name;"
sudo mysql -e "DROP USER IF EXISTS 'your_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Reboot system
echo "Rebooting system..."
sudo reboot
