class postfix::config(
  $ensure = 'present',
  $ssl = undef,
  $sasl = undef,
  $proxy_interfaces = undef,
  $hostname = 'mailhost',
  $networks = ['127.0.0.0/8'],
  $content_filter = undef,
  $spf_helo = "SPF_Not_Pass",
  $spf_from = "Fail",
  $spf_skip = [],
  $virtual = undef,
  $virtual_homes = '/srv/mailboxes',
  $virtual_usergroup = 'vmail:vmail',
  $virtual_uid = 90,
  $virtual_gid = 90,
  ) inherits postfix {

  $spf = $postfix::spf
  $spf_full_skip = [[
    '127.0.0.0/8',
    '::ffff:127.0.0.0//104',
    '::1//128'
  ], $spf_skip ]

  $directory = $ensure ? {
    'absent' => 'absent',
    default  => 'directory'
  }
  $virtfile = $virtual ? { undef => 'absent', default => $ensure }
  $virtdir = $virtual ? { undef => 'absent', default => $directory }

  File {
    ensure => $ensure,
    owner  => 'root',
    group  => 'postfix',
    mode   => '0644',
    notify => Class['postfix::service']
  }

  file {
    "/etc/mailname":
      content => "${$hostname}\n",
      ;
    "${postfix::conf}/master.cf":
      content => template('postfix/master.cf.erb')
      ;
    "${postfix::conf}/main.cf":
      content => template('postfix/main.cf.erb')
      ;
    "/etc/postfix/maps":
      ensure => $virtdir,
      mode   => '0750'
      ;
    "/etc/postfix-policyd-spf-python":
      ensure => $spf ? { true => $directory, default => 'default' },
      group  => 'root',
      mode   => '0755'
      ;
    "/etc/postfix-policyd-spf-python/policyd-spf.conf":
      ensure  => $spf ? { true => $ensure, default => 'default' },
      group   => 'root',
      content => template('postfix/policyd-spf-python.conf.erb')
      ;
  }
}
