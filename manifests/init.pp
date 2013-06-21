class phabricator (
  $path,
  $hostname,
  $mysql_rootpass = '',
  $owner = 'root',
  $group = 'root',
  $conftemplate = '',
) {
  # Install mysql and php modules

  Package { ensure => 'installed' }

  include 'mysql'

  $phpmodules = ['php5',
                  'php5-mysql',
                  'php5-gd',
                  'php5-dev',
                  'php5-curl',
                  'php-apc',
                  'php5-cli']

  package { $phpmodules: }

  package { 'dpkg-dev': }

  # Get phabricator git repositories

  file { $path: ensure => directory, }

  $libpdir = "${path}/libphutil"

  $arcdir = "${path}/arcanist"

  $phabdir = "${path}/phabricator"

  vcsrepo { $libpdir:
    ensure   => present,
    provider => git,
    source   => 'git://github.com/facebook/libphutil.git',
  }

  vcsrepo { $arcdir:
    ensure   => present,
    provider => git,
    source   => 'git://github.com/facebook/arcanist.git',
  }

  vcsrepo { $phabdir:
    ensure   => present,
    provider => git,
    source   => 'git://github.com/facebook/phabricator.git',
  }


  # Configure apache vhost

  class { 'apache':
      mpm_module => 'prefork'
  }

  include 'apache::mod::php'

  apache::mod { 'rewrite': }

  apache::vhost { 'phabricator':
    ensure            => present,
    servername        => $::fqdn,
    port              => '80',
    docroot           => "${phabdir}/webroot",
    directories       => [ "webroot" => {
        path          => "${phabdir}/webroot",
        allowOverride => ['Indexes']
        }],
    custom_fragment   => template('phabricator/apache-vhost-default.conf.erb'),
    require           => Vcsrepo[$phabdir],
  }

  # Add host entry for the FQDN (hostname)
  # We assume that the FQDN should map to localhost. We set this host
  # entry so the name resolution does not depend on a correct DNS
  # server configuration; as a consequence, even a test environment
  # should work without name resolution problems (as an example,
  # consider that if there is a name resolution problem, the phd
  # launcher won't work).
  host { $hostname:
    ip => '127.0.0.1',
  }

  # Set default configuration
  # We use a template configuration file with the mysql root password

  $confdir = "${phabdir}/conf/custom"

  $conffile = 'default.conf.php' # Phabricator configuration file

  if $conftemplate == '' {
    $cnftemplate = template("phabricator/${conffile}.erb")
  } else {
    $cnftemplate = $conftemplate
  }

  file { $confdir:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    require => Vcsrepo[$phabdir],
  }

  file { $conffile:
    ensure  => present,
    path    => "${confdir}/${conffile}",
    content => $cnftemplate,
    owner   => $owner,
    group   => $group,
    require => File[$confdir],
    notify  => Service['httpd'],
  }

  # Because we want phabricator to load its db schemata for the first
  # time after creating this file, we notify to upgrade_storage; we do
  # it here because this is where we end the db configuration. We also
  # want mysql::server to be configured with the correct password and,
  # therefore, we ensure this dependency.
  file { 'ENVIRONMENT':
    ensure  => present,
    path    => "${phabdir}/conf/local/ENVIRONMENT",
    content => "custom/default",
    require => [
      Class['mysql::server'],
      Package['httpd'],
      File[$conffile],
    ],
    notify  => [
      Service['httpd'],
      Exec['upgrade_storage'],
    ],
  }

  exec { 'upgrade_storage':
    command     => "${phabdir}/bin/storage upgrade --force",
    require     => Service['mysqld'],
    refreshonly => true,
  }
}
