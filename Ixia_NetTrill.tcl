
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.5
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.2
#		2. Add customized TLV class without implementation
# Version 1.3.4.0
#		3. Add fat-tree topology
#		4. Add custom TLV implementation
# Version 1.4.4.1
#		5. Fix get_stats handle -> hPort
# Version 1.5.4.3
#		6. change root_bridge_id to mac format
#		7. change nickname to single list format
# Version 1.5.4.5
#		8. update -appt_info in TrillApptFwrdrsSubTlv
#         9. update config in TrillApptFwrdrsSubTlv and TrillNicknameSubTlv
#         10. update -max_ver type from int to hex
#         11. update -start_vlan_id and len


class TrillSession {
    inherit IsisSession
	
    public variable dceTopologyRange
    public variable interestedVlan
		
    constructor { port } { chain $port } {}
    method reborn {} {}
    method config { args } {}
    method get_stats {} {}
    method get_neighbor_stats {} {}

}
body TrillSession::reborn {} {
	
    set tag "body TrillSession::reborn [info script]"
Deputs "----- TAG: $tag -----"

    ixNet setA $hPort/protocols/isis -emulationType trillIsis
    ixNet commit
	    
	chain
	
    #-- port/protocols/isis/router/dceTopologyRange
    set dceTopologyRange [ ixNet add $handle dceTopologyRange ]
    ixNet setA $dceTopologyRange -enabled True
    ixNet commit
    set dceTopologyRange [ ixNet remapIds $dceTopologyRange ]

}
body TrillSession::config { args } {
	
    set tag "body TrillSession::config [info script]"
    Deputs "----- TAG: $tag -----"

    global errorInfo
    global errNumber
    
	
	
Deputs "Args:$args "
    set index 0
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-nickname {
				set nickname [ list ]
				if { [ llength $value ] == 3 } {
					set nickname $value
				} else {
					while { [ llength $value ] >= 3 } {
						lappend nickname [ lrange $value 0 2 ]
						set value [ lrange $value 3 end ]
					}
				}
				set args [ lreplace $args [ expr 2*$index ] [ expr 2*$index +1 ] ]
				incr index -1
			}
			-interested_vlan {
				set interested_vlan $value
				set args [ lreplace $args [ expr 2*$index ] [ expr 2*$index +1 ] ]
				incr index -1
			}
			-announcing_vlan {
				set announcing_vlan $value
				set args [ lreplace $args [ expr 2*$index ] [ expr 2*$index +1 ] ]
				incr index -1
			}
			-tlv_list {
				set tlv_list $value
				set args [ lreplace $args [ expr 2*$index ] [ expr 2*$index +1 ] ]
				incr index -1				
			}
		}
		incr index
    }
	
    #param collection
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-cap_router_id -
			-cap_rt_id {
				set cap_rt_id $value
			}
			-enable_hostname {
				set enable_hostname $value  	    	
			}
			-hostname {
				set hostname $value
			}
			-priority {
				set priority $value
			}
			-tree_to_compute {
				set tree_to_compute $value
			}
			-designated_vlan {
				set designated_vlan $value
			}
			-auto_mtu {
				set auto_mtu $value
			}
			-link_mtu {
				set link_mtu $value
			}
		}
    }	

    if { [ info exists nickname ] } {
Deputs "dceTopologyRange: $dceTopologyRange"
Deputs "nickname: $nickname length:[ llength $nickname ]"
	    ixNet setA $dceTopologyRange -nicknameList $nickname 
    }
Deputs Step100	
    if { [ info exists cap_rt_id ] } {
	    ixNet setA $handle -capabilityRouterId $cap_rt_id
    }
Deputs Step120	
    if { [ info exists enable_hostname ] } {
	    ixNet setA $handle -enableHostName $enable_hostname
    }
	
Deputs Step130
    if { [ info exists hostname ] } {
	    ixNet setA $handle -hostName $hostname
    }
	
Deputs Step140
    if { [ info exists interested_vlan ] } {
	    foreach cvlan [ ixNet getL $dceTopologyRange dceInterestedVlanRange ] {
		    ixNet remove ${cvlan}
	    }
	    ixNet commit
	    set interestedVlan [ list ]
	    foreach cvlan $interested_vlan {
		    if { [ $cvlan isa InterestedVlan ] == 0 } {
			    error "$errNumber(1) key:interested_vlan value:$cvlan"
		    }
		    set nickname [ $cvlan cget -nickname ]
		    set vlan_id [ $cvlan cget -vlan_id ]
		    set vlan_num [ $cvlan cget -vlan_num ]
		    set vlan_step [ $cvlan cget -vlan_step ]
		    set enable_m4 [ $cvlan cget -enable_m4 ]
		    set enable_m6 [ $cvlan cget -enable_m6 ]
		    set num_spt_root [ $cvlan cget -num_spt_root ]
		    set root_bridge_id [ $cvlan cget -root_bridge_id ]
		    
		    set iVlan [ ixNet add $dceTopologyRange dceInterestedVlanRange ]
		    ixNet commit
		    ixNet setM $iVlan \
			    -enabled True \
			    -enableM4Bit $enable_m4 \
			    -enableM6Bit $enable_m6 \
			    -nickname $nickname \
			    -noOfSpanningTreeRoots $num_spt_root \
			    -startSpanningTreeRootBridgeId $root_bridge_id \
			    -startVlanId $vlan_id \
			    -vlanCount $vlan_num \
			    -vlanIdStep $vlan_step
		    ixNet commit
	    }
    }
	
Deputs Step150
	if { [ info exists tree_to_compute ] } {
		ixNet setA $dceTopologyRange -noOfTreesToCompute $tree_to_compute
	}
	
Deputs Step160
	if { [ info exists announcing_vlan ] } {
		if { [ llength $announcing_vlan ] > 0 } {
			foreach int [ ixNet getL $hPort interface ] {
				ixNet remove $int
			}
			foreach int [ ixNet getL $handle interface ] {
				ixNet remove $int
			}
			ixNet commit
			
			foreach vlan $announcing_vlan {
				set pInt [ixNet add $hPort interface]
				ixNet commit
				set pInt [ixNet remapIds $pInt]
				ixNet setA $pInt -enabled True
				if { [ info exists mac_addr ] && $mac_addr != "" && $mac_addr != "<undefined>" } {
					ixNet setA $pInt/ethernet -macAddress $mac_addr
				}
				ixNet setM $pInt/vlan \
					-vlanId $vlan \
					-vlanEnable True
Deputs "pInt:$pInt"				
				set rInt [ ixNet add $handle interface ]
				ixNet commit
				set rInt [ ixNet remapIds $rInt ]
Deputs "rInt:$rInt"				
				ixNet setM $rInt \
					-interfaceId $pInt \
					-enableConnectedToDut True \
					-enabled False
				ixNet commit	
			}
		}
	}
	
