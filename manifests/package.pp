class postfix::package($ensure = 'present', $mysql = false) {
  $packages = $mysql ? {
    true  => ['postfix', 'postfix-mysql'],
    false => 'postfix'
  }
  package {$packages:
    ensure => $ensure
  }
}
