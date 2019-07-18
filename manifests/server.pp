class percona::server (
  $socket_cnf          = '/var/lib/mysql/mysql.sock',
  $version_server      = undef,
  $versionlock         = false,
  $data_dir            = '/data/mysql',
  $tmp_dir             = '/data/mysql_tmp',
  $replace_mycnf       = false,
  $replace_root_mycnf  = false,
) {

  if ! $version_server {
    fail('Class[Percona::Server]: parameter version_server must be provided')
  }

  class { 'percona::server::package':
    version_server => $version_server,
    versionlock    => $versionlock
  }

  class { 'percona::server::config':
    data_dir           => $data_dir,
    tmp_dir            => $tmp_dir,
    replace_mycnf      => $replace_mycnf,
    replace_root_mycnf => $replace_root_mycnf,
    socket_cnf         => $socket_cnf
  }

  Class['percona::server::package'] -> Class['percona::server::config']

  service { 'mysql':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Class['percona::server::package'], Class['percona::server::config'] ],
  }
}
