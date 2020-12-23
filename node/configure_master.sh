#!/usr/bin/env bash

set -eou pipefail

echo "Configuring master..."

CACHE_PATH="/vagrant/.cache"
mkdir -p $CACHE_PATH

# ip of this box
IP_ADDR=`ifconfig enp0s8 | grep inet | awk '{print $2}'| cut -f2 -d:`

# install k8s master
HOST_NAME=$(hostname -s)

kubeadm init \
  --apiserver-advertise-address=$IP_ADDR \
  --apiserver-cert-extra-sans=$IP_ADDR  \
  --node-name $HOST_NAME \
  --pod-network-cidr=172.16.0.0/16

#copying credentials to regular user - vagrant
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

cat /etc/kubernetes/admin.conf > $CACHE_PATH/k8s-config.yaml

# install Calico pod network addon
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://docs.projectcalico.org/archive/v3.17/manifests/calico.yaml

kubeadm token create --print-join-command > $CACHE_PATH/kubeadm_join.sh
chmod +x $CACHE_PATH/kubeadm_join.sh

# required for setting up password less ssh between guest VMs
#sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
#service sshd restart
