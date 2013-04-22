require 'spec_helper'

describe 'postfix::config' do
  context do
    it do
      should contain_file('/etc/postfix/master.cf').with(
        owner: 'root',
        group: 'postfix',
        mode:  '0640'
      ).with_content(%r{^smtp\s+inet\s.+\bpostscreen$}
      ).with_content(%r{^smtpd\s+pass\s.+\bsmtpd$}
      ).with_content(%r{^dnsblog\s+unix\s.+\bdnsblog$}
      ).with_content(%r{^tlsproxy\s+unix\s.+\btlsproxy$}
      ).with_content(%r{^submission\s+inet\s.+\bsmtpd$}
      ).without_content(%r{^smtpd\s.+$\s+-o\scontent_filter}
      ).without_content(%r{^cfilter\s+unix\s.+\blmtp$}
      ).without_content(%r{^127.0.0.1:10025\s+inet\s.+\ssmtpd$\s+
                        -o\scontent_filter=$\s}x
      )
    end
  end

  context 'with content_filter' do
    let(:params) { { content_filter: 'cfilter' } }
    it do
      should contain_file('/etc/postfix/master.cf'
      ).with_content(
        %r{^smtpd\s+pass\s.+\bsmtpd$\s+
        -o\scontent_filter=cfilter:\[127\.0\.0\.1\]:10024$
        }x
      ).with_content(%r{^cfilter\s+unix\s.+\blmtp$}
      ).with_content(%r{^127.0.0.1:10025\s+inet\s.+\ssmtpd$\s+
                     -o\scontent_filter=$\s}x
      )
    end
  end

  context 'when absent' do
    let(:params) { { ensure: 'absent' } }
    it do
      should contain_file('/etc/postfix/master.cf').with_ensure('absent')
    end
  end
end

