#!/usr/bin/env rspec

require 'spec_helper'

describe 'percona::server' do

  context 'with faulty input' do
    context 'without version_shared_compat' do
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_shared_compat must be provided/
      )}
    end


    context 'without version_shared' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_shared must be provided/
      )}
    end

    context 'without version_server' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_shared => '5.5.31-rel30.3.520.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_server must be provided/
      )}
    end

    context 'without version_client' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_shared => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.31-rel30.3.520.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_client must be provided/
      )}
    end

    context 'without version_debuginfo' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_shared => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.31-rel30.3.520.rhel6', :version_client => '5.5.31-rel30.3.520.rhel6' } }
      it { expect { subject }.to raise_error(
        Puppet::Error, /parameter version_debuginfo must be provided/
      )}
    end
  end

  context 'with parameters' do
    context 'version_shared_compat => 5.5.31-rel30.3.520.rhel6, version_shared => 5.5.31-rel30.3.520.rhel6, version_server => 5.5.31-rel30.3.520.rhel6, version_client => 5.5.31-rel30.3.520.rhel6, version_debuginfo => 5.5.31-rel30.3.520.rhel6' do
      let (:params) { { :version_shared_compat => '5.5.31-rel30.3.520.rhel6', :version_shared => '5.5.31-rel30.3.520.rhel6', :version_server => '5.5.31-rel30.3.520.rhel6', :version_client => '5.5.31-rel30.3.520.rhel6', :version_debuginfo => '5.5.31-rel30.3.520.rhel6' } }

      it { should contain_class('percona::server::package').with_version_shared_compat('5.5.31-rel30.3.520.rhel6')}
      it { should contain_class('percona::server::package').with_version_shared('5.5.31-rel30.3.520.rhel6')}
      it { should contain_class('percona::server::package').with_version_server('5.5.31-rel30.3.520.rhel6')}
      it { should contain_class('percona::server::package').with_version_client('5.5.31-rel30.3.520.rhel6')}
      it { should contain_class('percona::server::package').with_version_debuginfo('5.5.31-rel30.3.520.rhel6')}

      it { should contain_class('percona::server::config').with_data_dir('/data/mysql') }
      it { should contain_class('percona::server::config').with_tmp_dir('/data/mysql_tmp') }

      it { should contain_class('percona::server::package').with_before('Class[Percona::Server::Config]') }

    end
  end
end
