#
# dashboard.pp
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
class puppet::dashboard {

include mysql::server

    $puppet_mysql_username      = extlookup('puppet_mysql_username'      ,'')
	$puppet_mysql_password      = extlookup('puppet_mysql_password'      ,'')

mysql::database{"puppet":
  ensure   => present,
  require => Class["mysql::server"]
}


mysql::rights{"puppet database rights":
  ensure   => present,
  database => "dashboard_production",
  user     => "${puppet_mysql_username}",
  password => "${puppet_mysql_password}",
  require => Class["mysql::server"],
}


package { "puppet-dashboard":
	ensure => present,	
}

file { "/etc/default/puppet-dashboard":
	ensure => present,
	content => template('puppet/puppet-dashboard_default.erb'),
	require => Package["puppet-dashboard"],
}

file { "/usr/share/puppet-dashboard/config/database.yml":
	ensure => present,
	content => template('puppet/database.yml.erb'),
	require => Package["puppet-dashboard"],
}

service { "puppet-dashboard":
  ensure => "running",
  require => [File["/etc/default/puppet-dashboard"], File["/usr/share/puppet-dashboard/config/database.yml"]],
}

service { "puppet-dashboard-workers":
  ensure => "running",
  require => [File["/etc/default/puppet-dashboard"], File["/usr/share/puppet-dashboard/config/database.yml"]],
}

file { "/var/lib/puppet/reports":
	ensure => present,
	mode => 755,
}

}
