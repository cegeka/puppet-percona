class percona::server::package($version_shared_compat=undef,$version_shared=undef,$version_server=undef,$version_client=undef, $versionlock=false) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  package {
    'Percona-Server-shared-compat' :
      ensure => $version_shared_compat;
    "Percona-Server-shared-${_percona_major_version}" :
      ensure => $version_shared;
    "Percona-Server-server-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-Server-client-${_percona_major_version}" :
      ensure => $version_client;
  }

  Package['Percona-Server-shared-compat']
    -> Package["Percona-Server-shared-${_percona_major_version}"]
    -> Package["Percona-Server-server-${_percona_major_version}"]
    -> Package["Percona-Server-client-${_percona_major_version}"]

  case $versionlock {
    true: {
      packagelock { 'Percona-Server-shared-compat': }
      packagelock { "Percona-Server-shared-${_percona_major_version}": }
      packagelock { "Percona-Server-server-${_percona_major_version}": }
      packagelock { "Percona-Server-client-${_percona_major_version}": }
    }
    false: {
      packagelock { 'Percona-Server-shared-compat': ensure => absent }
      packagelock { "Percona-Server-shared-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-Server-server-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-Server-client-${_percona_major_version}": ensure => absent }
    }
    default: { fail('Class[Percona::Server::Package]: parameter versionlock must be true or false')}
  }


}
