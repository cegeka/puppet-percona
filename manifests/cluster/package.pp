class percona::cluster::package(
  $version_shared_compat=undef,
  $version_server=undef,
  $version_client=undef,
  $version_debuginfo=undef,
  $version_galera=undef,
  $version_galera_debuginfo=undef,
  $versionlock=false) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  $galera_major_version = regsubst($version_galera, '^(\d)\.(\d)-(.*)','\1')
  $_galera_major_version = regsubst($galera_major_version, '\.', '', 'G')
  debug("Galera major version = ${galera_major_version}")

  package {
    "Percona-XtraDB-Cluster-server-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-XtraDB-Cluster-client-${_percona_major_version}" :
      ensure => $version_client;
    "Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo" :
      ensure => $version_debuginfo;
    "Percona-XtraDB-Cluster-galera-${_galera_major_version}" :
      ensure => $version_galera;
    "Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo" :
      ensure => $version_galera_debuginfo;
  }

  Package["Percona-XtraDB-Cluster-galera-${_galera_major_version}"]
    -> Package["Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo"]
    -> Package["Percona-XtraDB-Cluster-server-${_percona_major_version}"]
    -> Package["Percona-XtraDB-Cluster-client-${_percona_major_version}"]
    -> Package["Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo"]

  case $versionlock {
    true: {
      packagelock { "Percona-XtraDB-Cluster-server-${_percona_major_version}": }
      packagelock { "Percona-XtraDB-Cluster-client-${_percona_major_version}": }
      packagelock { "Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo": }
      packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}": }
      packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo": }
    }
    false: {
      packagelock { "Percona-XtraDB-Cluster-server-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-XtraDB-Cluster-client-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-XtraDB-Cluster-${_percona_major_version}-debuginfo": ensure => absent }
      packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}": ensure => absent }
      packagelock { "Percona-XtraDB-Cluster-galera-${_galera_major_version}-debuginfo": ensure => absent }
    }
    default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false')}
  }

}
