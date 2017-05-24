#!/bin/bash
pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

project=$1
version="5.3"

source $SCRIPTPATH/include/info_box.sh
source $SCRIPTPATH/include/pretty_tasks.sh

if [ -z "$1" ];then
  echo "${red}You must specify a project name to create.${default}"
  exit 1
fi

source $SCRIPTPATH/build_apache_vagrantfile.sh

echo "enter 'vagrant up' to start";
