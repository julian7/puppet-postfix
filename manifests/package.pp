class postfix::package($ensure = 'present') {
  package {'postfix':
    ensure => $ensure
  }
}
