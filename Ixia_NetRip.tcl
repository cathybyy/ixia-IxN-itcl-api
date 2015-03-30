# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class RipSession {
	inherit RouterEmulationObject
	public variable hRouter
	constructor { port } {
		global errNumber
		
		set tag "body OspfvSession::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set portObj [ GetObject $port ]
		if { [ catch {
			set hPort   [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in rip ctor"
		}
		
		if {[ixNet getA $hPort/protocols/rip -enabled]} {
			
		} else {
			ixNet setM $hPort/protocols/rip -enabled True
		     ixNet commit
		}	   
		
		#-- add rip protocol
	     set handle [ ixNet add $hPort/protocols/rip router ]
	     ixNet setA $handle -Enabled True
	     ixNet commit
	     set handle [ ixNet remapIds $handle ]
	     ixNet setA $handle -name $this
	    
	     set rb_interface [ ixNet getL $hPort interface ]
	     array set interface [ list ]
	    
	     generate_interface
	}
	
	method config { args } {}
	method set_route { args } {}
	method unset_route { args } {}
	method advertise_route {} {}
	method withdraw_route {} {}
	method flapping_route { args } {}
	method enable {} {}
	method disable {} {}
	method get_session_status {} {}
	method get_session_stats {} {}
	
	method generate_interface { args } {
		set tag "body RipSession::generate_interface [info script]"
Deputs "----- TAG: $tag -----"
		foreach int $rb_interface {
			ixNet setM $handle -interfaceId $int -enabled True
			ixNet commit
		}
	}	

}

class RipRoute {
	inherit NetObject
	
	constructor { router } {
		global errNumber
	    
		set tag "body RipRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in RipRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	
	
	method config { args } {}
	
}

body RipSession::config { args } {
	global errorInfo
     global errNumber
	
	set version V2
	set update_interval 30
	set ipv4_addr 1.1.1.2
	set ipv4_prefix_len 24
	set ipv4_gw 1.1.1.1
	set ipv6_addr 3ffe:3210::2
	set ipv6_prefix_len 64
	set ipv6_gw 3ffe:3210::1
	
	set src_mac_step	"00:00:00:00:00:01"
	set ipv4_addr_step	0.0.0.1
	set ipv6_addr_step	::1
	set vlan_id1_step	1
	set vlan_id2_step	1

	set count 		1
	set ip_version		ipv4
	set enabled 		True
	
    set tag "body RipSession::config [info script]"
Deputs "----- TAG: $tag -----"
	
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
		   -router_id {
			   set router_id $value
		   }
		   -version {
			   set value [string toupper $value]
			   set version $value
		   }
		   -update_interval {
			   set update_interval $value
		   }
		   -update_jitter {
			   set update_jitter $value
		   }
		   -ipv4_addr {
			   set ipv4_addr $value
		   }
		   -ipv4_prefix_len {
			   set ipv4_prefix_len $value			   
		   }
		   -ipv4_gw {
			   set ipv4_gw $value			   
		   }
		   -ipv6_addr {
			   set ipv6_addr $value			   
		   }					   
		   -ipv6_prefix_len {
			   set ipv6_prefix_len $value			   
		   }
		   -ipv6_gw {
			   set ipv6_gw $value
		   }
		   -vlan_id1 {
			   set vlan_id1 $value
			   set flagOuterVlan   1
		   }
		   -vlan_id1_step {
			   set vlan_id1_step $value		
			   set flagOuterVlan   1
		   }
		   -vlan_id2 {
			   set vlan_id2 $value			   
			   set flagInnerVlan   1
		   }
		   -vlan_id2_step {
			   set vlan_id2_step $value
			   set flagInnerVlan   1
		   }
		   -outer_vlan_id {
			   if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
				   set outer_vlan_id $value
				   set flagOuterVlan   1									   
			   } else {
				   error "$errNumber(1) key:$key value:$value"									   
			   }			   
		   }
		   -outer_vlan_step {
			   if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
				   set outer_vlan_step $value
				   set flagOuterVlan   1									   
			   } else {
				   error "$errNumber(1) key:$key value:$value"									   
			   }							   
		   }
		   -outer_vlan_num {
			   if { [ string is integer $value ] && ( $value >= 0 ) } {
				   set outer_vlan_num $value
				   set flagOuterVlan   1									   
			   } else {
				   error "$errNumber(1) key:$key value:$value"					
			   }							   
		   }
		   -outer_vlan_priority {
			   if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
				   set outer_vlan_priority $value
				   set flagOuterVlan   1									   
			   } else {
				   error "$errNumber(1) key:$key value:$value"									   
			   }							   
		   }
		   -inner_vlan_id {
			   if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
				   set inner_vlan_id $value
				   set flagInnerVlan   1									   
			   } else {
				   error "$errNumber(1) key:$key value:$value"									   
			   }							   
		   }
		   -inner_vlan_step {
			   if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
				   set inner_vlan_step $value
				   set flagInnerVlan   1					
			   } else {
				   error "$errNumber(1) key:$key value:$value"					
			   }				
		   }
		   -inner_vlan_num {
			   if { [ string is integer $value ] && ( $value >= 0 ) } {
				   set inner_vlan_num $value
				   set flagInnerVlan   1					
			   } else {
				   error "$errNumber(1) key:$key value:$value"					
			   }				
		   }
		   -inner_vlan_priority {
			   if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
				   set inner_vlan_priority $value
				   set flagInnerVlan   1					
			   } else {
				   error "$errNumber(1) key:$key value:$value"					
			   }				
		   }
		   -outer_vlan_cfi {
			   set outer_vlan_cfi $value				
		   }
		   -inner_vlan_cfi {
			   set inner_vlan_cfi $value				
		   }		
        }
    }
	
	ixNet setM $handle -enabled True
	
	if { [ info exists router_id ] } {
		ixNet setA $handle -routerId $router_id
		ixNet commit
	}
	
	if { [ info exists version ] } {
		switch $version {
			V1 {
				set version receiveVersion1
			}
			V2 {
				set version receiveVersion2
			}
			NG {
				set version receiveVersion1And2				
			}
		}
		ixNet setA $handle -receiveType $version
		ixNet commit
	}
	
	if { [ info exists update_interval ] } {
		ixNet setA $handle -updateInterval $update_interval
		ixNet commit
	}
	
	if { [ info exists update_jitter ] } {
		ixNet setA $handle -updateIntervalOffset $update_jitter
		ixNet commit
	}
	
	if { [ info exists ipv4_addr ] } {
		foreach int $rb_interface {
			if { [ llength [ ixNet getList $int ipv4 ] ] == 0 } {
				set ipv4Int   [ ixNet add $int ipv4 ]								
			} else {
				set ipv4Int   [ lindex [ ixNet getList $int ipv4 ] 0 ]								
			}
			ixNet setA $ipv4Int -ip $ipv4_addr 
			ixNet setA $ipv4Int -maskWidth $ipv4_prefix_len
			ixNet setA $ipv4Int -gateway $ipv4_gw
		}
		ixNet commit		
	}	
	
	if { [ info exists ipv6_addr ] } {
		foreach int $rb_interface {
			if { [ llength [ ixNet getList $int ipv6 ] ] == 0 } {
				set ipv6Int   [ ixNet add $int ipv6 ]								
			} else {
				set ipv6Int   [ lindex [ ixNet getList $int ipv6 ] 0 ]								
			}
			ixNet setA $ipv6Int -ip $ipv6_addr 
			ixNet setA $ipv6Int -prefixLength $ipv6_prefix_len
			ixNet setA $ipv6Int -gateway $ipv6_gw
		}
		ixNet commit		
	}	

	set pfxIncr 	[ GetStepPrefixlen $ipv4_addr_step ]
