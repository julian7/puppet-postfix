require 'spec_helper'

describe 'postfix::config' do
  context do
    it 'generates main.cf' do
      should contain_file('/etc/postfix/main.cf').with(
        owner: 'root',
        group: 'postfix',
        mode:  '0640'
      ).
        with_content(%r{^myhostname = mailhost$}).
        with_content(%r{^mynetworks = 127.0.0.0/8$})
    end

    it 'generates master.cf' do
      should contain_file('/etc/postfix/master.cf').with(
        owner: 'root',
        group: 'postfix',
        mode:  '0640'
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
      mpath = 'mysql:/etc/postfix/mysql/'
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
  end

  context 'when absent' do
    let(:params) { { ensure: 'absent' } }
    it do
      should contain_file('/etc/postfix/main.cf').with_ensure('absent')
      should contain_file('/etc/postfix/master.cf').with_ensure('absent')
    end
  end
end

