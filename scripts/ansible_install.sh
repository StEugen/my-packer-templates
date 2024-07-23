#!/bin/bash

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible
ansible --version

echo "Ansible installation completed successfully."
