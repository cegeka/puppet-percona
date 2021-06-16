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
  $character_set       = undef,
  $secret_file         = undef,
  $root_password       = undef
) {

  if ! $version_server {
    fail('Class[Percona::Server]: parameter version_server must be provided')
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
    ssl_ca              => $ssl_ca,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    character_set       => $character_set
  }


  service { 'mysqld':
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

  Class['percona::server::package'] -> Class['percona::server::config'] -> Service['mysqld'] -> Class['percona::server::root']

}
