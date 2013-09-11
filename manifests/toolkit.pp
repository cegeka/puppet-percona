class percona::toolkit($version=undef, $packagelock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  package { 'percona-toolkit':
    ensure => $version
  }

  if $packagelock {
    packagelock { 'percona-toolkit': }
  }

}
