#!/bin/bash

# Set MySQL root password and WordPress database details
MYSQL_ROOT_PASSWORD="your_mysql_root_password"
WORDPRESS_DB_NAME="wordpress"
WORDPRESS_DB_USER="wordpressuser"

# Remove WordPress files
echo "Removing WordPress files..."
rm -rf /var/www/html/wordpress

# Remove MySQL database and user
echo "Removing WordPress database and user..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
DROP DATABASE $WORDPRESS_DB_NAME;
DROP USER '$WORDPRESS_DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Remove Apache virtual host configuration for WordPress
echo "Removing Apache virtual host configuration..."
a2dissite wordpress.conf
rm /etc/apache2/sites-available/wordpress.conf

# Reload Apache to apply changes
echo "Reloading Apache..."
systemctl reload apache2

# Optional: Uninstall dependencies (use with caution)
echo "Uninstalling dependencies (optional)..."
apt remove -y apache2 php php-mysql libapache2-mod-php php-xml php-curl php-zip php-gd php-mbstring mysql-server wget unzip dos2unix
apt autoremove -y

echo "Cleanup completed successfully!"
