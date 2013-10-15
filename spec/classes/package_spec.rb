require 'spec_helper'

describe 'postfix::package' do
  context do
    it {
      should contain_package('postfix').with(ensure: 'present')
      should contain_package('postfix-mysql').with(ensure: 'absent')
      should contain_package('postfix-policyd-spf-python').with(ensure: 'absent')
    }
  end

  context 'with ensure: latest' do
    let(:params) { {ensure: 'latest'} }

    it {
      should contain_package('postfix').with(ensure: 'latest')
      should contain_package('postfix-mysql').with(ensure: 'absent')
      should contain_package('postfix-policyd-spf-python').with(ensure: 'absent')
    }
  end

  context 'with mysql: true' do
    let(:params) {{mysql: true, ensure: 'ensure'}}

    it { should contain_package('postfix-mysql').with_ensure('ensure') }
  end

  context 'with spf: true' do
    let(:params) {{spf: true, ensure: 'ensure'}}

    it { should contain_package('postfix-policyd-spf-python').with_ensure('ensure') }
  end
end
