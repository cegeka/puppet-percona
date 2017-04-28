class percona::server::config (
  $socket_cnf         ='/var/lib/mysql/mysql.sock',
  $data_dir           ='/data/mysql',
  $tmp_dir            ='/data/mysql_tmp',
  $replace_mycnf      = false,
  $replace_root_mycnf = false
) {

  file { '/etc/my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/server/my.cnf.erb"),
    replace => $replace_mycnf
  }

  file { $data_dir:
    ensure => directory,
    owner  => 'mysql',
    group  => 'mysql'
  }

  file { $tmp_dir:
    ensure  => directory,
    owner   => 'mysql',
    group   => 'mysql',
    require => File[$data_dir]
  }
  file { '/root/.my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/server/root_my.cnf.erb"),
    replace => $replace_root_mycnf
  }
}
