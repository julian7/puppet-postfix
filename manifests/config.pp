class postfix::config(
  $ensure = 'present',
  $ssl = true,
  $hostname = 'mailhost',
  $networks = ['127.0.0.0/8'],
  $content_filter = undef,
  $virtual = undef,
  $virtual_homes = '/srv/mailboxes',
  $virtual_usergroup = 'vmail:vmail',
  $virtual_uid = 90,
  $virtual_gid = 90,
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
      ;
    "${postfix::conf}/main.cf":
      content => template('postfix/main.cf.erb')
      ;
  }
  $virtfile = $virtual ? {
    undef   => 'absent',
    default => 'present'
  }
  $virtdir = $virtual ? {
    undef   => 'absent',
    default => $ensure ? {
      'absent' => 'absent',
      default  => 'directory'
    }
  }
  file {
    "/etc/postfix/maps":
      ensure => $virtdir,
      mode   => '0750'
  }
}
