class percona::server::package(
  $package_shared_compat=undef
  $version_shared_compat=undef,
  $version_shared=undef,
  $version_server=undef,
  $version_client=undef,
  $version_debuginfo=undef,
  $versionlock=false
) {

  $percona_major_version = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version = regsubst($percona_major_version, '\.', '', 'G')
  debug("Percona major version = ${percona_major_version}")

  if defined($package_shared_compat) {
    $real_package_shared_compat = $package_shared_compat
  } else {
    $real_package_shared_compat = 'Percona-Server-shared-compat'
  }

  package {
    $real_package_shared_compat :
      ensure => $version_shared_compat;
    "Percona-Server-shared-${_percona_major_version}" :
      ensure => $version_shared;
    "Percona-Server-server-${_percona_major_version}" :
      ensure => $version_server;
    "Percona-Server-client-${_percona_major_version}" :
      ensure => $version_client;
    "Percona-Server-${_percona_major_version}-debuginfo" :
      ensure => $version_debuginfo;
  }

  Package[$real_package_shared_compat]
    -> Package["Percona-Server-shared-${_percona_major_version}"]
    -> Package["Percona-Server-server-${_percona_major_version}"]
    -> Package["Percona-Server-client-${_percona_major_version}"]
    -> Package["Percona-Server-${_percona_major_version}-debuginfo"]

  case $versionlock {
    true: {
      packagelock { $real_package_shared_compat : }
      packagelock { "Percona-Server-shared-${_percona_major_version}": }
      packagelock { "Percona-Server-server-${_percona_major_version}": }
      packagelock { "Percona-Server-client-${_percona_major_version}": }
      packagelock { "Percona-Server-${_percona_major_version}-debuginfo": }
    }
    false: {
      packagelock { $real_package_shared_compat : ensure => absent }
      packagelock { "Percona-Server-shared-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-Server-server-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-Server-client-${_percona_major_version}": ensure => absent }
      packagelock { "Percona-Server-${_percona_major_version}-debuginfo": ensure => absent }
    }
    default: { fail('Class[Percona::Server::Package]: parameter versionlock must be true or false')}
  }


}
