#!/bin/bash

# Define variables
SSL_CERTIFICATE_FILE="/etc/apache2/ssl/certificate.cert"
SSL_INTERMEDIATE_FILE="/etc/apache2/ssl/intermediate.pem"
SSL_PRIVATE_KEY_FILE="/etc/apache2/ssl/private.pem"
APACHE_CONFIG_FILE="/etc/apache2/sites-available/wordpress-ssl.conf"
DOMAIN="aloteknisyen.net"  # Change this to your domain

# Create directory for SSL certificates if it doesn't exist
echo "Creating directory for SSL certificates..."
sudo mkdir -p /etc/apache2/ssl

# Copy SSL certificate files
echo "Copying SSL certificate files..."
sudo cp /path/to/certificate.cert $SSL_CERTIFICATE_FILE
sudo cp /path/to/intermediate.pem $SSL_INTERMEDIATE_FILE
sudo cp /path/to/private.pem $SSL_PRIVATE_KEY_FILE

# Create Apache SSL configuration file
echo "Creating Apache SSL configuration..."
sudo bash -c "cat > $APACHE_CONFIG_FILE <<EOF
<VirtualHost *:443>
    ServerAdmin webmaster@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN

    DocumentRoot /var/www/html/wordpress

    SSLEngine on
    SSLCertificateFile $SSL_CERTIFICATE_FILE
    SSLCertificateKeyFile $SSL_PRIVATE_KEY_FILE
    SSLCertificateChainFile $SSL_INTERMEDIATE_FILE

    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN

    Redirect permanent / https://$DOMAIN/
</VirtualHost>
EOF"

# Enable SSL module and new site configuration
echo "Enabling SSL module and site configuration..."
sudo a2enmod ssl
sudo a2ensite wordpress-ssl.conf

# Reload Apache to apply changes
echo "Reloading Apache..."
sudo systemctl reload apache2

echo "SSL installation completed successfully!"
