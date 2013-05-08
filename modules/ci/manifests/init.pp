

define ci::jenkins_main_project(
  $project_name = $title,
  $project_git_url
){
  $jenkins_home = "/var/lib/jenkins/jobs"

  file { "$jenkins_home/$project_name":
    owner  => jenkins,
    group  => nogroup,
    mode   => 0755,
    ensure => directory
  }
  ->
  file { "$jenkins_home/$project_name/config.xml":
    content => template("ci/main_project.xml.erb"),
    owner   => jenkins,
    group   => nogroup,
    mode    => 0644,
    ensure  => present,
    notify  => Service['jenkins']
  }
}

define ci::jenkins_deploy_project(
  $project_name = $title
){
  $jenkins_home = "/var/lib/jenkins/jobs"

  file { "$jenkins_home/deploy_${project_name}":
    owner  => jenkins,
    group  => nogroup,
    mode   => 0755,
    ensure => directory
  }
  ->
  file { "$jenkins_home/deploy_${project_name}/config.xml":
    content => template("ci/deploy_project.xml.erb"),
    owner   => jenkins,
    group   => nogroup,
    mode    => 0644,
    ensure  => present,
    notify  => Service['jenkins']
  }
}

