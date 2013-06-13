class percona::server::package($version_shared_compat=undef,$version_shared=undef,$version_server=undef,$version_client=undef) {

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

}
