class phabricator::phd (
  $path     = $phabricator::params::path,
  $phabdir  = $phabricator::params::phabdir,
  $owner    = $phabricator::params::owner,
  $group    = $phabricator::params::group,
  $phd_service_file          = $phabricator::params::phd_service_file,
  $phd_service_name          = $phabricator::params::phd_service_name,
  $phd_service_file_template = $phabricator::params::phd_service_file_template,
  $phd_user = $phabricator::params::phd_user,) {

  file { ['/var/tmp/phd', '/var/tmp/phd/pid', '/var/tmp/phd/log']:
    ensure => directory,
    owner  => $phd_user,
    group  => $group,
  }

  $phd_path = "${$phabdir}/bin" # For phd.erb template

  notify { "phabricator phabdir is #{phabricator::params::phabdir}": }

  file { $phd_service_file:
    ensure  => present,
    mode    => 0755,
    content => template($phd_service_file_template),
  }

  service { $phd_service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File[$phd_service_file],
  }
}
