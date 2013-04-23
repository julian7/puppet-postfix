require 'spec_helper'

describe 'postfix' do
  context do
    it { should contain_class('postfix::package').with(ensure: 'present') }
    it { should contain_class('postfix::service').with(ensure: 'running') }
  end

  context 'with ensure: latest' do
    let(:params) { {ensure: 'latest'} }
    it { should contain_class('postfix::package').with(ensure: 'latest') }
    it { should contain_class('postfix::service').with(ensure: 'running') }
  end

  context 'with ensure: absent' do
    let(:params) { {ensure: 'absent'} }
    it { should contain_class('postfix::package').with(ensure: 'absent') }
    it { should contain_class('postfix::service').with(ensure: 'absent') }
  end
end
