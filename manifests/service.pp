class postfix::service($ensure = 'running') {
  service {'postfix':
    ensure => $ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [Class['postfix::package'], Class['postfix::config']]
  }
}
