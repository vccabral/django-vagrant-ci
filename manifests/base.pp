
# Configuration variables

$python_version = '2.4' # other options: '2.5', '3.2'.

# End of configuration variables

file { '/etc/motd':
  content => "Welcome to django-vagrant-ci virtual machine!
              Managed by Puppet.\n"
}

include jenkins

package { "git":
  ensure => installed
}

class { 'postgresql::server':
  config_hash => {
    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    'ip_mask_allow_all_users'    => '0.0.0.0/0',
    'listen_addresses'           => '*',
    'ipv4acls'                   => ['local all all trust'],
    'postgres_password'          => 'P@ssword',
  },
}

include apt
# For other versions of Python: 2.4, 2.5, etc
apt::ppa { "ppa:fkrull/deadsnakes":
  before     => Class['python']
}

Class['apt::update'] -> Class['python::install']

class { 'python':
  version    => $python_version,
  dev        => false,
  virtualenv => true,
  gunicorn   => false
}

