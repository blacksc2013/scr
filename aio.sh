#!/bin/bash

# Update package list and install dependencies
echo "Updating package list..."
sudo apt update

echo "Installing dependencies..."
sudo apt install -y apache2 php php-mysql libapache2-mod-php php-xml php-curl php-zip php-gd php-mbstring mysql-server wget unzip dos2unix

# Secure MySQL installation
echo "Securing MySQL installation..."
sudo mysql_secure_installation

# Set MySQL root password and create database for WordPress
MYSQL_ROOT_PASSWORD="your_mysql_root_password"
WORDPRESS_DB_NAME="wordpress"
WORDPRESS_DB_USER="wordpressuser"
WORDPRESS_DB_PASSWORD="your_wordpress_db_password"

echo "Creating WordPress database and user..."
sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
CREATE DATABASE $WORDPRESS_DB_NAME;
CREATE USER '$WORDPRESS_DB_USER'@'localhost' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Download and extract WordPress
echo "Downloading WordPress..."
wget https://wordpress.org/latest.zip -O /tmp/latest.zip

echo "Extracting WordPress..."
unzip /tmp/latest.zip -d /tmp

# Configure WordPress
echo "Configuring WordPress..."
sudo mv /tmp/wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Create Apache virtual host for WordPress
echo "Creating Apache virtual host..."
cat <<EOF | sudo tee /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Disable the default Apache site and enable the WordPress site
echo "Disabling default Apache site and enabling WordPress site..."
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

# Configure WordPress wp-config.php
echo "Configuring wp-config.php..."
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wordpress/wp-config.php

# Generate secure salts for WordPress
echo "Generating secure salts..."
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > /tmp/wp_salts
sed -i '/AUTH_KEY/d' /var/www/html/wordpress/wp-config.php
sed -i '/SECURE_AUTH_KEY/d' /var/www/html/wordpress/wp-config.php
sed -i '/LOGGED_IN_KEY/d' /var/www/html/wordpress/wp-config.php
sed -i '/NONCE_KEY/d' /var/www/html/wordpress/wp-config.php
sed -i '/AUTH_SALT/d' /var/www/html/wordpress/wp-config.php
sed -i '/SECURE_AUTH_SALT/d' /var/www/html/wordpress/wp-config.php
sed -i '/LOGGED_IN_SALT/d' /var/www/html/wordpress/wp-config.php
sed -i '/NONCE_SALT/d' /var/www/html/wordpress/wp-config.php
sed -i '/#@-/r /tmp/wp_salts' /var/www/html/wordpress/wp-config.php

# Download and install WooCommerce
echo "Installing WooCommerce..."
cd /var/www/html/wordpress/wp-content/plugins
wget https://downloads.wordpress.org/plugin/woocommerce.latest-stable.zip
unzip woocommerce.latest-stable.zip
rm woocommerce.latest-stable.zip

# Set appropriate permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Restart Apache to apply all changes
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "Installation completed successfully!"
echo "You can now complete the WordPress setup by visiting your server's IP address or domain name in your web browser."
