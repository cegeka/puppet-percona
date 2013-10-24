class percona::toolkit($version=undef, $versionlock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  package { 'percona-toolkit':
    ensure => $version
  }

  case $versionlock {
    true: {
      packagelock { 'percona-toolkit': }
    }
    false: {
      packagelock { 'percona-toolkit': ensure => absent }
    }
    default: { fail('Class[Percona::Toolkit]: parameter versionlock must be true or false')}
  }

}
