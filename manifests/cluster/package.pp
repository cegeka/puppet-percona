class percona::cluster::package (
  $version_server     = undef,
  $versionlock        = undef, 
  $version_galera     = undef,
  $version_xtrabackup = undef,
) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  $galera_major_version = regsubst($version_galera, '^(\d)\.(\d*)-(.*)','\1')
  $_galera_major_version = regsubst($galera_major_version, '\.', '', 'G')

  debug("Galera major version = ${galera_major_version}")

   package {
    "Percona-XtraDB-Cluster-server-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-client-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-shared-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-test-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-galera-${_galera_major_version}" :
      ensure => $version_galera;
    "Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo" :
      ensure => $version_galera;
    "Percona-XtraDB-Cluster-garbd-${_galera_major_version}" :
      ensure => $version_galera;
    "percona-xtrabackup" :
      ensure => $version_xtrabackup;
    "percona-xtrabackup-debuginfo" :
      ensure => $version_xtrabackup;
  }

  exec { 'remove-Percona-Server-shared':
    command => "/bin/rpm -e --nodeps Percona-Server-shared-${_percona_major_version}",
    onlyif  => "/bin/rpm -qi Percona-Server-shared-${_percona_major_version}",
    require => [ Package['net-snmp'], Package['postfix'] ]
  }
  exec { 'remove-mariadb-libs':
    command => "/bin/rpm -e --nodeps mariadb-libs",
    onlyif  => "/bin/rpm -qi mariadb-libs",
    require => [ Package['net-snmp'], Package['postfix']]
  }

  Exec['remove-Percona-Server-shared']
  -> Exec['remove-mariadb-libs'] 
  -> Package["Percona-XtraDB-Cluster-galera-${_galera_major_version}"]
  -> Package["Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo"]
  -> Package["Percona-XtraDB-Cluster-shared-${_percona_major_version}"]
  -> Service['postfix']
  -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
  -> Package["Percona-XtraDB-Cluster-test-${_percona_major_version}"]
  -> Package["percona-xtrabackup"]
  -> Package["percona-xtrabackup-debuginfo"]
  -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
  -> Package["Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo"] 
  -> Package["Percona-XtraDB-Cluster-garbd-${_galera_major_version}"] 

   case $versionlock {
     true: {
       packagelock { "Percona-XtraDB-Cluster-server-${_percona_major_version}-${version_server}": }
       packagelock { "Percona-XtraDB-Cluster-client-${_percona_major_version}-${version_server}": }
       packagelock { "Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo-${version_server}": }
       packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-${version_galera}": }
       packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo-${version_galera}": }
       packagelock { "Percona-XtraDB-Cluster-shared-${_percona_major_version}-${version_server}": }
       packagelock { "Percona-XtraDB-Cluster-test-${_percona_major_version}-${version_server}": }
       packagelock { "percona-xtrabackup-${version_xtrabackup}": }
       packagelock { "percona-xtrabackup-debuginfo-${version_xtrabackup}": }
       packagelock { "Percona-XtraDB-Cluster-garbd-${_galera_major_version}-${version_galera}": }
     }
     false: {
       packagelock { "Percona-XtraDB-Cluster-server-${_percona_major_version}-${version_server}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-client-${_percona_major_version}-${version_server}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo-${version_server}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-${version_galera}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo-${version_galera}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-shared-${_percona_major_version}-${version_server}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-test-${_percona_major_version}-${version_server}": ensure => absent }
       packagelock { "percona-xtrabackup-${version_xtrabackup}": ensure => absent }
       packagelock { "percona-xtrabackup-debuginfo-${version_xtrabackup}": ensure => absent }
       packagelock { "Percona-XtraDB-Cluster-garbd-${_galera_major_version}-${version_galera}": ensure => absent }
     }
    default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false')}
  }
}
