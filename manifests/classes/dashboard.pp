class puppet::dashboard {

package { "puppet-dashboard":
	ensure => present,	
}

file { "/etc/default/puppet-dashboard":
	ensure => present,
	content => template('puppet/puppet-dashboard_default.erb'),
	require => Package["puppet-dashboard"],
}