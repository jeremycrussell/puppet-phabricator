class phabricator (
  $path             = $phabricator::params::path,
  $phabdir          = $phabricator::params::phabdir,
  $group            = $phabricator::params::group,
  $hostname         = $phabricator::params::hostname,
  $owner            = $phabricator::params::owner,
  $vcs_user         = $phabricator::params::vcs_user,
  $phd_user         = $phabricator::params::phd_user,
  $timezone         = $phabricator::params::timezone,
  $conftemplate     = $phabricator::params::conftemplate,
  $conffile         = $phabricator::params::conffile,
  $confdir          = $phabricator::params::confdir,
  $git_libphutil    = $phabricator::params::git_libphutil,
  $git_arcanist     = $phabricator::params::git_arcanist,
  $git_phabricator  = $phabricator::params::git_phabricator,
  $mysql_rootpass   = $phabricator::params::mysql_rootpass,
  $mysql_host       = $phabricator::params::mysql_host,
  $mysql_root_user  = $phabricator::params::mysql_root_user,
  $base_uri         = $phabricator::params::base_uri,
  $phd_service_file = $phabricator::params::phd_service_file,
  $phd_service_name = $phabricator::params::phd_service_name,
  $phd_service_file_template = $phabricator::params::phd_service_file_template) inherits phabricator::params {
  # Install mysql and php modules

  Package {
    ensure => 'installed' }

  class { 'mysql::server':
    root_password    => 'blossom',
    override_options => {
      'mysqld' => {
        'sql_mode' => 'STRICT_ALL_TABLES'
      }
    }
  }
  
  class { 'phabricator::apache_install':
    
  }

  class { 'phabricator::pear':
    require => Package[$phabricator::params::php_packages]
  }

  package { $phabricator::params::php_packages: }

  package { $phabricator::params::git_package: }

  class { 'phabricator::phab_install':
    require => [
      Package[$phabricator::params::php_packages],
      Package[$phabricator::params::git_package]]
  }

  class { 'phabricator::phab_config':
    require => Class['phabricator::phab_install']
  }

  # Add host entry for the FQDN (hostname)
  # We assume that the FQDN should map to localhost. We set this host
  # entry so the name resolution does not depend on a correct DNS
  # server configuration; as a consequence, even a test environment
  # should work without name resolution problems (as an example,
  # consider that if there is a name resolution problem, the phd
  # launcher won't work).
  host { $hostname: ip => '127.0.0.1', }

  # Set default configuration
  # We use a template configuration file with the mysql root password
}
