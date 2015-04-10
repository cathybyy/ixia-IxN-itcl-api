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
	public variable ipv4PrefixPools
	public variable ipv6PrefixPools
	public variable bgpIPRouteProperty
	public variable bgpV6IPRouteProperty
	
	# -- port can be a list, but one port recommended
	# -- template
	# -- 	-enum: BGP4_DUAL L3VPN_PE	
	constructor { port template } {
		set portObj $port
		set type [ string toupper $template ]
		reborn
	}
	
	method reborn {} {}
	
	method config { args } 
	method SetMultipleValue { obj key value } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::SetMultipleValue [info script]"
Deputs "----- TAG: $tag -----"
Deputs "obj:$obj key:$key val:$value"
		set mv [ ixNet getA $obj $key ]
Deputs "mv:$mv"
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
	method import_bgp_route { obj filename } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::import_bgp_route [info script]"
Deputs "----- TAG: $tag -----"
Deputs "filename:$filename"
		ixNet setM $obj/importBgpRoutesParams \
			-fileType csv \
			-dataFile [ixNet readFrom $filename]
		ixNet commit
		ixNet exec importBgpRoutes $obj/importBgpRoutesParams
	}
	method import_bgp4_route { filename } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::import_bgp4_route [info script]"
Deputs "----- TAG: $tag -----"
		import_bgp_route $bgpIPRouteProperty $filename
	}
	method import_bgp4plus_route { filename } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::import_bgp4plus_route [info script]"
Deputs "----- TAG: $tag -----"
		import_bgp_route $bgpV6IPRouteProperty $filename
	}
}

body DeviceGroup::reborn {} {
	global errorInfo
	global errNumber
	set tag "body DeviceGroup::reborn [info script]"
Deputs "----- TAG: $tag -----"
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
			set ipv4PrefixPools [ ixNet add $bgpIpv4NetworkGroup ipv4PrefixPools ]
			set ipv6PrefixPools [ ixNet add $bgpIpv6NetworkGroup ipv6PrefixPools ]
			ixNet commit
			set bgpIPRouteProperty 		[ ixNet getL $ipv4PrefixPools bgpIPRouteProperty ]
			set bgpV6IPRouteProperty 	[ ixNet getL $ipv6PrefixPools bgpV6IPRouteProperty ]
			SetMultipleValue [ ixNet getL $ipv4PrefixPools bgpV6IPRouteProperty ] -active false
			SetMultipleValue [ ixNet getL $ipv6PrefixPools bgpIPRouteProperty ] -active false
			
		}
		L3VPN_PE {
		}
	}
	
	ixNet setA $topology -name $type
	ixNet commit

}

# ---------------------------------
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
			-count {
				set count $value
			}
			-router_id {
				set router_id $value
			}
		}
    }
		
	ixNet setM $handle \
		-multiplier $count \
		-name $this 
	ixNet commit
	
	if { [ info exists router_id ] } {
		SetMultipleValue [ ixNet getL $handle routerData ] -routerId $router_id
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
		config -count $count
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

	return [eval config_ip -family $ipv4 $args]
}
body DeviceGroup::config_ipv6 { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ipv6 [info script]"
Deputs "----- TAG: $tag -----"

	return [eval config_ip -family $ipv6 $args]
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
		config -count $count
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

	return [eval config_bgp -family $bgpIpv4Peer $args]
}
body DeviceGroup::config_bgp4plus { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_bgp4plus [info script]"
Deputs "----- TAG: $tag -----"

	return [eval config_bgp -family $bgpIpv6Peer $args]
}







