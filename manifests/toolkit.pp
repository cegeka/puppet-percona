class percona::toolkit($version=undef, $versionlock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  package { 'percona-toolkit':
    ensure => $version
  }

  if $versionlock {
    $versionlock_ensure = present
  } else {
    $versionlock_ensure = absent
  }

  case $operatingsystemmajrelease {
    '8': { dnf::versionlock { "0:percona-toolkit-${version}.*": ensure => $versionlock_ensure } }
    default: { yum::versionlock { "0:percona-toolkit-${version}.*": ensure => $versionlock_ensure } }
  }

}
