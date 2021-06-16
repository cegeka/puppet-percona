# Class: percona::server::package
#
# Usage: this class should not be called directly
#
class percona::server::package(
  $package_name=undef,
  $version_server=undef,
  $xtrabackup_name=undef,
  $version_xtrabackup='present',
  $versionlock=false
) {

  $percona_major_version   = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version  = regsubst($percona_major_version, '\.', '', 'G')
  $percona_package_version = regsubst($version_server, '^(.*?)-(.*)','\1')
  $percona_package_release = regsubst($version_server, '^(.*?)-(.*)','\2')

  if $package_name {
    $real_package_name = $package_name
  } else {
    $real_package_name = "Percona-Server-server-${_percona_major_version}"
  }

  package {
    $real_package_name:
      ensure => $version_server;
    $xtrabackup_name :
      ensure => $version_xtrabackup;
  }

  if $versionlock {
    $versionlock_ensure = present
  } else {
    $versionlock_ensure = absent
  }

  yum::versionlock { $real_package_name:
    ensure  => "${versionlock_ensure}",
    version => "${percona_package_version}",
    release => "${percona_package_release}",
    epoch   => 0,
    arch    => 'x86_64',
  }
}
