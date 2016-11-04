class percona::cluster::package (
  $version_server=undef,
  $versionlock=false
) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  package {
    "Percona-XtraDB-Cluster-full-${_percona_major_version}":
      ensure => $version_server;
  }

  exec { 'remove-Percona-Server-shared':
    command => "/bin/rpm -e --nodeps Percona-Server-shared-${_percona_major_version}",
    onlyif  => "/bin/rpm -qi Percona-Server-shared-${_percona_major_version}"
  }

  Exec['remove-Percona-Server-shared']
  -> Package["Percona-XtraDB-Cluster-full-${_percona_major_version}"]

  case $versionlock {
    true: {
      packagelock { "Percona-XtraDB-Cluster-full-${_percona_major_version}": }
    }
    false: {
      packagelock { "Percona-XtraDB-Cluster-full-${_percona_major_version}": ensure => absent }
    }
    default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false')}
  }

}
