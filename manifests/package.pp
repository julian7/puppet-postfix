class postfix::package($ensure = 'present', $mysql = false) {
  $packages = ['postfix']
  if $mysql == true {
    $packages += 'postfix-mysql'
  }
  package {$packages:
    ensure => $ensure
  }
}
