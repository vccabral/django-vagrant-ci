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

Activate the virtual env via:

    source ~/virtualenv/icecream/bin/activate

Connect to the database via:

    psql -h localhost -U icecream -d icecream
The user `icecream` has full access to the database `icecream`.
Another way to connect to the database is with this sequence of commands:

    source ~/virtualenv/icecream/bin/activate
    cd ~/icecream
    python icecream/manage.py dbshell

Django is installed inside the virtual env, so the virtualenv must be activated before running `django-admin.py`:

    source ~/virtualenv/icecream/bin/activate
    django-admin.py --version

Run the django project via

    . ~/virtualenv/icecream/bin/activate
    cd ~/icecream/icecream
    #pip install -r requirements/local.txt
    python manage.py syncdb
    python manage.py migrate
    python manage.py runserver 0.0.0.0:8000

You can check the database content after the initial `python manage.py syncdb` in the psql shell with the '\d' command:

    . ~/virtualenv/icecream/bin/activate
    cd ~/icecream/icecream
    
    python manage.py dbshell
    \d

Access the web application via

    http://localhost:8082


TODO
===
    Create git repo for the newly created project.
    Add jenkins plugins needed for django continuous integration.
    jenkins::plugin {
        "git" : ;
    }
    ...
    Add a jenkins project that polls the local git repo every 10 minutes. The project_name should be $project_name.
    The build process should run unit tests, code coverage, PEP8 analysis, have a post build process that, on success, makes the project publically available on 8083. 
    Other items should be, database syncing, database migrations, collecting static content, deploying latest code. 

Credits
===
This project uses the following puppet modules:

- [rtyler/puppet-jenkins](https://github.com/rtyler/puppet-jenkins)
- [stankevich/puppet-python](https://github.com/stankevich/puppet-python)
- [puppetlabs/puppet-postgresql](https://github.com/puppetlabs/puppet-postgresql)
- [puppetlabs/puppetlabs-apt](https://github.com/puppetlabs/puppetlabs-apt)

