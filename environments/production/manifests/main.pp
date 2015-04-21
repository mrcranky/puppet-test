node default {
  notice('version - 0.0.13')

  file { ['c:\installers']:
    ensure => 'directory',
  } ->
  cloud_file { 'c:\installers\npp-Installer.exe':
    ensure => present,
    source => 'blackcompany-puppet/installers/npp.6.7.7.Installer.exe',
    access_key_id     => 'AKIAJQGZHGFW2O7XVM7A',
    secret_access_key => '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',
  } ->
  package { 'Notepad++':
    ensure => '6.7.7',
    source => 'c:\installers\npp-Installer.exe',
    install_options => [ '/S' ],
  }

}
