define s3get ($domain="s3-eu-west-1", $bucket=$DEFAULTS3BUCKET, $cwd="/tmp", $expires=30) {
  $curlCommand = s3getcurl($domain, $bucket, $title, $name, $expires)

  $actualCommand = "powershell \"Invoke-WebRequest ${curlCommand}\""
  notice("curlCommand: ${curlCommand}")

  exec { "s3getcurl[$bucket][$title][$name]":
      cwd     => $cwd,
      path    => $::path,
      creates => "$cwd/$name",
      command => $actualCommand,
  }
}  

node default {
  notice('version - 0.0.18')

  exec { 'AllowPowerShellScripts':
    path => $::path,
    command => "powershell Set-ExecutionPolicy Unrestricted", 
    logoutput => true,
  } ->

  file { "$system32/WindowsPowerShell/v1.0/Modules/PSWindowsUpdate":
    ensure => directory,
    recurse => remote,
    source => 'puppet:///modules/thor/PSWindowsUpdate',
    source_permissions => ignore,
  } ->

  file { ['c:\installers']:
    ensure => directory,
  } ->

  file { 'c:\installers\windows_update.ps1':
    ensure => present,
    source => 'puppet:///modules/thor/windows_update.ps1',
    source_permissions => ignore,
  } ->

  exec { 'WindowsUpdate':
    path => $::path,
    cwd => 'c:\installers',
    command => 'powershell .\windows_update.ps1 \"04/16/2015 12:00\"', 
    logoutput => true,
  } ->

  s3get { 'installers/npp.6.7.7.Installer.exe':
    cwd     => 'c:\installers',
    name    => 'npp-Installer.exe',
    expires => '3600',
    bucket  => 'blackcompany-puppet',
  } ->
  package { 'Notepad++':
    source => 'c:\installers\npp-Installer.exe',
    ensure => '6.7.7',
    install_options => [ "/S" ],
  }

}
