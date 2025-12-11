# @summary Manages BINLOG_ADMIN privilege for a MySQL user
#
# @param user
#   The MySQL user to grant or revoke BINLOG_ADMIN privilege
# @param host
#   The host from which the user connects (default: 'localhost')
# @param ensure
#   Whether to grant (true) or revoke (false) the privilege (default: false)
#
define percona::provision::binlog_admin_user (
  String $user,
  String $host = 'localhost',
  Boolean $ensure = false,
) {
  if $ensure {
    exec { "grant_binlog_admin_${user}_${host}":
      command => "mysql --defaults-file=/root/.my.cnf -e \"GRANT BINLOG_ADMIN ON *.* TO '${user}'@'${host}' WITH GRANT OPTION\"",
      unless  => "mysql --defaults-file=/root/.my.cnf -e \"SHOW GRANTS FOR '${user}'@'${host}'\" 2>/dev/null | grep -iq BINLOG_ADMIN",
      path    => ['/usr/bin', '/bin'],
      require => Service['mysqld'],
    }
  } else {
    exec { "revoke_binlog_admin_${user}_${host}":
      command => "mysql --defaults-file=/root/.my.cnf -e \"REVOKE BINLOG_ADMIN ON *.* FROM '${user}'@'${host}'\"",
      onlyif  => "mysql --defaults-file=/root/.my.cnf -e \"SHOW GRANTS FOR '${user}'@'${host}'\" 2>/dev/null | grep -iq BINLOG_ADMIN",
      path    => ['/usr/bin', '/bin'],
      require => Service['mysqld'],
    }
  }
}
