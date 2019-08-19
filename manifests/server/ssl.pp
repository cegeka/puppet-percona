# Class: percona::server::ssl
#
# Usage: this class should not be called directly
#
class percona::server::ssl (
  $ssl_autogen = undef,
  $ssl_ca = undef,
  $ssl_key = undef,
  $ssl_cert = undef
) {

  file { '/etc/my.cnf.d/ssl.cnf':
    ensure  => present,
    content => template("${module_name}/cluster/ssl.cnf.erb")
  }

}
