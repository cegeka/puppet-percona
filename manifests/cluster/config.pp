# Class: percona::cluster::config
#
# Usage: this class should not be called directly
#
class percona::cluster::config(
  $server_id          = undef,
  $socket_cnf         ='/var/lib/mysql/mysql.sock',
  $data_dir           = '/data/mysql',
  $tmp_dir            = '/data/mysql_tmp',
  $binlog_dir         = '/data/mysql_binlog',
  $ip_address         = undef,
  $cluster_address    = undef,
  $cluster_name       = undef,
  $sst_method         = 'rsync',
  $replace_mycnf      = false,
  $replace_root_mycnf = false,
  $ssl                = false,
  $ssl_autogen        = false,
  $ssl_ca             = undef,
  $ssl_key            = undef,
  $ssl_cert           = undef,
  $default_config     = {
    bind_address       => '0.0.0.0',
    character_set_server => 'utf8',
    pxc_strict_mode    => undef,
    wsrep_sst_auth     => undef,
    wsrep_sst_receive_address => $::ipaddress,
    wsrep_node_address => "${::ipaddress}:4567",
    wsrep_node_incoming_address => "${::ipaddress}:4567",
    wsrep_cluster_address => "gcomm://${cluster_address}",
    wsrep_cluster_name  => $cluster_name,
    wsrep_provider => '/usr/lib64/libgalera_smm.so',
    wsrep_slave_threads => 8,
    wsrep_causal_reads => 1,
    wsrep_sync_wait    => undef,
    wsrep_log_conflicts => 'ON',
    log-bin            => "${binlog_dir}/mysql-bin",
    log-bin-index      => "${binlog_dir}/bin-log.index",
    max_binlog_size    => '100M',
    binlog_format      => 'ROW',
    binlog_do_db       => undef,
    binlog_space_limit => '800M',
    binlog_row_image   => undef,
    expire_logs_days   => 10,
    innodb_autoinc_lock_mode => 2,
    innodb_ft_min_token_size => 2,
    log_bin_trust_function_creators => undef,
    slow_query_log_file  => '/var/log/mysql-slow.log',
    slow_query_log     => 'ON',
    log_slave_updates  => 'ON',
    sql_mode           => undef,
    max_connections    => undef,
    max_connect_errors => undef,
    time_zone          => undef,
    max_allowed_packet => '16M',
    gtid_mode          => undef,
    enforce_gtid_consistency => undef,
    innodb_locks_unsafe_for_binlog => undef,
    innodb_buffer_pool_size => '256M',
    thread_stack       => undef,
    thread_cache_size  => undef,
    query_cache_limit  => undef,
    query_cache_size   => undef,
    skip_name_resolve  => 'ON'
  },
  $additional_config = {}
) {

  $config = deep_merge($default_config,$additional_config)

  file { '/etc/my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/cluster/my.cnf.erb"),
    replace => $replace_mycnf,
    notify  => Service['mysqld']
  }

  file { $config['slow_query_log_file'] :
    ensure => present,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '644'
  }

  if $::selinux {
    notify {'ssl-disable':
      message => 'Percona Cluster is not selinux compatible at this point in
                  time.'
    }
  }
  file {
    $data_dir:
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql';
    $tmp_dir:
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql';
    $binlog_dir:
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql';
  }

  if $ssl {
    if $ssl_autogen {
      fail("[Percona::Cluster::Config] You can not configure SSL autogen in clustered mode.
        It is important that your cluster uses the same SSL certificates on all nodes.")
    }
    class { '::percona::cluster::ssl':
      ssl_autogen => $ssl_autogen,
      ssl_ca   => $ssl_ca,
      ssl_key  => $ssl_key,
      ssl_cert => $ssl_cert,
    }
  }

}
