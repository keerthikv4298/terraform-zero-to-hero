#!/bin/bash

# Update package list
sudo apt-get update

# Install Apache2
sudo apt-get install -y apache2

# (Optional) Ensure web root exists — but it's already created by apache2 package
sudo mkdir -p /var/www/html

# Enable Apache to start on boot
sudo systemctl enable apache2

# Start Apache service
sudo systemctl start apache2

# Create an index.html file with custom message
echo "THIS IS MY second instance" | sudo tee /var/www/html/index.html > /dev/null
