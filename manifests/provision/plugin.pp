define percona::provision::plugin($ensure, $type='server') {

  if $::mysql_exists {
    mysql_plugin { $name:
      ensure  => $ensure,
      require => Service['mysqld']
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }

}
