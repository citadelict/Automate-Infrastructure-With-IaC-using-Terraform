#!/bin/bash
mkdir /var/www/
sudo mount -t efs -o tls,accesspoint=fsap-02b31c27a545f57e8 fs-0142678e946eb3ed4:/ /var/www/
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
yum module reset php -y
yum module enable php:remi-7.4 -y
yum install -y php php-common php-mbstring php-opcache php-intl php-xml php-gd php-curl php-mysqlnd php-fpm php-json
systemctl start php-fpm
systemctl enable php-fpm
git clone https://github.com/citadelict/tooling2.git
mkdir /var/www/html
sudo cp -rf tooling2/html/*  /var/www/html/
cd tooling2
mysql -h citatech-database.cb42aocm8t1r.eu-central-1.rds.amazonaws.com -u admin -p toolingdb < tooling-db.sql
cd /home/ec2-user
sudo touch healthstatus
cd /var/www/html
sudo sed -i "s/$db = mysqli_connect('mysql.tooling.svc.cluster.local', 'admin', 'admin', 'tooling');/$db = mysqli_connect('citatech-database.cb42aocm8t1r.eu-central-1.rds.amazonaws.com', 'admin', 'guessWhat232', 'toolingdb');/g" functions.php
chcon -t httpd_sys_rw_content_t /var/www/html/ -R
sudo systemctl restart httpd
sudo systemctl status httpd