class percona::server (
  $socket_cnf          = '/var/lib/mysql/mysql.sock',
  $package_name        = undef,
  $version_server      = undef,
  $xtrabackup_name     = undef,
  $version_xtrabackup  = 'present',
  $versionlock         = false,
  $data_dir            = '/data/mysql',
  $tmp_dir             = '/data/mysql_tmp',
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

  if $facts['operatingsystemmajrelease'] == '6' {
    $service_name = 'mysql'
  } else {
    $service_name = 'mysqld'
  }

  class { 'percona::server::package':
    package_name    => $package_name,
    version_server  => $version_server,
    versionlock     => $versionlock,
    xtrabackup_name => $xtrabackup_name
  }

  class { 'percona::server::config':
    data_dir            => $data_dir,
    tmp_dir             => $tmp_dir,
    replace_mycnf       => $replace_mycnf,
    socket_cnf          => $socket_cnf,
    ssl                 => $ssl,
    ssl_autogen         => $ssl_autogen,
    ssl_ca              => $ssl_ca,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    additional_config   => $additional_config,
    service_name        => $service_name
  }

  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class['percona::server::package'], Class['percona::server::config'] ],
  }

  class { 'percona::server::root':
    socket_cnf         => $socket_cnf,
    replace_root_mycnf => $replace_root_mycnf,
    secret_file        => $secret_file,
    root_password      => $root_password
  }

  Class['percona::server::package'] -> Class['percona::server::config'] -> Service[$service_name] -> Class['percona::server::root']

}
