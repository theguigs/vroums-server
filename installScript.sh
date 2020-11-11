#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 2
fi

ProjectName=$1

sudo apt update
sudo apt install apache2
sudo apt-get install libapache2-mod-wsgi-py3 python-dev # (Python 3.6)
sudo apt-get install libapache2-mod-wsgi-py python-dev # (Python 2.7)
sudo apt-get install python3-pip

mkdir ~/$ProjectName
cd ~/$ProjectName

pip3 install virtualenv

virtualenv venv

source venv/bin/activate
pip3 install flask
pip3 install pymongo
pip3 install pymongo[srv]
deactivate

sudo touch ~/$ProjectName/__init__.py

sudo touch ~/$ProjectName/my_flask_app.py
sudo echo "from flask import Flask
app = Flask(__name__)
@app.route(\"/\")
def hello():
    return \"Hello world!\"
if __name__ == \"__main__\":
    app.run()" > ~/$ProjectName/my_flask_app.py

sudo touch ~/$ProjectName/my_flask_app.wsgi
sudo echo "#! /usr/bin/python3.6
import logging
import sys
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, '/home/ubuntu/$ProjectName/')
from my_flask_app import app as application
application.secret_key = 'anything you wish'" > ~/$ProjectName/my_flask_app.wsgi

sudo touch /etc/apache2/sites-available/$ProjectName.conf
sudo echo "<VirtualHost *:80>
     # Add machine's IP address (use ifconfig command)
     ServerName 146.59.234.106

     WSGIDaemonProcess $ProjectName python-path=/home/ubuntu/$ProjectName:/home/ubuntu/$ProjectName/venv/lib/python3.6/site-packages
     WSGIProcessGroup $ProjectName
     # Give an alias to to start your website url with
     WSGIScriptAlias /$ProjectName /home/ubuntu/$ProjectName/my_flask_app.wsgi

     <Directory /home/ubuntu/$ProjectName/>
     		# set permissions as per apache2.conf file
            Options FollowSymLinks
            AllowOverride None
            Require all granted
     </Directory>
     ErrorLog \${APACHE_LOG_DIR}/error.log
     LogLevel warn
     CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$ProjectName.conf

sudo a2ensite $ProjectName.conf
sudo service apache2 restart