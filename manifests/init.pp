import "classes/*.pp"
#import "definitions/*.pp"

# Class: puppet
#
# A puppet agent module for puppet clients/agents and a base for the 
# puppet::master module.
#
class puppet {
    
    $puppet_server      = extlookup('puppet_server'      ,'puppet')
    $puppet_report      = extlookup('puppet_report'      ,'false')
    $puppet_noop        = extlookup('puppet_noop'        ,'false')
    $puppet_pluginsync  = extlookup('puppet_pluginsync'  ,'false')
    $puppet_report_url  = extlookup('puppet_report_url'  , 'http://puppet.analytical-labs.com:3000/reports')    
#    include repos
#    realize( Yumrepo['epel'], Yumrepo['epel-puppet'] )
    
    package { 'puppet':
        ensure => present,
    }
    
    file { '/etc/puppet/puppet.conf':
        ensure => present,
        content => template('puppet/puppet.conf-agent.erb'),
    }
    
    service { 'puppet':
        ensure => running,
        enable => true,
    }
    
#    Yumrepo['epel'] -> Yumrepo['epel-puppet'] -> 
     Package['puppet'] -> File['/etc/puppet/puppet.conf'] ~> Service['puppet']
    
}

