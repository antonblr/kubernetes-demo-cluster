#!/usr/bin/env bash

set -eou pipefail

__here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Docker CE
## Install packages to allow apt to use a repository over HTTPS
#apt-get update && apt-get install -y \
#  apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

# Add the Docker apt repository:
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get install -y containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

# Set up the Docker daemon
mkdir -p /etc/docker
cp "${__here}/daemon.json" /etc/docker/

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker and start on boot
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# force docker to do some initialization of its directories by first pulling
# use this ~1KiB image from docker hub because grc rate limits
docker pull registry.hub.docker.com/library/hello-world:latest
