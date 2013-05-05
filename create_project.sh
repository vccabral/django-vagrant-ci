#!/bin/bash
. ~/virtualenv/icecream/bin/activate
cd ~
django-admin.py startproject --template=https://github.com/vccabral/django-twoscoops-project/zipball/master --extension=py,rst,html icecream
cd icecream
pip install -r requirements/local.txt
