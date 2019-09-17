class percona::toolkit($version=undef, $versionlock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  package { 'percona-toolkit':
    ensure => $version
  }

  if $versionlock {
    yum::versionlock { "0:percona-toolkit-${version}.*": }
  } else {
    yum::versionlock { "0:percona-toolkit-${version}.*": ensure => absent }
  }

}
