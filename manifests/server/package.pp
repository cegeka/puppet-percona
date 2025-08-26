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

  $default_server_pkg = $_percona_major_version ? {
   '57' => "Percona-Server-server-57",
   '80' => 'percona-server-server',
  }

  $real_package_name = $package_name ? {
    undef   => $default_server_pkg,
    default => $package_name,
  }

  # 5.7 uses "Percona-Server-<..>-57" (Capitalized); 8.0 uses "percona-server-<..>" (lowercase).
  $packages_by_major = {
    '57' => {
      $real_package_name                => $version_server,
      $xtrabackup_name                  => $version_xtrabackup,
      "Percona-Server-client-57"        => $version_server,
      "Percona-Server-shared-57"        => $version_server,
      "Percona-Server-shared-compat-57" => $version_server,
    },
    '80' => {
      $real_package_name                => $version_server,
      $xtrabackup_name                  => $version_xtrabackup,
      "percona-server-client"           => $version_server,
      "percona-server-shared"           => $version_server,
      "percona-icu-data-files"          => $version_server,
    },
  }

  $packages_to_install = $packages_by_major[$_percona_major_version]

  # create package resources
  $packages_to_install.each |$pkg_name, $pkg_ensure| {
    package { $pkg_name:
      ensure => $pkg_ensure,
    }
  }

  if $versionlock {
    $versionlock_ensure = present
  } else {
    $versionlock_ensure = absent
  }

  # create/remove versionlock entries for packages
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
