require 'spec_helper'

describe 'postfix::service' do
  context do
    it 'makes sure it is running' do
      should contain_service('postfix').with(
        ensure: 'running',
        hasstatus: true,
        hasrestart: true,
        enable: true,
        require: ['Class[Postfix::Package]', 'Class[Postfix::Config]']
      )
    end
  end
end
