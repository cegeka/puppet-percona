define percona::provision::database($ensure) {

  include percona::provision::service

  if $::mysql_exists {
    mysql_database { $name:
      ensure  => $ensure,
      require => [Service["${::percona::provision::service::myservice}"], File['/root/.my.cnf'] ]
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }

}
