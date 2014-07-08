class phabricator::phab_install (
  $path            = $phabricator::params::path,
  $owner           = $phabricator::params::owner,
  $group           = $phabricator::params::group,
  $vcs_user        = $phabricator::params::vcs_user,
  $phd_user        = $phabricator::params::phd_user,
  $git_libphutil   = $phabricator::params::git_libphutil,
  $git_arcanist    = $phabricator::params::git_arcanist,
  $git_phabricator = $phabricator::params::git_phabricator,
  $phabdir         = $phabricator::params::phabdir,) {
  # Get phabricator git repositories

  file { $path:
    ensure => directory,
    owner  => $owner,
    group  => $group
  }

  $libpdir = "${path}/libphutil"

  $arcdir = "${path}/arcanist"

  vcsrepo { $libpdir:
    ensure   => present,
    provider => git,
    source   => $git_libphutil,
  }

  vcsrepo { $arcdir:
    ensure   => present,
    provider => git,
    source   => $git_arcanist,
  }

  vcsrepo { $phabdir:
    ensure   => present,
    provider => git,
    source   => $git_phabricator,
  }

  # Create user

  if ($owner != 'root') {
    user { $owner:
      comment    => "User for Phabricator",
      ensure     => present,
      managehome => false,
      system     => true,
    }
  }

  group { $group:
    ensure  => present,
    members => $apache::params::apache_name,
  }

  user { $phd_user:
    ensure  => present,
    groups  => $group,
    system  => true,
    require => Group[$group]
  #    uid    => 10001,
  }

  user { $vcs_user:
    ensure  => present,
    groups  => $group,
    system  => true,
    require => Group[$group]
  #    uid    => 10002,
  }

}
