# Class: percona::server::root
#
# Usage: this class should not be called directly
#
class percona::cluster::root (
  $server_id     = undef,
  $socket_cnf    = undef,
  $replace_root_mycnf = false,
  $secret_file   = undef,
  $root_user     = 'root',
  $root_password = undef,
) {

  $root_password_set = check_file('/root/.my.cnf','password=.*')

  case $root_password_set {
    0: {
      $real_replace_root_mycnf = false
    }
    1,default: {
      # 1: no password is present in /root/.my.cnf
      # default: it's a clean install, proceed
      $real_replace_root_mycnf = $replace_root_mycnf
    }
  }

  if $real_replace_root_mycnf and $root_password {
    $real_root_password = getsecret($root_password,'Password')

    if $server_id == 1 {
      $rm_pass_cmd = join([
          "echo \"ALTER USER 'root'@'localhost' IDENTIFIED BY '${real_root_password}'; FLUSH PRIVILEGES;\" | mysql -S ${socket_cnf} -u root --password=\$(sed -n 's/.* temporary password .*: \\(.*\\)/\\1/p' ${secret_file}) --connect-expired-password",
          "touch /root/.mysql_root_reset",
      ], ' && ')
    } else {
      $rm_pass_cmd = "touch /root/.mysql_root_reset"
    }

    exec { 'replace temporary root pass':
      command => $rm_pass_cmd,
      creates => '/root/.mysql_root_reset',
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    }

    file { '/root/.my.cnf':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template("${module_name}/server/root_my.cnf.erb"),
      replace => $real_replace_root_mycnf,
      require => Exec['replace temporary root pass']
    }
  }

}
