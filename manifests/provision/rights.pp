# == Definition: mysql::rights
#
# A basic helper used to create a user and grant him some privileges on a database.
#
# Example usage:
#  percona::provision::rights { "example case":
#    user       => "foo",
#    password   => "bar",
#    database   => "mydata",
#    priv       => ["select_priv", "update_priv"],
#    sectret_id => 123456
#  }
#
#Available parameters:
#- *$ensure": defaults to present
#- *$database*: the target database
#- *$user*: the target user
#- *$password*: user's password
#- *$secret_id*: the ID for PIM
#- *$host*: target host, default to "localhost"
#- *$priv*: target privileges, defaults to "all" (values are the fieldnames from mysql.db table).

define percona::provision::rights(
  $database,
  $user,
  $password=undef,
  $secret_id=undef,
  $host='localhost',
  $ensure='present',
  $priv='all'
) {

  include percona::provision::service

  if $::mysql_exists {
    if $secret_id == undef and $password == undef {
      fail('You must privide a password or a secret_id to ::mysql::rights')
    }

    if $secret_id != undef {
      $mysql_password = getsecret($secret_id, 'Password')
    } else {
      $mysql_password = $password
    }

    ensure_resource('mysql_user', "${user}@${host}", {
      ensure        => $ensure,
      password_hash => mysql_password($mysql_password),
      provider      => 'mysql',
      require       => [ File['/root/.my.cnf'], Service[${::percona::provision::service::myservice}] ]
    })

    if $ensure == 'present' {
      mysql_grant { "${user}@${host}/${database}":
        privileges => $priv,
        provider   => 'mysql',
        require    => [ Mysql_user["${user}@${host}"], Service[${::percona::provision::service::myservice}] ]
      }
    }

    if $ensure == 'absent' {
      mysql_user { "${user}@${host}":
        ensure => absent
      }
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }
}
