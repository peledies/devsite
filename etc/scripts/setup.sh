#!/bin/bash
pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

project=$1
source $SCRIPTPATH/assets/info_box.sh
source $SCRIPTPATH/assets/pretty_tasks.sh

init_slim_app() {
  source $SCRIPTPATH/slim_app_init.sh $project
  build_docker_containers
}

init_opencart_site() {
  source $SCRIPTPATH/install_opencart.sh $project
  build_docker_containers
}

init_laravel_app() {
  source $SCRIPTPATH/install_laravel.sh $project
}

build_docker_containers(){
  docker-compose build
}

clear

# Ask the user for the existing project they want to add
info_box "New Project Setup"

if [ -z "$1" ];then
  read -p "What is the project name: ${gold}" project
  echo "${default}"
else
  project=$1
fi



_menu () {
  echo "${green}  Choose an Option"
  echo " ===================${normal}"
  echo "${magenta} 1 ${default}- This is a ${red}Slim App (Docker)${default}"
  echo "${magenta} 2 ${default}- This is a ${red}Laravel App (Vagrant)${default}"
  echo "${magenta} 3 ${default}- This is an ${red}Opencart site (Docker)${default}"
  echo "${magenta} x ${default}- Exit"

  while true; do
    read -p "${cyan} Select an option from the list above: ${gold}" answer
    case $answer in
      1 ) clear; init_slim_app; break;;
      2 ) clear; init_laravel_app; break;;
      3 ) clear; init_opencart_site; break;;
      x ) clear; exit; break;;

      * ) echo "Please select a valid option.";;
    esac
  done
}

_menu