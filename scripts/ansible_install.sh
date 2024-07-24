#!/bin/bash

echo packer | sudo apt update
echo packer | sudo apt install -y software-properties-common
echo packer | sudo add-apt-repository --yes --update ppa:ansible/ansible
echo packer | sudo apt update
echo packer | sudo apt install -y ansible
ansible --version

echo "Ansible installation completed successfully."
