class phabricator::mysql_install (
  $mysql_rootpass  = $phabricator::params::mysql_rootpass,
  $mysql_host      = $phabricator::params::mysql_host,
  $mysql_root_user = $phabricator::params::mysql_root_user,) {
  class { 'mysql::server':
    root_password    => $mysql_rootpass,
    override_options => {
      'mysqld' => {
        'sql_mode' => 'STRICT_ALL_TABLES'
      }
    }
  }

}
