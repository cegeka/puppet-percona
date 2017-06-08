class percona::provision::service_cluster() {

  $myservice = $::operatingsystem ? {
    default                 => 'mysql',
  }

  service { $myservice:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class[Percona::Cluster::Package], Class[Percona::Cluster::Config] ],
  }
}
