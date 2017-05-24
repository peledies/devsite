#!/bin/bash
pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`

echo -e "\n -- Configure Vagrant MySql for access -- \n"

password=${1:-secret}

# Set the fujita_f password
echo -e "\n -- Setting Vagrant MySql user fujita_f password to $password -- \n"
  com="mysql -uroot -e \"SET PASSWORD FOR fujita_f@localhost = PASSWORD(\\\"${password}\\\"); FLUSH PRIVILEGES;\""
  vagrant ssh -c "$com" > /dev/null 2>&1

# Grant priveleges to the fujita_f user to access the db from the host db client
echo -e "\n -- Granting Priveleges for external Database access -- \n"
  com="mysql -uroot -e \"GRANT ALL PRIVILEGES ON fujita_f.* TO 'fujita_f'@'%' IDENTIFIED BY \\\"${password}\\\" WITH GRANT OPTION; FLUSH PRIVILEGES;\""
  vagrant ssh -c "$com" > /dev/null 2>&1

echo -e "\n -- Complete -- \n"
