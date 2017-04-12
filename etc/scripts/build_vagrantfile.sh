read -p "${cyan}What local port should Vagrant Map to its port ${red}80${cyan}: [default 8000]${gold} " port
http_port=${port:-8000}
read -p "${cyan}What local port should Vagrant Map to its port ${red}3306${cyan}: [default 3307]${gold} " port
mysql_port=${port:-3307}

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
  
  config.vm.network :forwarded_port, host: ${http_port}, guest: 80
  config.vm.network :forwarded_port, host: ${mysql_port}, guest: 3306

  config.vm.provision "shell" do |s|
    s.path = "./etc/scripts/bootstrap_laravel_generic.sh"
    s.args   = "${project}"
  end
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

