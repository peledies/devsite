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

source $SCRIPTPATH/build_vagrantfile.sh

# Update permissions
echo_start
echo -n "${gold}Updating storage and cache permissions${default}"
  chmod -R 777 $INITDIR/storage
  chmod -R 777 $INITDIR/bootstrap/cache
test_for_success $?

# Start Vagrant
vagrant up