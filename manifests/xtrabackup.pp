class percona::xtrabackup($version=undef, $packagelock=false) {

  if ! $version {
    fail('Class[Percona::Xtrabackup]: parameter version must be provided')
  }

  package { 'percona-xtrabackup':
    ensure => $version
  }

  if $packagelock {
    packagelock { 'percona-xtrabackup': }
  }

}
