#!/bin/bash


echo -n "${gold}Updating Aptitude package list${default}"
  apt update > /dev/null 2>&1


## Install dependencies for laravel

echo -n "${gold}Installing laravel server dependencies ${magenta}[PHP]${default}"
  apt install php php-curl php7.0-mysql php-mcrypt php-gd php-mbstring php7.0-zip php-simplexml -y > /dev/null 2>&1


echo -n "${gold}Installing laravel server dependencies ${magenta}[Apache]${default}"
  apt install apache2 libapache2-mod-php -y > /dev/null 2>&1


## Enable apache modules

echo -n "${gold}Enabling Apache module ${magenta}[rewrite]${default}"
  sudo a2enmod rewrite > /dev/null 2>&1

echo -n "${gold}Enabling Apache module ${magenta}[php7.0]${default}"
  sudo a2enmod php7.0 > /dev/null 2>&1

echo -n "${gold}Disabling Apache module ${magenta}[mpm_event]${default}"
  sudo a2dismod mpm_event > /dev/null 2>&1

echo -n "${gold}Enabling Apache module ${magenta}[mpm_prefork]${default}"
  sudo a2enmod mpm_prefork > /dev/null 2>&1



## Create virtual host file for project

echo -n "${gold}Creating Virualhost file for project${default}"

touch /etc/apache2/sites-available/default.conf
cat <<EOF > /etc/apache2/sites-available/default.conf
<VirtualHost *:80>
        DocumentRoot /var/www/html/public/
        <Directory /var/www/html/>
                Options FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>
EOF


sudo a2ensite default
## Restart apache

echo -n "${gold}Restart Apache${default}"
  sudo service apache2 restart > /dev/null 2>&1

# Disable sendfile
cp /etc/httpd/conf/httpd.conf /tmp/httptmp
sed -e "s/#EnableSendfile off/EnableSendfile off/" /tmp/httptmp
cat /tmp/httptmp > /etc/httpd/conf/httpd.conf                                            