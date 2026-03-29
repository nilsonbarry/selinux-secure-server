#!/bin/bash

echo "Installing packages..."
yum install -y httpd mariadb-server policycoreutils-python-utils

echo "Starting services..."
systemctl enable --now httpd
systemctl enable --now mariadb

echo "Creating directories..."
mkdir -p /srv/secure_site/upload
mkdir -p /data/mysql

echo "Creating test webpage..."
echo "<h1>Secure SELinux Server</h1>" > /srv/secure_site/index.html

echo "Configuring Apache..."
sed -i 's#/var/www/html#/srv/secure_site#g' /etc/httpd/conf/httpd.conf

echo "Setting SELinux contexts..."
semanage fcontext -a -t httpd_sys_content_t "/srv/secure_site(/.*)?"
restorecon -Rv /srv/secure_site

echo "Setting upload directory writable..."
semanage fcontext -a -t httpd_sys_rw_content_t "/srv/secure_site/upload(/.*)?"
restorecon -Rv /srv/secure_site/upload

echo "Configuring MariaDB SELinux context..."
semanage fcontext -a -t mysqld_db_t "/data/mysql(/.*)?"
restorecon -Rv /data/mysql

echo "Allow Apache network connections..."
setsebool -P httpd_can_network_connect 1

echo "Restarting services..."
systemctl restart httpd
systemctl restart mariadb

echo "Done! Server is ready."
