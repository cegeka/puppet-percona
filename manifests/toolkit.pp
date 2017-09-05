class percona::toolkit($version=undef, $versionlock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  package { 'percona-toolkit':
    ensure => $version
  }

  if $versionlock {
    packagelock { 'percona-toolkit': }
  } else {
    packagelock { 'percona-toolkit': ensure => absent }
  }

}
