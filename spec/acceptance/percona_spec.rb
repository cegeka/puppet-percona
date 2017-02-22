require 'spec_helper_acceptance'

describe 'percona' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management

        class { 'cegekarepos' : stage => 'setup_repo' }

        Yum::Repo <| title == 'epel' |>
        Yum::Repo <| title == 'percona' |>

        $percona_version = '5.6.21-25.8.938.el6'
        $toolkit_version = '2.2.11-1'

        file { '/data':
          ensure => directory,
          mode   => '0755'
        }

        class { 'percona::toolkit':
          version     => $toolkit_version,
          versionlock => true
        }

        class { 'percona::cluster':
          version_server           => $percona_version,
          versionlock              => true,
          data_dir                 => '/data/mysql',
          tmp_dir                  => '/data/mysql_tmp',
          ip_address               => '127.0.0.1',
          cluster_name             => 'test-cluster',
          sst_method               => 'xtrabackup',
          cluster_address          => '127.0.0.1',
        }

        service { 'mysql' :
          ensure     => 'running',
          enable     => true,
          require    => File['/etc/my.cnf'],
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
