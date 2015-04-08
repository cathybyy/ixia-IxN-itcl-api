# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.7
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1.4.8
#		2. add Scenario DeviceGroup class for NGPF

class DeviceGroup {
	
	inherit EmulationObject
	public variable topology
	public variable type
	public variable count
	public variable ethernet
	public variable vlan
	public variable ipv4
	public variable ipv6
	public variable bgpIpv4Peer
	public variable bgpIpv6Peer
	public variable bgpIpv4NetworkGroup
	public variable bgpIpv6NetworkGroup
	
	# -- port can be a list, but one port recommended
	constructor { port } {
		set portObj $port
		reborn
	}
	
	method reborn {} {
		set root [ixNet getRoot]
		set topology [ixNet add $root topology]
		set vPortList [ list ]
		foreach vport $portObj {
			set vport [ $vport cget -handle ]
			lappend vPortList $vport
		}
		ixNet setM $topology \
			-vports $vPortList
		ixNet commit
		
		set hPort $vPortList
		
		set handle [ixNet add $topology deviceGroup]
		ixNet setA $handle -name $this
		ixNet commit		
	}
	
	method config { args } 
	method SetMultipleValue { obj key value } {
		set mv [ ixNet getA $obj -key ]
		ixNet setA $mv/counter -start $value
		if { [ catch {
			ixNet commit
		} ] } {
			ixNet setA $mv/singleValue -value $value
			ixNet commit
		}
	}
	method config_ethernet { args } {}
	method config_ip { args } {}
	method config_ipv4 { args } {}
	method config_ipv6 { args } {}
	method config_bgp { args } {}
	method config_bgp4 { args } {}
	method config_bgp4plus { args } {}
}

# ---------------------------------
# -- type
# -- 	-enum: BGP4_DUAL L3VPN_PE
# -- count
# --	-INT
# -- router_id
# --	-IP
body DeviceGroup::config { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config [info script]"
Deputs "----- TAG: $tag -----"

	if { $handle == "" } {
		reborn
	}
	
	set count 1
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-type {
				set type [ string tolower $value ]
			}
			-count {
				set count $value
			}
			-router_id {
				set router_id $value
			}
		}
    }
	
	ixNet setA $topology -name $type
	ixNet commit
	
	ixNet setM $handle \
		-multiplier $count \
		-name $this 
	ixNet commit
	
	if { [ info exists router_id ] } {
		SetMultipleValue [ ixNet getL $handle routerData ] -routerId $router_id
	}
	
	switch $type {
		BGP4_DUAL {
			set ethernet [ixNet add $handle ethernet]
			ixNet commit
			set ipv4 	 [ixNet add $ethernet ipv4]
			ixNet commit
			set ipv6	 [ixNet add $ethernet ipv6]
			ixNet commit
			set bgpIpv4Peer [ixNet add $ipv4 bgpIpv4Peer]
			ixNet commit
			set bgpIpv6Peer [ixNet add $ipv6 bgpIpv6Peer]
			ixNet commit
			set bgpIpv4NetworkGroup [ixNet add $handle networkGroup]
			set bgpIpv6NetworkGroup [ixNet add $handle networkGroup]
			ixNet commit
		}
		L3VPN_PE {
		}
	}
	
    return [GetStandardReturnHeader]

}

# ---------------------------------
# -- address
# --	-IP
# -- prefix
# --	-INT
# -- gateway
# --	-IP
# -- family
# --	-enum: ipv4 ipv6
body DeviceGroup::config_ip { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ip [info script]"
Deputs "----- TAG: $tag -----"

	if { $handle == "" } {
		config -type $type -count $count
	}
	
#param collection
Deputs "Args:$args "

	array set kvList [list]

    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-address -
			-prefix {
			}
			-gateway {
				set key -gatewayIp
			}
			-family {
				set obj $value
				continue
			}
			default {
				continue
			}
		}
		set kvList($key) $value
    }
	
	if { [ info exists obj ] } {
		foreach key [array names kvList] {
			SetMultipleValue $obj $key $kvList($key)
		}
	}
	return [GetStandardReturnHeader]

}
body DeviceGroup::config_ipv4 { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ipv4 [info script]"
Deputs "----- TAG: $tag -----"

	return [config_ip -family ipv4]
}
body DeviceGroup::config_ipv6 { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ipv6 [info script]"
Deputs "----- TAG: $tag -----"

	return [config_ip -family ipv6]
}

# ---------------------------------
# -- authentication
# --	-enum: null md5
# -- type
# --	-enum: internal external
# -- as
# --	-INT
# -- hold_time_interval
# --	-INT
# -- update_interval
# -- 	-INT
# -- md5
# -- 	-STRING
# -- family
# --	-enum: bgpIpv4Peer bgpIpv6Peer
body DeviceGroup::config_bgp { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_bgp [info script]"
Deputs "----- TAG: $tag -----"

	if { $handle == "" } {
		config -type $type -count $count
	}
	
#param collection
Deputs "Args:$args "

	array set kvList [list]

    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-authentication -
			-type -
			-ttl {
			}
			-md5 {
				set key -md5Key
			}
			-dut_ip {
				set key -dutIp
			}
			-hold_time_interval {
				set key -holdTimer
			}
			-update_interval {
				set key -updateInterval
			}
			-as {
				set key -localAs2Bytes
			}
			-family {
				set obj $value
				continue
			}
			default {
				continue
			}
		}
		set kvList($key) $value
    }
	
	if { [ info exists obj ] } {
		foreach key [array names kvList] {
			SetMultipleValue $obj $key $kvList($key)
		}
	}
	return [GetStandardReturnHeader]

}

body DeviceGroup::config_bgp4 { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_bgp4 [info script]"
Deputs "----- TAG: $tag -----"

	return [config_ip -family bgpIpv4Peer]
}
body DeviceGroup::config_bgp4plus { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_bgp4plus [info script]"
Deputs "----- TAG: $tag -----"

	return [config_ip -family bgpIpv6Peer]
}







