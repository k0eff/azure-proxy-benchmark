#!/bin/bash
echo ${password} | sudo -S -u root -v
sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl restart nginx

echo "Provisioning Finished!"