Deputs Step170
	if { [ info exists designated_vlan ] } {
		set desInt ""
		foreach int [ ixNet getL $handle interface ] {
			set pInt [ ixNet getA $int -interfaceId ]
			if { [ ixNet getA $pInt/vlan -vlanId ] == $designated_vlan } {
				set desInt $int
				break
			}
		}
Deputs "desInt:$desInt"
		if { $desInt != "" } {
			ixNet setA $desInt -enabled True
		} else {
			set pInt [ixNet add $hPort interface]
Deputs "pInt:$pInt"
			ixNet commit
			set pInt [ixNet remapIds $pInt]
			ixNet setA $pInt -enabled True
			if { [ info exists mac_addr ] && $mac_addr != "" && $mac_addr != "<undefined>" } {
				ixNet setA $pInt/ethernet -macAddress $mac_addr
			}
			ixNet setM $pInt/vlan \
				-vlanId $designated_vlan \
				-vlanEnable True
			
			set rInt [ ixNet add $handle interface ]
			ixNet commit
			set rInt [ ixNet remapIds $rInt ]
			ixNet setM $rInt \
				-interfaceId $pInt \
				-enableConnectedToDut True \
				-enabled True
			ixNet commit
			
			set desInt $rInt
		}
		set rb_interface $desInt
		set interface [ ixNet getA $rb_interface -interfaceId ]
	}
Deputs Step175	
    if { [ info exists priority ] } {
Deputs Step178
	    ixNet setA $rb_interface -priorityLevel1 $priority
    }
Deputs Step180
	if { [ info exists auto_mtu ] } {
Deputs "rb_interface:$rb_interface"	
		ixNet setA $rb_interface -enableAutoAdjustMtu $auto_mtu
	}
Deputs Step190
	if { [ info exists link_mtu ] } {
		ixNet setA $interface -mtu $link_mtu
	}
	
Deputs Step200	
	if { [ info exists tlv_list ] } {
	
		if { [ catch {
			foreach tlv [ ixNet getL $handle customTlv ] {
				ixNet remove $tlv
			}
			ixNet commit
		} err ] } {
Deputs $err		
		}
	
		foreach tlv $tlv_list {
		    if { [ $tlv isa Tlv ] == 0 } {
			    error "$errNumber(1) key:tlv_list value:$tlv"
		    }

			set type [ $tlv cget -type ]
			set len	 [ $tlv cget -len ]
			set val	 [ $tlv cget -val ]
			set inHello	[ $tlv cget -inHello ]
			set inLsp 	[ $tlv cget -inLsp ]
Deputs "type:$type len:$len val:$val inHello:$inHello inLsp:$inLsp"

			set hTlv [ ixNet add $handle customTlv ]
			ixNet commit
			set hTlv [ ixNet remapIds $hTlv ]
			
			ixNet setM $hTlv \
				-enabled True \
				-type $type \
				-length $len \
				-value $val \
				-includeInLsp $inLsp \
				-includeInHello $inHello
			ixNet commit
			
		}
	}
