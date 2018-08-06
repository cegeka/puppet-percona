# == Definition: mysql::rights
#
# A basic helper used to create a user
#
# Example usage:
#  percona::provision::user { "example case":
#    user       => "foo",
#    password   => "bar",
#    or
#    sectret_id => 123456
#  }
#
#Available parameters:
#- *$ensure": defaults to present
#- *$user*: the target user
#- *$password*: user's password
#- *$secretid*: the ID for PIM

define percona::provision::user(
  $user='root',
  $password=undef,
  $secretid=undef,
  $host='localhost',
  $ensure='present',
  $type='server'
) {

  if $::mysql_exists {
    if $secretid == undef and $password == undef {
      fail('You must privide a password or a secretid to ::mysql::rights')
    }

    if $secretid != undef {
      $mysql_password = getsecret($secretid, 'Password')
    } else {
      $mysql_password = $password
    }
    if $user == 'root'
    {
      ensure_resource('percona_user', "${user}@${host}", {
        ensure        => $ensure,
        password_hash => mysql_password($mysql_password),
        provider      => 'mysql',
        require       => Service["mysql"]
      })
      augeas { '/root/.my.cnf':
        incl    => '/root/.my.cnf',
        lens    => 'MySQL.lns',
        changes => [
          "set target[.='client']/user root",
          "set target[.='client']/password ${mysql_password}",
          "set target[.='mysql']/user root",
          "set target[.='mysql']/password ${mysql_password}",
          "set target[.='mysqladmin']/user root",
          "set target[.='mysqladmin']/password ${mysql_password}",
          "set target[.='mysqldump']/user root",
          "set target[.='mysqldump']/password ${mysql_password}",
          "set target[.='mysqlshow']/user root",
          "set target[.='mysqlshow']/password ${mysql_password}"
          ],
        require => Percona_user["root@${host}"]
      }
    }
    else
    {
    ensure_resource('percona_user', "${user}@${host}", {
      ensure        => $ensure,
      password_hash => mysql_password($mysql_password),
      provider      => 'mysql',
      require       => Service["mysql"]
    })
    }

    if $ensure == 'absent' {
      percona_user { "${user}@${host}":
        ensure => absent
      }
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }
}
