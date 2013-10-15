class postfix::package($ensure = 'present', $mysql = false, $spf = false) {
  package {'postfix': ensure => $ensure }
  package {'postfix-mysql':
    ensure => $mysql ? { true => $ensure, default => 'absent' }
  }
  package {'postfix-policyd-spf-python':
    ensure => $spf ? { true => $ensure, default => 'absent' }
  }
}
