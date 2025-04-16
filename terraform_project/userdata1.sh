#!/bin/bash
sudo apt-get update
sudo apt install -y apache2
sudo mkdir /var/www/html
systemctl enable apache2
systemctl start apache2

echo "THIS IS MY First instance" >> /var/www/html/index.html







