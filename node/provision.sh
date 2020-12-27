#!/usr/bin/env bash

set -eou pipefail

K8S_VERSION=1.19.6-00

__here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DEBIAN_FRONTEND=noninteractive

# Add vagrant user to sudo group:
# ubuntu_rvm only adds users in group sudo to group rvm
usermod -a -G sudo vagrant

# Setup DNS
sudo sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
service systemd-resolved restart

## Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2

# Install Docker
"${__here}"/docker/install.sh

# Install kubernetes runtime
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
# apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet="${K8S_VERSION}" kubeadm="${K8S_VERSION}" kubectl="${K8S_VERSION}"
apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl enable kubelet

# kubelet requires swap off
swapoff -a
# keep swap off after reboot
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# ip of this box
IP_ADDR=`ifconfig enp0s8 | grep inet | awk '{print $2}'| cut -f2 -d:`
sed -e "s/^.*${HOSTNAME}.*/${IP_ADDR} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# set node-ip
echo "Environment='KUBELET_EXTRA_ARGS=--node-ip=${IP_ADDR}'" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet
