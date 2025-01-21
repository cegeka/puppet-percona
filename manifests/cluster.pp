class percona::cluster (
  $server_id                 = undef,
  $package_name              = undef,
  $version_galera            = undef,
  $version_server            = undef,
  $versionlock               = undef,
  $version_xtrabackup        = undef,
  $xtrabackup_name           = undef,
  $data_dir                  = '/data/mysql',
  $tmp_dir                   = '/data/mysql_tmp',
  $binlog_dir                = '/data/mysql_binlog',
  $error_log                 = '/var/log/mysqld.log',
  $ip_address                = undef,
  $cluster_address           = undef,
  $cluster_name              = undef,
  $sst_method                = 'rsync',
  $replace_mycnf             = false,
  $replace_root_mycnf        = false,
  $socket_cnf                = '/var/lib/mysql/mysql.sock',
  $server_shared_compat_name = 'Percona-Server-shared-compat',
  $service_ensure            = 'running',
  $service_enable            = true,
  $ssl                       = false,
  $ssl_autogen               = true,
  $ssl_ca                    = undef,
  $ssl_cert                  = undef,
  $ssl_key                   = undef,
  $character_set             = undef,
  $secret_file               = undef,
  $root_password             = undef,
  $additional_config         = undef,
  $ssl_ca_client_path        = undef,
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
    package_name              => $package_name,
    version_server            => $version_server,
    versionlock               => $versionlock,
    version_xtrabackup        => $version_xtrabackup,
    version_galera            => $version_galera,
    xtrabackup_name           => $xtrabackup_name,
    server_shared_compat_name => $server_shared_compat_name
  }

  class { 'percona::cluster::config':
    server_id          => $server_id,
    data_dir           => $data_dir,
    tmp_dir            => $tmp_dir,
    binlog_dir         => $binlog_dir,
    error_log          => $error_log,
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
    ssl_key            => $ssl_key,
    additional_config  => $additional_config,
    ssl_ca_client_path => $ssl_ca_client_path,
  }

  class { '::percona::cluster::service':
    server_id      => $server_id,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  }

  class { 'percona::cluster::root':
    server_id          => $server_id,
    socket_cnf         => $socket_cnf,
    replace_root_mycnf => $replace_root_mycnf,
    secret_file        => $secret_file,
    root_password      => $root_password,
  }

  # The if statement is temporary until all percona-clusters have been upgraded to v8.0.37
  if ($version_server == '8.0.37-29.1.el8' ) {
    service { 'percona-telemetry-agent':
      ensure => stopped,
      enable => false,
    }
  }

  # Install package, configure mysql, bootstrap cluster, configure root user, start mysql
  Class['percona::cluster::package']
    -> Class['percona::cluster::config']
    -> Exec<| title == 'bootstrap_percona_cluster' |>
    -> Class['percona::cluster::root']
    -> Service['mysql@bootstrap']
}
