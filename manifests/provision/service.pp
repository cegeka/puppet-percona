class percona::provision::service() {

  $myservice = $::operatingsystem ? {
    default                 => 'mysql',
  }

  service { $myservice:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class[Percona::Server::Package], Class[Percona::Server::Config] ],
  }
}
