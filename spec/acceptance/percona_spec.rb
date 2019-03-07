require 'spec_helper_acceptance'

describe 'percona' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management
        include profile::iac::repository_management
  
        class { 'cegekarepos':
          require => Class['profile::iac::repository_management'] 
        }

        Yum::Repo <| title == 'epel' |>
        Yum::Repo <| title == 'percona' |>

        $percona_version = '5.6.32-25.17.1.el6'
        $toolkit_version = '2.2.11-1'
        $version_xtrabackup = '2.3.6-1.el6'
        $version_galera = '3.17-1.rhel6'
        $xtrabackup_name = 'percona-xtrabackup'

        file { '/data':
          ensure => directory,
          mode   => '0755'
        }

        class { 'percona::toolkit':
          version     => $toolkit_version,
          versionlock => true,
          require     => Yum::Repo['percona']
        }

        class { 'percona::cluster':
          version_server           => $percona_version,
          version_xtrabackup       => $version_xtrabackup,
          version_galera           => $version_galera,
          xtrabackup_name          => $xtrabackup_name,
          versionlock              => true,
          data_dir                 => '/data/mysql',
          tmp_dir                  => '/data/mysql_tmp',
          ip_address               => '127.0.0.1',
          cluster_name             => 'test-cluster',
          sst_method               => 'xtrabackup',
          cluster_address          => '127.0.0.1',
          require                  => Yum::Repo['percona']
        }

        service { 'postfix':
          ensure    => running,
          hasstatus => true,
          enable    => true
        }
        package { ['net-snmp', 'postfix'] :
          ensure  => present,
        }

      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    describe port(3306) do
      it { should be_listening }
    end
  end
end
