class postfix($ensure = 'present') {
  $conf = '/etc/postfix'

  class {postfix::package: ensure => $ensure}
}
