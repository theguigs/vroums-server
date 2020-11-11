#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 2
fi

ProjectName=$1

sudo rm -rf ~/$ProjectName
sudo rm -rf /etc/apache2/sites-available/$ProjectName.conf
sudo rm -rf /etc/apache2/sites-enabled/$ProjectName.conf
