class postfix::maps(
  $ensure = 'present',
  $dbhost,
  $dbname,
  $dbuser,
  $dbpass,
  $aliases_table = 'aliases',
  $aliases_destination = 'destination',
  $aliases_local = 'local',
  $aliases_domain = 'domain',
  $domains_table = 'domains',
  $domains_domain = 'domain',
  $users_table = 'users',
  $users_user = 'user',
  $users_domain = 'domain'
  ) inherits postfix {

  include postfix::config

  File {
    ensure  => $ensure,
    owner   => 'root',
    group   => 'postfix',
    mode    => '0640',
    require => [Package['postfix-mysql'], Class['postfix::config']],
    notify  => Class['postfix::service']
  }

  file {
    "${postfix::maps}/domain_forwardings.cf":
      content => template("postfix/domain_forwardings_map.erb")
      ;
    "${postfix::maps}/domains.cf":
      content => template("postfix/domains_map.erb")
      ;
    "${postfix::maps}/email2email.cf":
      content => template("postfix/email2email_map.erb")
      ;
    "${postfix::maps}/forwardings.cf":
      content => template("postfix/forwardings_map.erb")
      ;
    "${postfix::maps}/mailboxes.cf":
      content => template("postfix/mailboxes_map.erb")
      ;
  }
}