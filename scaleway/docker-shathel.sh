#!/usr/bin/env bash

set -e
INSTALL_DOCKER_VERSION=$1

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-mark hold grub-legacy-ec2
sudo apt-mark hold grub-efi-amd64

echo "this package asks interactively for strategy during upgrade though all Dpkg flags should handle it"
sudo apt-get remove unattended-upgrades -y

echo "sudo apt-get upgrade ..."
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

echo "sudo apt-get install python ..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install python htop iotop tree jq fail2ban vim mosh apt-transport-https ca-certificates curl software-properties-common -y

echo "curl -fsSL https://download..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "sudo apkhjggggsd;'kl;lsdfkg;klt-key fingerprint 0EBFCD88..."
sudo apt-key fingerprint 0EBFCD88

echo "sudo add-apt-repository ..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"

echo "sudo apt-get update ..."
sudo apt-get update

echo "sudo apt-cache madison docker ..."
sudo apt-cache madison docker-ce

echo "sudo apt-get install docker ..."
sudo apt-get install docker-ce=${INSTALL_DOCKER_VERSION} -y
