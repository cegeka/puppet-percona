class percona::cluster::package($version_shared_compat=undef, $version_server=undef, $version_client=undef, $version_galera=undef, $versionlock=false) {

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

  case $versionlock {
    true: {
      packagelock { 'Percona-Server-shared-compat': }
      packagelock { 'Percona-XtraDB-Cluster-server': }
      packagelock { 'Percona-XtraDB-Cluster-client': }
      packagelock { 'Percona-XtraDB-Cluster-galera': }
    }
    false: {
      packagelock { 'Percona-Server-shared-compat': ensure => absent }
      packagelock { 'Percona-XtraDB-Cluster-server': ensure => absent }
      packagelock { 'Percona-XtraDB-Cluster-client': ensure => absent }
      packagelock { 'Percona-XtraDB-Cluster-galera': ensure => absent }
    }
    default: { fail('Class[Percona::Cluster::Package]: parameter versionlock must be true or false')}
  }

}
