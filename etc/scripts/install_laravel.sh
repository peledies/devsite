#!/bin/bash

pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

project=$1
port=$2

source $SCRIPTPATH/assets/info_box.sh
source $SCRIPTPATH/assets/pretty_tasks.sh

if [ -z "$1" ];then
  echo "${red}You must specify a project name to create.${default}"
  exit 1
fi

  read -p "What local port should Vagrant Map to its port 80: [default 8000]${gold} " port
  port=${port:-8000}

  echo "${green} Which image do you want to use"
  echo " ===================${normal}"
  echo "${magenta} 1 ${default}- SFP Image${default}"
  echo "${magenta} 2 ${default}- Generic (hashicorp/precise64)"

  while true; do
    read -p "${cyan} Select an option from the list above: ${gold}" answer
    case $answer in
      1 ) clear; image='sfp'; break;;
      2 ) clear; image='hashi'; break;;

      * ) echo "Please select a valid option.";;
    esac
  done

  if [ "$image" == "sfp" ]
    then
    use_image='config.vm.box = "kacomp_v4"
config.vm.box_url = "http://dash.sfp.cc/kacomp_v4.box"'
  else 
    use_image='config.vm.box = "hashicorp/precise64"
config.vm.box_url = "http://files.vagrantup.com/precise64.box"'
  fi

# Clone the current laravel repo
echo_start
echo -n "${gold}Creating laravel project with composer${default}"
  composer create-project --prefer-dist laravel/laravel tmp/ > /dev/null 2>&1
test_for_success $?

# Move files from tmp directory
echo_start
echo -n "${gold}Moving files from tmp directory${default}"
  mv tmp/* .
test_for_success $?

# Create new nginx server configuration
echo_start
echo -n "${gold}Creating Vagrant configuration file${default}"

cat <<EOF > $INITDIR/Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ${use_image}
  config.vm.network :forwarded_port, guest: 80, host: ${port}

  config.vm.synced_folder "./public", "/home/fujita/public_html"
  config.vm.synced_folder "./app", "/home/fujita/app"
  config.vm.synced_folder "./bootstrap", "/home/fujita/bootstrap"
  config.vm.synced_folder "./config", "/home/fujita/config"
  config.vm.synced_folder "./database", "/home/fujita/database"
  config.vm.synced_folder "./resources", "/home/fujita/resources"
  config.vm.synced_folder "./routes", "/home/fujita/routes"
  config.vm.synced_folder "./storage", "/home/fujita/storage"
  config.vm.synced_folder "./vendor", "/home/fujita/vendor"
  config.vm.synced_folder "./etc", "/home/fujita/"

$bashlaunch = <<SCRIPT
    cp /etc/httpd/conf/httpd.conf /tmp/httptmp
    sed -e "s/#EnableSendfile off/EnableSendfile off/" /tmp/httptmp
    cat /tmp/httptmp > /etc/httpd/conf/httpd.conf
    mkdir /home/fujita/public_html
    /etc/init.d/httpd restart
SCRIPT
  config.vm.provision "shell",
   inline: $bashlaunch

end
EOF
test_for_success $?


# Move files from tmp directory
echo_start
echo -n "${gold}Updating storage and cache permissions${default}"
  chmod 777 storage
  chmod 777 bootstrap/cache
test_for_success $?

# Move files from tmp directory
echo_start
echo -n "${gold}Creating Environment file and APP KEY${default}"
  echo "APP_KEY=" > .env
  php artisan key:generate > /dev/null 2>&1
test_for_success $?

# Remove tmp directory
echo_start
echo -n "${gold}Removing tmp directory${default}"
  rm -rf tmp
test_for_success $?

# Start Vagrant
vagrant up