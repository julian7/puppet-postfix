class postfix($ensure = 'present') {
  $conf = '/etc/postfix'

  class {postfix::package: ensure => $ensure}
  class {postfix::service:
    ensure => $ensure ? {
      'absent' => 'absent',
      default  => 'running'
    }
  }
}
