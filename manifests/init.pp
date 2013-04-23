class postfix($ensure = 'present') {
  $conf = '/etc/postfix'
  $maps = "${conf}/maps"

  class {postfix::package: ensure => $ensure}
  class {postfix::service:
    ensure => $ensure ? {
      'absent' => 'absent',
      default  => 'running'
    }
  }
}
