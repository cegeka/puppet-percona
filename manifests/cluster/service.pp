# Class: percona::cluster::service
#
# Usage: this class should not be called directly
#
class percona::cluster::service (
  $server_id     = undef,
  $service_ensure = undef,
  $service_enable = undef
) {

  if $server_id == 1 {
    # Bootstrap first, then configure root password if required
    exec { 'bootstrap_galera_cluster':
      command  => 'systemctl start mysql@bootstrap && touch /root/.mysql_bootstrap',
      # Also possible to nmap scan all the nodes in the cluster and check if one is already listening on port 3306/4567
      unless   => "netstat -tulpen | grep -q ':4567'",
      creates  => "/root/.mysql_bootstrap",
      before   => Service['mysqld'],
      provider => shell,
      path     => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
      require  => Class['percona::cluster::config'],
    }
  }

  service { 'mysql@bootstrap':
    ensure => 'stopped',
    before => Service['mysqld'],
  }

  service { 'mysqld':
    name       => 'mysql',
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class['percona::cluster::package'], Class['percona::cluster::config'], Class['percona::cluster::root'] ],
  }

}
