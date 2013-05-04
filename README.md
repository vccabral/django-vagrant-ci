django-vagrant-ci
=================

A vagrant manifest to create continuous integration environments with puppet on a local box or in the cloud.

Getting started
=====

This project uses git submodules. After cloning it, the submodules must be cloned too:

    git clone git://github.com/vccabral/django-base-template.git
    git submodule update --init

or

    git clone --recursive git://github.com/vccabral/django-base-template.git

To create a django ci environment you should run

    vagrant up

in the root of the project.
Building the VM for the first time will take a few minutes.

Configuration variables
====

All the configuration variables are located at the top of the `base.pp` file.
After changing one variable the machine might work after running:

    vagrant reload
but it is advised to recreate it from the beginning:

    vagrant destroy
    vagrant up

Connecting
====
Access jenkins via
    http://localhost:8081

SSH into the box via
    vagrant ssh

Connect to the database via
    *fix me*

Run the django project via
    . ~/virtualenvironment/$project_name/bin/activate
    cd *fixme*
    python manage.py syncdb
    python manage.py migrate
    python manage.py runserver 0.0.0.0:8000

Access the web application via
    http://localhost:8082

Credits
===
This project uses the following puppet modules:

- [rtyler/puppet-jenkins](https://github.com/rtyler/puppet-jenkins)
- [stankevich/puppet-python](https://github.com/stankevich/puppet-python)
- [puppetlabs/puppet-postgresql](https://github.com/puppetlabs/puppet-postgresql)
- [puppetlabs/puppetlabs-apt](https://github.com/puppetlabs/puppetlabs-apt)

