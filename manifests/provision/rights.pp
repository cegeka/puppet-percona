# @summary A basic helper used to create a user and grant some privileges on a database.
#
# @example
#  percona::provision::rights { "example case":
#    user            => "foo",
#    password_hash   => "bar",
#    database        => "mydata",
#    priv            => ["select_priv", "update_priv"],
#    secretid      => 123456
#  }
#
# @param database
#   The target database
# @param user
#   The target user
# @param password_hash
#   User's hashed password
# @param secretid
#   The ID for PIM
# @param host
#   Target host, default to "localhost"
# @param ensure
#   Defaults to present
# @param priv
#   Target privileges, defaults to "all" (values are the fieldnames from mysql.db table)
# @param type
#   The type of grant, defaults to "server" (other value is "database")
# @param global
#   Whether to apply the grant globally (on all databases) or not
#   **WARNING**: when setting a true global value to false, global permission are not revoked.
#   Manual intervention is required for this:
#   - Check user grants: `SHOW GRANTS FOR <user>;`
#     Acceptable global grant is: ``GRANT USAGE ON *.* TO `<user>`@`%` ``
#   - Revoke global grants: `REVOKE ALL ON *.* FROM '<user>'@'%';`
#
define percona::provision::rights (
  String $database,
  String $user,
  Optional[String] $password_hash = undef,
  Optional[Integer] $secretid = undef,
  String $host = 'localhost',
  String $ensure = 'present',
  Variant[String, Array[String]] $priv = 'all',
  String $type = 'server',
  Boolean $global = false,
) {
  if $::mysql_exists {
    if $secretid == undef and $password_hash == undef {
      fail('You must provide a password hash or a secretid to ::mysql::rights')
    }

    if $database == '' and !$global {
      fail('Database parameter is required when global is false')
    }

    if $secretid != undef {
      $pim_password = getsecret($secretid, 'Password')
      $mysql_password = mysql_password($pim_password)
    } else {
      $mysql_password = $password_hash
    }

    ensure_resource('percona_user', "${user}@${host}", {
        ensure        => $ensure,
        password_hash => $mysql_password,
        provider      => 'mysql',
        require       => Service['mysqld']
    })

    if $global { $real_type = '' } else { $real_type = "/${database}"}
    if $ensure == 'present' {
      mysql_grant { "${user}@${host}${real_type}":
        privileges => $priv,
        provider   => 'mysql',
        require    => [Percona_user["${user}@${host}"], Service['mysqld']],
      }
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }
}