Deputs Step210	
    ixNet commit
    eval chain $args
	
    return [GetStandardReturnHeader]    
    
}
body TrillSession::get_stats {} {
	global errorInfo
	global errNumber
	set tag "body TrillSession::get_stats [info script]"
    Deputs "----- TAG: $tag -----"
	    set root [ixNet getRoot]
	    set view {::ixNet::OBJ-/statistics/view:"ISIS Aggregated Statistics"}
    Deputs "view:$view"
	set captionList             [ ixNet getA $view/page -columnCaptions ]
    Deputs "caption list:$captionList"

	   
	    set port_name		[ lsearch -exact $captionList {Stat Name} ]
	set neighbors          	[ lsearch -exact $captionList {L1 Neighbors} ]
	set session_up          [ lsearch -exact $captionList {L1 Sess. Up} ]
	set init         	[ lsearch -exact $captionList {L1 Init State Count} ]
	set full         	[ lsearch -exact $captionList {L1 Full State Count} ]
	set flap         	[ lsearch -exact $captionList {L1 Session Flap Count} ]
	set db_size       	[ lsearch -exact $captionList {L1 DB Size} ]
	set rx_hello        	[ lsearch -exact $captionList {L1 Hellos Rx} ]
	set rx_ptp_hello	[ lsearch -exact $captionList {L1 PTP Hellos Rx} ]
	set rx_lsp		[ lsearch -exact $captionList {L1 LSP Rx} ]
	set rx_csnp          	[ lsearch -exact $captionList {L1 CSNP Rx} ]
	set rx_psnp          	[ lsearch -exact $captionList {L1 PSNP Rx} ]
	set tx_hello         	[ lsearch -exact $captionList {L1 Hellos Tx} ]
	set tx_ptp_hello        [ lsearch -exact $captionList {L1 PTP Hellos Tx} ]
	set tx_lsp         	[ lsearch -exact $captionList {L1 LSP Tx} ]
	set tx_csnp       	[ lsearch -exact $captionList {L1 CSNP Tx} ]
	set tx_psnp        	[ lsearch -exact $captionList {L1 PSNP Tx} ]
	set rb_learned		[ lsearch -exact $captionList {RBridges Learned} ]

	set ret [ GetStandardReturnHeader ]
	    
	set stats [ ixNet getA $view/page -rowValues ]
    Deputs "stats:$stats"
    
	set connectionInfo [ ixNet getA $hPort -connectionInfo ]
    Deputs "connectionInfo :$connectionInfo"
	regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
    Deputs "chas:$chassis card:$card port$port"
	foreach row $stats {
	
		eval {set row} $row
Deputs "row:$row"
Deputs "portname:[ lindex $row $port_name ]"

    Deputs "row:$row"
    Deputs "portname:[ lindex $row $port_name ]"
	   if { [ string length $card ] == 1 } {
		   set card "0$card"
	   }
	   if { [ string length $port ] == 1 } {
		   set port "0$port"
	   }
	   if { "${chassis}/Card${card}/Port${port}" != [ lindex $row $port_name ] } {
		   continue
	   }
    
	   set statsItem   "neighbors"
	   set statsVal    [ lindex $row $neighbors ]
    Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				  
	   set statsItem   "session_up"
	   set statsVal    [ lindex $row $session_up ]
    Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				
	   set statsItem   "init"
	   set statsVal    [ lindex $row $init ]
    Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				
	   set statsItem   "full"
	   set statsVal    [ lindex $row $full ]
    Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "flap"
	   set statsVal    [ lindex $row $flap ]
    Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		 
	   set statsItem   "db_size"
	   set statsVal    [ lindex $row $db_size ]
    Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	
		set statsItem   "rx_hello"
		set statsVal    [ lindex $row $rx_hello ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				  
		set statsItem   "rx_ptp_hello"
		set statsVal    [ lindex $row $rx_ptp_hello ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		  
		set statsItem   "rx_lsp"
		set statsVal    [ lindex $row $rx_lsp ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
		set statsItem   "rx_csnp"
		set statsVal    [ lindex $row $rx_csnp ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

		set statsItem   "rx_psnp"
		set statsVal    [ lindex $row $rx_psnp ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

		set statsItem   "tx_hello"
		set statsVal    [ lindex $row $tx_hello ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				  
		set statsItem   "tx_ptp_hello"
		set statsVal    [ lindex $row $tx_ptp_hello ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		  
		set statsItem   "tx_lsp"
		set statsVal    [ lindex $row $tx_lsp ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
		set statsItem   "tx_csnp"
		set statsVal    [ lindex $row $tx_csnp ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

		set statsItem   "tx_psnp"
		set statsVal    [ lindex $row $tx_psnp ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

		set statsItem   "rb_learned"
		set statsVal    [ lindex $row $rb_learned ]
		Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

Deputs "ret:$ret"
    }
	   
	    return $ret
	    
}
body TrillSession::get_neighbor_stats {} {
	global errorInfo
	global errNumber
	set tag "body TrillSession::get_neighbor_stats [info script]"
    Deputs "----- TAG: $tag -----"
	
	ixNet exec refreshLearnedInformation $handle
	
	set learned_info $handle/learnedInformation/rBridges
	
#	system_id
#	sequence_num
#	nickname
#	hostname
#	mt_id
#	common_mt_id
#	ext_circuit_id
#	role
#	priority
#	age
#	metric
	
	set system_id [ ixNet getA $learned_info -systemId ]
	set sequence_num [ ixNet getA $learned_info -sequenceNumber ]
	set nickname [ ixNet getA $learned_info -switchId ]
	set hostname [ ixNet getA $learned_info -hostName ]
	set mt_id [ ixNet getA $learned_info -mtId ]
	set common_mt_id [ ixNet getA $learned_info -enableCommonMtId ]
	set ext_circuit_id [ ixNet getA $learned_info -extendedCircuitId ]
	set role [ ixNet getA $learned_info -role ]
	set priority [ ixNet getA $learned_info -priority ]
	set age [ ixNet getA $learned_info -age ]
	set metric [ ixNet getA $learned_info -linkMetric ]
	
	set statsItem   "system_id"
	set statsVal    $system_id
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			   
	set statsItem   "sequence_num"
	set statsVal    $sequence_num
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
					
	   set statsItem   "nickname"
	   set statsVal    $nickname
	   Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			   
	   set statsItem   "hostname"
	   set statsVal    $hostname
	   Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "mt_id"
	set statsVal    $mt_id
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
	set statsItem   "common_mt_id"
	set statsVal    $common_mt_id
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				  
	set statsItem   "ext_circuit_id"
	set statsVal    $ext_circuit_id
	Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
	set statsItem   "role"
	set statsVal    $role
	Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "priority"
	set statsVal    $priority
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
				  
	set statsItem   "age"
	set statsVal    $age
	Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
	set statsItem   "metric"
	set statsVal    $metric
	Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

Deputs "ret:$ret"
	return $ret
}

class InterestedVlan {
	inherit NetObject
	public variable nickname
	public variable vlan_id
	public variable vlan_num
	public variable vlan_step
	public variable enable_m4
	public variable enable_m6
	public variable num_spt_root
	public variable root_bridge_id
	constructor {} {
		set nickname 1
		set vlan_id 1
		set vlan_num 1
		set vlan_step 1
		set enable_m4 1
		set enable_m6 1
		set num_spt_root 0
		set root_bridge_id 00AA00000001
	}
	method config { args } {}
}
body InterestedVlan::config { args } {
	global errorInfo
	global errNumber
	set tag "body InterestedVlan::config [info script]"
    Deputs "----- TAG: $tag -----"
	foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
		-nickname {
		    set nickname $value
		}
		-vlan_id {
		    if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
			set vlan_id $value
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
		}
		-vlan_step {
		    if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
			set vlan_step $value
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
		}
		-vlan_num {
		    if { [ string is integer $value ] && ( $value >= 0 ) } {
			set vlan_num $value
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
		}
		-enable_m4 {
			set trans [ BoolTrans $value ]
			if { $trans == "1" || $trans == "0" } {
			    set enable_m4 $trans
			} else {
			    error "$errNumber(1) key:$key value:$value"
			}
			
		}
		-enable_m6 {
			set trans [ BoolTrans $value ]
			if { $trans == "1" || $trans == "0" } {
			    set enable_m6 $trans
			} else {
			    error "$errNumber(1) key:$key value:$value"
			}
		}
		-num_spt_root {
			set num_spt_root $value
		}
		-root_bridge_id {
			if { [ IsMacAddress $value ] } {
				set root_bridge_id $value
			} else {
				set root_bridge_id \
				[ string range $value 0 1 ]:[ string range $value 2 3 ]:[ string range $value 4 5 ]:[ string range $value 6 7 ]:[ string range $value 8 9 ]:[ string range $value 10 11 ]
			}
Deputs "bridge_id:$root_bridge_id"			
		}
	    }
	}
    return [GetStandardReturnHeader]    
    
}

class TrillTopology {
	inherit Topology
	
	public variable topoRb	
	public variable hostRb
	
	public variable system_id
	public variable system_id_step
	
	constructor {} { chain } {
		array set topoRb [ list ]
	}
	method config { args } {}
	method advertise {} {}
	method withdraw {} {}
	method flap { args } {}
	method flapping { args } {
		eval flap $args
	}
	method set_rb { args } {}
	method advertise_rb { args } {}
	method withdraw_rb { args } {}
	method flap_rb { args } {}
}
body TrillTopology::config { args } {
	
	global errorInfo
	global errNumber
	set tag "body TrillTopology::config [info script]"
    Deputs "----- TAG: $tag -----"
	
	# rb number of every layer
	array set layer_rb_array [list]
	
	set system_id 		"00:00:01:00:00:01"
	set system_id_step 	"00:00:00:00:00:01"
	set maxLayer		1
	set nickname		1
	set nickname_step 	1
	set broadcast_priority 0
	
	foreach { key value } $args {
	    set key [string tolower $key]
	    if { [ regexp -- {-layer([2-9])_rb_num} $key match index ] } {
			set layer_rb_array($index) $value
			if { $index > $maxLayer } {
				set maxLayer $index
			}
	    }
	}
	
	foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
			-connected_to {
					set connected_to $value
			}
			-interested_vlan {
				set interested_vlan $value
			}
			-system_id {
				set system_id $value
			}
			-system_id_step {
					set system_id_step $value
			}
			-enable_hostname {
				set enable_hostname $value
			}
			-hostname {
				set hostname $value
			}
			-cap_router_id {
				set cap_router_id $value
			}
			-nickname {
				set nickname $value
Deputs "nickname:$nickname"				
			}
			-nickname_count {
				set nickname_count $value
			}
			-nickname_step {
				set nickname_step $value
			}
			-broadcast_priority {
				set broadcast_priority $value
			}
	    }
	}

	eval chain $args
	
	#	connected_to
	#	interested_vlan
	#	system_id
	#	system_id_step
	#	enable_hostname
	#	hostname
	#	cap_router_id
	#	nickname
	#	nickname_count
	#	nickname_step
	#	broadcast_priority
	#
	array set topoRb [list]

	if { [ info exists connected_to ] } {
		
		foreach rb $connected_to {
			if { [ $rb isa TrillSession ] == 0 } {
				error "$errNumber(1) $rb is not a TrillSession"
			}
						
			set hRb [ $rb cget -handle ]
			lappend topoRb(emulate) $hRb
			lappend topoRb(simulate,1) $hRb
			set topoRb($hRb,sysid) [ ixNet getA $hRb -systemId ]
			
			# if rb hasn't customTopology attached, set as hostRb
			if { [ info exists hostRb ] == 0 } {
				if { [ llength [ ixNet getL $hRb customTopology ] ] == 0 } {
					set hostRb $hRb
				}
			}
		}
		if { [ info exists hostRb ] == 0 } {
			# if all rb has customTopology attached, the first rb is set as hostRb and topology will be overwriten
			set hostRb [ [ lindex $connected_to 0 ] cget -handle ]
		}
	} else {
		error "$errNumber(2) connected_to"
		
	}
Deputs "topo rb:[ array names topoRb ]"	
Deputs "host rb:$hostRb"	
	# -- create topo
	if { [ llength [ ixNet getL $hostRb customTopology ] ] } {
		set topo [ lindex [ ixNet getL $hostRb customTopology ] 0 ]
	} else {
		set topo [ ixNet add $hostRb customTopology ]
		ixNet commit
		set topo [ ixNet remapIds $topo ]
	}
Deputs "topo:$topo"			
	set topoRb(topo) $topo
	set handle $topo
Deputs "handle:$handle"			
	# -- config topo
	if { [ info exists system_id ] } {
		ixNet setA $handle -startSysId $system_id
	}
	
	if { [ info exists system_id_step ] } {
		ixNet setA $handle -sysIdInc $system_id_step
	}
	
	if { [ info exists enable_hostname ] } {
Deputs "enable_hostname:$enable_hostname"			
		ixNet setA $handle -enableHostname $enable_hostname
	}
	
	if { [ info exists hostname ] } {
		ixNet setA $handle -hostNamePrefix $hostname
	}
	
	if { [ info exists cap_router_id ] } {
Deputs "cap_router_id:$cap_router_id"			
		ixNet setA $handle -capRouterId $cap_router_id
	}
	
	if { [ info exists interested_vlan ] } {
		
		if { [ llength [ ixNet getL $handle customTopologyNodeTopologyRange ] ] == 0 } {
			set topoRange [ ixNet add $handle customTopologyNodeTopologyRange ]
			ixNet commit
			set topoRange [ ixNet remapIds $topoRange ]
		}
		
		foreach cvlan [ ixNet getL $topoRange customTopologyInterestedVLANRange ] {
			ixNet remove $cvlan
		}
		ixNet commit
		
		foreach cvlan $interested_vlan {
			
			if { [ $cvlan isa InterestedVlan ] == 0 } {
				error "$errNumber(1) key:interested_vlan value:$cvlan"
			}
			set vlan_id [ $cvlan cget -vlan_id ]
			set vlan_num [ $cvlan cget -vlan_num ]
			set vlan_step [ $cvlan cget -vlan_step ]
			set enable_m4 [ $cvlan cget -enable_m4 ]
			set enable_m6 [ $cvlan cget -enable_m6 ]
			set num_spt_root [ $cvlan cget -num_spt_root ]
			set root_bridge_id [ $cvlan cget -root_bridge_id ]
						
			set nodeIntVlan [ ixNet add $topoRange customTopologyInterestedVLANRange ]
			ixNet setM $nodeIntVlan \
				-includeInterestedVlan True \
				-startVLANId $vlan_id \
				-VLANCount $vlan_num \
				-VLANIdStep $vlan_step \
				-m4BitEnabled $enable_m4 \
				-m6BitEnabled $enable_m6 \
				-numberOfSpanningTreeRoots $num_spt_root \
				-startspanningTreeRootBridgeId $root_bridge_id
			ixNet commit
		}
	}
	ixNet commit

	set sys_id [ ixNet getA $handle -startSysId ]
	set sys_id_incr [ ixNet getA $handle -sysIdInc ]
	switch $type {
		grid {
			for { set colIndex 0 } { $colIndex < $column_num } { incr colIndex } {
				for { set rowIndex 0 } { $rowIndex < $row_num } { incr rowIndex } {
			
					#-- create simulated rb
					set s_rb [ ixNet add $handle customTopologyNode ]
					ixNet commit
					set s_rb [ ixNet remapIds $s_rb ]
Deputs "simulated rb:$s_rb"					
					lappend topoRb(simulate) $s_rb
					set topoRb(simulate,$rowIndex,$colIndex) $s_rb
					# -- assign system id
Deputs "sys id:$sys_id"					
					set topoRb($rowIndex,$colIndex,sysid) $sys_id
					set sys_id [ IncrMacAddr $sys_id $sys_id_incr ]
					# -- set nickname
Deputs "nickname:$nickname"					
					ixNet setA $s_rb \
						-Nickname $nickname \
						-Priority $broadcast_priority \
						-enabled True
					set nickname [ expr $nickname + $nickname_step ]
					# -- set edge
Deputs "column index: $colIndex == [ expr $column_num - 1 ]"
					if { $colIndex == [ expr $column_num - 1 ] } {
						ixNet setA $s_rb -EdgeBridge True
					}
					ixNet commit
					# -- bidirectional links
					if { $rowIndex >= 1 } {
						# -- add row links
						set linkTo [ ixNet add $s_rb customTopologyLink ]
						ixNet commit
						#-- link to previous layer
						set linkTo [ ixNet remapIds $linkTo ]
						set pRowIndex [ expr $rowIndex - 1 ] 
						ixNet setM $linkTo \
							-enabled True \
							-linkNodeSystemId $topoRb($pRowIndex,$colIndex,sysid)
						#-- link to later layer
						set linkFrom [ ixNet add $topoRb(simulate,$pRowIndex,$colIndex) customTopologyLink ]
						ixNet commit
						set linkFrom [ ixNet remapIds $linkFrom ]
						ixNet setM $linkFrom \
							-enabled True \
							-linkNodeSystemId $topoRb($rowIndex,$colIndex,sysid)
						ixNet commit
					}
					if { $colIndex >= 1 } {
						# -- add row links
						set linkTo [ ixNet add $s_rb customTopologyLink ]
						ixNet commit
						#-- link to previous layer
						set linkTo [ ixNet remapIds $linkTo ]
						set pColIndex [ expr $colIndex - 1 ] 
						ixNet setM $linkTo \
							-enabled True \
							-linkNodeSystemId $topoRb($rowIndex,$pColIndex,sysid)
						#-- link to later layer
						set linkFrom [ ixNet add $topoRb(simulate,$rowIndex,$pColIndex) customTopologyLink ]
						ixNet commit
						set linkFrom [ ixNet remapIds $linkFrom ]
						ixNet setM $linkFrom \
							-enabled True \
							-linkNodeSystemId $topoRb($rowIndex,$colIndex,sysid)
						ixNet commit
					}					
				}
			}
			# -- connected to emulated rb
			if { $attach_row > $row_num || $attach_row < 1 } {
				error "$errNumber(1) key:attach_row value:$attach_row"
			} else {
				incr attach_row -1
			}
			if { $attach_column > $column_num || $attach_column < 1 } {
				error "$errNumber(1) key:attach_column value:$attach_column"
			} else {
				incr attach_column -1
			}
			foreach e_rb $topoRb(emulate) {
				if { [ llength [ ixNet getL $e_rb customTopology ] ] } {
					set rbTopo [ lindex [ ixNet getL $e_rb customTopology ] 0 ]
				} else {
					set rbTopo [ ixNet add $e_rb customTopology ]
					ixNet commit
					set rbTopo [ ixNet remapIds $rbTopo ]

				}
Deputs "rb topo: $rbTopo"	
				#-- link from emulated rb to attached rb
				set linkTo [ ixNet add $rbTopo customTopologyRBLinks ]
				ixNet commit
				set linkTo [ ixNet remapIds $linkTo ]
				ixNet setM $linkTo \
					-enabled True \
					-linkNodeSystemId $topoRb($attach_row,$attach_column,sysid)
				ixNet commit

				#-- link from attached rb to emulated rb
				set linkFrom [ ixNet add $topoRb(simulate,$attach_row,$attach_column) customTopologyLink ]
				ixNet commit
				set linkFrom [ ixNet remapIds $linkFrom ]
				ixNet setM $linkFrom \
					-enabled True \
					-linkNodeSystemId $topoRb($e_rb,sysid)
				ixNet commit
			}
		}
		fat-tree -
		fat_tree {
			# -- support 9 layer at most
			# -- round robin all layer
			for { set layer 2 } { $layer <= $maxLayer } { incr layer } {
				# -- if rb num of layer isn't set, set as 1
				if { [ info exists layer_rb_array($layer) ] } {
					set layer_rb $layer_rb_array($layer)
				} else {
Deputs "layer:$layer not found..."		
					# if layer index not found in args, set rb num 1
					set layer_rb 1
				}
Deputs "simulated rb on layer $layer : $layer_rb"				
				#-- add all s_rb to host rb
				for { set index 0 } { $index < $layer_rb } { incr index } {
					#-- create simulated rb
					set s_rb [ ixNet add $handle customTopologyNode ]
					ixNet commit
					set s_rb [ ixNet remapIds $s_rb ]
Deputs "simulated rb:$s_rb"					
					lappend topoRb(simulate) $s_rb
					lappend topoRb(simulate,$layer) $s_rb
					# -- assign system id
Deputs "sys id:$sys_id"					
					set topoRb($s_rb,sysid) $sys_id
					set sys_id [ IncrMacAddr $sys_id $sys_id_incr ]
					# -- set nickname
Deputs "nickname:$nickname"					
					ixNet setA $s_rb \
						-Nickname $nickname \
						-Priority $broadcast_priority \
						-enabled True
					set nickname [ expr $nickname + $nickname_step ]
					# -- set edge
					if { $layer == $maxLayer } {
Deputs "layer:$layer == $maxLayer"						
						ixNet setA $s_rb -EdgeBridge True
					}						
					ixNet commit
					# -- bidirectional links
					set previousLayer [ expr $layer - 1 ]
					foreach p_rb $topoRb(simulate,$previousLayer) {
Deputs "previous rb:$p_rb"					
						# -- add links
						set linkTo [ ixNet add $s_rb customTopologyLink ]
						ixNet commit
						#-- link to previous layer
						set linkTo [ ixNet remapIds $linkTo ]
Deputs "link to $topoRb($p_rb,sysid)"
						ixNet setM $linkTo \
							-enabled True \
							-linkNodeSystemId $topoRb($p_rb,sysid)
						# not emulated rb
						if { $previousLayer > 1 } {
							#-- link to later layer
							set linkFrom [ ixNet add $p_rb customTopologyLink ]
Deputs "link from $topoRb($s_rb,sysid)"
							ixNet commit
							set linkFrom [ ixNet remapIds $linkFrom ]
							ixNet setM $linkFrom \
								-enabled True \
								-linkNodeSystemId $topoRb($s_rb,sysid)
							ixNet commit
						} else {
							#-- add link on emulated rb
							if { [ llength [ ixNet getL $p_rb customTopology ] ] } {
								set rbTopo [ lindex [ ixNet getL $p_rb customTopology ] 0 ]
							} else {
								set rbTopo [ ixNet add $p_rb customTopology ]
								ixNet commit
								set rbTopo [ ixNet remapIds $rbTopo ]

							}
Deputs "rb topo: $rbTopo"							
							set linkFrom [ ixNet add $rbTopo customTopologyRBLinks ]
							ixNet commit
							set linkFrom [ ixNet remapIds $linkFrom ]
							ixNet setM $linkFrom \
								-enabled True \
								-linkNodeSystemId $topoRb($s_rb,sysid)
							ixNet commit
						}
					}
				}
			}
			
			
		}
	}
	
	ixNet commit
	return [GetStandardReturnHeader]    
		
	
}
body TrillTopology::advertise {} {
	global errorInfo
	global errNumber
	set tag "body TrillTopology::advertise [info script]"
    Deputs "----- TAG: $tag -----"
	
Deputs "topoRb:[ array names topoRb ]"
Deputs "emulated rb: $topoRb(emulate)"
	foreach e_rb $topoRb(emulate) {
		set hTopo [ ixNet getL $e_rb customTopology ]
	    ixNet setA $hTopo -enabled True
	    ixNet commit
    }
	
    return [GetStandardReturnHeader]    

}
body TrillTopology::withdraw {} {
	global errorInfo
	global errNumber
	set tag "body TrillTopology::withdraw [info script]"
    Deputs "----- TAG: $tag -----"

	foreach e_rb $topoRb(emulate) {
		set hTopo [ ixNet getL $e_rb customTopology ]
	    ixNet setA $hTopo -enabled False
	    ixNet commit
    }
	
    return [GetStandardReturnHeader]
}
body TrillTopology::flap { args } {
	set tag "proc TrillTopology::flap [info script]"
Deputs "----- TAG: $tag -----"

	set times 1
	set a2w 10
	set w2a 10
	set end_up_dn 1
	
	Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-a2w {
				set trans [ TimeTrans $value ]
				set a2w $trans
			}
			-w2a {
				set trans [ TimeTrans $value ]
				set w2a $trans
			}
			-duration {
				set trans [ TimeTrans $value ]
				set duration $trans
			}
			-times {
				set times $value  	    	
			}
			-end_up_dn {
				set end_up_dn $value
			}
		}
	}	
	
	advertise
	if { [ info exists duration ] } {
		set now [ clock seconds ]
		while { [ expr [ clock seconds ] - $now ] < $duration } {
Deputs "stop R..."
			withdraw
Deputs "W2A..."
			after [ expr 1000*$w2a ]
Deputs "start R..."
			advertise
Deputs "A2W..."
			after [ expr 1000*$a2w ]
		}
	} else {
		for { set index 0 } { $index < $times } { incr index } {
Deputs "times..."
			withdraw
Deputs "W2A..."
			after [ expr 1000*$w2a ]
Deputs "start R..."
			advertise
Deputs "A2W..."
			after [ expr 1000*$a2w ]
		}
	}
	
	if { $end_up_dn } {
		advertise
	} else {
		withdraw
	}

	return [ GetStandardReturnHeader ]
}
body TrillTopology::set_rb { args } {

	set tag "proc TrillTopology::set_rb [info script]"
	Deputs "----- TAG: $tag -----"

	global errorInfo
	global errNumber

    #param collection
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-nickname {
				set nickname $value
			}
			-priority {
				set priority $value
			}
			-interested_vlan {
				set interested_vlan $value
			}
		}
    }	
	
	if { [ info exists nickname ] == 0 } {
		error "$errNumber(2) nickname"
	}
Deputs "handle:$handle"	
	set rb [ ixNet getF $handle customTopologyNode -Nickname $nickname ]
	
	if { $rb == "" } {
		error "$errNumber(1) nickname:$nickname"
	}
	
	if { [ info exists priority ] } {
		ixNet setA $rb -Priority $priority
	}
	
	ixNet commit
	
	return [GetStandardReturnHeader]
		
}
body TrillTopology::advertise_rb { args } {

	set tag "proc TrillTopology::advertise_rb [info script]"
	Deputs "----- TAG: $tag -----"

	global errorInfo
	global errNumber

    #param collection
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-nickname {
				set nickname $value
			}
		}
    }	
	
	if { [ info exists nickname ] == 0 } {
		error "$errNumber(2) nickname"
	}
	
	set rb [ ixNet getF $handle customTopologyNode -Nickname $nickname ]
	
	if { $rb == "" } {
		error "$errNumber(1) nickname:$nickname"
	}
	
	ixNet setA $rb -enabled True
	ixNet commit
	
	return [GetStandardReturnHeader]
}
body TrillTopology::withdraw_rb { args } {

	set tag "proc TrillTopology::withdraw_rb [info script]"
	Deputs "----- TAG: $tag -----"

	global errorInfo
	global errNumber

    #param collection
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-nickname {
				set nickname $value
			}
		}
    }	
	
	if { [ info exists nickname ] == 0 } {
		error "$errNumber(2) nickname"
	}
	
	set rb [ ixNet getF $handle customTopologyNode -Nickname $nickname ]
	
	if { $rb == "" } {
		error "$errNumber(1) nickname:$nickname"
	}
	
	ixNet setA $rb -enabled False
	ixNet commit
	
	return [GetStandardReturnHeader]
}
body TrillTopology::flap_rb { args } {
	set tag "proc TrillTopology::flap_rb [info script]"
Deputs "----- TAG: $tag -----"

	set times 1
	set a2w 10
	set w2a 10
	set end_up_dn 1

	
	Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-nickname { set nickname $value }
			-a2w {
				set trans [ TimeTrans $value ]
				set a2w $trans
			}
			-w2a {
				set trans [ TimeTrans $value ]
				set w2a $trans
			}
			-duration {
				set trans [ TimeTrans $value ]
				set duration $trans
			}
			-times {
				set times $value  	    	
			}
			-end_up_dn {
				set end_up_dn $value
			}
		}
	}	
	
	if { [ info exists nickname ] == 0 } {
		error "$errNumber(2) nickname"
	}
	
	advertise_rb -nickname $nickname
	if { [ info exists duration ] } {
		set now [ clock seconds ]
		while { [ expr [ clock seconds ] - $now ] < $duration } {
Deputs "stop R..."
			withdraw_rb -nickname $nickname
Deputs "W2A..."
			after [ expr 1000*$w2a ]
Deputs "start R..."
			advertise_rb -nickname $nickname
Deputs "A2W..."
			after [ expr 1000*$a2w ]
		}
	} else {
		for { set index 0 } { $index < $times } { incr index } {
Deputs "stop R..."
			withdraw_rb -nickname $nickname
Deputs "W2A..."
			after [ expr 1000*$w2a ]
Deputs "start R..."
			advertise_rb -nickname $nickname
Deputs "A2W..."
			after [ expr 1000*$a2w ]
		}
	}
	
	if { $end_up_dn } {
		advertise_rb -nickname $nickname
	} else {
		withdraw_rb -nickname $nickname
	}

	return [ GetStandardReturnHeader ]
}



