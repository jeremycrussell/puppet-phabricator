class phabricator::apache_install ($phabdir = $phabricator::params::phabdir,) {
  class { 'apache': default_vhost => false, }

  class { 'apache': mpm_module => 'prefork' }

  class { 'apache::mod::php': }

  class { 'apache::mod::rewrite': }

  class { 'apache::mod::ssl': }

  class { 'apache::mod::php': }

  apache::vhost { $fqdn:
    port            => '80',
    docroot         => "${$phabdir}/webroot",
    custom_fragment => template('phabricator/apache-vhost-default.conf.erb'),
  }

}
