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

# Create new slim app using composer
echo_start
echo -n "${gold}Cloning latest Phreeze from repo${default}"
  git clone git://github.com/jasonhinkle/phreeze.git www/phreeze
test_for_success $? 'allow'

# Create new nginx server configuration
echo_start
echo -n "${gold}Creating new nginx configuration file${default}"

cat <<EOF > $INITDIR/etc/nginx/sites-enabled/$project.conf
server {
  listen 80;
  server_name $project.local;
  index index.php;
  root /var/www/html/;

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