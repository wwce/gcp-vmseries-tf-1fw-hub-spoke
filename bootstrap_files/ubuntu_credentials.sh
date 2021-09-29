#!/bin/bash
sudo useradd --groups google-sudoers tempuser
sudo echo "tempuser:password" | chpasswd
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
