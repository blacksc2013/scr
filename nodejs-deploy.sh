#!/bin/bash

# Exit on any error
set -e

# Define project variables
PROJECT_NAME="test-server"
GITHUB_REPO="https://github.com/blacksc2013/test-server.git"
PM2_APP_NAME="test-server"
PM2_LOG_FILE="/var/log/pm2.log"
DOMAIN="example.com"

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y git curl gnupg build-essential

# Install Node.js
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone the repository
echo "Cloning repository from GitHub..."
git clone $GITHUB_REPO $PROJECT_NAME

# Navigate into the project directory
cd $PROJECT_NAME

# Install project dependencies
echo "Installing project dependencies..."
npm install

# Install PM2 globally
echo "Installing PM2 globally..."
sudo npm install -g pm2

# Start the project with PM2
echo "Starting the project with PM2..."
pm2 start npm --name $PM2_APP_NAME -- start

# Set PM2 to start at boot
echo "Setting PM2 to start at boot..."
pm2 startup systemd -u $(whoami) --hp /home/$(whoami)

# Save current PM2 configuration
echo "Saving current PM2 configuration..."
pm2 save

# Set PM2 to log everything
echo "Setting PM2 to log everything..."
pm2 log > $PM2_LOG_FILE 2>&1

# Install Nginx
echo "Installing Nginx..."
sudo apt-get install -y nginx

# Configure Nginx as a reverse proxy
echo "Configuring Nginx as a reverse proxy..."
cat <<EOL | sudo tee /etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:4455;  # Ensure your Node.js app is running on this port
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Enable the Nginx configuration
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Test Nginx configuration and restart
sudo nginx -t
sudo systemctl restart nginx

# Allow Nginx through the firewall
sudo ufw allow 'Nginx Full'

# Install Certbot for SSL (optional)
echo "Installing Certbot for SSL..."
sudo apt-get install -y certbot python3-certbot-nginx

# Obtain SSL certificates for your domain
echo "Obtaining SSL certificates for your domain..."
sudo certbot --nginx -d $DOMAIN

echo "Node.js project setup completed successfully and is accessible at http://$DOMAIN"
