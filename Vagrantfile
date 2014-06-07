# -*- mode: ruby -*-
# vi: set ft=ruby :

#ENV setting section

#virtual box setting
BOX_NAME = ENV['BOX_NAME'] || "leviathan"
BOX_URI = ENV['BOX_URI'] || "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
SSH_PRIVKEY_PATH = ENV["SSH_PRIVKEY_PATH"]

#Tasks: task management here
TASKS = !ENV["TASKS"].nil? && ENV["TASKS"].split(" ")  || ["dev"]


#project related
PROJECT_NAME=Dir.pwd.split('/').last || "leviathan"

#HTTP wrapper, you can use nginx/apache/varnish or whatever

HTTP_WRAPPER = ENV['HTTP_WRAPPER'] || "nginx"

#config server/docker server/services
DOCKER_REGISTRY= ENV["DOCKER_REGISTRY"] || "leviathan.example.com:5000"
CONFIG_SERVER= ENV["CONFIG_SERVER"] || "leviathan.example.com:8080"

CONIFIG_PATH="#{CONFIG_SERVER}/#{HTTP_WRAPPER}"
DOCKER_REGISTRY_PATH="#{DOCKER_REGISTRY}"

#config dev env
DEV_ENV_FOR = ENV["DEV_ENV_FOR"] || "example"
DEV_ENV_SCRIPTS_PATH = "#{CONFIG_SERVER}/dev"
SET_UP_SCRIPT_URL = "#{DEV_ENV_SCRIPTS_PATH}/#{DEV_ENV_FOR}/setup.sh"
CONTAINER_START_SCRIPT_URL="#{DEV_ENV_SCRIPTS_PATH}"

#Services
SERVICES=ENV["SERVICES"] || ["app", "services"]



Vagrant::Config.run do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI

  # Use the specified private key path if it is specified and not empty.
  # if SSH_PRIVKEY_PATH
  #     config.ssh.private_key_path = SSH_PRIVKEY_PATH
  # end

  config.ssh.forward_agent = true
end


# Providers were added on Vagrant >= 1.1.0
#
# NOTE: The vagrant "vm.provision" appends its arguments to a list and executes
# them in order.  If you invoke "vm.provision :shell, :inline => $script"
# twice then vagrant will run the script two times.  Unfortunately when you use
# providers and the override argument to set up provisioners (like the vbox
# guest extensions) they 1) don't replace the other provisioners (they append
# to the end of the list) and 2) you can't control the order the provisioners
# are executed (you can only append to the list).  If you want the virtualbox
# only script to run before the other script, you have to jump through a lot of
# hoops.
#
# Here is my only repeatable solution: make one script that is common ($script)
# and another script that is the virtual box guest *prepended* to the common
# script.  Only ever use "vm.provision" *one time* per provider.  That means
# every single provider has an override, and every single one configures
# "vm.provision".  Much saddness, but such is life.
Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|

  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--memory", 2048]
  end
  config.vm.synced_folder ".", "/home/vagrant/#{PROJECT_NAME}"
end


Vagrant::Config.run do |config|
    config.vm.network :hostonly, "192.168.50.4"
end

#Tasks, provision on start up, setting up the dev env for project
def dev
  Vagrant::Config.run do |config|
      config.vm.provision :shell, :inline => "curl #{SET_UP_SCRIPT_URL} | bash"
      config.vm.provision :shell, :inline => "apt-get install -y #{HTTP_WRAPPER}"
      config.vm.provision :shell, :inline => "[ -d /etc/nginx/ssl ] || mkdir -p /etc/nginx/ssl; cd /etc/nginx/ssl && wget #{CONIFIG_PATH}/ssl/server.{crt,key}"
      config.vm.provision "docker" , :version => "latest" if not SERVICES.empty?
      config.vm.provision :shell, :inline => "apt-get install lxc -y"
      config.vm.provision :shell, :inline => 'echo "DOCKER_OPTS=\"-e lxc\"" > /etc/default/docker'
  end
end


def config
  Vagrant::Config.run do |config|
    config.vm.provision :shell, :inline => "cd /etc/nginx/conf.d; rm -f *.conf"
      SERVICES.each do |service|
        config.vm.provision :shell, :inline => "cd /etc/nginx/conf.d && curl -O #{CONIFIG_PATH}/#{service}.conf"
      end
    config.vm.provision :shell, :inline => "service nginx restart"
  end
end


def docker
  Vagrant::Config.run do |config|
    config.vm.provision :shell, :inline => "containerID=`docker ps -a | awk '{if (NR != 1) {print $1;}}'`; for i in $containerID; do docker stop $i && docker rm $i; done"
    SERVICES.each do |service_name|
      config.vm.provision :shell, :inline => "docker pull #{DOCKER_REGISTRY_PATH}/#{service_name}"
      config.vm.provision :shell, :inline => "curl #{CONTAINER_START_SCRIPT_URL}/#{service_name}/run.sh | bash"
    end
  end
end

def update
  Vagrant::Config.run do |config|
    #update apps/services inside vm
    SERVICES.each do |package_name|
      config.vm.provision :shell, :inline => "containerID=`docker ps -a --no-trunc | grep #{package_name} | awk '{print $1;}'`; echo 'yum install -y #{package_name}' | sudo lxc-attach -n $containerID"
    end
  end
end

TASKS.each do |task|
  send(task)
end
