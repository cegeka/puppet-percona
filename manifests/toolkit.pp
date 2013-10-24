class percona::toolkit($version=undef, $version_lock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  package { 'percona-toolkit':
    ensure => $version
  }

  case $version_lock {
    true: {
      packagelock { 'percona-toolkit': }
    }
    false: {
      packagelock { 'percona-toolkit': ensure => absent }
    }
    default: { fail('Class[Percona::Toolkit]: parameter version_lock must be true or false')}
  }

}
