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

  if $versionlock {
    yum::versionlock { "0:${garb_packagename}-${garb_version}.*": }
  } else {
    yum::versionlock { "0:${garb_packagename}-${garb_version}.*": ensure => absent }
  }

}