class TrillCustomTlv {

	inherit Tlv
	
	public variable inLsp
	public variable inHello

	constructor { typeCode length { value 0 } } { chain $typeCode $value } {
		set len $length
		set inLsp False
		set inHello False
	}
}

class TrillVersionSubTlv {

	inherit TrillCustomTlv
	
	constructor {} { chain 13 1 } {	set inLsp True }
	method config { args } {}
}
body TrillVersionSubTlv::config { args } {
	global errorInfo
	global errNumber
	set tag "body TrillVersionSubTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-max_ver {
				set max_ver $value
			}
		}
    }	
		
	if { [ info exists max_ver ] } {
#		set val $max_ver	
		set val [FmtInt2Hex $max_ver 1]
Deputs "val:$val"
	}
	return [GetStandardReturnHeader]
}

class TrillNicknameSubTlv {
	
	inherit TrillCustomTlv
	
	constructor {} { chain 6 5 } { set inLsp True}
	method config { args } {}
}
body TrillNicknameSubTlv::config { args } {
	global errorInfo
	global errNumber
	set tag "body TrillNicknameSubTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
Deputs "Args:$args "

	set priority 0
	set root_priority 0
	set nickname 1

    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-priority {
				set priority $value
			}
			-root_priority {
				set root_priority $value
			}
			-nickname {
				set nickname $value
			}
		}
    }	
	
	set val [FmtInt2Hex $priority 1][FmtInt2Hex $root_priority 2][FmtInt2Hex $nickname 2]
