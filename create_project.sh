#!/bin/bash

#sudo apt-get -y build-dep python-psycopg2
. /home/vagrant/virtualenv/icecream/bin/activate
cd /home/vagrant
django-admin.py startproject --template=https://github.com/vccabral/django-twoscoops-project/zipball/master --extension=py,rst,html icecream
cd icecream
pip install -r requirements/local.txt
touch ~/.created_project