#	if {[ info exists vlan_id1 ]} {
#		foreach int $rb_interface {
#			for { set index 0 } { $index < $count } { incr index } {
#				Deputs "int:$int"	
#				if { [ llength [ ixNet getL $int ipv4 ] ] == 0 } {
#					ixNet add $int ipv4
#					ixNet commit
#					
#				}
#					ixNet setM $int/ipv4 \
#				                    -ip $ipv4_addr \
#								-gateway $ipv4_gw \
#								-maskWidth $ipv4_prefix_len
#				ixNet commit
#				set ipv4_addr [ IncrementIPAddr $ipv4_addr $pfxIncr ]
#				if { [ string tolower $ip_version ] != "ipv4" } {
#					if { [ llength [ ixNet getL $int ipv6 ] ] == 0 } {
#						ixNet add $int ipv6
#						ixNet commit
#					}
#					Deputs "IPv6 Addr: $ipv6_addr "
#					Deputs "int/ipv6: [ ixNet getL $int ipv6 ]"
#					ixNet setM [ ixNet getL $int ipv6 ] \
#					                    -ip $ipv6_addr \
#									-gateway $ipv6_gw \
#									-prefixLength $ipv6_prefix_len
#					ixNet commit
#					set ipv6_addr [ IncrementIPv6Addr $ipv6_addr 64 ]
#					Deputs "ipv6 addr incr: $ipv6_addr"								
#				}
#				if { [ info exists src_mac ] } {
#				ixNet setM $int/ethernet \
#					-macAddress $src_mac 
#				ixNet commit
#				set src_mac [ IncrMacAddr $src_mac $src_mac_step ]
#					
#				}
#				if { [ info exists vlan_id1 ] } {
#					set vlanId $vlan_id1
#				ixNet setM $int/vlan \
#					-count 1 \
#				     -vlanEnable True \
#					-vlanId $vlanId
#				ixNet commit
#				incr vlan_id1 $vlan_id1_step
#					
#				}
#				if { [ info exists vlan_id2 ] } {
#					set vlanId $vlan_id2
#					set vlanId1	[ ixNet getA $int/vlan -vlanId ]
#					set vlanId	"${vlanId1},${vlanId}"
#					ixNet setM $int/vlan \
#					               -count 2 \
#							    	-vlanEnable True \
#								-vlanId $vlanId
#					ixNet commit
#					incr vlan_id2 $vlan_id2_step
#					
#				}
#				if { [ info exists enabled ] } {
#					ixNet setA $int -enabled $enabled
#					ixNet commit			
#					
#				}
#				
#			}
#			
#		}
#	}
	
	if {[ info exists outer_vlan_id ]} {
		foreach int $rb_interface {
			for { set index 0 } { $index < $count } { incr index } {
				Deputs "int:$int"	
				if { [ info exists outer_vlan_id ] } {
					set vlanId $outer_vlan_id
				ixNet setM $int/vlan \
					-count 1 \
					-vlanEnable True \
					-vlanId $vlanId \
					-vlanPriority   $outer_vlan_priority
				ixNet commit
				incr outer_vlan_id $outer_vlan_step
					
				}
				if { [ info exists inner_vlan_id ] } {
					set vlanId $inner_vlan_id
					set innerPri $inner_vlan_priority
					set vlanId1	[ ixNet getA $int/vlan -vlanId ]					
					set vlanId	"${vlanId1},${vlanId}"
					
					set outerPri [ ixNet getA $int/vlan -vlanPriority]
					set Pri "${outerPri},${innerPri}"
					ixNet setM $int/vlan \
								-count 2 \
								-vlanEnable True \
								-vlanId $vlanId \
								-vlanPriority $Pri
					ixNet commit
					incr inner_vlan_id $inner_vlan_step
					
				}
				if { [ info exists enabled ] } {
					ixNet setA $int -enabled $enabled
					ixNet commit			
					
				}
				
			}
			
		}
	}
	ixNet commit
	return [GetStandardReturnHeader]
}

