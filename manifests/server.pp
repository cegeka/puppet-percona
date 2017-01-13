class percona::server (
  $version_server = undef,
  $versionlock    = false,
  $data_dir       = '/data/mysql',
  $tmp_dir        = '/data/mysql_tmp',
  $replace_mycnf  = false
) {

  if ! $version_server {
    fail('Class[Percona::Server]: parameter version_server must be provided')
  }

  class { 'percona::server::package':
    version_server => $version_server,
    versionlock    => $versionlock
  }

  class { 'percona::server::config':
    data_dir      => $data_dir,
    tmp_dir       => $tmp_dir,
    replace_mycnf => $replace_mycnf
  }

  Class['percona::server::package'] -> Class['percona::server::config']

}
