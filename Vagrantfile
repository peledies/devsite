# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"
  
  config.vm.network :forwarded_port, host: 8008, guest: 80
  config.vm.network :forwarded_port, host: 33068, guest: 3306

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.synced_folder "./", "/var/www/html", owner: "www-data", group: "www-data", mount_options: ["dmode=777", "fmode=777"]

  config.vm.provision "shell" do |s|
    s.path = "./.devL/etc/scripts/bootstrap_php_mysql.sh"
    s.args   = "firstib_devL"
  end
end
