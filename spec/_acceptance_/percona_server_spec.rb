require 'spec_helper_acceptance'

describe 'percona::server' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        Yum::Repo <| title == 'percona' |>
        Yum::Repo <| title == 'epel' |>

        class { 'percona::server':
          version_server  => '5.6.22-rel72.0.el6',
          versionlock     => false,
          replace_mycnf   => true,
          data_dir        => '/data/mysql,
          tmp_dir         => '/data/mysql/tmp'
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/my.cnf' do
      it { is_expected.to be_file }
      its(:content) { should contain /\/data\/mysql/ }
    end

  end
end

