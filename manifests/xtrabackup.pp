class percona::xtrabackup(
  $version=undef,
  $version_debuginfo=undef,
  $versionlock=false
) {

  if ! $version {
    fail('Class[Percona::Xtrabackup]: parameter version must be provided')
  }
  if ! $version_debuginfo {
    fail('Class[Percona::Xtrabackup]: parameter version_debuginfo must be provided')
  }

  package { 'percona-xtrabackup':
    ensure => $version
  }

  case $versionlock {
    true: {
      yum::versionlock { "0:percona-xtrabackup-${version}.*": }
    }
    false: {
      yum::versionlock { "0:percona-xtrabackup-${version}.*": ensure => absent }
    }
    default: { fail('Class[Percona::Xtrabackup]: parameter versionlock must be true or false')}
  }

}
