read -p "What local port should Vagrant Map to its port 80: [default 8000]${gold} " port
port=${port:-8000}

configure_sfp() {
  use_image='config.vm.box = "kacomp_v4"
config.vm.box_url = "http://dash.sfp.cc/kacomp_v4.box"'

write_vagrantfile_sfp
}

configure_generic() {
  echo "${green} Which image do you want to use"
  echo " ===================${normal}"
  echo "${magenta} 1 ${default}- Ubuntu (ubuntu/xenial64)[16.04 LTS]"
  echo "${magenta} 2 ${default}- Generic (hashicorp/precise64)[12.04 LTS]"

  while true; do
    read -p "${cyan} Select an option from the list above: ${gold}" answer
    case $answer in
      1 ) clear; version='xenial'; break;;
      2 ) clear; version='precise'; break;;

      * ) echo "Please select a valid option.";;
    esac
  done
  if [ "$version" == "xenial" ]
  then
    use_image='config.vm.box = "ubuntu/xenial64"'
  else
    use_image='config.vm.box = "hashicorp/precise64"'
  fi

  write_vagrantfile_generic
}

write_vagrantfile_sfp(){
# Create new Vagrantfile configuration
echo_start
echo -n "${gold}Creating SFP Vagrantfile${default}"

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

\$bashlaunch = <<SCRIPT
    cp /etc/httpd/conf/httpd.conf /tmp/httptmp
    sed -e "s/#EnableSendfile off/EnableSendfile off/" /tmp/httptmp
    cat /tmp/httptmp > /etc/httpd/conf/httpd.conf
    mkdir /home/fujita/public_html
    /etc/init.d/httpd restart
SCRIPT
  config.vm.provision "shell",
   inline: \$bashlaunch

end
EOF
test_for_success $?
}

write_vagrantfile_generic(){
# Create new Vagrantfile configuration
echo_start
echo -n "${gold}Creating Generic Vagrantfile${default}"

cat <<EOF > $INITDIR/Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ${use_image}
  
  config.vm.synced_folder "./", "/var/www/html/"

  config.vm.network :forwarded_port, host: ${port}, guest: 80
  config.vm.provision :shell, :path => "./etc/scripts/bootstrap_laravel_generic.sh"
end
EOF
test_for_success $?
}

echo "${green} Select the type of Development Environment"
echo " ===================${normal}"
echo "${magenta} 1 ${default}- SFP Environment"
echo "${magenta} 2 ${default}- Generic Environment"

while true; do
  read -p "${cyan} Select an option from the list above: ${gold}" answer
  case $answer in
    1 ) clear; configure_sfp; break;;
    2 ) clear; configure_generic; break;;

    * ) echo "Please select a valid option.";;
  esac
done

