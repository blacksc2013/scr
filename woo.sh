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

echo "Installation completed successfully!"
echo "You can now complete the WordPress setup by visiting your server's IP address or domain name in your web browser."