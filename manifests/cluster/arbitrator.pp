# Class: percona::cluster::arbitrator
#
# Usage: use this to add a node to an exiting percona cluster
#
class percona::cluster::arbitrator (
  $garb_version     = undef,
  $garb_packagename = undef,
  $versionlock      = undef,
  $cluster_address  = undef,
  $cluster_name     = undef,
) {

  package { $garb_packagename:
    ensure => $garb_version
  }

  file { '/etc/sysconfig/garb':
    ensure  => 'file',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('profile/iac/database/garb.sysconfig.erb'),
    require => Package[$garb_packagename]
  }

  service { 'garb':
    ensure  => 'running',
    enable  => true,
    require => [File['/etc/sysconfig/garb'],Package[$garb_packagename]]
  }

  $garb_package_version = regsubst($garb_version, '^(.*?)-(.*)','\1')
  $garb_package_release = regsubst($garb_version, '^(.*?)-(.*)','\2')
  $galera_major_version = regsubst($garb_packagename, '^(.*)-(.*)-(.*)-(.*)-(.*)','\5')


  if $versionlock {
    $versionlock_ensure = present
  } else {
    $versionlock_ensure = absent
  }

# Percona-XtraDB-Cluster-garbd-57
  yum::versionlock { "Percona-XtraDB-Cluster-garbd-${galera_major_version}":
    ensure  => "${versionlock_ensure}",
    version => "${garb_package_version}",
    release => "${garb_package_release}",
    epoch   => 0,
    arch    => 'x86_64',
  }

}
