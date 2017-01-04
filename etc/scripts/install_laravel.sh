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

# Vagrantfile API/syntax version. Don't touch!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "pinwheel-development/centos-minimal-6_5"
  config.vm.box_url = "http://vagrant.sdicgdev.com/pinwheel-development-centos-6-5.box"
  
  config.vm.network :forwarded_port, host: 4567, guest: 80
  config.vm.network "private_network", ip: "192.168.2.2"
  config.vm.provision :shell, :path => "bootstrap.sh"
end
EOF
test_for_success $?

# Remove tmp directory
echo_start
echo -n "${gold}Removing tmp directory${default}"
  rm -rf tmp
test_for_success $?

# Start Vagrant
vagrant up