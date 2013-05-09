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
$django_version = 'django==1.5.1'

# Virtualenv location
$virtualenv = "/home/vagrant/virtualenv/$project_name"

# Valid values: '8.4', '9.1', 'system'. Default: system default ('9.1').
$postgresql_version = 'system'

# Name of the database
$postgresql_database = $project_name
# User that will have full access to database
$postgresql_user = $project_name
$postgresql_password = 'Password'

$ci_root = "/home/vagrant/ci"
$project_path = "${ci_root}/${project_name}"
$template = "https://github.com/vccabral/django-twoscoops-project/zipball/master"
$requirements_file = "$project_path/requirements/local.txt"
$owner = 'vagrant'

# End of configuration variables

file { '/etc/motd':
  content => "Welcome to django-vagrant-ci virtual machine!
              Managed by Puppet. $owner\n"
}

include jenkins

jenkins::plugin { [
  "git",
  "git-client",
  "shiningpanda",
  "violations",
  "cobertura"] : }

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
->
python::virtualenv { $virtualenv:
  ensure       => present,
  version      => $python_version,
  systempkgs   => true,
  distribute   => true,
  owner        => $owner
}

python::pip { [$django_version, 'django-jenkins', 'coverage', 'pylint']:
  virtualenv => $virtualenv,
  owner      => $owner,
  require    => Python::Virtualenv[$virtualenv]
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

class { 'postgresql::devel': }

postgresql::db { $postgresql_database:
  user     => $postgresql_user,
  password => $postgresql_password
}


file { $ci_root:
  ensure  => directory,
  owner   => $owner,
}

file { $project_path:
  ensure  => directory,
  owner   => $owner,
  require => File[$ci_root]
}

$manage_py = "$project_path/$project_name/manage.py"

exec { "create_project_$project_path":
  command => "${virtualenv}/bin/django-admin.py startproject --template=${template} --extension=py,rst,html $project_name $project_path",
  creates => "$project_path/$project_name",
  cwd     => $ci_root,
  require => [File[$project_path], Python::Pip[$django_version]],
  user    => $owner
}

python::requirements { $requirements_file:
  virtualenv => $virtualenv,
  owner      => $owner,
  require    => Exec["create_project_$project_path"]
}

exec { "setup_project_$project_path":
  command     => "${virtualenv}/bin/python $manage_py syncdb --noinput\
  && ${virtualenv}/bin/python $manage_py migrate\
  && touch ${project_path}/.project_synced",
  cwd         => "$project_path",
  creates     => "$project_path/.project_synced",
  user        => $owner,
  require     => [ Python::Requirements[$requirements_file], Postgresql::Db[$postgresql_database]]
}

exec { "git_init_$project_path":
  command     => "/usr/bin/git config --global user.email 'vagrant@cibox'\
  && /usr/bin/git config --global user.name 'Vagrant'\
  && /usr/bin/git init \
  && /usr/bin/git add -A \
  && /usr/bin/git commit -m 'Initial commit'",
  cwd         => "$project_path",
  creates     => "$project_path/.git",
  user        => $owner,
  environment => ["USER=${owner}", "HOME=/home/${owner}"],
  require     => [Exec["create_project_$project_path"], Package['git']]
}

file { '/var/lib/jenkins/jobs':
  require => Package['jenkins'],
  ensure  => directory,
  owner   => jenkins,
  group   => jenkins,
  mode    => 0755
}

ci::jenkins_main_project{ $project_name:
  project_git_url => "file://$project_path",
  require         => [ File['/var/lib/jenkins/jobs'], Exec["git_init_$project_path"]]
}

ci::jenkins_deploy_project{ $project_name:
  require => File['/var/lib/jenkins/jobs']
}

# hack for the git plugin:
# https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
exec { "jenkins_git_hack":
  user        => jenkins,
  environment => "HOME=/home/jenkins",
  creates     => "/home/jenkins/.gitconfig",
  require     => [ Package['jenkins'], Package['git']],
  command     => "/usr/bin/git config --global user.email 'jenkins@cibox'\
  && /usr/bin/git config --global user.name 'Jenkins'",
  before      => Ci::Jenkins_main_project[$project_name],
  notify      => Service['jenkins']
}

file { '/home/vagrant/live':
  ensure => directory,
  owner  => jenkins,
  mode   => 0777
}

file { '/home/jenkins':
  ensure => directory,
  owner  => jenkins,
  before => Exec['jenkins_git_hack']
}
