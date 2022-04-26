define percona::provision::plugin(
  $ensure,
  $type='server',
  $config_dir='/etc/my.cnf.d',
  $config=undef
) {

  if $::mysql_exists {
    if ($config) {
      file { "${config_dir}/${name}.cnf" :
        ensure => present,
        content => template("${module_name}/plugin.cnf.erb"),
        require => Mysql_plugin[$name]
      }
    }
    mysql_plugin { $name:
      ensure  => $ensure,
      require => Service['mysqld']
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }

}
