# Class: percona::cluster::package
#
# Usage: this class should not be called directly
#
class percona::cluster::package (
  $version_galera     = undef,
  $version_server     = undef,
  $versionlock        = undef,
  $version_xtrabackup = undef,
  $xtrabackup_name    = undef,
  $server_shared_compat_name = 'Percona-Server-shared-compat'
) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  $galera_major_version = regsubst($version_galera, '^(\d)\.(\d*)-(.*)','\1')
  $_galera_major_version = regsubst($galera_major_version, '\.', '', 'G')

  debug("Galera major version = ${galera_major_version}")

  if $xtrabackup_name == undef  {
    fail("percona::Cluster::Package[${xtrabackup_name}]: must be given")
  }

  $number_percona_major_version = 0 + $_percona_major_version
  if $version_galera == undef and $number_percona_major_version < 57 {
      fail("Percona::Cluster::Package[${version_galera}]: must be given if version_server < 57")
  }

  exec { 'remove-Percona-Server-shared-55':
    command => '/bin/rpm -e --nodeps Percona-Server-shared-55',
    onlyif  => '/bin/rpm -qi Percona-Server-shared-55',
    require => [ Package['net-snmp'], Package['postfix'] ]
  }
  exec { 'remove-Percona-Server-shared-56':
    command => '/bin/rpm -e --nodeps Percona-Server-shared-56',
    onlyif  => '/bin/rpm -qi Percona-Server-shared-56',
    require => [ Package['net-snmp'], Package['postfix'], Exec['remove-Percona-Server-shared-55'] ]
  }
  exec { 'remove-mariadb-libs':
    command => '/bin/rpm -e --nodeps mariadb-libs',
    onlyif  => '/bin/rpm -qi mariadb-libs',
    require => [ Package['net-snmp'], Package['postfix']]
  }
  if $number_percona_major_version < 57 {
    package {
      "Percona-XtraDB-Cluster-galera-${_galera_major_version}" :
        ensure => $version_galera;
      "Percona-XtraDB-Cluster-garbd-${_galera_major_version}" :
        ensure => $version_galera;
    }
    Exec['remove-Percona-Server-shared-56']
    -> Exec['remove-mariadb-libs']
    -> Package["Percona-XtraDB-Cluster-galera-${_galera_major_version}"]
    -> Package["Percona-XtraDB-Cluster-shared-${_percona_major_version}"]
    -> Service['postfix']
    -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
    -> Package[$xtrabackup_name]
    -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
    -> Package["Percona-XtraDB-Cluster-garbd-${_galera_major_version}"]

    case $versionlock {
      true: {
        packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-${version_galera}": }
        packagelock { "Percona-XtraDB-Cluster-garbd-${_galera_major_version}-${version_galera}": }
      }
      false: {
        packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-${version_galera}": ensure => absent }
        packagelock { "Percona-XtraDB-Cluster-garbd-${_galera_major_version}-${version_galera}": ensure => absent }
      }
      default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false')}
    }
  }
  else {
    if (versioncmp($::operatingsystemmajrelease, '7') < 0) {
      package {
        "Percona-XtraDB-Cluster-garbd-${_percona_major_version}" :
          ensure => $version_server;
        $server_shared_compat_name :
          ensure => present;
      }
      Exec['remove-Percona-Server-shared-56']
      -> Exec['remove-mariadb-libs']
      -> Package["Percona-XtraDB-Cluster-shared-${_percona_major_version}"]
      -> Package[$server_shared_compat_name]
      -> Service['postfix']
      -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
      -> Package[$xtrabackup_name]
      -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
      -> Package["Percona-XtraDB-Cluster-garbd-${_percona_major_version}"]

      case $versionlock {
        true: {
          packagelock { "Percona-XtraDB-Cluster-garbd-${_percona_major_version}-${version_server}": }
          packagelock { $server_shared_compat_name : }
        }
        false: {
          packagelock { "Percona-XtraDB-Cluster-garbd-${_percona_major_version}-${version_server}": ensure => absent }
          packagelock { $server_shared_compat_name : ensure => absent }
        }
        default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false') }
      }
    }
    else {
      package {
        "Percona-XtraDB-Cluster-garbd-${_percona_major_version}" :
          ensure => $version_server;
        "Percona-XtraDB-Cluster-shared-compat-${_percona_major_version}" :
          ensure => $version_server;
      }
      Exec['remove-Percona-Server-shared-56']
      -> Exec['remove-mariadb-libs']
      -> Package["Percona-XtraDB-Cluster-shared-${_percona_major_version}"]
      -> Package["Percona-XtraDB-Cluster-shared-compat-${_percona_major_version}"]
      -> Service['postfix']
      -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
      -> Package[$xtrabackup_name]
      -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
      -> Package["Percona-XtraDB-Cluster-garbd-${_percona_major_version}"]

      case $versionlock {
        true: {
          packagelock { "Percona-XtraDB-Cluster-garbd-${_percona_major_version}-${version_server}": }
          packagelock { "Percona-XtraDB-Cluster-shared-compat-${_percona_major_version}-${version_server}": }
        }
        false: {
          packagelock { "Percona-XtraDB-Cluster-garbd-${_percona_major_version}-${version_server}": ensure => absent }
          packagelock { "Percona-XtraDB-Cluster-shared-compat-${_percona_major_version}-${version_server}": ensure => absent }
        }
        default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false') }
      }
    }
  }

  package {
    "Percona-XtraDB-Cluster-server-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-client-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-shared-${_percona_major_version}" :
      ensure => $version_server;
    $xtrabackup_name :
      ensure => $version_xtrabackup;
  }

  if $versionlock {
    packagelock { "Percona-XtraDB-Cluster-server-${_percona_major_version}-${version_server}": }
    packagelock { "Percona-XtraDB-Cluster-client-${_percona_major_version}-${version_server}": }
    packagelock { "Percona-XtraDB-Cluster-shared-${_percona_major_version}-${version_server}": }
    packagelock { "${xtrabackup_name}-${version_xtrabackup}": }
  } else {
    packagelock { "Percona-XtraDB-Cluster-server-${_percona_major_version}-${version_server}": ensure => absent }
    packagelock { "Percona-XtraDB-Cluster-client-${_percona_major_version}-${version_server}": ensure => absent }
    packagelock { "Percona-XtraDB-Cluster-shared-${_percona_major_version}-${version_server}": ensure => absent }
    packagelock { "${xtrabackup_name}-${version_xtrabackup}": ensure => absent }
  }

}
