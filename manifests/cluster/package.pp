# Class: percona::cluster::package
#
# Usage: this class should not be called directly
#
class percona::cluster::package (
  $package_name       = undef,
  $version_galera     = undef,
  $version_server     = undef,
  $versionlock        = undef,
  $version_xtrabackup = undef,
  $xtrabackup_name    = undef,
  $server_shared_compat_name = 'Percona-Server-shared-compat'
) {

  $percona_major_version        = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version       = regsubst($percona_major_version, '\.', '', 'G')
  $percona_package_version      = regsubst($version_server, '^(.*?)-(.*)','\1')
  $percona_package_release      = regsubst($version_server, '^(.*?)-(.*)','\2')
  $number_percona_major_version = 0 + Integer($_percona_major_version)

  if $xtrabackup_name == undef  {
    fail("percona::Cluster::Package[${xtrabackup_name}]: must be given")
  }

  if $version_galera == undef and $number_percona_major_version < 57 {
      fail("Percona::Cluster::Package[${version_galera}]: must be given if version_server < 57")
  }

  if $version_galera != undef {
    $galera_major_version   = regsubst($version_galera, '^(\d)\.(\d*)-(.*)','\1')
    $_galera_major_version  = regsubst($galera_major_version, '\.', '', 'G')
    $galera_package_version = regsubst($version_galera, '^(.*?)-(.*)','\1')
    $galera_package_release = regsubst($galera_major_version, '^(.*?)-(.*)','\2')
  }

  case $versionlock {
    true:    { $percona_versionlock = 'present' }
    false:   { $percona_versionlock = 'absent' }
    default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false') }
  }

  if $number_percona_major_version >= 80 {
    case Integer($::operatingsystemmajrelease) {
      8: {
        Dnf::Module <| title == 'python-27' |>
        package {
          $package_name :
            ensure => $version_server;
          $xtrabackup_name :
            ensure => $version_xtrabackup;
        }
      }
      default: {
        # We're only doing this for RHEL8
      }
    }

    ['server','client','shared', 'shared-compat'].each |String $percona_component| {
      yum::versionlock { "percona-xtradb-cluster-${percona_component}":
        ensure  => "${percona_versionlock}",
        version => "${percona_package_version}",
        release => "${percona_package_release}",
        epoch   => 0,
        arch    => 'x86_64',
      }
    }

  }else{
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
  exec { 'remove-mariadb-connector':
    command => '/bin/rpm -e --nodeps mariadb-connector-c-config',
    onlyif  => '/bin/rpm -qi mariadb-connector-c-config',
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
    -> Exec['remove-mariadb-connector']
    -> Package["Percona-XtraDB-Cluster-galera-${_galera_major_version}"]
    -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
    -> Package["Percona-XtraDB-Cluster-garbd-${_galera_major_version}"]

    ['garbd','galera'].each |String $percona_component| {
      yum::versionlock { "Percona-XtraDB-Cluster-${percona_component}-${_galera_major_version}":
        ensure  => "${percona_versionlock}",
        version => "${galera_package_version}",
        release => "${galera_package_release}",
        epoch   => 0,
        arch    => 'x86_64',
      }
    }
  }
  if $number_percona_major_version >= 57 and $number_percona_major_version < 80 {
    case Integer($::operatingsystemmajrelease) {
      6: {
        package {
          "Percona-XtraDB-Cluster-garbd-${_percona_major_version}" :
            ensure => $version_server;
          $server_shared_compat_name :
            ensure => present;
        }
        Exec['remove-Percona-Server-shared-56']
        -> Exec['remove-mariadb-libs']
        -> Exec['remove-mariadb-connector']
        -> Package["Percona-XtraDB-Cluster-shared-${_percona_major_version}"]
        -> Package[$server_shared_compat_name]
        -> Service['postfix']
        -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
        -> Package[$xtrabackup_name]
        -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
        -> Package["Percona-XtraDB-Cluster-garbd-${_percona_major_version}"]

        yum::versionlock { "Percona-XtraDB-Cluster-garbd-${_percona_major_version}":
          ensure  => "${percona_versionlock}",
          version => "${percona_package_version}",
          release => "${percona_package_release}",
          epoch   => 0,
          arch    => 'x86_64',
        }
      }
      7: {
        package {
          "Percona-XtraDB-Cluster-garbd-${_percona_major_version}" :
            ensure => $version_server;
          "Percona-XtraDB-Cluster-shared-compat-${_percona_major_version}" :
            ensure => $version_server;
        }
        Exec['remove-Percona-Server-shared-56']
        -> Exec['remove-mariadb-libs']
        -> Exec['remove-mariadb-connector']
        -> Package["Percona-XtraDB-Cluster-shared-compat-${_percona_major_version}"]
        -> Service['postfix']
        -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
        -> Package["Percona-XtraDB-Cluster-garbd-${_percona_major_version}"]

        ['garbd','shared-compat'].each |String $percona_component| {
          yum::versionlock { "Percona-XtraDB-Cluster-${percona_component}-${_percona_major_version}":
            ensure  => "${percona_versionlock}",
            version => "${percona_package_version}",
            release => "${percona_package_release}",
            epoch   => 0,
            arch    => 'x86_64',
          }
        }
      }
      8: {
        package {
          "Percona-XtraDB-Cluster-garbd-${_percona_major_version}" :
            ensure => $version_server;
        }
        Exec['remove-Percona-Server-shared-56']
        -> Exec['remove-mariadb-libs']
        -> Exec['remove-mariadb-connector']
        -> Package["Percona-XtraDB-Cluster-shared-${_percona_major_version}"]
        -> Service['postfix']
        -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
        -> Package[$xtrabackup_name]
        -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
        -> Package["Percona-XtraDB-Cluster-garbd-${_percona_major_version}"]

        ['garbd'].each |String $percona_component| {
          yum::versionlock { "Percona-XtraDB-Cluster-${percona_component}-${_percona_major_version}":
            ensure  => "${percona_versionlock}",
            version => "${percona_package_version}",
            release => "${percona_package_release}",
            epoch   => 0,
            arch    => 'x86_64',
          }
        }
      }
      default: {}
    }

    ['server','client','shared'].each |String $percona_component| {
      yum::versionlock { "Percona-XtraDB-Cluster-${percona_component}-${_percona_major_version}":
        ensure  => "${percona_versionlock}",
        version => "${percona_package_version}",
        release => "${percona_package_release}",
        epoch   => 0,
        arch    => 'x86_64',
      }
    }
  }
}
