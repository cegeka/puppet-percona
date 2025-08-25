# Class: percona::server::package
#
# Usage: this class should not be called directly
#
class percona::server::package (
  $package_name=undef,
  $version_server=undef,
  $xtrabackup_name=undef,
  $version_xtrabackup='present',
  $versionlock=false,
) {
  $percona_major_version   = regsubst($version_server, '^(\d\.\d)\.(\d+)-(.*)', '\1')
  $_percona_major_version  = regsubst($percona_major_version, '\.', '', 'G')
  $percona_package_version = regsubst($version_server, '^(.*?)-(.*)', '\1')
  $percona_package_release = regsubst($version_server, '^(.*?)-(.*)', '\2')

  if $package_name {
    $real_package_name = $package_name
  } else {
    $real_package_name = "Percona-Server-server-${_percona_major_version}"
  }

  # Base package list (always installed)
  $base_packages = {
    $real_package_name       => $version_server,
    $xtrabackup_name         => $version_xtrabackup,
    'percona-server-client'  => $version_server,
    'percona-server-shared'  => $version_server,
    'percona-icu-data-files' => $version_server,
  }

  # OS-Specific package
  $extra_packages = $facts['os']['release']['major'] ? {
    '8'  => { 'percona-server-shared-compat' => $version_server },
  }

  # Merge base and OS-specific package
  $packages = merge($base_packages, $extra_packages)

  $packages.each |String $pkg_name, String $pkg_version| {
    package { $pkg_name:
      ensure => $pkg_version,
    }
  }

  if $versionlock {
    $versionlock_ensure = present
  } else {
    $versionlock_ensure = absent
  }

  # Base versionlock components
  $versionlock_components = ['server-server', 'server-shared', 'server-client', 'icu-data-files']

  # OS-Specific versionlock components
  $extra_versionlock_components = $facts['os']['release']['major'] ? {
    '8'  => ['server-shared-compat'],
  }

  $all_versionlock_components = concat($versionlock_components, $extra_versionlock_components)

  $all_versionlock_components.each |String $component| {
    yum::versionlock { "percona-${component}":
      ensure  => $versionlock_ensure,
      version => $percona_package_version,
      release => $percona_package_release,
      epoch   => 0,
      arch    => 'x86_64',
    }
  }
}
