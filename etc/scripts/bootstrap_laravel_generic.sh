#! /usr/bin/env bash

###
#
# install_mysql.sh
#
# This script assumes your Vagrantfile has been configured to map the root of
# your application to /vagrant and that your web root is the "public" folder
# (Laravel standard).  Standard and error output is sent to
# $vagrant_build_log during provisioning.
#
###

# Variables
DBHOST=localhost
DBNAME=$1
DBUSER=$1
DBPASSWD=SECRET

vagrant_build_log=/var/www/vm_build.log

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install base packages ---\n"
apt-get -y install build-essential python-software-properties >> $vagrant_build_log 2>&1

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

# MySQL setup for development purposes ONLY
echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

apt-get -y install mysql-server >> $vagrant_build_log 2>&1

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> $vagrant_build_log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to '$DBUSER'@'%' identified by '$DBPASSWD'" >> $vagrant_build_log 2>&1
sed -i '/skip-external-locking/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i '/bind-address/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart >> $vagrant_build_log 2>&1

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php apache2 libapache2-mod-php php-curl php-gd php-mysql php-gettext >> $vagrant_build_log 2>&1

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite >> $vagrant_build_log 2>&1

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo -e "\n--- Removing Ubuntu's default landing page ---\n"
rm /var/www/html/index.html

echo -e "\n--- Updating webroot to /var/www/html/public ---\n"
sed -i s/.*Document.*/"DocumentRoot \/var\/www\/html\/public"/g /etc/apache2/sites-available/000-default.conf 

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart >> $vagrant_build_log 2>&1