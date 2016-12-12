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
echo -n "${gold}Creating new nginx configuration file${default}"
  composer create-project slim/slim-skeleton $INITDIR/www
test_for_success $? 'allow'

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

