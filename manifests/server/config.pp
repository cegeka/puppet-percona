# Class: percona::server::config
#
# Usage: this class should not be called directly
#
class percona::server::config (
  $socket_cnf         ='/var/lib/mysql/mysql.sock',
  $data_dir           ='/data/mysql',
  $tmp_dir            ='/data/mysql_tmp',
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
    content => template("${module_name}/server/my.cnf.erb"),
    replace => $replace_mycnf,
    notify  => Service['mysql']
  }
  if $::selinux {
    file_line {
      'selinux_context_mysql_datadir':
        path => '/etc/selinux/targeted/contexts/files/file_contexts.local',
        line => "${data_dir}(/.*)? system_u:object_r:mysqld_db_t:s0";
      'selinux_context_mysql_tmpdir':
        path => '/etc/selinux/targeted/contexts/files/file_contexts.local',
        line => "${tmp_dir}(/.*)? system_u:object_r:mysqld_db_t:s0"
    }
    file {
      $data_dir:
        ensure  => directory,
        owner   => 'mysql',
        group   => 'mysql',
        seltype => 'mysqld_db_t',
        require => [ File_line['selinux_context_mysql_datadir'] ];
      $tmp_dir:
        ensure  => directory,
        owner   => 'mysql',
        group   => 'mysql',
        seltype => 'mysqld_db_t',
        require => [ File[$data_dir], File_line['selinux_context_mysql_tmpdir'] ];
    }
  } else {
    file {
      $data_dir:
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql';
      $tmp_dir:
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql';
    }
  }

  file { '/root/.my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/server/root_my.cnf.erb"),
    replace => $real_replace_root_mycnf
  }
}
