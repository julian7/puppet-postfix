require 'spec_helper'

describe 'postfix::package' do
  context do
    it { should contain_package('postfix').with(ensure: 'present') }
  end

  context 'with ensure: latest' do
    let(:params) { {ensure: 'latest'} }

    it { should contain_package('postfix').with(ensure: 'latest') }
  end

  context 'with mysql: true' do
    let(:params) {{mysql: true, ensure: 'ensure'}}

    it { should contain_package('postfix-mysql').with_ensure('ensure') }
  end
end
