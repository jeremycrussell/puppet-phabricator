class phabricator::apache_install ($phabdir = $phabricator::params::phabdir,) {
  class { 'apache':
    mpm_module    => 'prefork',
    default_vhost => false,
  }

  class { 'apache::mod::php':
  }

#  class { 'apache::mod::rewrite':
#  }

  class { 'apache::mod::ssl':
  }

  apache::vhost { $phabricator::params::hostname:
    port            => '80',
    docroot         => "${$phabdir}/webroot",
    custom_fragment => template('phabricator/apache-vhost-default.conf.erb'),
  }

}