#	set val [ Int2Hex $priority 1 ][ Int2Hex $root_priority ][ Int2Hex $nickname ]	
	
Deputs "value:$val"	
	return [GetStandardReturnHeader]
}

class TrillEnabledVlanSubTlv {
	inherit TrillCustomTlv
	
	constructor {} { chain 2 4 } { set inHello True }
	method config { args } {}
}
body TrillEnabledVlanSubTlv::config { args } {
	global errorInfo
	global errNumber
	set tag "body TrillEnabledVlanSubTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
Deputs "Args:$args "

	set start_vlan_id 0
	set vlan_bit_map 0

    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-start_vlan_id {
				set start_vlan_id $value
			}
			-vlan_bit_map {
				if { [ string first "0x" $value ] >= 0 } {
					set vlan_bit_map [ string range $value 2 end ]
				} else {
					set vlan_bit_map $value
				}
			}
		}
    }	
	
	
	#set len [ expr [ llength $vlan_bit_map ] / 2 + 2 ] 
	#set val [ Int2Hex $start_vlan_id ]$vlan_bit_map
	set len [ expr [ llength $vlan_bit_map ] + 2 ] 
	set val [ FmtInt2Hex $start_vlan_id 2]$vlan_bit_map
	
	return [GetStandardReturnHeader]
}

