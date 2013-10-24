class percona::xtrabackup($version=undef, $version_lock=false) {

  if ! $version {
    fail('Class[Percona::Xtrabackup]: parameter version must be provided')
  }

  package { 'percona-xtrabackup':
    ensure => $version
  }

  case $version_lock {
    true: {
      packagelock { 'percona-xtrabackup': }
    }
    false: {
      packagelock { 'percona-xtrabackup': ensure => absent }
    }
    default: { fail('Class[Percona::Xtrabackup]: parameter version_lock must be true or false')}
  }

}
