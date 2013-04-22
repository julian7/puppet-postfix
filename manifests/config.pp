class postfix::config(
  $ensure = 'present',
  $content_filter = undef,
  $virtual = 'dovecot',
  $virtual_usergroup = 'vmail:vmail',
  $virtual_lda = '/usr/lib/dovecot/dovecot-lda',
  $virtual_lda_params = "-f \${sender} -d \${user}@\${nexthop} -m \${extension}"
  ) inherits postfix {

  File {
    ensure => $ensure,
    owner  => 'root',
    group  => 'postfix',
    mode   => '0640'
  }

  file {
    "${postfix::conf}/master.cf":
      ensure  => $ensure,
      content => template('postfix/master.cf.erb')
  }
}
