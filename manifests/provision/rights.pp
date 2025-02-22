# == Definition: mysql::rights
#
# A basic helper used to create a user and grant him some privileges on a database.
#
# Example usage:
#  percona::provision::rights { "example case":
#    user            => "foo",
#    password_hash   => "bar",
#    database        => "mydata",
#    priv            => ["select_priv", "update_priv"],
#    sectret_id      => 123456
#  }
#
#Available parameters:
#- *$ensure": defaults to present
#- *$database*: the target database
#- *$user*: the target user
#- *$password_hash*: user's hashed password
#- *$secretid*: the ID for PIM
#- *$host*: target host, default to "localhost"
#- *$priv*: target privileges, defaults to "all" (values are the fieldnames from mysql.db table).

define percona::provision::rights(
  $database,
  $user,
  $password_hash=undef,
  $secretid=undef,
  $host='localhost',
  $ensure='present',
  $priv='all',
  $type='server',
  $global=false
) {

  if $::mysql_exists {
    if $secretid == undef and $password_hash == undef {
      fail('You must provide a password hash or a secretid to ::mysql::rights')
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
          require    => [ Percona_user["${user}@${host}"], Service["mysqld"] ]
        }
      }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }
}