body RipSession::advertise_route {} {

	set tag "body RipSession::advertise_topo [info script]"
Deputs "----- TAG: $tag -----"

	foreach route [ ixNet getL $handle routeRange ] {
	
		ixNet setA $route -enabled True
	}
	ixNet commit
    return [GetStandardReturnHeader]
}

body RipSession::withdraw_route {} {

	set tag "body RipSession::withdraw_topo [info script]"
Deputs "----- TAG: $tag -----"

	foreach route [ ixNet getL $handle routeRange ] {
	
		ixNet setA $route -enabled False
	}
	
	ixNet commit
    return [GetStandardReturnHeader]
}

body RipSession::flapping_route { args } {
	
	set tag "body RipSession::flapping_topo [info script]"
Deputs "----- TAG: $tag -----"
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-route_block {
				set route_block $value
			}
			-flap_times {
				set flap_times $value
			}
			-flap_interval {
				set flap_interval $value
			}
		}
	}
	
	set routeBlock [ GetObject $route_block ]
Deputs "routeBlock is: $routeBlock"
	set routeRange [ $routeBlock cget -handle ]
Deputs "routeRange is: $routeRange"
	for { set index 0 } { $index < $flap_times } { incr index } {
		ixNet setA $routeRange -enabled True
		ixNet commit
		after [ expr $flap_interval * 1000 ]
		ixNet setA $routeRange -enabled False
		ixNet commit
	}

    return [GetStandardReturnHeader]
}

