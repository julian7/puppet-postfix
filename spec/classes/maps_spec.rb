require 'spec_helper'

describe 'postfix::maps' do
  let(:params) do
    {
      ensure: 'present',
      dbhost: 'dbhost',
      dbname: 'dbname',
      dbuser: 'dbuser',
      dbpass: 'dbpass',
      aliases_table: 'aliases',
      aliases_destination: 'destination',
      aliases_local: 'local',
      aliases_domain: 'domain',
      domains_table: 'domains',
      domains_domain: 'domain',
      users_table: 'users',
      users_user: 'user',
      users_domain: 'domain',
    }
  end

  it {should include_class('postfix')}

  it 'generates domain_forwardings map' do
    should contain_file('/etc/postfix/maps/domain_forwardings.cf').with(
      owner: 'root',
      group: 'postfix',
      mode: '0640',
      require: ['Package[postfix-mysql]', 'Class[Postfix::Config]'],
      notify: 'Class[Postfix::Service]'
    ).
      with_content(%r{^user = dbuser$}).
      with_content(%r{^password = dbpass$}).
      with_content(%r{^hosts = dbhost$}).
      with_content(%r{^dbname = dbname$}).

      with_content(%r{^query = SELECT `destination` FROM `aliases` WHERE `local`='' AND `domain`=SUBSTRING_INDEX\('%s', '@', -1\)$})
  end

  it 'generates domains map' do
    should contain_file('/etc/postfix/maps/domains.cf').with(
      owner: 'root',
      group: 'postfix',
      mode: '0640',
      require: ['Package[postfix-mysql]', 'Class[Postfix::Config]'],
      notify: 'Class[Postfix::Service]'
    ).
      with_content(%r{^user = dbuser$}).
      with_content(%r{^password = dbpass$}).
      with_content(%r{^hosts = dbhost$}).
      with_content(%r{^dbname = dbname$}).
      with_content(%r{^query = SELECT 'virtual' from `domains` WHERE `domain`='%s'$})
  end

  it 'generates email2email map' do
    should contain_file('/etc/postfix/maps/email2email.cf').with(
      owner: 'root',
      group: 'postfix',
      mode: '0640',
      require: ['Package[postfix-mysql]', 'Class[Postfix::Config]'],
      notify: 'Class[Postfix::Service]'
    ).
      with_content(%r{^user = dbuser$}).
      with_content(%r{^password = dbpass$}).
      with_content(%r{^hosts = dbhost$}).
      with_content(%r{^dbname = dbname$}).

      with_content(%r{^query = SELECT CONCAT\(user, '@', domain\) FROM users WHERE user='%u' AND domain='%d'$})
  end

  it 'generates forwardings map' do
    should contain_file('/etc/postfix/maps/forwardings.cf').with(
      owner: 'root',
      group: 'postfix',
      mode: '0640',
      require: ['Package[postfix-mysql]', 'Class[Postfix::Config]'],
      notify: 'Class[Postfix::Service]'
    ).
      with_content(%r{^user = dbuser$}).
      with_content(%r{^password = dbpass$}).
      with_content(%r{^hosts = dbhost$}).
      with_content(%r{^dbname = dbname$}).

      with_content(%r{^query = SELECT `destination` FROM `aliases` WHERE `local`='%u' AND `domain`='%d'$})
  end

  it 'generates mailboxes map' do
    should contain_file('/etc/postfix/maps/mailboxes.cf').with(
      owner: 'root',
      group: 'postfix',
      mode: '0640',
      require: ['Package[postfix-mysql]', 'Class[Postfix::Config]'],
      notify: 'Class[Postfix::Service]'
    ).
      with_content(%r{^user = dbuser$}).
      with_content(%r{^password = dbpass$}).
      with_content(%r{^hosts = dbhost$}).
      with_content(%r{^dbname = dbname$}).

      with_content(%r{^query = SELECT CONCAT\(`domain`, '/', `user`, '/'\) FROM `users` WHERE `user`='%u' AND `domain`='%d'$})
  end
end