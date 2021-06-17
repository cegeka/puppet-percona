# Class: percona::cluster::service
#
# Usage: this class should not be called directly
#
class percona::cluster::service (
  $server_id     = undef,
  $service_ensure = undef,
  $service_enable = undef
) {

  # Bootstrap first, then configure root password if required
  exec { 'bootstrap_galera_cluster':
    command  => 'systemctl start mysql@bootstrap && touch /root/.mysql_bootstrap',
    unless   => "netstat -tulpen | grep -q ':4567'",
    creates  => "/root/.mysql_bootstrap",
    before   => Service['mysqld'],
    provider => shell,
    path     => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
    require  => Class['percona::cluster::config'],
  }

  service { 'mysqld':
    name       => 'mysql',
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class['percona::cluster::package'], Class['percona::cluster::config'], Class['percona::cluster::root'] ],
  }

  service { 'mysql@bootstrap':
    ensure => 'stopped',
    before => Service['mysqld'],
  }

}
