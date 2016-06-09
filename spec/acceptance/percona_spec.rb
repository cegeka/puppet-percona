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

        Yum::Repo <| title == 'percona' |>


        $percona_version = '5.6.21-25.8.938.el6'
        $compat_version = '5.1.68-rel14.6.551.rhel6'
        $galera_version = '3.8-1.3390.rhel6'
        $xtrabackup_version = '2.2.9-5067.el6'
        $toolkit_version = '2.2.11-1'

        class { 'percona::toolkit':
          version     => $toolkit_version,
          versionlock => true
        }

        class { 'percona::xtrabackup':
          version           => $xtrabackup_version,
          version_debuginfo => $xtrabackup_version,
          versionlock       => true
        }

        class { 'percona::cluster':
          version_shared_compat    => $compat_version,
          version_server           => $percona_version,
          version_client           => $percona_version,
          version_debuginfo        => $percona_version,
          version_galera           => $galera_version,
          version_galera_debuginfo => $galera_version,
          versionlock              => true,
          data_dir                 => '/data/mysql',
          tmp_dir                  => '/data/mysql_tmp',
          ip_address               => '172.29.121.170',
          cluster_address          => '172.29.121.170,172.29.121.171,172.29.121.172',
          cluster_name             => 'renta_acc_cluster',
          sst_method               => 'xtrabackup'
        }

      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    describe port(3306) do
      it { should be_listening }
    end
    describe port(4567) do
      it { should be_listening }
    end
    describe port(4444) do
      it { should be_listening }
    end
    describe port(4568) do
      it { should be_listening }
    end
  end
end
