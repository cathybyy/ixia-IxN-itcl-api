# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.5
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1.4.8
#		2. add Scenario DeviceGroup class for NGPF
# Version 1.2.5.14
#		3. add enum IPV4 & IPV6 
#		4. add config_ethernet
#		5. add config_vlan
# Version 1.3.4.66
#		6. add config_ip
#		7. add config_bgp
#		8. add config_bgp_route
#		9. add set_route
# Version 1.4.6.9
#		10. add -type in config
# Version 1.5.6.10
#		11. add alias in config_ethernet config_ip

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
	constructor { port { template null } } {
		set portObj $port
		set type [ string toupper $template ]
		reborn
	}
	
	method reborn {} {}
	method init {} {
		switch $type {
			BGP4_DUAL {
				set ethernet [ixNet add $handle ethernet]
				ixNet commit
				set vlan [lindex [ixNet getL $ethernet vlan] 0]
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
			BGP4 {
				set ethernet [ixNet add $handle ethernet]
				ixNet commit
				set vlan [lindex [ixNet getL $ethernet vlan] 0]
				set ipv4 	 [ixNet add $ethernet ipv4]
				ixNet commit
				set bgpIpv4Peer [ixNet add $ipv4 bgpIpv4Peer]
				ixNet commit
			
			}
			IPV4 {
				set ethernet [ixNet add $handle ethernet]
				ixNet commit
				set vlan [lindex [ixNet getL $ethernet vlan] 0]
				set ipv4 	 [ixNet add $ethernet ipv4]
				ixNet commit		
			}
			IPV6 {
				set ethernet [ixNet add $handle ethernet]
				ixNet commit
				set vlan [lindex [ixNet getL $ethernet vlan] 0]
				set ipv6	 [ixNet add $ethernet ipv6]
				ixNet commit
			}
			L3VPN_PE {
			}
		}
		ixNet setA $topology -name ${type}_$this
		ixNet commit
	}
	method config { args } 
	proc SetMultipleValue { obj key value { step 0 } } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::SetMultipleValue [info script]"
Deputs "----- TAG: $tag -----"
Deputs "obj:$obj key:$key val:$value step:$step"
		set mv [ ixNet getA $obj $key ]
Deputs "mv:$mv"
		if { $step != 0 } {
Deputs Step5
			ixNet setA $mv -pattern counter
			ixNet commit
		}
Deputs Step10		
		if { [ catch {
			set isMvObj [ixNet exists $mv]
	 	} ] } {
			return
		} else {
			if { $isMvObj == "false" } {
				return
			}
		}
		
		ixNet setM $mv/counter \
			-start $value \
			-step $step
		if { [ catch {
Deputs Step20		
			ixNet commit
		} ] } {
Deputs Step30		
			ixNet setA $mv/singleValue -value $value
			catch {
Deputs Step40			
				ixNet commit
			}
		}
	}
	method config_ethernet { args } {}
	method config_vlan { args } {}
	method config_ip { args } {}
	method config_ipv4 { args } {}
	method config_ipv6 { args } {}
	method config_bgp { args } {}
	method config_bgp4 { args } {}
	method config_bgp4plus { args } {}
	method config_bgp_route { args } {}
	method config_bgp4_route { args } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::config_bgp4_route [info script]"
Deputs "----- TAG: $tag -----"
		if { [ info exists bgpIPRouteProperty ] } {
		
			eval config_bgp_route $args -obj $bgpIPRouteProperty
		} else {
			eval config_bgp_route $args -family ipv4
		}
		return [GetStandardReturnHeader]

	}
	method config_bgp4plus_route { args } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::config_bgp4plus_route [info script]"
Deputs "----- TAG: $tag -----"
		eval config_bgp_route $args -obj $bgpV6IPRouteProperty
		return [GetStandardReturnHeader]

	}
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
	method start_bgp4_route {} {
		ixNet exec start $bgpIpv4NetworkGroup
	}
	method start_bgp4plus_route {} {
		ixNet exec start $bgpIpv6NetworkGroup
	}
	method set_route { args } {}
	proc enable_prefix { obj } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::enable_prefix [info script]"
