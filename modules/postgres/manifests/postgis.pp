class postgres::postgis {

  include postgres::repository

  package { 'postgis':
    ensure => present,
  }

}
