class percona::cluster::package($version_shared_compat=undef, $version_server=undef, $version_client=undef, $version_galera=undef, $packagelock=false) {

  package {
    'Percona-Server-shared-compat' :
      ensure => $version_shared_compat;
    'Percona-XtraDB-Cluster-server' :
      ensure => $version_server;
    'Percona-XtraDB-Cluster-client' :
      ensure => $version_client;
    'Percona-XtraDB-Cluster-galera' :
      ensure => $version_galera;
  }

  Package['Percona-Server-shared-compat'] -> Package['Percona-XtraDB-Cluster-server'] -> Package['Percona-XtraDB-Cluster-client'] -> Package['Percona-XtraDB-Cluster-galera']

  if $packagelock {
    packagelock { 'Percona-Server-shared-compat': }
    packagelock { 'Percona-XtraDB-Cluster-server': }
    packagelock { 'Percona-XtraDB-Cluster-client': }
    packagelock { 'Percona-XtraDB-Cluster-galera': }
  }

}
