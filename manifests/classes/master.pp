#
# master.pp
# 
# Copyright (c) 2011, OSBI Ltd. All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301  USA
#
# Class: puppet::master
#
# A puppetmaster server module for cloudbi
#
class puppet::master inherits puppet {
    
    $empty = []
    $puppet_report_types            = extlookup('puppet_report_types'         ,'store')
    $puppet_svn_user                = extlookup('puppet_svn_user'             ,'puppet')
    $puppet_svn_password            = extlookup('puppet_svn_password'         ,'')
    $puppet_puppetup_cron_minutes   = extlookup('puppet_puppetup_cron_minutes','')
    $puppet_autosign                = extlookup('puppet_autosign'             ,$empty)
    $puppetdashboard_mysql_database = extlookup('puppetdashboard_mysql_database','')
    $puppetdashboard_mysql_user     = extlookup('puppetdashboard_mysql_user','')
    $puppetdashboard_mysql_pass     = extlookup('puppetdashboard_mysql_pass','')


    $puppet_mysql_username      = extlookup('puppet_mysql_username'      ,'')
	$puppet_mysql_password      = extlookup('puppet_mysql_password'      ,'')

	mysql::database{"dashboard_production":
  		ensure   => present,
  		require => Class["mysql::server"]
	}


	mysql::rights{"dashboard database rights":
  		ensure   => present,
  		database => "puppet",
  		user     => "${puppet_mysql_username}",
  		password => "${puppet_mysql_password}",
  		require => Class["mysql::server"],
	}
    
    package { 'puppetmaster':
       ensure => present,
    }
#    package { 'puppetmaster-passenger':
#       ensure => present,
#    }
    package { "libactiverecord-ruby":
    	ensure => present,
    }
    #package { 'puppet-dashboard':
    #	ensure  => present,
    #}
    
    #include mysql::server
    #include subversion
    
    # Overwrite puppet.conf from puppet module with template specific to master
    File['/etc/puppet/puppet.conf'] {
        content => template('puppet/puppet.conf-master.erb'),
    }
    
    service { 'puppetmaster':
        ensure => stopped,
        enable => false,
		hasstatus => true,
    }
    
    service { 'apache2':
        ensure => running,
        enable => true,
		hasstatus => true,
    }
    
    # Convinience wrapper to update manfiests & modules from subversion
    file { '/usr/sbin/puppetup':
        ensure  => present,
        content => template('puppet/puppetup.erb'),
        mode    => '0755'
    }
    
    # Setup cron job for puppetup to be executed every X minutes
    if ( $puppet_puppetup_cron_minutes != '' and $puppet_svn_password != '' ) {
        file { '/etc/cron.d/puppetup':
            ensure => present,
            content => template('puppet/puppetup.cron.erb'),
            require => File['/usr/sbin/puppetup']
        }
    }

    # enable autosign  
    file { '/etc/puppet/autosign.conf':
        ensure => present,
        content => template('puppet/autosign.conf.erb')
    }
    
    # Ruby from epel, puppet from epel-puppet
    #Yumrepo['epel'] -> Yumrepo['epel-puppet'] -> Package['puppet-server'] -> 
    #File['/etc/puppet/puppet.conf'] 
    #~> Service['puppetmaster']
    
    
    # Puppet-dashboard config 
    #file { '/usr/share/puppet-dashboard/config/database.yml':
    #    ensure  => present,
    #    content => template('puppet/puppet-dashboard_database.yml.erb'),
    #    mode    => '0755',
    #    require => Package['puppet-dashboard']
    #}
    
    #ÊPuppet dashboard service should be running
    #service { 'puppet-dashboard':
    #    ensure => running,
    #    enable => true,
    #}    
    
    # TODO: create the database and run the following from /usr/share/puppet-dashboard 
    #       rake RAILS_ENV=production db:create
    #       rake RAILS_ENV=production db:migrate
    #       rake RAILS_ENV=production reports:import REPORT_DIR=/path/to/your/reports


}

