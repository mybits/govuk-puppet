class jenkins {
  #TODO:
  # also need to install fabric and cloth which are needed by private-utils,
  # possibly this would be better done in the private-utils/jenkins.sh

  user { 'jenkins':
    ensure     => present,
    home       => '/home/jenkins',
    managehome => true,
    shell      => '/bin/bash'
  }

  package { 'brakeman':
    ensure   => 'installed',
    provider => gem,
  }

  include jenkins::apache
  include jenkins::ssh_key

  package { 'sqlite3':
    ensure => installed,
  }

  file { '/home/jenkins/.gitconfig':
    source  => 'puppet:///modules/jenkins/dot-gitconfig',
    owner   => jenkins,
    group   => jenkins,
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/mnt/jenkins':
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/var/lib/jenkins':
    ensure  => link,
    target  => '/mnt/jenkins',
    require => File['/mnt/jenkins'],
  }
}

class jenkins::master inherits jenkins {
  include java

  # Kohsuke Kawaguchi <kk@kohsuke.org>
  apt::key { 'D50582E6': }

  exec { 'update-alternatives-java':
    command => 'update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java',
    require => Package['sun-java6-jdk']
  }
  package { 'jenkins':
    ensure  => 'latest',
    require => [
      User['jenkins'],
      Apt::Key['D50582E6'],
      File['jenkins.list'],
      Exec['apt-get update'],
      Package['sun-java6-jdk'],
      Exec['update-alternatives-java']
    ],
  }

  package { 'keychain':
    ensure => 'installed'
  }

  file { '/home/jenkins/.bashrc':
    source  => 'puppet:///modules/jenkins/dot-bashrc',
    owner   => jenkins,
    group   => jenkins,
    mode    => '0700',
    require => Package['keychain'],
  }

  file { 'jenkins.list':
    path   => '/etc/apt/sources.list.d/jenkins.list',
    source => 'puppet:///modules/jenkins/jenkins.list',
    mode   => '0644',
    before => [
      Exec['apt-get update'],
      Apt::Key['D50582E6']
    ],
  }
}

class jenkins::slave inherits jenkins {
}