class TrillApptFwrdrsSubTlv {
	inherit TrillCustomTlv
	
	constructor {} { chain 3 6 } { set inHello True }
	method config { args } {}
}
body TrillApptFwrdrsSubTlv::config { args } {
	global errorInfo
	global errNumber
	set tag "body TrillApptFwrdrsSubTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
Deputs "Args:$args "

    set index 0
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-appt_info {		
				set appt_info [ list ]
				if { [ llength $value ] == 3 } {
					set appt_info $value
				} else {
					while { [ llength $value ] >= 3 } {
						lappend appt_info [ lrange $value 0 2 ]
						set value [ lrange $value 3 end ]
					}
				}
				set args [ lreplace $args [ expr 2*$index ] [ expr 2*$index +1 ] ]
				incr index -1
			}
		}
    }	
	
	
	set len [ expr [ llength $appt_info ] * 6 ] 
	
	set value ""
	foreach appt $appt_info {
		set nickname 	[ lindex $appt 0 ]
		set start_vlan 	[ lindex $appt 1 ]
		set end_vlan	[ lindex $appt 2 ]
		set value $value[ FmtInt2Hex $nickname 2][ FmtInt2Hex $start_vlan 2][ FmtInt2Hex $end_vlan 2]
#		set value $value[ Int2Hex $nickname ][ Int2Hex $start_vlan ][ Int2Hex $end_vlan ]
	}
	set val $value
	return [GetStandardReturnHeader]
}


