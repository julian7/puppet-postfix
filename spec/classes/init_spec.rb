require 'spec_helper'

describe 'postfix' do
  context do
    it { should contain_class('postfix::package').with(ensure: 'present') }
  end

  context 'with ensure: latest' do
    let(:params) { {ensure: 'latest'} }
    it { should contain_class('postfix::package').with(ensure: 'latest') }
  end
end