body RipSession::get_session_status {} {
	set tag "body RipSession::get_session_status [info script]"
Deputs "----- TAG: $tag -----"
	
	set root [ixNet getRoot]
Deputs "root $root"
	
	set view {::ixNet::OBJ-/statistics/view:"RIP Aggregated Statistics"}
Deputs "view $view"	

	after 5000
	set captionList [ ixNet getA $view/page -columnCaptions ]
Deputs "captionList $captionList"	 
	set name_index [ lsearch -exact $captionList {Stat Name} ]
	set routers_index [ lsearch -exact $captionList {Routers Configured} ]
#	set request_index [ lsearch -exact $captionList {Request Packet Tx} ]
#	set regupdate_index [ lsearch -exact $captionList {Regular Update Packet Tx} ]
#	set trigupdate_index [ lsearch -exact $captionList {Triggered Update Packet Tx} ]
#	set rouadver_index [ lsearch -exact $captionList {Routes Advertised Tx} ]
#	set rouwithd_index [ lsearch -exact $captionList {Routes Withdraws Tx} ]
	
	set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
	
	set portFound 0
	foreach row $stats {
		eval {set row} $row
Deputs "row:$row"
		
Deputs "port index:$name_index"
		set rowPortName [ lindex $row $name_index ]
Deputs "row port name:$name_index"
		
		set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
		
		regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port:$port"
		
		set portName ${chassis}/Card${card}/Port${port}
Deputs "filter name: $portName"
		
		# 192.168.0.110/Card1/Port7
		# 192.168.0.110/Card01/Port07
		regexp -nocase {([0-9\.]+)/Card([0-9\.]+)/Port([0-9\.]+)} $rowPortName match rchassis rcard rport
Deputs "rchass:$rchassis rcard:$rcard rport:$rport"
		
		if {$chassis == $rchassis && $card == $rcard && $port == $rport} {
			set portFound 1
			break
		}
	}	
	
	set status "down"	
	
	if { $portFound } {
		set routers [ lindex $row $routers_index ]
#		set request [ lindex $row $routers_index ]
#		set regupdate [ lindex $row $regupdate_index ]
#		set trigupdate [ lindex $row $trigupdate_index ]
#		set rouadver [ lindex $row $rouadver_index ]
#		set rouwithd [ lindex $row $rouwithd_index ]

		if { $routers == "" } {
			set status "none"
		}
		if { $routers == 0 } {
			set status "closed"
		}
		if { $routers > 0 } {
			set status "open"
		}	
	}	
	
	set ret [ GetStandardReturnHeader ]
     set ret $ret[ GetStandardReturnBody "status" $status ]
	return $ret
}