#===================
# isis/router
#===================
# Child Lists:
	# customTlv (kLegacyUnknown : getList)
	# customTopology (kLegacyUnknown : getList)
	# dceMulticastIpv4GroupRange (kLegacyUnknown : getList)
	# dceMulticastIpv6GroupRange (kLegacyUnknown : getList)
	# dceMulticastMacRange (kLegacyUnknown : getList)
	# dceNetworkRange (kLegacyUnknown : getList)
	# dceTopologyRange (kLegacyUnknown : getList)
	# interface (kLegacyUnknown : getList)
	# learnedInformation (kLegacyUnknown : getList)
	# networkRange (kLegacyUnknown : getList)
	# routeRange (kLegacyUnknown : getList)
	# spbNetworkRange (kLegacyUnknown : getList)
	# spbTopologyRange (kLegacyUnknown : getList)
	# trillUnicastMacRange (kLegacyUnknown : getList)
# Attributes:
	# -areaAddressList (readOnly=False, type=(kArray)[(kString)])
	# -areaAuthType (readOnly=False, type=(kEnumValue)=md5,none,password)
	# -areaReceivedPasswordList (readOnly=False, type=(kArray)[(kString)])
	# -areaTransmitPassword (readOnly=False, type=(kString))
	# -broadcastRootPriority (readOnly=False, type=(kInteger), deprecated)
	# -capabilityRouterId (readOnly=False, type=(kIPv4))
	# -deviceId (readOnly=False, type=(kInteger), deprecated)
	# -devicePriority (readOnly=False, type=(kInteger), deprecated)
	# -domainAuthType (readOnly=False, type=(kEnumValue)=md5,none,password)
	# -domainReceivedPasswordList (readOnly=False, type=(kArray)[(kString)])
	# -domainTransmitPassword (readOnly=False, type=(kString))
	# -enableAttached (readOnly=False, type=(kBool))
	# -enableAutoLoopback (readOnly=False, type=(kBool))
	# -enabled (readOnly=False, type=(kBool))
	# -enableDiscardLearnedLsps (readOnly=False, type=(kBool))
	# -enableFtag (readOnly=False, type=(kBool), deprecated)
	# -enableHelloPadding (readOnly=False, type=(kBool))
	# -enableHitlessRestart (readOnly=False, type=(kBool))
	# -enableHostName (readOnly=False, type=(kBool))
	# -enableIgnoreMtPortCapability (readOnly=False, type=(kBool))
	# -enableIgnoreRecvMd5 (readOnly=False, type=(kBool))
	# -enableMtIpv6 (readOnly=False, type=(kBool))
	# -enableMtuProbe (readOnly=False, type=(kBool))
	# -enableMultiTopology (readOnly=False, type=(kBool))
	# -enableOverloaded (readOnly=False, type=(kBool))
	# -enablePartitionRepair (readOnly=False, type=(kBool))
	# -enableWideMetric (readOnly=False, type=(kBool))
	# -filterIpv4MulticastTlvs (readOnly=False, type=(kBool))
	# -filterIpv6MulticastTlvs (readOnly=False, type=(kBool))
	# -filterLearnedIpv4Prefixes (readOnly=False, type=(kBool))
	# -filterLearnedIpv6Prefixes (readOnly=False, type=(kBool))
	# -filterLearnedRbridges (readOnly=False, type=(kBool))
	# -filterLearnedSpbRbridges (readOnly=False, type=(kBool))
	# -filterLearnedTrillMacUnicast (readOnly=False, type=(kBool))
	# -filterMacMulticastTlvs (readOnly=False, type=(kBool))
	# -fTagValue (readOnly=False, type=(kInteger), deprecated)
	# -hostName (readOnly=False, type=(kString))
	# -interLspMgroupPduBurstGap (readOnly=False, type=(kInteger64))
	# -lspLifeTime (readOnly=False, type=(kInteger))
	# -lspMaxSize (readOnly=False, type=(kInteger))
	# -lspMgroupPduMinTransmissionInterval (readOnly=False, type=(kInteger64))
	# -lspRefreshRate (readOnly=False, type=(kInteger))
	# -maxAreaAddresses (readOnly=False, type=(kInteger))
	# -maxLspMgroupPdusPerBurst (readOnly=False, type=(kInteger64))
	# -numberOfMtuProbes (readOnly=False, type=(kInteger))
	# -numberOfMultiDestinationTrees (readOnly=False, type=(kInteger), deprecated)
	# -originatingLspBufSize (readOnly=False, type=(kInteger64))
	# -psnpInterval (readOnly=False, type=(kInteger64))
	# -restartMode (readOnly=False, type=(kEnumValue)=helperRouter,normalRouter,restartingRouter,startingRouter)
	# -restartTime (readOnly=False, type=(kInteger))
	# -restartVersion (readOnly=False, type=(kEnumValue)=version3,version4)
	# -startFtagValue (readOnly=False, type=(kInteger), deprecated)
	# -switchId (readOnly=False, type=(kInteger), deprecated)
	# -switchIdPriority (readOnly=False, type=(kInteger), deprecated)
	# -systemId (readOnly=False, type=(kString))
	# -teEnable (readOnly=False, type=(kBool))
	# -teRouterId (readOnly=False, type=(kIP))
	# -trafficGroupId (readOnly=False, type=(kObjref)=null,/traffic/trafficGroup)