Deputs "----- TAG: $tag -----"
		SetMultipleValue [ixNet getP $obj] -enabled true
	}
	proc disable_prefix { obj } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::disable_prefix [info script]"
Deputs "----- TAG: $tag -----"
		SetMultipleValue [ixNet getP $obj] -enabled false
	}
	proc start_prefix { obj } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::advertise_prefix [info script]"
Deputs "----- TAG: $tag -----"
		ixNet exec start [ixNet getP $obj]
	}
	proc stop_prefix { obj } {
		global errorInfo
		global errNumber
		set tag "body DeviceGroup::stop_prefix [info script]"
Deputs "----- TAG: $tag -----"
		ixNet exec stop [ixNet getP $obj]
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

	if { $type != "NULL" } {
		init
	}
    
	return [GetStandardReturnHeader]

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
			-type {
				set type [string toupper $value]
				init
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
# -- mac/src_mac
# --	-MAC addr
# -- src_mac_step
# --	-MAC addr
# -- mtu
# --	-INT
# -- enable_vlan
# --	-BOOL
body DeviceGroup::config_ethernet { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ethernet [info script]"
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
			-mac -
			-mtu {
			}
			-vlan_count {
				ixNet setA $ethernet -vlanCount $value
				ixNet commit
			}
			-enable_vlan {
				set key -enableVlans
			}
			-src_mac {
				set key -mac
			}
			-src_mac_step {
				set src_mac_step $value
			}
			default {
				continue
			}
		}
		set kvList($key) $value
    }
	
	foreach key [array names kvList] {
		switch -exact -- $key {
			-mac {
				if { [ info exists src_mac_step ] } {
					SetMultipleValue $ethernet $key $kvList($key) $src_mac_step
				} else {
					SetMultipleValue $ethernet $key $kvList($key)
				}
			}
			default {
				SetMultipleValue $ethernet $key $kvList($key)
			}
		}
	}
	return [GetStandardReturnHeader]
}

