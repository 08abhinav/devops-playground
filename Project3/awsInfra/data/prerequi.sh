#!/bin/bash
#################################################
# Author        : Abhinav Negi
# Date          : 21-05-2026
# Description   : Nginx installation
#################################################

apt update -y
apt install nginx -y

systemctl enable nginx
systemctl start nginx
