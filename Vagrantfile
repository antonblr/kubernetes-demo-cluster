#!/usr/bin/env ruby

# -*- mode: ruby -*-
# # vi: set ft=ruby :
# https://docs.vagrantup.com

Vagrant.require_version ">= 2.2.9"

BOX = "ubuntu/bionic64"
BOX_VERSION = "20201211.1.0"

NODE_IP="192.168.10.%d"
VM_GROUP = "/#{File.basename(Dir.getwd)}"

MASTER_NAME = "master-0"
MASTER_VM_MEMORY = 2048
MASTER_VM_CPUS = 2

WORKERS = 2
WORKER_NAME="worker-%d"
WORKER_VM_MEMORY = 512
WORKER_VM_CPUS = 1

Vagrant.configure("2") do |config|
  # Available boxes https://vagrantcloud.com/search.
  config.vm.box = BOX
  config.vm.box_version = BOX_VERSION

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--groups", VM_GROUP]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]

    # vagrant was setting this to legacy
    vb.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]

    # these have a significant effect on performance
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--x2apic", "on"]
    vb.customize ["modifyvm", :id, "--vtxvpid", "on"]
    vb.customize ["modifyvm", :id, "--vtxux", "on"]
    vb.customize ["modifyvm", :id, "--nestedpaging", "on"]
    vb.customize ["modifyvm", :id, "--largepages", "on"]
    vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
    vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
    vb.customize ["setextradata", :id, "VBoxInternal/CPUM/IsaExts/AVX2", "1"]
  end

  config.vm.provision :shell, inline: "/vagrant/node/provision.sh"

  # Provision Master Node
  config.vm.define MASTER_NAME do |node|
    node.vm.provider :virtualbox do |vb|
      vb.name = MASTER_NAME
      vb.memory = MASTER_VM_MEMORY
      vb.cpus = MASTER_VM_CPUS
    end

    node.vm.hostname = MASTER_NAME
    node.vm.network :private_network, ip: NODE_IP % 10
    node.vm.network :forwarded_port, guest: 22, host: 2720, auto_correct: true

    node.vm.provision :shell, inline: "/vagrant/node/configure_master.sh"
  end

  # Provision Worker Nodes
  (1..WORKERS).each do |i|
    node_name = WORKER_NAME % i
    config.vm.define node_name do |node|
      node.vm.provider :virtualbox do |vb|
        vb.name = node_name
        vb.memory = WORKER_VM_MEMORY
        vb.cpus = WORKER_VM_CPUS
      end

      node.vm.hostname = node_name
      node.vm.network :private_network, ip: NODE_IP % (20 + i)
      node.vm.network :forwarded_port, guest: 22, host: 2730 + i, auto_correct: true

      node.vm.provision :shell, inline: "/vagrant/.cache/kubeadm_join.sh"
    end
  end

end
