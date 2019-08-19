class percona::cluster (
  $version_galera            = undef,
  $version_server            = undef,
  $versionlock               = undef,
  $version_xtrabackup        = undef,
  $xtrabackup_name           = undef,
  $data_dir                  = '/data/mysql',
  $tmp_dir                   = '/data/mysql_tmp',
  $ip_address                = undef,
  $cluster_address           = undef,
  $cluster_name              = undef,
  $sst_method                = 'rsync',
  $replace_mycnf             = false,
  $replace_root_mycnf        = false,
  $socket_cnf                = '/var/lib/mysql/mysql.sock',
  $server_shared_compat_name = 'Percona-Server-shared-compat',
  $ssl                       = false,
  $ssl_autogen               = true,
  $ssl_ca                    = undef,
  $ssl_cert                  = undef,
  $ssl_key                   = undef,
) {

  if ! $version_server {
    fail('Class[Percona::Cluster]: parameter version_server must be provided')
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
  if $cluster_address !~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}(,((?:[0-9]{1,3}\.){3}[0-9]{1,3}))*$/ {
    fail('Class[Percona::Cluster]: parameter cluster_address must be a comma separated list of IP addresses')
  }

  if ! $cluster_name {
    fail('Class[Percona::Cluster]: parameter cluster_name must be provided')
  }

  if ! ($sst_method in ['mysqldump', 'rsync', 'xtrabackup', 'xtrabackup-v2']) {
    fail('Class[Percona::Cluster]: parameter sst_method must be mysqldump, rsync, xtrabackup or xtrabackup-v2')
  }

  class { 'percona::cluster::package':
    version_server            => $version_server,
    versionlock               => $versionlock,
    version_xtrabackup        => $version_xtrabackup,
    version_galera            => $version_galera,
    xtrabackup_name           => $xtrabackup_name,
    server_shared_compat_name => $server_shared_compat_name
  }

  class { 'percona::cluster::config':
    data_dir           => $data_dir,
    tmp_dir            => $tmp_dir,
    ip_address         => $ip_address,
    cluster_address    => $cluster_address,
    cluster_name       => $cluster_name,
    sst_method         => $sst_method,
    replace_mycnf      => $replace_mycnf,
    socket_cnf         => $socket_cnf,
    replace_root_mycnf => $replace_root_mycnf,
    ssl                => $ssl,
    ssl_ca             => $ssl_ca,
    ssl_cert           => $ssl_cert,
    ssl_key            => $ssl_key
  }

  Class['percona::cluster::package'] -> Class['percona::cluster::config']
  service { 'mysql':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class['percona::cluster::package'], Class['percona::cluster::config'] ],
  }
}
