node default {
  notice('version - 0.0.9')

  file { ['c:\installers']:
    ensure => 'directory',
  }
  file { 'npp.6.7.7.Installer.exe':
    source => 'puppet:///modules/thor/npp.6.7.7.Installer.exe',
    path => 'c:\installers\npp.6.7.7.Installer.exe',
    ensure => present,
    source_permissions => ignore,
  }
}
