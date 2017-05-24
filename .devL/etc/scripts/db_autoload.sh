#!/bin/bash

pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

# VARIABLES
SQL_PATH=/home/fujita/sql/src
evil_database=fujita_f

# RESET DATABASE
if [ $1 = "reset" ]; then
  echo -e "\n -- DROP EVIL MYSQL DB ${evil_database}"
  mysql -uroot -e "DROP DATABASE IF EXISTS ${evil_database};"
  
  echo -e "\n -- CREATE NEW MYSQL DB ${evil_database}"
  mysql -uroot -e "CREATE DATABASE ${evil_database};"
fi

# IMPORT SQL ALL FILES FROM SOURCE FOLDER
for f in $SQL_PATH/*.sql
do
  echo -e "\n -- Importing MySql dump $f"
  mysql -uroot fujita_f < ${f} > /dev/null 2>&1
done
