class percona::server (
  $socket_cnf          = '/var/lib/mysql/mysql.sock',
  $package_name        = undef,
  $version_server      = undef,
  $xtrabackup_name     = undef,
  $version_xtrabackup  = 'present',
  $versionlock         = false,
  $data_dir            = '/data/mysql',
  $tmp_dir             = '/data/mysql_tmp',
  $error_log           = '/var/log/mysqld.log',
  $replace_mycnf       = false,
  $replace_root_mycnf  = false,
  $service_ensure      = 'running',
  $service_enable      = true,
  $ssl                 = false,
  $ssl_autogen         = true,
  $ssl_ca              = undef,
  $ssl_cert            = undef,
  $ssl_key             = undef,
  $secret_file         = undef,
  $root_password       = undef,
  $additional_config   = undef
) {
  if ! $version_server {
    fail('Class[Percona::Server]: parameter version_server must be provided')
  }

  if $facts['os']['release']['major'] == '6' {
    $service_name = 'mysql'
  } else {
    $service_name = 'mysqld'
  }

  class { 'percona::server::package':
    package_name    => $package_name,
    version_server  => $version_server,
    versionlock     => $versionlock,
    xtrabackup_name => $xtrabackup_name,
  }

  class { 'percona::server::config':
    data_dir          => $data_dir,
    tmp_dir           => $tmp_dir,
    error_log         => $error_log,
    replace_mycnf     => $replace_mycnf,
    socket_cnf        => $socket_cnf,
    ssl               => $ssl,
    ssl_autogen       => $ssl_autogen,
    ssl_ca            => $ssl_ca,
    ssl_cert          => $ssl_cert,
    ssl_key           => $ssl_key,
    additional_config => $additional_config,
    service_name      => $service_name,
    version_server    => $version_server,
  }

  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [Class['percona::server::package'], Class['percona::server::config']],
  }

  class { 'percona::server::root':
    socket_cnf         => $socket_cnf,
    replace_root_mycnf => $replace_root_mycnf,
    secret_file        => $secret_file,
    root_password      => $root_password,
  }

  # Temporary if statement until all percona-servers have been upgraded to at least v8.0.39-30 or higher
  if ( $version_server =~ '8.0.39-30.1' ) {
    # By default Percona now sends telemetry which we do not want since we're working with sensitive data
    # According to the docs disabling the agent is enough to not send logs anymore
    package { 'percona-telemetry-agent':
      ensure => present,
    }
    service { 'percona-telemetry-agent':
      ensure  => stopped,
      enable  => false,
      require => Package['percona-telemetry-agent'],
    }
  }

  Class['percona::server::package'] -> Class['percona::server::config'] -> Service[$service_name] -> Class['percona::server::root']
}
