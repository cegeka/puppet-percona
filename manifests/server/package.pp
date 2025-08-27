# Class: percona::server::package
#
# Usage: this class should not be called directly
#
class percona::server::package(
  $package_name=undef,
  $version_server=undef,
  $xtrabackup_name=undef,
  $version_xtrabackup='present',
  $versionlock=false,
) {
  $percona_major_version   = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)','\1')
  $_percona_major_version  = regsubst($percona_major_version, '\.', '', 'G')
  $percona_package_version = regsubst($version_server, '^(.*?)-(.*)','\1')
  $percona_package_release = regsubst($version_server, '^(.*?)-(.*)','\2')

  if $package_name {
    $real_package_name = $package_name
  } else {
    $real_package_name = "Percona-Server-server-${_percona_major_version}"
  }

  $packages_to_install = $percona_major_version ? {
    '8.0' => {
      $real_package_name        => $version_server,
      $xtrabackup_name          => $version_xtrabackup,
      'percona-server-client'   => $version_server,
      'percona-server-shared'   => $version_server,
      'percona-icu-data-files'  => $version_server,
    },
    '5.7' => {
      "${real_package_name}"    => $version_server,
      $xtrabackup_name          => $version_xtrabackup,
    },
    default => warning("We don't provide any other versions")
  }

  $packages_to_install.each |$pkg_name, $pkg_ensure| {
    package {
      $pkg_name:
    }
  }

  $versionlock_ensure = $versionlock ? {
    true  => present,
    false => absent,
  }

  $packages_to_install.each |$pkg_name, $pkg_ensure| {
    if $pkg_ensure =~ /-/ {
      yum::versionlock { $pkg_name:
        ensure  => $versionlock_ensure,
        version => $percona_package_version,
        release => $percona_package_release,
        arch    => 'x86_64',
        epoch   => 0,
      }
    }
  }
}
