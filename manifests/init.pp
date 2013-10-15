class postfix($ensure = 'present', $mysql = false, $spf = false) {
  $conf = '/etc/postfix'
  $maps = "${conf}/maps"

  class {postfix::package: ensure => $ensure, mysql => $mysql, spf => $spf}
  class {postfix::service:
    ensure => $ensure ? {
      'absent' => 'absent',
      default  => 'running'
    }
  }
}
