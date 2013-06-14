class percona::cluster::config($data_dir='/data/mysql', $tmp_dir='/data/tmp', $ip_address=undef, $cluster_address=undef, $cluster_name=undef, $sst_method='rsync') {

  file { '/etc/my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/cluster/my.cnf.erb"),
    replace => false
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

}
