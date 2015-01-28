class phabricator::phab_post_install_config (  
  $vcs_user        = $phabricator::params::vcs_user,
  $phd_user        = $phabricator::params::phd_user,
  $timezone         = $phabricator::params::timezone,
  ) {
  
  ini_setting { 'php_ini':
    ensure  => present,
    path    => '/etc/php.ini',
    section => 'Date',
    setting => 'date.timezone',
    value   => $timezone,
    notify  => Service[$apache::params::service_name],
    require => Package[$phabricator::params::php_packages]
  }

 

  # TODO: remomve Defaults    requiretty
  if ! defined (Class['sudo']) {
    class { 'sudo':
      purge               => false,
      config_file_replace => false,
    }
  }

  sudo::conf { $vcs_user:
    priority => 10,
    content  => "${vcs_user} ALL=(${phd_user}) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/hg, /usr/bin/svnserve",
  }

  sudo::conf { $apache::params::apache_name:
    priority => 9,
    content  => "${apache::params::apache_name} ALL=(${phd_user}) SETENV: NOPASSWD: /usr/bin/git-http-backend, /usr/bin/hg",
  }


}
