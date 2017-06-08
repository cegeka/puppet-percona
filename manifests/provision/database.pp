define percona::provision::database($ensure, $type='server') {

  if $type == 'server' {
    include percona::provision::service
    $real_service = "${::percona::provision::service::myservice}"
  }
  else
  {
    include percona::provision::service_cluster
    $real_service = "${::percona::provision::service_cluster::myservice}"
  }
  if $::mysql_exists {
    mysql_database { $name:
      ensure  => $ensure,
      require => Service["${service}"]
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }

}
