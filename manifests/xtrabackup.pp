class percona::xtrabackup($version=undef) {

  if ! $version {
    fail('Class[Percona::Xtrabackup]: parameter version must be provided')
  }

  package { 'percona-xtrabackup':
    ensure => $version
  }

}
