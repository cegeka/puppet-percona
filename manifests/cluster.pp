class percona::cluster( $version_shared_compat=undef,
                        $version_server=undef,
                        $version_client=undef,
                        $version_galera=undef,
                        $data_dir='/data/mysql',
                        $tmp_dir='/data/tmp',
                        $ip_address=undef,
                        $cluster_address=undef,
                        $cluster_name=undef,
                        $sst_method='rsync'
) {

  if ! $version_shared_compat {
    fail('Class[Percona::Cluster]: parameter version_shared_compat must be provided')
  }

  if ! $version_server {
    fail('Class[Percona::Cluster]: parameter version_server must be provided')
  }

  if ! $version_client {
    fail('Class[Percona::Cluster]: parameter version_client must be provided')
  }

  if ! $version_galera {
    fail('Class[Percona::Cluster]: parameter version_galera must be provided')
  }

  if ! $ip_address {
    fail('Class[Percona::Cluster]: parameter ip_address must be provided')
  }
  if $ip_address !~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}/ {
    fail('Class[Percona::Cluster]: parameter ip_address must be a valid IP address')
  }

  if ! $cluster_address {
    fail('Class[Percona::Cluster]: parameter cluster_address must be provided')
  }
  if $cluster_address !~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3},*)*/ {
    fail('Class[Percona::Cluster]: parameter cluster_address must be a comma separated list of IP addresses')
  }

  if ! $cluster_name {
    fail('Class[Percona::Cluster]: parameter cluster_name must be provided')
  }

  if ! ($sst_method in ['mysqldump', 'rsync', 'xtrabackup']) {
    fail('Class[Percona::Cluster]: parameter sst_method must be mysqldump, rsync or xtrabackup')
  }

  class { 'percona::cluster::package':
    version_shared_compat => $version_shared_compat,
    version_server        => $version_server,
    version_client        => $version_client,
    version_galera        => $version_galera
  }

  class { 'percona::cluster::config':
    data_dir        => $data_dir,
    tmp_dir         => $tmp_dir,
    ip_address      => $ip_address,
    cluster_address => $cluster_address,
    cluster_name    => $cluster_name,
    sst_method      => $sst_method
  }

  Class['percona::cluster::package'] -> Class['percona::cluster::config']

}
