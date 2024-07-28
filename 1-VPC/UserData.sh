#!/bin/bash
sudo apt update -y
sudo apt install -y httpd
sudo service httpd start
sudo chkconfig httpd on
echo "Hello World Welcome to Cloud Convo. This is server 1"
/var/www/html/index.html
