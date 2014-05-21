class percona::server($version_shared_compat=undef,
                      $version_shared=undef,
                      $version_server=undef,
                      $version_client=undef,
                      $version_debuginfo=undef,
                      $versionlock=false,
                      $data_dir='/data/mysql',
                      $tmp_dir='/data/mysql_tmp'
) {

  if ! $version_shared_compat {
    fail('Class[Percona::Server]: parameter version_shared_compat must be provided')
  }

  if ! $version_shared {
    fail('Class[Percona::Server]: parameter version_shared must be provided')
  }

  if ! $version_server {
    fail('Class[Percona::Server]: parameter version_server must be provided')
  }

  if ! $version_client {
    fail('Class[Percona::Server]: parameter version_client must be provided')
  }

  if ! $version_debuginfo {
    fail('Class[Percona::Server]: parameter version_debuginfo must be provided')
  }

  class { 'percona::server::package':
    version_shared_compat => $version_shared_compat,
    version_shared        => $version_shared,
    version_server        => $version_server,
    version_client        => $version_client,
    version_debuginfo     => $version_debuginfo,
    versionlock           => $versionlock
  }

  class { 'percona::server::config':
    data_dir => $data_dir,
    tmp_dir  => $tmp_dir
  }

  Class['percona::server::package'] -> Class['percona::server::config']

}
