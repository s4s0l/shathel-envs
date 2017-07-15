#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

echo "sudo apt-get upgrade ..."
sudo apt-get upgrade -y

echo "sudo apt-get install python ..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install python htop iotop tree jq fail2ban vim mosh apt-transport-https ca-certificates curl software-properties-common -y

echo "curl -fsSL https://download..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "sudo apt-key fingerprint 0EBFCD88..."
sudo apt-key fingerprint 0EBFCD88

echo "sudo add-apt-repository ..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"

echo "sudo apt-get update ..."
sudo apt-get update

echo "sudo apt-cache madison docker ..."
sudo apt-cache madison docker-ce

echo "sudo apt-get install docker ..."
sudo apt-get install docker-ce=${INSTALL_DOCKER_VERSION}~ce-0~ubuntu -y

echo "sudo usermod -a -G ..."
sudo usermod -a -G docker ubuntu

echo "setting cgroup_enable=memory swapaccount=1"
sudo grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
sudo sed -i 's#^GRUB_CMDLINE_LINUX_DEFAULT="\(.*"\)$#GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 \1#' /etc/default/grub
sudo sed -i 's#^GRUB_CMDLINE_LINUX="\(.*"\)$#GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 \1#' /etc/default/grub
echo "Verification"
sudo grep GRUB_CMDLINE_LINUX /etc/default/grub
sudo curl -s https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh -o /docker-verify.sh

echo "sudo update-grub"
sudo update-grub

# TODO: make it work
# sudo apt-get clean
# sudo dd if=/dev/zero of=/EMPTY bs=1M | true
# sudo rm -f /EMPTY
# cat /dev/null > ~/.bash_history && history -c
