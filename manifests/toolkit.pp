class percona::toolkit($version=undef, $versionlock=false) {

  if ! $version {
    fail('Class[Percona::Toolkit]: parameter version must be provided')
  }

  $toolkit_package_version = regsubst($version, '^(.*?)-(.*)','\1')
  $toolkit_package_release = regsubst($version, '^(.*?)-(.*)','\2')

  package { 'percona-toolkit':
    ensure => $version
  }

  if $versionlock {
    $versionlock_ensure = present
  } else {
    $versionlock_ensure = absent
  }

  yum::versionlock { "percona-toolkit":
    ensure  => "${versionlock_ensure}",
    version => "${toolkit_package_version}",
    release => "${toolkit_package_release}",
    epoch   => 0,
    arch    => 'x86_64',
  }

}
