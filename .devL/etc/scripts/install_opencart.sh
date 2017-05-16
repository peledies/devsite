#!/bin/bash

pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

project=$1
source $SCRIPTPATH/assets/info_box.sh
source $SCRIPTPATH/assets/pretty_tasks.sh

if [ -z "$1" ];then
  echo "${red}You must specify a project name to create.${default}"
  exit 1
fi

# Clone the current opencart repo
echo_start
echo -n "${gold}Cloning the current opencart repo${default}"
  git clone https://github.com/opencart/opencart.git tmp/ > /dev/null 2>&1
test_for_success $?

# Move files from tmp directory
echo_start
echo -n "${gold}Moving files from tmp directory${default}"
  mv tmp/upload/* www/
  mv www/config-dist.php www/config.php
  mv www/admin/config-dist.php www/admin/config.php
test_for_success $?

# Update permissions
echo_start
echo -n "${gold}Updating project permissions${default}"
  chmod 0755 www/system/storage/cache/
  chmod 0755 www/system/storage/logs/
  chmod 0755 www/system/storage/download/
  chmod 0755 www/system/storage/upload/
  chmod 0755 www/system/storage/modification/
  chmod 0755 www/image
  chmod 0755 www/image/cache/
  chmod 0755 www/image/catalog/
  chmod 0755 www/config.php 
  chmod 0755 www/admin/config.php
test_for_success $?

# Create new nginx server configuration
echo_start
echo -n "${gold}Creating new nginx configuration file${default}"

cat <<EOF > $INITDIR/etc/nginx/sites-enabled/$project.conf
server {
  listen 80;
  server_name $project.local;
  index index.php;
  root /var/www/html/public;

  location / {
    try_files \$uri /index.php\$is_args\$args;
  }

  location ~ \.php {
    try_files \$uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)\$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
    fastcgi_index index.php;
    fastcgi_pass php:9000;
  }
}
EOF
test_for_success $?

# Create appropriate php container provisioner
echo_start
echo -n "${gold}Creating PHP7 docker container provisioner${default}"

cat <<EOF > $INITDIR/etc/docker/dockerfile_php_7
FROM php:7.0-fpm

RUN apt-get update

# Install mysqli
RUN docker-php-ext-install mysqli

# Install mcrypt
RUN apt-get install -y libmcrypt-dev
RUN docker-php-ext-install mcrypt

# Install gd
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install gd

# Install zip
RUN docker-php-ext-install zip

# RUN apt-get install libssl-dev -y

CMD ["php-fpm"]
EOF
test_for_success $?

# Create database stub file
echo_start
echo -n "${gold}Creating database stub file${default}"
cat <<EOF > $INITDIR/etc/mysql/$project.sql
create database $project;
EOF
test_for_success $?

# Remove tmp directory
echo_start
echo -n "${gold}Removing tmp directory${default}"
  rm -rf tmp
test_for_success $?

# Restart nginx
docker-compose restart nginx

# Restart php
docker-compose restart php