# ---------------------------------
# -- tpid
# --	-HEX
# -- priority
# --	-INT
# -- vlan_id
# --	-INT
body DeviceGroup::config_vlan { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_vlan [info script]"
Deputs "----- TAG: $tag -----"

	if { $handle == "" } {
		config -count $count
	}
	
#param collection
Deputs "Args:$args "

	config_ethernet -enable_vlan 1

	array set kvList [list]

    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-tpid {
				if { [ IsHex $value ] } {
					set value [string replace $value 0 1 ethertype]
					# set value [ format %i $value ]
				}
			}
			-priority {
			}
			-vlan_id -
			-vlan_id1 -
			-outer_vlan_id {
				set key -vlanId				
			}
			-vlan_id1_step -
			-outer_vlan_step {
				set vlan_step $value
			}
			-vlan_id2 -
			-inner_vlan_id {
				set key -vlanId2
			}
            -vlan_id2_step -
			-inner_vlan_step {
				set vlan_step2 $value
			}			
			default {
				continue
			}
		}
		set kvList($key) $value
    }
	
	foreach key [array names kvList] {
		switch -exact -- $key {
			-vlanId {
				if { [ info exists vlan_step ] } {
					SetMultipleValue $vlan $key $kvList($key) $vlan_step
				} else {
					SetMultipleValue $vlan $key $kvList($key)
				}
			}
			-vlanId2 {
				config_ethernet -vlan_count 2
				set vlan [lindex [ixNet getL $ethernet vlan] 1]
				if { [ info exists vlan_step2 ] } {
					SetMultipleValue $vlan -vlanId $kvList($key) $vlan_step2
				} else {
					SetMultipleValue $vlan -vlanId $kvList($key)
				}
				set vlan [lindex [ixNet getL $ethernet vlan] 0]
			}
			default {
				SetMultipleValue $ethernet $key $kvList($key)
			}
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
			-gateway -
			-ipv4_gw -
			-ipv6_gw {
				set key -gatewayIp
			}
			-ipv4_gw_step -
			-ipv6_gw_step {
				set gw_step $value
			}
			-family {
				set obj $value
				continue
			}
			-ipv4_addr -
			-ipv6_addr {
				set key -address
			}
			-ipv4_addr_step -
			-ipv6_addr_step {
				set addr_step $value
			}
			-ipv4_prefix_len -
			-ipv4_prefix_length -
			-ipv6_prefix_len -
			-ipv6_prefix_length {
				set key -prefix
			}
			default {
				continue
			}
		}
		set kvList($key) $value
    }
	
	if { [ info exists obj ] } {
		foreach key [array names kvList] {
			switch -exact -- $key {
				-address {
					if { [ info exists addr_step ] } {
						SetMultipleValue $obj $key $kvList($key) $addr_step
					} else {
						SetMultipleValue $obj $key $kvList($key)
					}
				}
				-gatewayIp {
					if { [ info exists gw_step ] } {
						SetMultipleValue $obj $key $kvList($key) $gw_step
					} else {
						SetMultipleValue $obj $key $kvList($key)
					}
				}
				default {
					SetMultipleValue $obj $key $kvList($key)
				}
			}
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
			-as_step {
				set as_step $value
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
			switch -- $key {
				-localAs2Bytes {
					SetMultipleValue $obj $key $kvList($key) $as_step
				}
				default {
					SetMultipleValue $obj $key $kvList($key)
				}
			}
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

# ---------------------------------
# -- start
# --	-IP
# -- step
# --	-IP
# -- prefix_len
# --	-INT
# -- prefix_step
# --	-INT
# -- num
# --	-INT
# -- family
# --	-ipv4/ipv6
# -- obj
body DeviceGroup::config_bgp_route { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_bgp [info script]"
Deputs "----- TAG: $tag -----"
	if { $handle == "" } {
		config -count $count
	}
	
	set num 1
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-start {
				set address_start $value
			}
			-step {
				set address_step $value
			}
			-prefix_len {
				set prefix_length_start $value
			}
			-prefix_step {
				set prefix_length_step $value
			}
			-num {
				set num $value
			}
			-obj {
				set obj $value
			}
			-family {
				set family $value
			}
		}
    }
		
	if { [ info exists obj ] == 0 } {
		set networkGroup [ixNet add $handle networkGroup]
		ixNet commit
		if { $family == "ipv6" } {
			set obj [ ixNet add $networkGroup ipv6PrefixPools ]
		} else {
			set obj [ ixNet add $networkGroup ipv4PrefixPools ]
		}
		ixNet commit
	}
	
	ixNet setA $networkGroup -multiplier $num

	set mvAddr [ ixNet getA $obj -networkAddress ]
	set mvPfx  [ ixNet getA $obj -prefixLength ]
	if { [ info exists address_start ] } {
		ixNet setA $mvAddr/counter -start $address_start
	}
	if { [ info exists address_step ] } {
		ixNet setA $mvAddr/counter -step $address_step
	}
	if { [ info exists prefix_length_start ] } {
		ixNet setA $mvPfx/counter -start $prefix_length_start
	}
	if { [ info exists prefix_length_step ] } {
		ixNet setA $mvPfx/counter -step $prefix_length_step
	}
	ixNet commit
	
	if { [ info exists family ] } {
		if { $family == "ipv4" } {
			catch {
				SetMultipleValue [ ixNet getL $obj bgpV6IPRouteProperty ] -active false				
			}
		}
		if { $family == "ipv6" } {
			catch {
				SetMultipleValue [ ixNet getL $obj bgpIPRouteProperty ] -active false
			}
		}
	}
	
	return $obj

}

# ---------------------------------
# -- route_block
# --	-RouteBlock obj
body DeviceGroup::set_route { args } {

    global errorInfo
    global errNumber
    set tag "body DeviceGroup::set_route [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
        }
    }
	
	if { [ info exists route_block ] } {
	
		set num 		[ $route_block cget -num ]
		set step 		[ $route_block cget -step ]
		set prefix_len 	[ $route_block cget -prefix_len ]
		set start 		[ $route_block cget -start ]
		set type 		[ $route_block cget -type ] 
		
		set handle [ \
			config_bgp_route \
				-num $num \
				-start $start \
				-family $type \
				-step [ IncrementIPAddr 0.0.0.0 $prefix_len $step ] \
				-prefix_len $prefix_len
		]
		
		$route_block configure -handle $handle
	}
	
    return [GetStandardReturnHeader]
	

}