body RipSession::get_session_stats {} {
	set tag "body RipSession::get_session_stats [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view {::ixNet::OBJ-/statistics/view:"RIP Aggregated Statistics"}

	after 5000
	set captionList [ ixNet getA $view/page -columnCaptions ]
Deputs "captionList $captionList"	 
	
	set name_index [ lsearch -exact $captionList {Stat Name} ]
#	set routers_index [ lsearch -exact $captionList {Routers Configured} ]
#	set request_index [ lsearch -exact $captionList {Request Packet Tx} ]
#	set regupdate_index [ lsearch -exact $captionList {Regular Update Packet Tx} ]
#	set trigupdate_index [ lsearch -exact $captionList {Triggered Update Packet Tx} ]
	set rouadver_index [ lsearch -exact $captionList {Routes Advertised Tx} ]
	set rouwithd_index [ lsearch -exact $captionList {Routes Withdraws Tx} ]
	
	set stats [ ixNet getA $view/page -rowValues ]
	Deputs "stats:$stats"
		
		set portFound 0
		foreach row $stats {
			eval {set row} $row
	Deputs "row:$row"
			
	Deputs "port index:$name_index"
			set rowPortName [ lindex $row $name_index ]
	Deputs "row port name:$name_index"
			
			set connectionInfo [ ixNet getA $hPort -connectionInfo ]
	Deputs "connectionInfo :$connectionInfo"
			
			regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
	Deputs "chas:$chassis card:$card port:$port"
			
			set portName ${chassis}/Card${card}/Port${port}
	Deputs "filter name: $portName"
			
			# 192.168.0.110/Card1/Port7
			# 192.168.0.110/Card01/Port07
			regexp -nocase {([0-9\.]+)/Card([0-9\.]+)/Port([0-9\.]+)} $rowPortName match rchassis rcard rport
	Deputs "rchass:$rchassis rcard:$rcard rport:$rport"
			
			if {$chassis == $rchassis && $card == $rcard && $port == $rport} {
				set portFound 1
				break
			}
		}	
	


    set ret "Status : true\nLog : \n"
    
    if { $portFound } {
        set statsItem   "rx_adv_update_count"
	   set statsVal N/A
Deputs "stats val:$statsVal"
	    set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_withdrawn_update_count"
	   set statsVal   N/A
Deputs "stats val:$statsVal"
			 set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "tx_adv_update_count"
		set statsVal    [ lindex $row $rouadver_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_withdrawn_update_count"
		set statsVal    [ lindex $row $rouwithd_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        
    }

Deputs "ret:$ret"
	
    return $ret
	
}

body RipSession::set_route {args} {
	
	set tag "body RipSession::set_route [info script]"
Deputs "----- TAG: $tag -----"

	set hRouter [ixNet add $handle routeRange]
Deputs "hRouter is: $hRouter"
	ixNet commit
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-route_block {
				set route_block $value
			}
			-metric {
				set metric $value
			}
			-next_hop {
				set next_hop $value
			}
			-route_tag {
				set route_tag $value
			}
		}
	}
	
	if {[info exists metric]} {
		ixNet setA $hRouter -metric $metric
	}
	
	if {[info exists next_hop]} {
		ixNet setA $hRouter -nextHop $next_hop
	}
	
	if {[info exists route_tag]} {
		ixNet setA $hRouter -routeTag $route_tag
	}
	
	if { [ info exists route_block ] } {
		
		set routeBlock [ GetObject $route_block ]
		$routeBlock configure -handle $hRouter
		
		if { $routeBlock == ""} {
			return [GetErrorReturnHeader "No valid object found...-route_block $routeBlock"]
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $hRouter \
		-noOfRoutes $num \
		-firstRoute $start \
		-step $step \
		-maskWidth $prefix_len 

	} else {
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	ixNet commit

	return [GetStandardReturnHeader]
}

body RipSession::unset_route {args} {
	
	set tag "body RipSession::unset_route [info script]"
Deputs "----- TAG: $tag -----"	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-route_block {
				set route_block $value
			}
		}
	}
	
	set routeBlock [ GetObject $route_block ]
     $routeBlock unconfig
}

body RipRoute::config { args } {
	global errorInfo
     global errNumber
	
	set tag "body RipRoute::config [info script]"
Deputs "----- TAG: $tag -----"
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-route_block {
				set route_block $value
			}
			-metric {
				set metric $value
			}
			-next_hop {
				set next_hop $value
			}
			-route_tag {
				set route_tag $value
			}
		}
	}
	
	if {[info exists metric]} {
		ixNet setA $handle -metric $metric
	}
	
	if {[info exists next_hop]} {
		ixNet setA $handle -nextHop $next_hop
	}
	
	if {[info exists route_tag]} {
		ixNet setA $handle -routeTag $route_tag
	}
	
	if { [ info exists route_block ] } {
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == ""} {
			return [GetErrorReturnHeader "No valid object found...-route_block $routeBlock"]
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 	[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
		-noOfRoutes $num \
		-firstRoute $start \
	     -step $step \
	     -maskWidth $prefix_len 

	} else {
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	ixNet commit
	
	return [GetStandardReturnHeader]
	
}