class percona::server::package(
  $version_server=undef,
  $versionlock=false
) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  package {
    "Percona-Server-server-${_percona_major_version}" :
      ensure => $version_server;
  }

  case $versionlock {
    true: {
      packagelock { "Percona-Server-server-${_percona_major_version}": }
    }
    false: {
      packagelock { "Percona-Server-server-${_percona_major_version}": ensure => absent }
    }
    default: { fail('Class[Percona::Server::Package]: parameter versionlock must be true or false')}
  }


}