# Execs:
	# refreshLearnedInformation((kObjref)=/vport/protocols/isis/router)

#===================
# isis/router/customTlv
#===================
# Attributes:
	# -enabled (readOnly=False, type=(kBool))
	# -includeInHello (readOnly=False, type=(kBool))
	# -includeInLsp (readOnly=False, type=(kBool))
	# -includeInNetworkRange (readOnly=False, type=(kBool))
	# -length (readOnly=False, type=(kInteger))
	# -type (readOnly=False, type=(kInteger))
	# -value (readOnly=False, type=(kBlob))

#===================
# isis/router/customTopology
#===================
# Child Lists:
	# CustomTopologyMulticastIPv4GroupRange (kLegacyUnknown : getList)
	# CustomTopologyMulticastIPv6GroupRange (kLegacyUnknown : getList)
	# customTopologyMulticastMacRange (kLegacyUnknown : getList)
	# customTopologyNode (kLegacyUnknown : getList)
	# customTopologyNodeTopologyRange (kLegacyUnknown : getList)
	# customTopologyRBLinks (kLegacyUnknown : getList)
	# customTopologyUnicastMacRange (kLegacyUnknown : getList)
# Attributes:
	# -capRouterId (readOnly=False, type=(kIPv4))
	# -enabled (readOnly=False, type=(kBool))
	# -enableHostname (readOnly=False, type=(kBool))
	# -hostNamePrefix (readOnly=False, type=(kString))
	# -startSysId (readOnly=False, type=(kString))
	# -sysIdInc (readOnly=False, type=(kString))

#===================
# isis/router/customTopology/customTopologyNode
#===================
# Child Lists:
	# customTopologyLink (kLegacyUnknown : getList)
# Attributes:
	# -EdgeBridge (readOnly=False, type=(kBool))
	# -enabled (readOnly=False, type=(kBool))
	# -Nickname (readOnly=False, type=(kInteger))
	# -Priority (readOnly=False, type=(kInteger))



