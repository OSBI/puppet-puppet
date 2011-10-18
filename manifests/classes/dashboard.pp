class puppet::dashboard {

include mysql::server

    $puppet_mysql_username      = extlookup('puppet_mysql_username'      ,'')
	$puppet_mysql_password      = extlookup('puppet_mysql_password'      ,'')

mysql::database{"dashboard_production":
  ensure   => present,
  require => Class["mysql::server"]
}


mysql::rights{"dashboard database rights":
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



}
