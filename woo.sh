# Download and install WooCommerce
echo "Installing WooCommerce..."
cd /var/www/html/wordpress/wp-content/plugins
wget https://downloads.wordpress.org/plugin/woocommerce.latest-stable.zip -O woocommerce.zip
unzip unzip woocommerce.zip -d /var/www/html/wordpress/wp-content/plugins/
rm woocommerce.zip

# Set appropriate permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Restart Apache to apply all changes
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "Installation completed successfully!"
echo "You can now complete the WordPress setup by visiting your server's IP address or domain name in your web browser."
