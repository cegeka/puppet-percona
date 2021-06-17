# Class: percona::server::config
#
# Usage: this class should not be called directly
#
class percona::server::config (
  $socket_cnf         ='/var/lib/mysql/mysql.sock',
  $data_dir           ='/data/mysql',
  $tmp_dir            ='/data/mysql_tmp',
  $replace_mycnf      = false,
  $replace_root_mycnf = false,
  $secret_file        = undef,
  $ssl                = false,
  $ssl_autogen        = true,
  $ssl_ca             = undef,
  $ssl_key            = undef,
  $ssl_cert           = undef,
  $character_set      = 'utf8',
  $default_config     = {
    server-id          => 1,
    bind_address       => '0.0.0.0',
    character_set_server => 'utf8',
    log-bin            => 'mysql-bin.log',
    log-bin-index      => 'bin-log.index',
    max_binlog_size    => '100M',
    binlog_format      => 'ROW',
    binlog_do_db       => undef,
    binlog_space_limit => '800M',
    binlog_row_image   => undef,
    expire_logs_days   => 10,
  },
  $additional_config  = {},
) {

  $config = deep_merge($default_config,$additional_config)

  file { '/etc/my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/server/my.cnf.erb"),
    replace => $replace_mycnf,
    notify  => Service['mysqld']
  }
  if $::selinux {
    file_line {
      'selinux_context_mysql_datadir':
        path => '/etc/selinux/targeted/contexts/files/file_contexts.local',
        line => "${data_dir}(/.*)? system_u:object_r:mysqld_db_t:s0";
      'selinux_context_mysql_tmpdir':
        path => '/etc/selinux/targeted/contexts/files/file_contexts.local',
        line => "${tmp_dir}(/.*)? system_u:object_r:mysqld_db_t:s0"
    }
    file {
      $data_dir:
        ensure  => directory,
        owner   => 'mysql',
        group   => 'mysql',
        seltype => 'mysqld_db_t',
        require => [ File_line['selinux_context_mysql_datadir'] ];
      $tmp_dir:
        ensure  => directory,
        owner   => 'mysql',
        group   => 'mysql',
        seltype => 'mysqld_db_t',
        require => [ File[$data_dir], File_line['selinux_context_mysql_tmpdir'] ];
    }
  } else {
    file {
      $data_dir:
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql';
      $tmp_dir:
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql';
    }
  }

  if $ssl {
    class { '::percona::server::ssl':
      ssl_ca   => $ssl_ca,
      ssl_key  => $ssl_key,
      ssl_cert => $ssl_cert,
    }
  }

}
