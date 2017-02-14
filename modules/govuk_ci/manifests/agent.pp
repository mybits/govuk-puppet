# == Class: govuk_ci::agent
#
# Class to manage continuous deployment agents
#
# === Parameters:
#
# [*docker_enabled*]
#   Set to true to install the Docker service on this agent
#
# [*master_ssh_key*]
#   The public SSH key of the CI master to enable SSH based agent builds
#
class govuk_ci::agent(
  $docker_enabled = false,
  $master_ssh_key = undef,
) {
  include ::govuk_ci::agent::redis
  if $docker_enabled {
    include ::govuk_ci::agent::docker
  }
  include ::guix
  include ::govuk_ci::agent::rabbitmq
  include ::govuk_ci::agent::elasticsearch
  include ::govuk_ci::agent::mongodb
  include ::govuk_ci::agent::postgresql
  include ::govuk_ci::agent::mysql
  include ::govuk_ci::credentials
  include ::govuk_ci::vpn
  include ::govuk_java::oracle8
  include ::govuk_jenkins::github_enterprise_cert
  include ::govuk_jenkins::user
  include ::govuk_jenkins::pipeline
  include ::govuk_rbenv::all
  include ::golang
  include ::govuk_testing_tools

  # Override sudoers.d resource (managed by sudo module) to enable Jenkins user to run sudo tests
  File<|title == '/etc/sudoers.d/'|> {
    mode => '0555',
  }

  ssh_authorized_key { 'ci-master-1.ci':
    ensure  => present,
    user    => 'jenkins',
    type    => 'ssh-rsa',
    key     => $master_ssh_key,
    require => Class['::govuk_jenkins::user'],
  }

  # FIXME: set the package to absent when/if the agents are connecting over SSH
  service { 'jenkins-agent':
    ensure => 'stopped',
  }

  package { 'libgdal-dev': # needed for mapit
    ensure => installed,
  }
}
