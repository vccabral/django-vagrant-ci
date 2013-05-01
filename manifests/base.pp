
file { '/etc/motd':
  content => "Welcome to your Vagrant-built virtual machine!
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

