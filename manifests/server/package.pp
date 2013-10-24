class percona::server::package($version_shared_compat=undef,$version_shared=undef,$version_server=undef,$version_client=undef, $versionlock=false) {

  package {
    'Percona-Server-shared-compat' :
      ensure => $version_shared_compat;
    'Percona-Server-shared-55' :
      ensure => $version_shared;
    'Percona-Server-server-55' :
      ensure => $version_server;
    'Percona-Server-client-55' :
      ensure => $version_client;
  }

  Package['Percona-Server-shared-compat'] -> Package['Percona-Server-shared-55'] -> Package['Percona-Server-server-55'] -> Package['Percona-Server-client-55']

  case $versionlock {
    true: {
      packagelock { 'Percona-Server-shared-compat': }
      packagelock { 'Percona-Server-shared-55': }
      packagelock { 'Percona-Server-server-55': }
      packagelock { 'Percona-Server-client-55': }
    }
    false: {
      packagelock { 'Percona-Server-shared-compat': ensure => absent }
      packagelock { 'Percona-Server-shared-55': ensure => absent }
      packagelock { 'Percona-Server-server-55': ensure => absent }
      packagelock { 'Percona-Server-client-55': ensure => absent }
    }
    default: { fail('Class[Percona::Server::Package]: parameter versionlock must be true or false')}
  }


}
