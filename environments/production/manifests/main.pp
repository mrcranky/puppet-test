node default {
  notice('version - 0.0.11')

  file { ['c:\installers']:
    ensure => 'directory',
  }
  file { 'npp.6.7.7.Installer.exe':
    source => 'puppet:///modules/thor/npp.6.7.7.Installer.exe',
    path => 'c:\installers\npp-Installer.exe',
    ensure => present,
    source_permissions => ignore,
    mode => 'u+rwx',
  }
  package { 'Notepad++':
    ensure => '6.7.7',
    source => 'c:\installers\npp-Installer.exe',
    install_options => [ '/S' ],
  }
}
