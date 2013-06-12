#!/usr/bin/env rspec

require 'spec_helper'

describe 'percona' do
  it { should contain_class 'percona' }
end
