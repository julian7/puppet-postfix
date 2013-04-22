require 'spec_helper'

describe 'postfix::package' do
  context do
    it { should contain_package('postfix').with(ensure: 'present') }
  end

  context 'with ensure: latest' do
    let(:params) { {ensure: 'latest'} }

    it { should contain_package('postfix').with(ensure: 'latest') }
  end
end
