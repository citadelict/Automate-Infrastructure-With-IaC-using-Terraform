#!/bin/bash
mkdir /var/www/
sudo mount -t efs -o tls,accesspoint=fsap-0a1bfe0a6753accb9 fs-0142678e946eb3ed4:/ /var/www/
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
yum module reset php -y
yum module enable php:remi-7.4 -y
yum install -y php php-common php-mbstring php-opcache php-intl php-xml php-gd php-curl php-mysqlnd php-fpm php-json
systemctl start php-fpm
systemctl enable php-fpm
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
rm -rf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
mkdir /var/www/html/
sudo cp -R /wordpress/* /var/www/html/
cd /var/www/html/
sudo touch healthstatus
sed -i "s/localhost/citatech-database.cb42aocm8t1r.eu-central-1.rds.amazonaws.com/g" wp-config.php 
sed -i "s/username_here/admin/g" wp-config.php 
sed -i "s/password_here/guessWhat232/g" wp-config.php 
sed -i "s/database_name_here/wordpressdb/g" wp-config.php 
chcon -t httpd_sys_rw_content_t /var/www/html/ -R
sudo systemctl restart httpd
sudo systemctl status httpd