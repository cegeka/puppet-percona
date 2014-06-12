#!/usr/bin/env rspec

require 'spec_helper'

describe 'percona::cluster' do

  context 'with faulty input' do
    context 'without version_shared_compat' do
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_shared_compat must be provided/
      )}
    end

    context 'without version_server' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_server must be provided/
      )}
    end

    context 'without version_client' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_client must be provided/
      )}
    end

    context 'without version_debuginfo' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_debuginfo must be provided/
      )}
    end

    context 'without version_galera' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_galera must be provided/
      )}
    end

    context 'without version_galera_debuginfo' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6'} }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_galera_debuginfo must be provided/
      )}
    end

    context 'without ip_address' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter ip_address must be provided/
      )}
    end

    context 'with ip_address => foo' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '2.5-1.150.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6',
                        :ip_address => 'foo' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter ip_address must be a valid IP address/
      )}
    end

    context 'without cluster_address' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6',
                        :ip_address => '172.16.0.2' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter cluster_address must be provided/
      )}
    end

    context 'with cluster_address => 172.16.0.2;172.16.0.3' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6',
                        :ip_address => '172.16.0.2', :cluster_address => '172.16.0.2;172.16.0.3' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter cluster_address must be a comma separated list of IP addresses/
      )}
    end

    context 'without cluster_name' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6',
                        :ip_address => '172.16.0.2', :cluster_address => '172.16.0.2,172.16.0.3' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter cluster_name must be provided/
      )}
    end

    context 'with sst_method => foo' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6',
                        :ip_address => '172.16.0.2', :cluster_address => '172.16.0.2,172.16.0.3', :cluster_name => 'test_cluster', :sst_method => 'foo' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter sst_method must be mysqldump, rsync or xtrabackup/
      )}
    end
  end

  context 'with parameters' do
    context '' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.30-23.7.4.406.rhel6',
                        :version_client => '5.5.30-23.7.4.406.rhel6', :version_debuginfo => '5.5.30-23.7.4.406.rhel6',
                        :version_galera => '2.5-1.150.rhel6', :version_galera_debuginfo => '2.5-1.150.rhel6',
                        :ip_address => '172.16.0.2', :cluster_address => '172.16.0.2,172.16.0.3', :cluster_name => 'test_cluster'} }

      it { should contain_class('percona::cluster::package').with_version('')}

      it { should contain_class('percona::cluster::config').with_data_dir('/data/mysql') }
      it { should contain_class('percona::cluster::config').with_tmp_dir('/data/mysql_tmp') }
      it { should contain_class('percona::cluster::config').with_ip_address('172.16.0.2') }
      it { should contain_class('percona::cluster::config').with_cluster_address('172.16.0.2,172.16.0.3') }
      it { should contain_class('percona::cluster::config').with_cluster_name('test_cluster') }
      it { should contain_class('percona::cluster::config').with_sst_method('rsync') }

      it { should contain_class('percona::cluster::package').with_before('Class[Percona::Cluster::Config]') }
    end
  end

end
