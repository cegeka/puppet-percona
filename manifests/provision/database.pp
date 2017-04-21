define percona::provision::database($ensure) {

  $myservice = $::operatingsystem ? {
    /RedHat|Fedora|CentOS/  => 'mysqld',
    default                 => 'mysql',
  }

  if $::mysql_exists {
    mysql_database { $name:
      ensure  => $ensure,
      require => [Service[$myservice], File['/root/.my.cnf'] ]
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }

  service { $myservice:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class[Percona::Server::Package], File['/root/.my.cnf'] ],
  }

}
