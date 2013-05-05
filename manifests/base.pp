
# Configuration variables

# The name of the project.
# It will be contained in the value of other variables like:
# virtualenv name, database name, etc.
$project_name = 'icecream'

# Valid values: '2.6', '3.2', etc. 'system' will install system default.
# Ubuntu 12.04 comes with python 2.7.
# Note that not all python versions will generate a working configuration.
# For example, if you try to run `pip` with python 2.4 it will fail.
$python_version = 'system'

# This is the parameter passed to `pip install`.
# Example valid values: `django`, `django==1.2.5`.
# Note that the version of django must be compatible with the version of Python.
$django_version = 'django==1.5'

# Virtualenv location
$virtualenv = "/home/vagrant/virtualenv/$project_name"

# Valid values: '8.4', '9.1', 'system'. Default: system default ('9.1').
$postgresql_version = 'system'

# Name of the database
$postgresql_database = $project_name
# User that will have full access to database
$postgresql_user = $project_name
$postgresql_password = 'Password'

# End of configuration variables

file { '/etc/motd':
  content => "Welcome to django-vagrant-ci virtual machine!
              Managed by Puppet.\n"
}

include jenkins

package { "git":
  ensure => installed
}

# For other versions of Python: 2.4, 2.5, etc
include apt
apt::ppa { "ppa:fkrull/deadsnakes":
  before     => Class['python']
}

Class['apt::update'] -> Class['python::install']

class { 'python':
  version    => $python_version,
  dev        => true,
  virtualenv => true,
  gunicorn   => false
}

python::virtualenv { $virtualenv:
  ensure       => present,
  version      => $python_version,
  systempkgs   => true,
  distribute   => true
}

python::pip { $django_version:
  virtualenv => $virtualenv
}

exec { 'sudo chown -R vagrant:vagrant /home/vagrant/virtualenv':
  command => 'sudo chown -R vagrant:vagrant /home/vagrant/virtualenv',
  creates => "/home/vagrant/.changed_owner",
}

exec { 'bash /vagrant/create_project.sh':
  command => 'bash /vagrant/create_project.sh',
  creates => "/home/vagrant/.created_project",
}

if ($postgresql_version != 'system') {
  class { 'postgresql':
    version => $postgresql_version
  }
  Class['postgresql'] -> Class['postgresql::server']
}

class { 'postgresql::server':
  config_hash => {
    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    'ip_mask_allow_all_users'    => '0.0.0.0/0',
    'listen_addresses'           => '*',
    'ipv4acls'                   => ['local all all trust',
                                     'host  all all 127.0.0.1/32 trust'],
    'postgres_password'          => $postgresql_password,
  },
}

postgresql::db { $postgresql_database:
  user     => $postgresql_user,
  password => $postgresql_password
}
