define s3get ($bucket=$DEFAULTS3BUCKET, $cwd="/tmp", $expires=30) {
  $curlCommand = s3getcurl($bucket, $title, $name, $expires)

  notice($curlCommand)

  exec { "s3getcurl[$bucket][$title][$name]":
      cwd     => $cwd,
      path    => $::path,
      creates => "$cwd/$name",
      command => 'curl.exe ${curlCommand}',
  }
}  

node default {
  notice('version - 0.0.17')

  file { ['c:\installers']:
    ensure => 'directory',
  } ->
  file { 'c:\installers\vcredist_x64.exe':
    source => "puppet:///modules/thor/vcredist_x64.exe",
    source_permissions => ignore,
    mode => 'u+rwx',
  } ->
  package { 'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219':
    source => 'c:\installers\vcredist_x64.exe',
    ensure => '10.0.40219',
    install_options => [ '/q' ],
  } ->
  file { 'c:\installers\curl.exe':
    source => 'puppet:///modules/thor/curl.exe',
    source_permissions => ignore,
    mode => 'u+rwx',
  } ->
  file { 'c:\installers\curl-ca-bundle.crt':
    source => 'puppet:///modules/thor/curl-ca-bundle.crt',
    source_permissions => ignore,
    mode => 'u+rw',
  } ->
  s3get { 'npp-Installer.exe':
    cwd     => 'c:\installers',
    name    => 'installers/npp.6.7.7.Installer.exe',
    expires => '90',
    bucket  => 'blackcompany-puppet',
  }


}
