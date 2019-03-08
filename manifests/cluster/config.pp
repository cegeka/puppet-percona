# Class: percona::cluster::config
#
# Usage: this class should not be called directly
#
class percona::cluster::config(
  $socket_cnf         ='/var/lib/mysql/mysql.sock',
  $data_dir           = '/data/mysql',
  $tmp_dir            = '/data/mysql_tmp',
  $ip_address         = undef,
  $cluster_address    = undef,
  $cluster_name       = undef,
  $sst_method         = 'rsync',
  $replace_mycnf      = false,
  $replace_root_mycnf = false
) {
  if check_file('/root/.my.cnf','password=..*') {
    $real_replace_root_mycnf=false
  }
  else {
    $real_replace_root_mycnf=$replace_root_mycnf
  }

  file { '/etc/my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/cluster/my.cnf.erb"),
    replace => $replace_mycnf,
    notify  => Service['mysql']
  }

  file_line { 'selinux_context_mysql_datadir':
    path => '/etc/selinux/targeted/contexts/files/file_contexts.local',
    line => "${data_dir}(/.*)? system_u:object_r:mysqld_db_t:s0"
  }

  file { $data_dir:
    ensure  => directory,
    owner   => 'mysql',
    group   => 'mysql',
    seltype => 'mysqld_db_t',
    require => [ File_line['selinux_context_mysql_datadir'] ]
  }

  file { $tmp_dir:
    ensure  => directory,
    owner   => 'mysql',
    group   => 'mysql',
    seltype => 'mysqld_db_t',
    require => [ File_line['selinux_context_mysql_datadir'] ]
  }

  file { '/root/.my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/cluster/root_my.cnf.erb"),
    replace => $real_replace_root_mycnf
  }
}
