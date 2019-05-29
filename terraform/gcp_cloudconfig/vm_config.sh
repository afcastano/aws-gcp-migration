#!/bin/bash
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo sed -i "/^[^#]*PubkeyAuthentication[[:space:]]no/c\PasswordAuthentication no" /etc/ssh/sshd_config
sudo service sshd restart

adduser --disabled-password --gecos "" gcp
echo 'gcp:gcp' | sudo chpasswd