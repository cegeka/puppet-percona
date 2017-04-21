class percona::provision::service() {

  $myservice = $::operatingsystem ? {
    /RedHat|Fedora|CentOS/  => 'mysqld',
    default                 => 'mysql',
  }

  service { $myservice:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class[Percona::Server::Package], File['/root/.my.cnf'] ],
  }
}
