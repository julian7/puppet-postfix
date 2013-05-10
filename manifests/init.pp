class postfix($ensure = 'present', $mysql = false) {
  $conf = '/etc/postfix'
  $maps = "${conf}/maps"

  class {postfix::package: ensure => $ensure, mysql => $mysql}
  class {postfix::service:
    ensure => $ensure ? {
      'absent' => 'absent',
      default  => 'running'
    }
  }
}
