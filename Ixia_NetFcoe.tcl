
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.1
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class FcoeVNPortHost {
    inherit ProtocolStackObject
    
    public variable host_type
    public variable fcStack
    public variable target_mac
    public variable virtual_link
	public variable fc_map
	
    constructor { port } { chain $port } {}
    method reborn {} {}
    method config { args } {}
    method login {} { 
		set tag "body FcFPortHost::get_fc_vn_port_stats [info script]"
Deputs "----- TAG: $tag -----"	
		waitPortReset $hPort 120
		ixNet exec fcoeClientFlogi $handle/fcoeClientFlogiRange 
		return [GetStandardReturnHeader]
	}
    method logout {} { 
		set tag "body FcFPortHost::get_fc_vn_port_stats [info script]"
Deputs "----- TAG: $tag -----"	
		waitPortReset $hPort 120
		ixNet exec fcoeClientFlogo $handle/fcoeClientFlogiRange 
		return [GetStandardReturnHeader]

	}
	method discovery {} { 
		set tag "body FcoeVNPortHost::discovery [info script]"
Deputs "----- TAG: $tag -----"	
		waitPortReset $hPort 120
		set ret [ start ]
		
		after 3000

		return $ret
	}
	method start {} {
		set tag "body FcoeVNPortHost::start [info script]"
Deputs "----- TAG: $tag -----"	
		waitPortReset $hPort 120
		set ret [ chain ]
		after 3000

		return $ret
	}
    method clear_virtual_links {} {}
    method get_fcoe_vn_port_stats {} {}
 	method CreateFcoeVNPerSessionView {} {}
}
body FcoeVNPortHost::reborn {} {
	set tag "body FcoeVNPortHost::reborn [info script]"
	Deputs "----- TAG: $tag -----"
		
	chain 
		
	#-- add fcoe endpoint stack
	set fcStack [ ixNet add $stack fcoeClientEndpoint ]
	ixNet setA $fcStack -name $this
	ixNet commit
	set fcStack [ ixNet remapIds $fcStack ]
	
	#-- add default range
	set fcRange [ ixNet add $fcStack range ]
	ixNet commit
	set fcRange [ ixNet remapIds $fcRange ]
	
	ixNet setA $fcRange/vlanRange -enabled False
	
	ixNet setM $fcRange/fcoeClientFdiscRange \
		-enabled False \
		-nameServerQuery False \
		-nameServerRegistration False
	ixNet commit
		
	ixNet setM $fcRange/fcoeClientFlogiRange \
		-enabled True \
		-plogiEnabled True \
		-nameServerQuery False \
		-nameServerRegistration False
	ixNet commit
	
	set handle [ ixNet remapIds $fcRange ]
Deputs "handle:$handle"	

}
body FcoeVNPortHost::config { args } {
	global errorInfo
	global errNumber
    	set tag "body FcoeVNPortHost::config [info script]"
	Deputs "----- TAG: $tag -----"
	
        eval { chain } $args
	Deputs "Args:$args "
	foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
				-host_cnt -
				-count {
					if { [ string is integer $value ] && ( $value <= 65535 ) } {
					set count $value
					} else {
					error "$errNumber(1) key:$key value:$value"
					}
				}
				-enode_cnt {
					set enode_cnt  $value
				}
                -enable_vlan_discovery {
			set trans [ BoolTrans $value ]
			if { $trans == "1" || $trans == "0" } {
			    set enable_vlan_discovery $trans
			} else {
			    error "$errNumber(1) key:$key value:$value"
			}
                }
                -wwpn {
                	set wwpn  $value
                }
                -wwpn_step {
                    set wwpn_step  $value
                }
                -wwpn_list {
                    set wwpn_list  $value
                }    
                -wwnn {
                    set wwnn  $value
                }
                -wwnn_step {
                	set wwnn_step  $value
                }
                -addressing_mode {
                	set addressing_mode  $value
                } 
                -fc_map {
                	set fc_map  $value
                }
                -fip_priority {
                    set fip_priority  $value
                }
                -host_type {
                    set host_type  $value
                }
                -bb_credit {
                    set bb_credit  $value
                }
                -max_rcv_size {
                	set max_rcv_size  $value
                }
                -fcf_mac_addr {
                	set fcf_mac_addr  $value
                } 		    
                -clear_links_list {
                    set clear_links_list  $value
                }
	    }
	}
	
	if { [ info exists count ] } {
		if { $count } {
			ixNet setM $handle/fcoeClientFdiscRange \
				-enabled True \
				-count $count
		} else {
			ixNet setM $handle/fcoeClientFdiscRange \
				-enabled False \
		}
	}
	if { [ info exists enode_cnt ] } {
Deputs "enode_cnt:$enode_cnt"
			ixNet setA $handle/fcoeClientFlogiRange -count $count
	}
	if { [ info exists enable_vlan_discovery ] } {
			ixNet setA $handle/fcoeClientFlogiRange -fipVlanDiscovery $enable_vlan_discovery
	}
	if { [ info exists wwpn ] } {
			ixNet setA $handle/fcoeClientFlogiRange -portWwnStart $wwpn
	}
	if { [ info exists wwpn_step ] } {
			ixNet setA $handle/fcoeClientFlogiRange -portWwnIncrement $wwpn_step
	}
	if { [ info exists wwpn_list ] } {
	}
	if { [ info exists wwnn ] } {
		if { [ info exists wwnn_step ] == 0 } {
			set wwnn_step 00:00:00:00:00:00:00:01
		}
			ixNet setA $handle/fcoeClientFlogiRange -nodeWwnStart $wwnn
#			set wwnn [ incr $wwnn_step ]
	}
	if { [ info exists addressing_mode ] } {
			ixNet setA $handle/fcoeClientFlogiRange -fipAddressingMode $addressing_mode
	}
	if { [ info exists fc_map ] == 0 } {
		set fc_map NA
	}
	if { [ info exists fip_priority ] } {
		# not supported
	}
	if { [ info exists host_type ] } {
		set host_type [ string tolower $host_type ]
		switch host_type {
			target {
					# ixNet setA $handle/fcoeClientFlogiRange -plogiEnabled False
			}
			initiator -
			both {
					# ixNet setA $handle/fcoeClientFlogiRange -plogiEnabled True
			}
		}
	}
	if { [ info exists bb_credit ] } {
		# not supported
	}
	if { [ info exists max_rcv_size ] } {
		# not supported
	}
	if { [ info exists fcf_mac_addr ] } {
		set target_mac $fcf_mac_addr
	}
	if { [ info exists clear_links_list ] } {
		set virtual_link $clear_links_list
	}

	ixNet commit

	foreach obj [ find objects ] {
		if { [ $obj isa FcoeVFPortHost ] == 0 } {
			continue
		}
Deputs "FCF obj found: $obj"		
		set vnRange [ $obj cget -vn_range ]
		set vhRange [ $obj cget -vh_range ]
Deputs "vnRange:$vnRange"		
Deputs "vhRange:$vhRange"
		ixNet setA $handle/fcoeClientFlogiRange \
			-plogiTargetName [ ixNet getA $vnRange/fcoeFwdVnPortRange -name ]
		if { [ string tolower [ ixNet getA $handle/fcoeClientFdiscRange -enabled ] ] == "true" } {
			ixNet setA $handle/fcoeClientFdiscRange \
				-plogiTargetName [ ixNet getA $vhRange/fcoeFwdVnPortRange -name ]
		}
	}
	
	return [GetStandardReturnHeader]	
    
}
body FcoeVNPortHost::get_fcoe_vn_port_stats {} {

	global errorInfo
	global errNumber
	    
	set tag "body FcoeVNPortHost::get_fcoe_vn_port_stats [info script]"
Deputs "----- TAG: $tag -----"

	# == Supported Stats
	# {Stat Name}
	# {Session Name}
	# {Interface Status}
	# {Failure Reason}
	# {Discovered VLAN IDs}
	# {Assigned MAC}
	# {Port Name}
	# {Source ID}
	# {PLOGI Destination ID}
	# {Switch Name}
	# {Fabric Name}
	# {Fabric FC Map}
	# {Fabric Priority}
	# {Fabric MAC}
	# {FCF-MAC List}
	# {FKA D Bit}
	# {Advertised FKA}
	# {FLOGI Tx}
	# {FDISC Tx}
	# {FLOGI LS_ACC Rx}
	# {FLOGI LS_RJT Rx}
	# {FDISC LS_ACC Rx}
	# {FDISC LS_RJT Rx}
	# {F_BSY Rx}
	# {F_RJT Rx}
	# {FLOGO Tx}
	# {PLOGI Tx}
	# {PLOGI Requests Rx}
	# {PLOGI LS_ACC Rx}
	# {PLOGI LS_RJT Rx}
	# {PLOGO Tx}
	# {PLOGO Rx}
	# {NS Registration Tx}
	# {NS Registration OK}
	# {NS Queries Tx}
	# {NS Queries OK}
	# {SCR Tx}
	# {SCR ACC Rx}
	# {RSCN Rx}
	# {RSCN ACC Tx}
	# {FIP Discovery Solicitations Tx}
	# {FIP Discovery Advertisements Rx}
	# {FIP Unsolicited Discovery Advertisements Rx}
	# {FIP Keep-Alives Tx}
	# {FIP Clear Virtual Links Rx}
	

    set root [ixNet getRoot]
    set view [ lindex [ ixNet getF $root/statistics view -caption "fcoeVNPerSessionView" ] 0 ]
Deputs "view:$view"
    if { $view == "" } {
		if { [ catch {
			set view [ CreateFcoeVNPerSessionView ]
		} err ] } {
Deputs "err:$err"		
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }

    set captionList         [ ixNet getA $view/page -columnCaptions ]

	#== Request stats ==
	# role
	# dst_mac_addr
	# fc_id
	# granted_mac_addr
	# granted_vlan_id
	# keep_alive_period
	# max_rx_size
	# rx_accept_count
	# rx_clear_virtual_links_count
	# rx_multicast_advertisement_count
	# rx_reject_count
	# rx_unicast_advertisement_count
	# rx_vlan_notification_count
	# state
	# sub_state
	# tx_fdisc_count
	# tx_flogi_count
	# tx_keep_alive_count
	# tx_logo_count
	# tx_plogi_count
	# tx_state_change_register_count
	# tx_unicast_solicatation_count
	# tx_vlan_request_count
	# world_wide_node_name
	# world_wide_port_name
	
	
	set rangeIndex          					[ lsearch -exact $captionList {Session Name} ]
    set fc_id		        					[ lsearch -exact $captionList {Source ID} ]
    set granted_mac_addr   						[ lsearch -exact $captionList {Assigned MAC} ]
    set granted_vlan_id   						[ lsearch -exact $captionList {Discovered VLAN IDs} ]
    # set keep_alive_period       				[ lsearch -exact $captionList {FDISC Requests Rx} ]
    # set max_rx_size         					[ lsearch -exact $captionList {FLOGI Requests Rx} ]
    set rx_accept_count        					[ lsearch -exact $captionList {FLOGI LS_ACC Rx} ]
    set rx_clear_virtual_links_count    		[ lsearch -exact $captionList {FIP Clear Virtual Links Rx} ]
    set rx_multicast_advertisement_count    	[ lsearch -exact $captionList {FIP Unsolicited Discovery Advertisements Rx} ]
    set rx_reject_count          				[ lsearch -exact $captionList {FLOGI LS_RJT Rx} ]    
    set rx_unicast_advertisement_count  		[ lsearch -exact $captionList {FIP Discovery Advertisements Rx} ]
    # set rx_vlan_notification_count    		[ lsearch -exact $captionList {Clear Virtual Links Tx} ]
    set state	    							[ lsearch -exact $captionList {Interface Status} ]
    set sub_state	    						[ lsearch -exact $captionList {Failure Reason} ]
    set tx_fdisc_count             				[ lsearch -exact $captionList {FDISC Tx} ]
    set tx_flogi_count	            			[ lsearch -exact $captionList {FLOGI Tx} ]
    set tx_keep_alive_count 	          		[ lsearch -exact $captionList {FIP Keep-Alives Tx} ]
    set tx_logo_count         					[ lsearch -exact $captionList {FLOGO Tx} ]
    set tx_plogi_count          				[ lsearch -exact $captionList {PLOGI Tx} ]    
    set tx_state_change_register_count          [ lsearch -exact $captionList {SCR Tx} ]    
    set tx_unicast_solicatation_count          	[ lsearch -exact $captionList {FIP Discovery Solicitations Tx} ]    
    # set tx_vlan_request_count          		[ lsearch -exact $captionList {FIP Discovery Solicitations Tx} ]    
    # set world_wide_node_name  				[ lsearch -exact $captionList {Node Name} ]
	set world_wide_port_name   					[ lsearch -exact $captionList {Port Name}  ]
    
Deputs "handle:$handle"

    set rangeName [ ixNet getA $handle/fcClientFlogiRange -name ]
Deputs "range name:$rangeName"

    set ret "Status : true\nLog : \n"
    
	set pageCount [ ixNet getA $view/page -totalPages ]
	
	for { set index 1 } { $index <= $pageCount } { incr index } {

		ixNet setA $view/page -currentPage $index
		ixNet commit 
		
		set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
		
		foreach row $stats {

			set ret "$ret\{\n"
			
			eval {set row} $row
Deputs "row:$row"
						
			set statsItem   "fc_id"
			set statsVal    [ lindex $row $fc_id ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "granted_mac_addr"
			set statsVal    [ lindex $row $granted_mac_addr ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "granted_vlan_id"
			set statsVal    [ lindex $row $granted_vlan_id ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_accept_count"
			set statsVal    [ lindex $row $rx_accept_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "rx_clear_virtual_links_count"
			set statsVal    [ lindex $row $rx_clear_virtual_links_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_multicast_advertisement_count"
			set statsVal    [ lindex $row $rx_multicast_advertisement_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "rx_reject_count"
			set statsVal    [ lindex $row $rx_reject_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_unicast_advertisement_count"
			set statsVal    [ lindex $row $rx_unicast_advertisement_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "state"
			set statsVal    [ lindex $row $state ]
Deputs "stats val:$statsVal"
			switch $statsVal {
				"FLOGI Complete" {
					set statsVal "UP"
				}
				default {
					set statsVal "DOWN"
				}
			}
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "sub_state"
			set statsVal    [ lindex $row $sub_state ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "tx_fdisc_count"
			set statsVal    [ lindex $row $tx_fdisc_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_flogi_count"
			set statsVal    [ lindex $row $tx_flogi_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_keep_alive_count"
			set statsVal    [ lindex $row $tx_keep_alive_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_logo_count"
			set statsVal    [ lindex $row $tx_logo_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_plogi_count"
			set statsVal    [ lindex $row $tx_plogi_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_state_change_register_count"
			set statsVal    [ lindex $row $tx_state_change_register_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			set statsItem   "tx_unicast_solicatation_count"
			set statsVal    [ lindex $row $tx_unicast_solicatation_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "world_wide_port_name"
			set statsVal    [ lindex $row $world_wide_port_name ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "keep_alive_period"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "max_rx_size"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "rx_vlan_notification_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_vlan_request_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			set statsItem   "world_wide_node_name"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]


			
			set ret "$ret\}\n"

		}
			
Deputs "ret:$ret"
	}

	ixNet remove $view
	ixNet commit
    return $ret	

}
body FcoeVNPortHost::CreateFcoeVNPerSessionView {} {
	set tag "body FcoeVNPortHost::CreateFcoeVNPerSessionView [info script]"
Deputs "----- TAG: $tag -----"
	set root [ixNet getRoot]
	set customView          [ ixNet add $root/statistics view ]
	ixNet setM  $customView -caption "fcoeVNPerSessionView" -type layer23ProtocolStack -visible true
	ixNet commit
	set customView          [ ixNet remapIds $customView ]
Deputs "view:$customView"
	set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
Deputs "available filter:$availableFilter"
	set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
Deputs "filter:$filter"
Deputs "handle:$handle"
	set fcRange $handle/fcoeClientFlogiRange
Deputs "fcRange:$fcRange"
	set rangeName [ ixNet getA $fcRange -name ]
Deputs "range name:$rangeName"
	foreach afil $availableFilter {
Deputs "$afil"
		if { [ regexp $rangeName $afil ] } {
			set stackFilter $afil
		}
	}
Deputs "stack filter:$stackFilter"
	ixNet setM $filter -drilldownType perSession -protocolStackFilterId [ list $stackFilter ]
	ixNet commit
	set srtStat [lindex [ixNet getF $customView statistic -caption {Session Name}] 0]
	ixNet setA $filter -sortAscending true -sortingStatistic $srtStat
	ixNet commit
	foreach s [ixNet getL $customView statistic] {
		ixNet setA $s -enabled true
	}
	ixNet setA $customView -enabled true
	ixNet commit
	return $customView
}
body FcoeVNPortHost::clear_virtual_links {} {
	set tag "body FcoeVNPortHost::clear_virtual_links [info script]"
Deputs "----- TAG: $tag -----"

	set fcfList [ ixNet getL $hPort/protocolStack fcoeFwdEndpoint ]

	if { [ llength $fcfList ] == 0 } {
		return [GetErrorReturnHeader "No FCF found in session"]			
	}

	set fcfFound 0
	foreach fcf $fcfList {
		set fcfRange [ ixNet getL $fcf range ]
		set fcMap [ ixNet getA $fcfRange/fcoeFwdVxPort -fcMap ]
		if { $fcMap == $fc_map } {
			set fcfFound 1
			break
		}
	}

	if { $fcfFound } {
		$fcf clear_virtual_links
	} else {
		
		foreach fcf $fcfList {
			$fcf clear_virtual_links
		}
	}
	
		return [GetStandardReturnHeader]	

}


class FcoeVFPortHost {
    inherit ProtocolStackObject
    
    public variable fcStack
    public variable vn_range
	public variable vh_range
	
    constructor { port } { chain $port } {}
    method reborn {} {}
    method get_fcoe_vf_port_stats {} {}
    method get_fcoe_vf_neighbor_stats {} {}
	method config { args } {}
	method CreateFcoeVFPerSessionView {} {}
	method clear_virtual_links {} {}
	method start {} {
		waitPortReset $hPort 120
		set ret [ chain ]
		after 3000
		return 
	}

}
body FcoeVFPortHost::reborn {} {
	set tag "body FcoeVFPortHost::reborn [info script]"
	Deputs "----- TAG: $tag -----"
		
	chain 
	
	#-- add fcoe endpoint stack
	set fcStack [ ixNet add $stack fcoeFwdEndpoint ]
	ixNet setA $fcStack -name $this
	ixNet commit
	set fcStack [ ixNet remapIds $fcStack ]
	
	#-- add default range
	set fcRange [ ixNet add $fcStack range ]
	ixNet setA $fcRange/vlanRange -enabled False
	ixNet setM $fcRange/fcoeFwdVxPort \
		-enabled True \
		-nameServer False
	
	ixNet commit
	set handle [ ixNet remapIds $fcRange ]
Deputs "handle:$handle"	

	#-- add node range
	set vn_range [ ixNet add $fcStack secondaryRange ]
	ixNet commit
	set vn_range [ ixNet remapIds $vn_range ]
Deputs "vnRange:$vn_range"
	ixNet setM $vn_range/fcoeFwdVnPortRange \
		-enabled True \
		-count 1 \
		-simulated False
	ixNet commit
	
	#-- add host range
	set vh_range [ ixNet add $fcStack secondaryRange ]
	ixNet commit
	set vh_range [ ixNet remapIds $vh_range ]
Deputs "vhRange:$vh_range"
	ixNet setM $vh_range/fcoeFwdVnPortRange \
		-enabled True \
		-count 1 \
		-simulated True
	ixNet commit
	
}
body FcoeVFPortHost::config { args } {
	global errorInfo
	global errNumber
	    set tag "body FcoeVFPortHost::config [info script]"
	Deputs "----- TAG: $tag -----"
	
        set index 0
    	foreach { key value } $args {
                set key [string tolower $key]
                switch -exact -- $key {
                    -negotiated_vlan {
                    	set negotiated_vlan $value
                    	set args [ lreplace $args $index [ expr $index + 1 ] ]
                    	incr index -2    			
                    }
                }
            	incr index 2
        }
	
	
	Deputs "Args:$args "
		    
	eval { chain } $args
			    
	foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
		    -host_cnt -
			-count {
				if { [ string is integer $value ] && ( $value <= 65535 ) } {
				set count $value
				} else {
				error "$errNumber(1) key:$key value:$value"
				}
			}
			-enable_vlan_discovery {
				set trans [ BoolTrans $value ]
				if { $trans == "1" || $trans == "0" } {
					set enable_vlan_discovery $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-wwpn {
				set wwpn  $value
			}
			-wwpn_step {
				set wwpn_step  $value
			}
			-wwpn_list {
				set wwpn_list  $value
			}    
			-wwnn {
				set wwpn  $value
			}
			-wwnn_step {
				set wwnn_step  $value
			}
			-addressing_mode {
				set addressing_mode  $value
			} 
			-domain_id {
				set domain_id $value
			}
			-fc_map {
				set fc_map  $value
			}
			-fip_priority {
				set fip_priority  $value
			}
		    -edtov {
			    set edtov $value
		    }
		    -adv_interval -
		    -adv_interver {
			    set adv_interval $value
		    }
		    -datov {
			    set datov $value
		    }
			-bb_credit {
				set bb_credit  $value
			}
			-max_rcv_size {
				set max_rcv_size  $value
			}
			-vlan_id1 -
			-vlan_id -
			-outer_vlan_id {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
					set outer_vlan_id $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}

		}
	}
	
	if { [ info exists count ] } {
		if { $count } {
			ixNet setM $vh_range/fcoeFwdVnPortRange \
				-count $count \
				-enabled True
		} else {
			ixNet setM $vh_range/fcoeFwdVnPortRange \
				-enabled False
		}

	}
	if { [ info exists enable_vlan_discovery ] } {
			ixNet setA $handle/fcoeFwdVxPort -fipVlanDiscovery $enable_vlan_discovery
	}
	if { [ info exists wwpn ] } {
		
		ixNet setA $vh_range/fcoeFwdVnPortRange -portWwnStart $wwpn
		
	}
	if { [ info exists wwpn_step ] } {
		ixNet setA $vh_range/fcoeFwdVnPortRange -portWwnIncrement $wwpn_step
	}
	if { [ info exists wwnn ] } {

		ixNet setA $vh_range/fcoeFwdVnPortRange -nodeWwnStart $wwnn

	}
	if { [ info exists addressing_mode ] } {
			ixNet setA $handle/fcoeFwdVxPort -fipAddressingMode $addressing_mode
	}
	if { [ info exists fc_map ] } {
			ixNet setA $handle/fcoeFwdVxPort -fcMap $fc_map
	}
	if { [ info exists fip_priority ] } {
			ixNet setA $handle/fcoeFwdVxPort -fipPriority $fip_priority
		
	}
	if { [ info exists bb_credit ] } {
		# not supported
	}
	if { [ info exists max_rcv_size ] } {
			ixNet setA $handle/fcoeFwdVxPort -b2bRxSize $max_rcv_size
	}
	if { [ info exists adv_interval ] } {
			ixNet setA $handle/fcoeFwdVxPort -fipAdvertisementPeriod $adv_interval
	}

	if { [ info exists outer_vlan_id ] } {
		ixNet setA $handle/fcoeFwdVxPort -vlanIds $outer_vlan_id
	}
	ixNet commit
	
	eval { chain } $args
	
	return [GetStandardReturnHeader]	
    
}
body FcoeVFPortHost::CreateFcoeVFPerSessionView {} {
	set tag "body FcoeVFPortHost::CreateFcoeVFPerSessionView [info script]"
Deputs "----- TAG: $tag -----"
	set root [ixNet getRoot]
	set customView          [ ixNet add $root/statistics view ]
	ixNet setM  $customView -caption "fcoeVFPerSessionView" -type layer23ProtocolStack -visible true
	ixNet commit
	set customView          [ ixNet remapIds $customView ]
Deputs "view:$customView"
	set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
Deputs "available filter:$availableFilter"
	set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
Deputs "filter:$filter"
Deputs "handle:$handle"
	set fcRange $handle/fcoeFwdVxPort
Deputs "fcRange:$fcRange"
	set rangeName [ ixNet getA $fcRange -name ]
Deputs "range name:$rangeName"
	foreach afil $availableFilter {
Deputs "$afil"
		if { [ regexp $rangeName $afil ] } {
			set stackFilter $afil
		}
	}
Deputs "stack filter:$stackFilter"
	ixNet setM $filter -drilldownType perSession -protocolStackFilterId [ list $stackFilter ]
	ixNet commit
	set srtStat [lindex [ixNet getF $customView statistic -caption {Session Name}] 0]
	ixNet setA $filter -sortAscending true -sortingStatistic $srtStat
	ixNet commit
	foreach s [ixNet getL $customView statistic] {
		ixNet setA $s -enabled true
	}
	ixNet setA $customView -enabled true
	ixNet commit
	return $customView
}
body FcoeVFPortHost::get_fcoe_vf_port_stats {} {
	# == Supported Stats ==
	# {Stat Name}
	# {VN_Ports Registered}
	# {NS Requests Rx}
	# {NS Accepts Tx}
	# {NS Rejects Tx}
	# {SCR Requests Rx}
	# {SCR Accepts Tx}
	# {SCR Rejects Tx}
	# {FLOGI Requests Rx}
	# {FLOGI LS_ACC Tx}
	# {FLOGI LS_RJT Tx}
	# {FDISC Requests Rx}
	# {FDISC LS_ACC Tx}
	# {FDISC LS_RJT Tx}
	# {FLOGO Requests Rx}
	# {FLOGO LS_ACC Tx}
	# {FLOGO LS_RJT Tx}
	# {PLOGI Requests Rx}
	# {PLOGI LS_ACC Tx}
	# {PLOGI LS_RJT Tx}
	# {PLOGO Requests Rx}
	# {PLOGO LS_ACC Tx}
	# {PLOGO LS_RJT Tx}
	# {PLOGI Requests Tx}
	# {PLOGI LS_ACC Rx}
	# {PLOGI LS_RJT Rx}
	# {PLOGO Requests Tx}
	# {PLOGO LS_ACC Rx}
	# {PLOGO LS_RJT Rx}
	# {Discovery Solicitations Rx}
	# {Discovery Advertisements Tx}
	# {VLAN Requests Rx}
	# {VLAN Notifications Tx}
	# {Unsolicited Discovery Advertisements Tx}
	# {ENode Keep-Alives Rx}
	# {ENode Keep-Alives Miss}
	# {Unexpected ENode Keep-Alives Rx}
	# {VN_Port Keep-Alives Rx}
	# {VN_Port Keep-Alives Miss}
	# {Unexpected VN_Port Keep-Alives Rx}
	# {Clear Virtual Links VN_Ports}
	# {Clear Virtual Links Tx}
	# {Clear Virtual Links Rx}
     set tag "body Port::get_stats [info script]"
Deputs "----- TAG: $tag -----"
    
	#{::ixNet::OBJ-/statistics/view:"Port Statistics"}
    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"FCoE VF_Port"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"

	# == Request Stats ==
	# state
	# neighbor_count
	# rx_fdisc_count
	# rx_flogi_count
	# rx_keep_alive_count
	# rx_logo_count
	# rx_plogi_count
	# rx_solicitation_count
	# rx_vlan_request_count
	# tx_advertisement_count
	# tx_clear_virtual_links_count
	# tx_fdisc_accept_count
	# tx_flogi_acept_count
	# tx_logo_count
	# tx_multicast_advertisement_count
	# tx_plogi_accept_count
	# tx_vlan_notification_count
	set port_name				[ lsearch -exact $captionList {Stat Name} ]

	set state_req 							[ lsearch -exact $captionList {NS Requests Rx} ]
	set state_acc							[ lsearch -exact $captionList {NS Accepts Tx} ]
	set state_rej							[ lsearch -exact $captionList {NS Rejects Tx} ]
	
    set neighbor_count          			[ lsearch -exact $captionList {VN_Ports Registered} ]
    set rx_fdisc_count          			[ lsearch -exact $captionList {FDISC Requests Rx} ]
    set rx_flogi_count         				[ lsearch -exact $captionList {FLOGI Requests Rx} ]
    set rx_keep_alive_count         		[ lsearch -exact $captionList {ENode Keep-Alives Rx} ]
    set rx_logo_count         				[ lsearch -exact $captionList {FLOGO Requests Rx} ]
    set rx_plogi_count       				[ lsearch -exact $captionList {PLOGI Requests Rx} ]
    set rx_solicitation_count        		[ lsearch -exact $captionList {Discovery Solicitations Rx} ]
    set rx_vlan_request_count				[ lsearch -exact $captionList {VLAN Requests Rx} ]
	set tx_advertisement_count				[ lsearch -exact $captionList {Discovery Advertisements Tx} ]
    set tx_clear_virtual_links_count        [ lsearch -exact $captionList {Clear Virtual Links VN_Ports} ]
    set tx_fdisc_accept_count          		[ lsearch -exact $captionList {FDISC LS_ACC Tx} ]
    set tx_flogi_acept_count         		[ lsearch -exact $captionList {FLOGI LS_ACC Tx} ]
    set tx_logo_count         				[ lsearch -exact $captionList {FLOGO LS_ACC Tx} ]
    set tx_multicast_advertisement_count    [ lsearch -exact $captionList {Unsolicited Discovery Advertisements Tx} ]
    set tx_plogi_accept_count        		[ lsearch -exact $captionList {PLOGI LS_ACC Tx} ]
    set tx_vlan_notification_count			[ lsearch -exact $captionList {VLAN Notifications Tx} ]

    set ret "[ GetStandardReturnHeader ]{\n"
	
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
		if { [ string length $card ] == 1 } {
			set card "0$card"
		}
		if { [ string length $port ] == 1 } {
			set port "0$port"
		}
		if { "${chassis}/Card${card}/Port${port}" != [ lindex $row $port_name ] } {
			continue
		}

        set statsItem   "state"
        set state_req    [ lindex $row $state_req ]
        set state_acc    [ lindex $row $state_acc ]
        set state_rej    [ lindex $row $state_rej ]
		if { $state_req == $state_acc && $state_rej == 0 } {
			set statsVal    UP
		} else {
			set statsVal    DOWN
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          

        set statsItem   "neighbor_count"
        set statsVal    [ lindex $row $neighbor_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "rx_fdisc_count"
        set statsVal    [ lindex $row $rx_fdisc_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "rx_flogi_count"
        set statsVal    [ lindex $row $rx_flogi_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "rx_keep_alive_count"
        set statsVal    [ lindex $row $rx_keep_alive_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
              
        set statsItem   "rx_logo_count"
        set statsVal    [ lindex $row $rx_logo_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "rx_plogi_count"
        set statsVal    [ lindex $row $rx_plogi_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "rx_solicitation_count"
        set statsVal    [ lindex $row $rx_solicitation_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "rx_vlan_request_count"
        set statsVal    [ lindex $row $rx_vlan_request_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "tx_advertisement_count"
        set statsVal    [ lindex $row $tx_advertisement_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "tx_clear_virtual_links_count"
        set statsVal    [ lindex $row $tx_clear_virtual_links_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "tx_fdisc_accept_count"
        set statsVal    [ lindex $row $tx_fdisc_accept_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_flogi_acept_count"
        set statsVal    [ lindex $row $tx_flogi_acept_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_logo_count"
        set statsVal    [ lindex $row $tx_logo_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_multicast_advertisement_count"
        set statsVal    [ lindex $row $tx_multicast_advertisement_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_plogi_accept_count"
        set statsVal    [ lindex $row $tx_plogi_accept_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_vlan_notification_count"
        set statsVal    [ lindex $row $tx_vlan_notification_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]


Deputs "ret:$ret"

    }
        
    return "$ret}"
}
body FcoeVFPortHost::get_fcoe_vf_neighbor_stats {} {
	global errorInfo
	global errNumber
	    
	set tag "body FcFPortHost::get_fc_vn_port_stats [info script]"
Deputs "----- TAG: $tag -----"

	# == Supported Stats
	# {Stat Name}
	# {Session Name}
	# {Session Status}
	# {Source ID}
	# {Port Name}
	# {Node Name}
	# {Original MAC}
	# {Assigned MAC}
	# {Assigned VLAN ID}
	# {FLOGI Requests Rx}
	# {FLOGI LS_ACC Tx}
	# {FLOGI LS_RJT Tx}
	# {FDISC Requests Rx}
	# {FDISC LS_ACC Tx}
	# {FDISC LS_RJT Tx}
	# {FLOGO Requests Rx}
	# {FLOGO LS_ACC Tx}
	# {FLOGO LS_RJT Tx}
	# {PLOGI Requests Rx}
	# {PLOGI LS_ACC Tx}
	# {PLOGI LS_RJT Tx}
	# {PLOGO Requests Rx}
	# {PLOGO LS_ACC Tx}
	# {PLOGO LS_RJT Tx}
	# {NS Requests Rx}
	# {NS Accepts Tx}
	# {NS Rejects Tx}
	# {SCR Requests Rx}
	# {SCR Accepts Tx}
	# {SCR Rejects Tx}
	# {ENode Keep-Alives Rx}
	# {ENode Keep-Alives Miss}
	# {VN_Port Keep-Alives Rx}
	# {VN_Port Keep-Alives Miss}
	# {Clear Virtual Links VN_Ports}
	# {Clear Virtual Links Tx}
	

    set root [ixNet getRoot]
    set view [ lindex [ ixNet getF $root/statistics view -caption "fcoeVFPerSessionView" ] 0 ]
Deputs "view:$view"
    if { $view == "" } {
		if { [ catch {
			set view [ CreateFcoeVFPerSessionView ]
		} ] } {
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }

    set captionList         [ ixNet getA $view/page -columnCaptions ]

	#== Request stats ==
	# fc_id
	# mac_address
	# rx_fdisc_count
	# rx_flogi_count
	# rx_keep_alive_count
	# rx_logo_count
	# rx_plogi_count
	# rx_solicitation_count
	# rx_vlan_request_count
	# sub_state
	# tx_advertisement_count
	# tx_clear_virtual_links_count
	# tx_fdisc_accept_count
	# tx_flogi_acceptCount
	# tx_logo_count
	# tx_multicast_advertisement_count
	# tx_plogi_accept_count
	# tx_vlan_notification_count
	# world_wide_node_name
	# world_wide_port_name
	
	
	set rangeIndex          					[ lsearch -exact $captionList {Session Name} ]
    set fc_id		        					[ lsearch -exact $captionList {Source ID} ]
    set mac_address   							[ lsearch -exact $captionList {Assigned MAC} ]
    set rx_fdisc_count       					[ lsearch -exact $captionList {FDISC Requests Rx} ]
    set rx_flogi_count         					[ lsearch -exact $captionList {FLOGI Requests Rx} ]
    set rx_keep_alive_count        				[ lsearch -exact $captionList {ENode Keep-Alives Rx} ]
    set rx_logo_count    						[ lsearch -exact $captionList {FLOGO Requests Rx} ]
    set rx_plogi_count    						[ lsearch -exact $captionList {PLOGI Requests Rx} ]
    # set rx_solicitation_count             	[ lsearch -exact $captionList {FDISC Tx} ]
    # set rx_vlan_request_count           [ lsearch -exact $captionList {FLOGI LS_ACC Rx} ]
    set sub_state          						[ lsearch -exact $captionList {Session Status} ]    
    # set tx_advertisement_count  			[ lsearch -exact $captionList {FDISC LS_ACC Rx} ]
    set tx_clear_virtual_links_count    		[ lsearch -exact $captionList {Clear Virtual Links Tx} ]
    set tx_fdisc_accept_count	    			[ lsearch -exact $captionList {FDISC LS_ACC Tx} ]
    set tx_flogi_accept_count             		[ lsearch -exact $captionList {FLOGI LS_ACC Tx} ]
    set tx_logo_count	            			[ lsearch -exact $captionList {FLOGO LS_ACC Tx} ]
    # set tx_multicast_advertisement_count 	          	[ lsearch -exact $captionList {PLOGI Tx} ]
    set tx_plogi_accept_count         			[ lsearch -exact $captionList {PLOGI LS_ACC Tx} ]
    # set tx_vlan_notification_count          	[ lsearch -exact $captionList {PLOGI LS_ACC Rx} ]    
    set world_wide_node_name  					[ lsearch -exact $captionList {Node Name} ]
	set world_wide_port_name   					[ lsearch -exact $captionList {Port Name}  ]
    
Deputs "handle:$handle"

    set rangeName [ ixNet getA $handle/fcClientFlogiRange -name ]
Deputs "range name:$rangeName"

    set ret "Status : true\nLog : \n"
    
	set pageCount [ ixNet getA $view/page -totalPages ]
	
	for { set index 1 } { $index <= $pageCount } { incr index } {

		ixNet setA $view/page -currentPage $index
		ixNet commit 
		
		set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
		
		foreach row $stats {

			set ret "$ret\{\n"
			
			eval {set row} $row
Deputs "row:$row"
						
			set statsItem   "fc_id"
			set statsVal    [ lindex $row $fc_id ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "mac_address"
			set statsVal    [ lindex $row $mac_address ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "rx_fdisc_count"
			set statsVal    [ lindex $row $rx_fdisc_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_flogi_count"
			set statsVal    [ lindex $row $rx_flogi_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "rx_keep_alive_count"
			set statsVal    [ lindex $row $rx_keep_alive_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_logo_count"
			set statsVal    [ lindex $row $rx_logo_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "rx_plogi_count"
			set statsVal    [ lindex $row $rx_plogi_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "sub_state"
			set statsVal    [ lindex $row $sub_state ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_clear_virtual_links_count"
			set statsVal    [ lindex $row $tx_clear_virtual_links_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_fdisc_accept_count"
			set statsVal    [ lindex $row $tx_fdisc_accept_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "tx_flogi_accept_count"
			set statsVal    [ lindex $row $tx_flogi_accept_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_logo_count"
			set statsVal    [ lindex $row $tx_logo_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "tx_plogi_accept_count"
			set statsVal    [ lindex $row $tx_plogi_accept_count ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "world_wide_node_name"
			set statsVal    [ lindex $row $world_wide_node_name ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "world_wide_port_name"
			set statsVal    [ lindex $row $world_wide_port_name ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_solicitation_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "rx_vlan_request_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_advertisement_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_multicast_advertisement_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			set statsItem   "tx_vlan_notification_count"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]


			
			set ret "$ret\}\n"

		}
			
Deputs "ret:$ret"
	}

Deputs "view:$view"
	ixNet remove $view
	ixNet commit
    return $ret	

}
body FcoeVFPortHost::clear_virtual_links {} {
	set tag "body FcoeVNPortHost::clear_virtual_links [info script]"
Deputs "----- TAG: $tag -----"
	
	ixNet exec fcoeFwdSendClearVlink $handle
	
	return [GetStandardReturnHeader]	

}

class FcNPortHost {
    inherit EmulationObject
    
    public variable fcStack
	
    constructor { port } {
	    
	    set portObj $port
   
	    reborn
    }
    method reborn {} {}
    method config { args } {}
    method login {} {}
    method logout {} {}
    method get_fc_vn_port_stats {} {}
	method CreateFcNPortPerSessionView {} {}
}
body FcNPortHost::reborn {} {
	set tag "body FcNPortHost::reborn [info script]"
	Deputs "----- TAG: $tag -----"

	if { [ info exists hPort ] == 0 } {
		if { [ catch {
			set hPort   [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in DhcpHost ctor"
		}
	}
	
	#-- add fc endpoint stack
	set fcStack [ ixNet add $hPort/protocolStack fcClientEndpoint ]
	ixNet setA $fcStack -name $this
	ixNet commit
	set fcStack [ ixNet remapIds $fcStack ]
	
	#-- add default range
	set fcRange [ ixNet add $fcStack range ]
	
	ixNet commit
	set handle [ ixNet remapIds $fcRange ]
	
}
body FcNPortHost::config { args } {
	global errorInfo
	global errNumber
	    set tag "body FcNPortHost::config [info script]"
	Deputs "----- TAG: $tag -----"
	
	Deputs "Args:$args "
		    
	if { $handle == "" } {
		reborn
	}
			    
	foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
		    -host_cnt -
		-count {
		    if { [ string is integer $value ] && ( $value <= 65535 ) } {
			set count $value
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
		}
		-wwpn {
			set wwpn  $value
		}
		-wwpn_step {
		    set wwpn_step  $value
		}
		-wwpn_list {
		    set wwpn_list  $value
		}    
		-wwnn {
		    set wwpn  $value
		}
		-wwnn_step {
			set wwnn_step  $value
		}
                -host_type {
                    set host_type  $value
                }
		-bb_credit {
		    set bb_credit  $value
		}
		-max_rcv_size {
			set max_rcv_size  $value
		}
	    }
	}
	
        
        if { [ info exists count ] } {
        	foreach fcRange $handle {
        		ixNet setA $fcRange/fcClientFlogiRange -count $count
        	}
        }
        if { [ info exists wwpn ] } {
        	foreach fcRange $handle {
        		ixNet setA $fcRange/fcClientFlogiRange -portWwnStart $wwpn
        	}	
        }
        if { [ info exists wwpn_step ] } {
        	foreach fcRange $handle {
        		ixNet setA $fcRange/fcClientFlogiRange -portWwnIncrement $wwpn_step
        	}
        }
        if { [ info exists wwpn_list ] } {
        }
        if { [ info exists wwnn ] } {
        	if { [ info exists wwnn_step ] == 0 } {
        		set wwnn_step 00:00:00:00:00:00:00:01
        	}
        	foreach fcRange $handle {
        		ixNet setA $fcRange/fcClientFlogiRange -nodeWwnStart $wwnn
        #			set wwnn [ incr $wwnn_step ]
        	}
        }
        if { [ info exists host_type ] } {
        	set host_type [ string tolower $host_type ]
        	switch host_type {
        		target {
        			foreach fcRange $handle {
        				ixNet setA $fcRange/fcClientFlogiRange -plogiEnabled False
        			}
        		}
        		initiator -
        		both {
        			foreach fcRange $handle {
        				ixNet setA $fcRange/fcClientFlogiRange -plogiEnabled True
        			}
        		}
        	}
        }
        if { [ info exists bb_credit ] } {
        	# not supported
        }
        if { [ info exists max_rcv_size ] } {
        	# not supported
        }

	ixNet commit
	
	return [GetStandardReturnHeader]	
    
}
body FcNPortHost::get_fc_vn_port_stats {} {

	global errorInfo
	global errNumber
	    
	set tag "body FcNPortHost::get_fc_vn_port_stats [info script]"
Deputs "----- TAG: $tag -----"

	# {Stat Name} {Session Name} {Port Name} {Interface Status} 
	# {Failure Reason} {Source ID} {PLOGI Destination ID} E_D_TOV 
	# {Remote BB_Credit} {FLOGI Tx} {FDISC Tx} {FLOGI LS_ACC Rx} 
	# {FLOGI LS_RJT Rx} {FDISC LS_ACC Rx} {FDISC LS_RJT Rx} {F_BSY Rx} 
	# {F_RJT Rx} {FLOGO Tx} {PLOGI Tx} {PLOGI Requests Rx} {PLOGI LS_ACC Rx}
	# {PLOGI LS_RJT Rx} {PLOGO Tx} {PLOGO Rx} {NS Registration Tx} 
	# {NS Registration OK} {NS Queries Tx} {NS Queries OK} {SCR Tx} 
	# {SCR ACC Rx} {RSCN Rx} {RSCN ACC Tx} {PRLI Tx} {PRLI Requests Rx} 
	# {PRLI LS_ACC Rx} {PRLI LS_RJT Rx}
	

    set root [ixNet getRoot]
    set view [ lindex [ ixNet getF $root/statistics view -caption "fcNportPerSessionView" ] 0 ]
Deputs "view:$view"
    if { $view == "" } {
		if { [ catch {
			set view [ CreateFcNPortPerSessionView ]
		} ] } {
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }

    set captionList         [ ixNet getA $view/page -columnCaptions ]

	set rangeIndex          		[ lsearch -exact $captionList {Session Name} ]
	set portNameIndex          		[ lsearch -exact $captionList {Port Name}  ]
    set intStatusIndex   			[ lsearch -exact $captionList {Interface Status}  ]
    set failureReasonIndex       	[ lsearch -exact $captionList {Failure Reason} ]
    set sourceIdIndex        		[ lsearch -exact $captionList {Source ID} ]
    set plogiDestIdIndex         	[ lsearch -exact $captionList {PLOGI Destination ID} ]
    set edTovIndex        			[ lsearch -exact $captionList {E_D_TOV} ]
    set remoteBbCreditIndex    		[ lsearch -exact $captionList {Remote BB_Credit} ]
    set txFlogiIndex    			[ lsearch -exact $captionList {FLOGI Tx} ]
    set txFdiscIndex             	[ lsearch -exact $captionList {FDISC Tx} ]
    set rxFlogiLsAccIndex           [ lsearch -exact $captionList {FLOGI LS_ACC Rx} ]
    set rxFlogiLsRjtIndex          	[ lsearch -exact $captionList {FLOGI LS_RJT Rx} ]    
    set rxFdiscLsAccIndex  			[ lsearch -exact $captionList {FDISC LS_ACC Rx} ]
    set rxFdiscLsRjtIndex    		[ lsearch -exact $captionList {FDISC LS_RJT Rx} ]
    set rxFBsyIndex	    			[ lsearch -exact $captionList {F_BSY Rx} ]
    set rxFRjtIndex             	[ lsearch -exact $captionList {F_RJT Rx} ]
    set txFLogoIndex	            [ lsearch -exact $captionList {FLOGO Tx} ]
    set txPlogiIndex 	          	[ lsearch -exact $captionList {PLOGI Tx} ]
    set rxPlogiRequestIndex         [ lsearch -exact $captionList {PLOGI Requests Rx} ]
    set rxPlogiLsAccIndex          	[ lsearch -exact $captionList {PLOGI LS_ACC Rx} ]    
    set rxPlogiLsRjtIndex  			[ lsearch -exact $captionList {PLOGI LS_RJT Rx} ]
    set txPlogoIndex	    		[ lsearch -exact $captionList {PLOGO Tx} ]
    set rxPlogoIndex    			[ lsearch -exact $captionList {PLOGO Rx} ]
    set txNsRegIndex             	[ lsearch -exact $captionList {NS Registration Tx} ]
    set nsRegOkIndex	            [ lsearch -exact $captionList {NS Registration OK} ]
    set txNsQueIndex 	          	[ lsearch -exact $captionList {NS Queries Tx} ]
    set nsQueOkIndex	    		[ lsearch -exact $captionList {NS Queries OK} ]
    set srcTxIndex	    			[ lsearch -exact $captionList {SCR Tx} ]
    set rxScrAccIndex             	[ lsearch -exact $captionList {SCR ACC Rx} ]
    set rxRscnIndex		            [ lsearch -exact $captionList {RSCN Rx} ]
    set txRscnAccIndex 	          	[ lsearch -exact $captionList {RSCN ACC Tx} ]
    set txPrliIndex	    			[ lsearch -exact $captionList {PRLI Tx} ]
    set rxPrliReqIndex             	[ lsearch -exact $captionList {PRLI Requests Rx} ]
    set rxPrliLsAccIndex            [ lsearch -exact $captionList {PRLI LS_ACC Rx} ]
    set rxPrliLsRjtIndex          	[ lsearch -exact $captionList {PRLI LS_RJT Rx} ]
    
Deputs "handle:$handle"

    set rangeName [ ixNet getA $handle/fcClientFlogiRange -name ]
Deputs "range name:$rangeName"

    set ret "Status : true\nLog : \n"
    
	set pageCount [ ixNet getA $view/page -totalPages ]
	
	for { set index 1 } { $index <= $pageCount } { incr index } {

		ixNet setA $view/page -currentPage $index
		ixNet commit 
		
		set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
		
		foreach row $stats {

			set ret "$ret\{\n"
			
			eval {set row} $row
Deputs "row:$row"

			set statsItem   "world_wide_node_name"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "max_rx_size"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "world_wide_port_name"
			set statsVal    [ lindex $row $portNameIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "state"
			set statsVal    [ lindex $row $intStatusIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "sub_state"
			set statsVal    [ lindex $row $failureReasonIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "fc_id"
			set statsVal    [ lindex $row $sourceIdIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "rx_accept_count"
			set statsVal    [ lindex $row $rxFlogiLsAccIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_reject_count"
			set statsVal    [ lindex $row $rxFlogiLsRjtIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_fdisc_count"
			set statsVal    [ lindex $row $txFdiscIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "tx_flogi_count"
			set statsVal    [ lindex $row $txFlogiIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_logo_count"
			set statsVal    [ lindex $row $txFLogoIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_plogi_count"
			set statsVal    [ lindex $row $txPlogiIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "tx_state_change_register_count"
			set statsVal    [ lindex $row $txNsRegIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			

			
			set ret "$ret\}\n"

		}
			
Deputs "ret:$ret"
	}

	ixNet remove $view
	ixNet commit
    return $ret	
	
}
body FcNPortHost::CreateFcNPortPerSessionView {} {
	set tag "body FcNPortHost::CreateFcNPortPerSessionView [info script]"
Deputs "----- TAG: $tag -----"
	set root [ixNet getRoot]
	set customView          [ ixNet add $root/statistics view ]
	ixNet setM  $customView -caption "fcNportPerSessionView" -type layer23ProtocolStack -visible true
	ixNet commit
	set customView          [ ixNet remapIds $customView ]
Deputs "view:$customView"
	set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
Deputs "available filter:$availableFilter"
	set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
Deputs "filter:$filter"
Deputs "handle:$handle"
	set fcRange $handle/fcClientFlogiRange
Deputs "fcRange:$fcRange"
	set rangeName [ ixNet getA $fcRange -name ]
Deputs "range name:$rangeName"
	foreach afil $availableFilter {
Deputs "$afil"
		if { [ regexp $rangeName $afil ] } {
			set stackFilter $afil
		}
	}
Deputs "stack filter:$stackFilter"
	ixNet setM $filter -drilldownType perSession -protocolStackFilterId $stackFilter
	ixNet commit
	set srtStat [lindex [ixNet getF $customView statistic -caption {Session Name}] 0]
	ixNet setA $filter -sortAscending true -sortingStatistic $srtStat
	ixNet commit
	foreach s [ixNet getL $customView statistic] {
		ixNet setA $s -enabled true
	}
	ixNet setA $customView -enabled true
	ixNet commit
	return $customView
}


class FcFPortHost {
    inherit EmulationObject
    
    public variable fcStack
    public variable vn_range
    
    constructor { port } {
	    
	    set portObj $port
   
	    reborn
    }
    method reborn {} {}
    method config { args } {}
    method get_fc_neighbor_stats {} {}
	method CreateFcFPerSessionView {} {}    
}
body FcFPortHost::reborn {} {
	set tag "body FcFPortHost::reborn [info script]"
	Deputs "----- TAG: $tag -----"

	if { [ info exists hPort ] == 0 } {
		if { [ catch {
			set hPort   [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in DhcpHost ctor"
		}
	}
	
	#-- add fc endpoint stack
	set fcStack [ ixNet add $hPort fcFportFwdEndpoint ]
	ixNet setA $fcStack -name $this
	ixNet commit
	set fcStack [ ixNet remapIds $fcStack ]
	
	#-- add default range
	set fcRange [ ixNet add $fcStack range ]
	ixNet setA $fcRange/fcoeFwdVxPort -enabled True
	
	ixNet commit
	set handle [ ixNet remapIds $fcRange ]
	
	#-- add secondary range
	set vn_range [ ixNet add $fcStack secondaryRange ]
	ixNet commit
	set vn_range [ ixNet remapIds $vn_range ]

}
body FcFPortHost::config { args } {
	global errorInfo
	global errNumber
	    set tag "body FcFPortHost::config [info script]"
	Deputs "----- TAG: $tag -----"

	Deputs "Args:$args "
		    
	if { $handle == "" } {
		reborn
	}
	
	foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
		    -host_cnt -
		-count {
		    if { [ string is integer $value ] && ( $value <= 65535 ) } {
			set count $value
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
		}
		-wwpn {
			set wwpn  $value
		}
		-wwpn_step {
		    set wwpn_step  $value
		}
		-wwpn_list {
		    set wwpn_list  $value
		}    
		-wwnn {
		    set wwpn  $value
		}
		-wwnn_step {
			set wwnn_step  $value
		}
		-domain_id {
			set domain_id $value
		}
		    -edtov {
			    set edtov $value
		    }
		    -datov {
			    set datov $value
		    }
		-bb_credit {
		    set bb_credit  $value
		}
		-max_rcv_size {
			set max_rcv_size  $value
		}
	    }
	}
	
	if { [ info exists count ] } {
		ixNet setA $vn_range/fcoeFwdVnPortRange -count $count

	}
	if { [ info exists wwpn ] } {
		
		ixNet setA $vn_range/fcoeFwdVnPortRange -portWwnStart $wwpn
		
	}
	if { [ info exists wwpn_step ] } {
		ixNet setA $vn_range/fcoeFwdVnPortRange -portWwnIncrement $wwpn_step
	}
	if { [ info exists wwnn ] } {

		ixNet setA $vn_range/fcoeFwdVnPortRange -nodeWwnStart $wwnn

	}
	if { [ info exists bb_credit ] } {
		# not supported
	}
	if { [ info exists max_rcv_size ] } {
		foreach fcRange $handle {
			ixNet setA $fcRange/fcFportVxPort -b2bRxSize $max_rcv_size
		}
	}


	ixNet commit
		
	return [GetStandardReturnHeader]	
    
}
body FcFPortHost::get_fc_neighbor_stats {} {

	global errorInfo
	global errNumber
	    
	set tag "body FcFPortHost::get_fc_vn_port_stats [info script]"
Deputs "----- TAG: $tag -----"

	# {Stat Name} {Session Name} {Port Name} {Interface Status} 
	# {Failure Reason} {Source ID} {PLOGI Destination ID} E_D_TOV 
	# {Remote BB_Credit} {FLOGI Tx} {FDISC Tx} {FLOGI LS_ACC Rx} 
	# {FLOGI LS_RJT Rx} {FDISC LS_ACC Rx} {FDISC LS_RJT Rx} {F_BSY Rx} 
	# {F_RJT Rx} {FLOGO Tx} {PLOGI Tx} {PLOGI Requests Rx} {PLOGI LS_ACC Rx}
	# {PLOGI LS_RJT Rx} {PLOGO Tx} {PLOGO Rx} {NS Registration Tx} 
	# {NS Registration OK} {NS Queries Tx} {NS Queries OK} {SCR Tx} 
	# {SCR ACC Rx} {RSCN Rx} {RSCN ACC Tx} {PRLI Tx} {PRLI Requests Rx} 
	# {PRLI LS_ACC Rx} {PRLI LS_RJT Rx}
	

    set root [ixNet getRoot]
    set view [ lindex [ ixNet getF $root/statistics view -caption "fcfPerSessionView" ] 0 ]
Deputs "view:$view"
    if { $view == "" } {
		if { [ catch {
			set view [ CreateFcFPerSessionView ]
		} ] } {
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }

    set captionList         [ ixNet getA $view/page -columnCaptions ]

	set rangeIndex          		[ lsearch -exact $captionList {Session Name} ]
	set portNameIndex          		[ lsearch -exact $captionList {Port Name}  ]
    set intStatusIndex   			[ lsearch -exact $captionList {Interface Status}  ]
    set failureReasonIndex       	[ lsearch -exact $captionList {Failure Reason} ]
    set sourceIdIndex        		[ lsearch -exact $captionList {Source ID} ]
    set plogiDestIdIndex         	[ lsearch -exact $captionList {PLOGI Destination ID} ]
    set edTovIndex        			[ lsearch -exact $captionList {E_D_TOV} ]
    set remoteBbCreditIndex    		[ lsearch -exact $captionList {Remote BB_Credit} ]
    set txFlogiIndex    			[ lsearch -exact $captionList {FLOGI Tx} ]
    set txFdiscIndex             	[ lsearch -exact $captionList {FDISC Tx} ]
    set rxFlogiLsAccIndex           [ lsearch -exact $captionList {FLOGI LS_ACC Rx} ]
    set rxFlogiLsRjtIndex          	[ lsearch -exact $captionList {FLOGI LS_RJT Rx} ]    
    set rxFdiscLsAccIndex  			[ lsearch -exact $captionList {FDISC LS_ACC Rx} ]
    set rxFdiscLsRjtIndex    		[ lsearch -exact $captionList {FDISC LS_RJT Rx} ]
    set rxFBsyIndex	    			[ lsearch -exact $captionList {F_BSY Rx} ]
    set rxFRjtIndex             	[ lsearch -exact $captionList {F_RJT Rx} ]
    set txFLogoIndex	            [ lsearch -exact $captionList {FLOGO Tx} ]
    set txPlogiIndex 	          	[ lsearch -exact $captionList {PLOGI Tx} ]
    set rxPlogiRequestIndex         [ lsearch -exact $captionList {PLOGI Requests Rx} ]
    set rxPlogiLsAccIndex          	[ lsearch -exact $captionList {PLOGI LS_ACC Rx} ]    
    set rxPlogiLsRjtIndex  			[ lsearch -exact $captionList {PLOGI LS_RJT Rx} ]
    set txPlogoIndex	    		[ lsearch -exact $captionList {PLOGO Tx} ]
    set rxPlogoIndex    			[ lsearch -exact $captionList {PLOGO Rx} ]
    set txNsRegIndex             	[ lsearch -exact $captionList {NS Registration Tx} ]
    set nsRegOkIndex	            [ lsearch -exact $captionList {NS Registration OK} ]
    set txNsQueIndex 	          	[ lsearch -exact $captionList {NS Queries Tx} ]
    set nsQueOkIndex	    		[ lsearch -exact $captionList {NS Queries OK} ]
    set srcTxIndex	    			[ lsearch -exact $captionList {SCR Tx} ]
    set rxScrAccIndex             	[ lsearch -exact $captionList {SCR ACC Rx} ]
    set rxRscnIndex		            [ lsearch -exact $captionList {RSCN Rx} ]
    set txRscnAccIndex 	          	[ lsearch -exact $captionList {RSCN ACC Tx} ]
    set txPrliIndex	    			[ lsearch -exact $captionList {PRLI Tx} ]
    set rxPrliReqIndex             	[ lsearch -exact $captionList {PRLI Requests Rx} ]
    set rxPrliLsAccIndex            [ lsearch -exact $captionList {PRLI LS_ACC Rx} ]
    set rxPrliLsRjtIndex          	[ lsearch -exact $captionList {PRLI LS_RJT Rx} ]
    
Deputs "handle:$handle"

    set rangeName [ ixNet getA $handle/fcClientFlogiRange -name ]
Deputs "range name:$rangeName"

    set ret "Status : true\nLog : \n"
    
	set pageCount [ ixNet getA $view/page -totalPages ]
	
	for { set index 1 } { $index <= $pageCount } { incr index } {

		ixNet setA $view/page -currentPage $index
		ixNet commit 
		
		set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
		
		foreach row $stats {

			set ret "$ret\{\n"
			
			eval {set row} $row
Deputs "row:$row"

			set statsItem   "world_wide_node_name"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "max_rx_size"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "world_wide_port_name"
			set statsVal    [ lindex $row $portNameIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "state"
			set statsVal    [ lindex $row $intStatusIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "sub_state"
			set statsVal    [ lindex $row $failureReasonIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "fc_id"
			set statsVal    [ lindex $row $sourceIdIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "rx_accept_count"
			set statsVal    [ lindex $row $rxFlogiLsAccIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "rx_reject_count"
			set statsVal    [ lindex $row $rxFlogiLsRjtIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_fdisc_count"
			set statsVal    [ lindex $row $txFdiscIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "tx_flogi_count"
			set statsVal    [ lindex $row $txFlogiIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_logo_count"
			set statsVal    [ lindex $row $txFLogoIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "tx_plogi_count"
			set statsVal    [ lindex $row $txPlogiIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "tx_state_change_register_count"
			set statsVal    [ lindex $row $txNsRegIndex ]
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			

			
			set ret "$ret\}\n"

		}
			
Deputs "ret:$ret"
	}

	ixNet remove $view
	ixNet commit
    return $ret	
	
}
body FcFPortHost::CreateFcFPerSessionView {} {
	set tag "body FcFPortHost::CreateFcPerSessionView [info script]"
Deputs "----- TAG: $tag -----"
	set root [ixNet getRoot]
	set customView          [ ixNet add $root/statistics view ]
	ixNet setM  $customView -caption "fcfPerSessionView" -type layer23ProtocolStack -visible true
	ixNet commit
	set customView          [ ixNet remapIds $customView ]
Deputs "view:$customView"
	set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
Deputs "available filter:$availableFilter"
	set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
Deputs "filter:$filter"
Deputs "handle:$handle"
	set fcRange $handle/fcClientFlogiRange
Deputs "fcRange:$fcRange"
	set rangeName [ ixNet getA $fcRange -name ]
Deputs "range name:$rangeName"
	foreach afil $availableFilter {
Deputs "$afil"
		if { [ regexp $rangeName $afil ] } {
			set stackFilter $afil
		}
	}
Deputs "stack filter:$stackFilter"
	ixNet setM $filter -drilldownType perSession -protocolStackFilterId $stackFilter
	ixNet commit
	set srtStat [lindex [ixNet getF $customView statistic -caption {Session Name}] 0]
	ixNet setA $filter -sortAscending true -sortingStatistic $srtStat
	ixNet commit
	foreach s [ixNet getL $customView statistic] {
		ixNet setA $s -enabled true
	}
	ixNet setA $customView -enabled true
	ixNet commit
	return $customView
}

proc waitPortReset { hPort sec } {
	set tag "body ::waitPortReset [info script]"
	Deputs "----- TAG: $tag -----"

Deputs "hPort:$hPort"
	set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "Port connect state:$connectionInfo"
	set timeout $sec
	while { $connectionInfo == "" } {
Deputs "Port connect state:$connectionInfo"
		incr timeout -1
		after 1000
		if { !$timeout } {
			break
		}
		set connectionInfo [ ixNet getA $hPort -connectionInfo ]
	}
}






