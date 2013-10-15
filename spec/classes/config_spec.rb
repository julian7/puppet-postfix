require 'spec_helper'

describe 'postfix::config' do
  context do
    let(:params) {{hostname: 'example.com'}}
    it "doesn't contain /etc/postfix/maps" do
      should contain_file('/etc/postfix/maps').with_ensure('absent')
    end

    it 'generates main.cf' do
      should contain_file('/etc/postfix/main.cf').with(
        owner: 'root',
        group: 'postfix',
        mode:  '0644'
      ).
        with_content(%r{^myhostname = example\.com$}).
        with_content(%r{^mynetworks = 127\.0\.0\.0/8$}).
        with_content(%r{^smtpd_use_tls = no$}).
        with_content(%r{^smtpd_sasl_auth_enable = no$})
    end

    it 'generates master.cf' do
      should contain_file('/etc/postfix/master.cf').with(
        owner: 'root',
        group: 'postfix',
        mode:  '0644'
      ).
        with_content(%r{^smtp\s+inet\s.+\bpostscreen$}).
        with_content(%r{^smtpd\s+pass\s.+\bsmtpd$}).
        with_content(%r{^dnsblog\s+unix\s.+\bdnsblog$}).
        with_content(%r{^tlsproxy\s+unix\s.+\btlsproxy$}).
        with_content(%r{^submission\s+inet\s.+\bsmtpd$}).
        without_content(%r{^smtpd\s.+$\s+-o\scontent_filter}).
        without_content(%r{^cfilter\s+unix\s.+\blmtp$}).
        without_content(%r{^127.0.0.1:10025\s+inet\s.+\ssmtpd$\s+
                        -o\scontent_filter=$\s}x)
    end

    it 'generates mailname' do
      should contain_file('/etc/mailname').with(
        owner: 'root',
        group: 'postfix',
        mode: '0644',
        content: "example.com\n"
      )
    end

    it 'does not generate virt map files' do
      should contain_file('/etc/postfix/maps').with_ensure('absent')
    end
  end

  context 'with content_filter,' do
    let(:params) { { content_filter: 'cfilter' } }

    it 'generates master.cf with double queue' do
      should contain_file('/etc/postfix/master.cf').
        with_content(%r{^smtpd\s+pass\s.+\bsmtpd$\s+
                     -o\scontent_filter=cfilter:\[127\.0\.0\.1\]:10024$}x).
        with_content(%r{^cfilter\s+unix\s.+\blmtp$}).
        with_content(%r{^127.0.0.1:10025\s+inet\s.+\ssmtpd$\s+
                     -o\scontent_filter=$\s}x)
    end

    it "doesn't contain /etc/postfix/maps" do
      should contain_file('/etc/postfix/maps').with_ensure('absent')
    end
  end

  context 'with spf,' do
    let(:params) { { spf_helo: 'helo', spf_from: 'from', spf_skip: ['skip'] } }
    let(:pre_condition) { "class {postfix: spf => true }" }

    it 'adds spf-specific settings to main.cf' do
      should contain_file('/etc/postfix/main.cf').
        with_content(%r{^policy-spf_time_limit = 3600s$}).
        with_content(%r{^smtpd_recipient_restrictions\s*=[^=]+
                     check_policy_service\sunix:private/policy-spf}x)
    end

    it 'adds spf-specific settings to master.cf' do
      should contain_file('/etc/postfix/master.cf').
        with_content(%r{policy-spf\s+unix\s+-\s+n\s+n\s+-\s+-\s+spawn$\s+
                     user=nobody\s+argv=/usr/bin/policyd-spf$}x)
    end

    it 'adds spf config' do
      should contain_file('/etc/postfix-policyd-spf-python/policyd-spf.conf').
        with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: <<-EnD)
debugLevel = 1
defaultSeedOnly = 1
HELO_reject = helo
Mail_From_reject = from
PermError_reject = False
TempError_Defer = False
skip_addresses = 127.0.0.0/8,::ffff:127.0.0.0//104,::1//128,skip
EnD
    end
  end

  context 'with virtual users' do
    let(:params) { {
      virtual: 'virtengine',
      virtual_homes: '/path/to/mailboxes',
      virtual_usergroup: 'virtuser:virtgroup',
      virtual_uid: '94779',
      virtual_gid: '39179',
      virtual_lda: '/path/to/lda',
      virtual_lda_params: 'virtual lda params'
    } }

    it 'generates main.cf with virtual user lookup' do
      mpath = 'mysql:/etc/postfix/maps/'
      should contain_file('/etc/postfix/main.cf').
        with_content(%r{^virtengine_destination_recipient_limit = 1$}).
        with_content(%r{^virtengine_destination_concurrency_limit = 1$}).
        with_content(%r{^virtual_transport = virtengine$}).
        with_content(%r{^virtual_mailbox_base = /path/to/mailboxes$}).
        with_content(%r{^virtual_uid_maps = static:94779$}).
        with_content(%r{^virtual_gid_maps = static:39179$}).
        with_content(%r{^virtual_alias_maps\s=\s+
                     #{mpath}forwardings.cf\s+
                     #{mpath}email2email.cf\s+
                     #{mpath}domain_forwardings.cf$}x).
        with_content(%r{^virtual_mailbox_domains = #{mpath}domains.cf$}).
        with_content(%r{^virtual_mailbox_maps = #{mpath}mailboxes.cf$})
    end

    it 'generates master.cf with virtual delivery agent' do
      should contain_file('/etc/postfix/master.cf').
        with_content(%r{^virtengine\s+unix\s.+\spipe\s+
                     flags=DRhu\suser=virtuser:virtgroup\sargv=/path/to/lda\s+
                     virtual\slda\sparams$}x)
    end

    it 'generates virtual maps files' do
      should contain_file('/etc/postfix/maps').with(
        ensure: 'directory',
        mode: '0750'
      )
    end
  end

  context 'when ssl is set' do
    let(:params) {{ssl: 'sslkey'}}

    it do
      should contain_file('/etc/postfix/main.cf').
        with_content(%r{^smtpd_use_tls = yes$}).
        with_content(%r{^smtpd_tls_cert_file = /etc/ssl/certs/sslkey.pem$}).
        with_content(%r{^smtpd_tls_key_file = /etc/ssl/private/sslkey.key$})
    end
  end

  context 'when sasl set' do
    let(:params) {{sasl: 'sasl_provider'}}
    it do
      should contain_file('/etc/postfix/main.cf').
        with_content(%r{^smtpd_sasl_auth_enable = yes$}).
        with_content(%r{^broken_sasl_auth_clients = yes$}).
        with_content(%r{^smtpd_sasl_type = sasl_provider$}).
        with_content(%r{^smtpd_sasl_path = private/auth$})
    end
  end

  context 'when absent' do
    let(:params) { { ensure: 'absent' } }
    it do
      should contain_file('/etc/postfix/main.cf').with_ensure('absent')
      should contain_file('/etc/postfix/master.cf').with_ensure('absent')
      should contain_file('/etc/postfix/maps').with_ensure('absent')
    end
  end
end
