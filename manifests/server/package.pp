# Class: percona::server::package
#
# Usage: this class should not be called directly
#
class percona::server::package(
  $version_server=undef,
  $xtrabackup_name=undef,
  $version_xtrabackup='present',
  $versionlock=false
) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  package {
    "Percona-Server-server-${_percona_major_version}" :
      ensure => $version_server;
    $xtrabackup_name :
      ensure => $version_xtrabackup;
  }

  if $versionlock {
    yum::versionlock { "0:Percona-Server-server-${_percona_major_version}-${version_server}.*": }
  } else {
    yum::versionlock { "0:Percona-Server-server-${_percona_major_version}-${version_server}.*": ensure => absent }
  }

}
