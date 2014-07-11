class phabricator::params {
  $path = '/usr/share/phabricator'
  $phabdir = "${path}/phabricator"
  $hostname = $fqdn
  $mysql_rootpass = undef
  $mysql_host = 'localhost'
  $mysql_root_user = 'root'
  $base_uri = "http://${::ipaddress}/"
  $owner = 'root'
  $group = 'phabricator'
  $vcs_user = 'vcs-user'
  $phd_user = 'phd-user'
  $conftemplate = ''
  $confdir = "${phabdir}/conf/custom"
  $conffile = 'default.conf.php'
  $install_pear = false
  $timezone = 'Europe/Dublin'
  $git_package = 'git'
  $git_libphutil = 'git://github.com/facebook/libphutil.git'
  $git_arcanist = 'git://github.com/facebook/arcanist.git'
  $git_phabricator = 'git://github.com/facebook/phabricator.git'
  $phd_service_file='/etc/init.d/phd'
  $phd_service_name='phd'
  

  # $::operatingsystem
  # - Fedora
  #  -$::operatingsystemrelease
  
  class {'apache::params':
    
  }

  case $::osfamily {
    'RedHat' : {
      $phd_service_file_template='phabricator/phd_rhel.erb'
      
      case $::operatingsystemmajrelease {
        '6', '7' : {
          $php_packages = [
            'php php-cli',
            'php-mysql',
            'php-process',
            'php-devel',
            'php-gd',
            'php-pecl-apc',
            'php-pecl-json',
            'php-mbstring']
        }
        '5'      : {
          $php_packages = [
            'php53',
            'php53-cli',
            'php53-mysql',
            'php53-process',
            'php53-devel',
            'php53-gd',
            'gcc',
            'wget',
            'make',
            'pcre-devel']
          $install_pear = true
        }
        default  : {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, operatingsystemmajrelease: ${::operatingsystemmajrelease} only support osfamily 5,6 or 7"
          )

        }
      }

    }

    'Debian' : {
      $phd_service_file_template='phabricator/phd.erb'
      $php_packages = ['dpkg-dev', 'php5', 'php5-mysql', 'php5-gd', 'php5-dev', 'php5-curl', 'php-apc', 'php5-cli', 'php5-json']

      case $::operatingsystem {
        'Ubuntu' : { $git_package = 'git_core' }
      }
    }

    default  : {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat or Debian"
      )

    }

  }

}
