#!/bin/bash
yum install -y nginx
systemctl start 
systemctl enable nginx
git clone https://github.com/citadelict/citatech-project-config.git
mv /citatech-project-config/reverse.conf /etc/nginx/
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf-distro
cd /etc/nginx/
touch nginx.conf
sed -n 'w nginx.conf' reverse.conf
systemctl restart nginx
rm -rf reverse.conf
rm -rf /citatech-project-config