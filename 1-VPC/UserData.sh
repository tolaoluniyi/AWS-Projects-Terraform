#!/bin/bash
sudo apt update -y
sudo apt install -y httpd
sudo service httpd start
sudo systemctl start httpd
sudo systemctl enable httpd
sudo chkconfig httpd on
echo <h1>"Hello World Welcome to Cloud Convo. This is server 1"</h1> > /var/www/html/index.html
