
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class PimSession {
	inherit RouterEmulationObject
	public variable hInt
	
	constructor { port } {
		global errNumber
		
		set tag "body PimSession::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set portObj [ GetObject $port ]
		if {[ catch {
			set hPort [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in rip ctor"
		}
		
		if {[ixNet getA $hPort/protocols/pimsm -enabled]} {
			
		} else {
			ixNet setM $hPort/protocols/pimsm -enabled True
		     ixNet commit
		}	   
		
		#-- add pimsm protocol
		set handle [ ixNet add $hPort/protocols/pimsm router ]
	     ixNet setA $handle -Enabled True
	     ixNet commit
	     set handle [ ixNet remapIds $handle ]
	     ixNet setA $handle -name $this
	    
	     set rb_interface [ ixNet getL $hPort interface ]
	     array set interface [ list ]
	    
	     generate_interface
	}
	
	method config { args } {}
	method get_status {} {}
	method get_stats {} {}
	method send_bsm {} {}
	method generate_interface { args } {
		set tag "body RipSession::generate_interface [info script]"
Deputs "----- TAG: $tag -----"
		foreach int $rb_interface {
			set hInt [ ixNet add $handle interface ]
			ixNet setM $hInt -interfaces $int -enabled True
			ixNet commit
			set interface($int) $hInt	
		}
	}	
}

class PimGroup {
	
	inherit NetObject
	public variable hJoinPrune
	public variable hSource
	public variable rb_interface
	
	constructor { router } {
		global errNumber
	    
		set tag "body PimGroup::ctor [info script]"
Deputs "----- TAG: $tag -----"
		
		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in PimGroup ctor"
		}
		
		set rb_interface [ ixNet getL $hRouter interface ]
		
		foreach int $rb_interface {
			set hJoinPrune [ ixNet add $rb_interface joinPrune ]
			ixNet commit
		}
		
		foreach int $rb_interface {
			set hSource [ ixNet add $rb_interface source ]
			ixNet commit
		}


	}
	
	method config { args } {}
	method send_join {} {}
	method send_prune {} {}

}


body PimSession::config { args } {
	global errorInfo
	global errNumber
	
	set bi_dir_option_set NO
	set Bootstrap_message_interval 60
	set bsr_priority 1
	set dr_priority 1
	set enable_bsr NO
	set gen_id_mode FIXED
	set hello_hold_time 105
	set hello_interval 30
	set join_prune_hold_time 60
	set join_prune_interval 60
	set ip_version Ipv4
	
	set tag "body PimSession::config [info script]"
Deputs "----- TAG: $tag -----"
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-router_id {
				set router_id $value
			}
			-bi_dir_option_set {
				set value [string toupper $value]
				set bi_dir_option_set $value
			}
			-bootstrap_message_interval {			
				set bootstrap_message_interval $value
			}
			-bsr_priority {
				set bsr_priority $value
			}
			-dr_priority {
				set dr_priority $value
			}
			-enable_bsr {
				set value [string toupper $value]
				set enable_bsr $value
			}
			-gen_id_mode {
				set value [string toupper $value]
				set gen_id_mode $value
			}
			-hello_hold_time {
				set hello_hold_time $value
			}
			-hello_interval {
				set hello_interval $value
			}
			-join_prune_hold_time {
				set join_prune_hold_time $value
			}
			-join_prune_interval {
				set join_prune_interval $value
			}
			-ip_version {
				set value [string tolower $value]
				set ip_version $value
			}
			
			# Can not find in ixNetwork
			-pim_mode {
				set pim_mode $value
			}
			-upstream_neighbor {
				set upstream_neighbor $value
			}
			
		}
	}
	
	ixNet setM $handle -enabled True
	
	if { [ info exists router_id ] } {
		ixNet setA $handle -routerId $router_id
		ixNet commit
	}
	if { [ info exists bi_dir_option_set ] } {
		switch $bi_dir_option_set {
			NO {
				set bi_dir_option_set False
			}
			YES {
				set bi_dir_option_set True
			}
		}
		foreach int $rb_interface {
			ixNet setA $interface($int) -sendBiDirCapableOption $bi_dir_option_set
		}
		
	}	
	if { [ info exists bootstrap_message_interval ] } {
		foreach int $rb_interface {
			set aa [ixNet getA $interface($int) -bootstrapEnable ]
			if {[ixNet getA $interface($int) -bootstrapEnable ]} {
			
			} else {
				ixNet setA $interface($int) -bootstrapEnable True
				
			}
			ixNet setA $interface($int) -bootstrapInterval $bootstrap_message_interval
			
		}
		
	}
	if { [ info exists bsr_priority ] } {
		foreach int $rb_interface {
			if {[ixNet getA $interface($int) -bootstrapEnable ]} {
				
			} else {
				ixNet setA $interface($int) -bootstrapEnable true
			}
			ixNet setA $interface($int) -bootstrapPriority $bsr_priority
		}

	}
	if { [ info exists dr_priority ] } {
		ixNet setA $handle -drPriority $dr_priority
	}
	if { [ info exists enable_bsr ] } {
		switch $enable_bsr {						
			NO {
				set enable_bsr False
			}
			YES {
				set enable_bsr True				
			}			
		}
		foreach int $rb_interface {
			ixNet setA $interface($int) -bootstrapEnable $enable_bsr			
		}
		ixNet commit
	}
	if { [ info exists gen_id_mode ] } {
		switch $gen_id_mode {						
			FIXED {
				set gen_id_mode constant				
			}
			INCREMENT {
				set gen_id_mode incremental			
			}
			RANDOM {
				set gen_id_mode random				
			}			
		}
		foreach int $rb_interface {
			ixNet setA $interface($int) -generationIdMode $gen_id_mode
		}
		ixNet commit
	}
	
	if { [ info exists hello_hold_time ] } {
		foreach int $rb_interface {
			ixNet setA $interface($int) -helloHoldTime $hello_hold_time
		}
		ixNet commit
	}
	
	if { [ info exists hello_interval ] } {
		foreach int $rb_interface {
			ixNet setA $interface($int) -helloInterval $hello_interval
		}
	
	}
	if { [ info exists join_prune_hold_time ] } {
		ixNet setA $handle -joinPruneHoldTime $join_prune_hold_time
		
	}
	if { [ info exists join_prune_interval ] } {
		ixNet setA $handle -joinPruneInterval $join_prune_interval
		
	}
	
	if { [ info exists ip_version ] } {
		switch $ip_version {
			ipv4 {
				set ip_version ipv4
			}
			ipv6 {
				set ip_version ipv6
			}
		}
		foreach int $rb_interface {
			ixNet setA $interface($int) -addressFamily $ip_version
		}
		
	}
	
	if { [ info exists upstream_neighbor ] } {
			foreach int $rb_interface {
				ixNet setM $interface($int) \
				-autoPickUpstreamNeighbor False \
				-upstreamNeighbor $upstream_neighbor
			}
			
		}
	
	ixNet commit
	
	# Workaround for hello_hold_time setting
	if { [ info exists hello_hold_time ] } {
		foreach int $rb_interface {
			ixNet setA $interface($int) -helloHoldTime $hello_hold_time
		}
		ixNet commit
	}
	# Workaround for join_prune_hold_time
	if { [ info exists join_prune_hold_time ] } {
		ixNet setA $handle -joinPruneHoldTime $join_prune_hold_time
		ixNet commit
	}
	return [GetStandardReturnHeader]
}

body PimSession::get_status {} {
	set tag "body PimSession::get_status [info script]"
Deputs "----- TAG: $tag -----"
	
	set root [ixNet getRoot]
Deputs "root $root"
	
	set view {::ixNet::OBJ-/statistics/view:"PIMSM Aggregated Statistics"}
Deputs "view $view"	

	after 5000
	set captionList [ ixNet getA $view/page -columnCaptions ]
Deputs "captionList $captionList"	 
	set name_index [ lsearch -exact $captionList {Stat Name} ]
	set rtrsconf_index [ lsearch -exact $captionList {Rtrs. Configured} ]
	set rtrsrun_index [ lsearch -exact $captionList {Rtrs. Running} ]
	set nbrslear_index [ lsearch -exact $captionList {Nbrs. Learnt} ]
	set hellotx_index [ lsearch -exact $captionList {Hellos Tx} ]

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
		set rtrsconf [ lindex $row $rtrsconf_index ]
		set rtrsrun [ lindex $row $rtrsrun_index ]
		set nbrslear [ lindex $row $nbrslear_index ]
		set hellotx [ lindex $row $hellotx_index ]

		if { $rtrsconf != "" && $rtrsconf == 0 } {
			set status "NO_STATE"
		}
		if { $rtrsrun != "" && $rtrsrun == 0 } {
			set status "STOPPED"
		} else {
			set status "STARTED"
		}
		if { $nbrslear != "" && $nbrslear != 0 } {
			set status "NEIGHBOR"
		}
		if { $hellotx != "" && $hellotx != 0} {
			set status "HELLO"
		}
#		if {} {
#			set status "DR"
#		}
	}	
	
	set ret [ GetStandardReturnHeader ]
	set ret $ret[ GetStandardReturnBody "status" $status ]
	return $ret
}

body PimSession::get_stats {} {
	set tag "body PimSession::get_stats [info script]"
Deputs "----- TAG: $tag -----"
	
	set root [ixNet getRoot]
Deputs "root $root"
	set view {::ixNet::OBJ-/statistics/view:"PIMSM Aggregated Statistics"}

	after 5000
	set captionList [ ixNet getA $view/page -columnCaptions ]
Deputs "captionList $captionList"	 
	
	set name_index [ lsearch -exact $captionList {Stat Name} ]
	set nbrslear_index [ lsearch -exact $captionList {Nbrs. Learnt} ]
	set bspmsgrx_index [ lsearch -exact $captionList {Bootstrap Msg Rx} ]
	set hellorx_index [ lsearch -exact $captionList {Hellos Rx} ]
	set regrx_index [ lsearch -exact $captionList {Register Rx} ]
	set regstoprx_index [ lsearch -exact $captionList {RegisterStop Rx} ]
	set bspmsgtx_index [ lsearch -exact $captionList {Bootstrap Msg Tx} ]
	set hellotx_index [ lsearch -exact $captionList {Hellos Tx} ]
	set regtx_index [ lsearch -exact $captionList {Register Tx} ]
	set regstoptx_index [ lsearch -exact $captionList {RegisterStop Tx} ]
	
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
		set statsItem   "neighbor_count"
		set statsVal    [ lindex $row $nbrslear_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_bootstrap_count"
		set statsVal    [ lindex $row $bspmsgrx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_hello_count"
		set statsVal    [ lindex $row $hellorx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_register_count"
	     set statsVal    [ lindex $row $regrx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_register_stop_count"
		set statsVal    [ lindex $row $regstoprx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_bootstrap_count"
	     set statsVal    [ lindex $row $bspmsgtx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_hello_count"
	     set statsVal    [ lindex $row $hellotx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_register_count"
	     set statsVal    [ lindex $row $regtx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	     set statsItem   "tx_register_stop_count"
	     set statsVal    [ lindex $row $regstoptx_index ]
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
# Can not find in ixNet,so set N/A		
		set statsItem   "rx_assert_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_cand_rp_advert_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_group_rp_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_group_sg_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_group_sgrpt_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_group_starg_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "rx_join_prune_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_assert_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_cand_rp_advert_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_group_rp_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_group_sg_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_group_sgrpt_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_group_starg_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
		set statsItem   "tx_join_prune_count"
		set statsVal    "N/A"
Deputs "stats val:$statsVal"
		set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	}

Deputs "ret:$ret"
	
	return $ret
	
}

body PimSession::send_bsm {} {
	global errorInfo
	global errNumber
	
	set tag "body PimSession::send_bsm [info script]"
Deputs "----- TAG: $tag -----"
	
	foreach int $rb_interface {
		ixNet setA $interface($int) -supportUnicastBootstrap True
	}
	ixNet commit
	return [GetStandardReturnHeader]
}

body PimGroup::config { args } {
	global errorInfo
	global errNumber
	
	set enabling_pruning no
	set group_type starg
	set tag "body PimGroup::config [info script]"
Deputs "----- TAG: $tag -----"

	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-enabling_pruning {
				set value [string toupper $value]
				set enabling_pruning $value
			}
			-group_type {
				set value [string toupper $value]
				set group_type $value
			}
			-rp_ip_addr {			
				set rp_ip_addr $value
			}
			-group {
				set group $value
			}
		}
	}
	
	if { [ info exists enabling_pruning ] } {
		switch $enabling_pruning {						
			NO {
				set enabling_pruning False
			}
			YES {
				set enabling_pruning True				
			}			
		}

		foreach int $rb_interface {
			ixNet setA $hJoinPrune -enabled $enabling_pruning	
		}
	}
	
	if { [ info exists group_type ] } {
		switch $group_type {						
			STARG {
				set group_type g
			}
			SG {
				set group_type sg				
			}	
			STARSTARRP {
				set group_type rp				
			}
		}

		foreach int $rb_interface {
			ixNet setA $hJoinPrune -groupRange $group_type	
		}
	}
	
	if { [ info exists rp_ip_addr ] } {
		foreach int $rb_interface {
			ixNet setA $hJoinPrune -rpAddress $rp_ip_addr
			puts "hJoinPrune is: $hJoinPrune"
		}
			
	}
	
	if { [ info exists group ] } {
		set group [ GetObject $group ]
		$group configure -handle $hSource
		
		if { $group == ""} {
			return [GetErrorReturnHeader "No valid object found...-group $group"]
		}
		
		ixNet setA $hSource -enabled True
		
		set source_ip 		[ $group cget -source_ip ]
		set source_num 		[ $group cget -source_num ]
		set group_ip		[ $group cget -group_ip ]
		set group_num	[ $group cget -group_num ]
		set group_modbit	[ $group cget -group_modbit ]
		
		ixNet setM $hSource \
		-enabled True \
		-sourceAddress $source_ip \
		-sourceCount $source_num \
		-groupAddress $group_ip \
		-groupCount $group_num \
		-groupMaskWidth $group_modbit
	} else {
		return [GetErrorReturnHeader "Madatory parameter needed...-group"]
	}
	
	ixNet commit
	return [GetStandardReturnHeader]
}

body PimGroup::send_join {} {
	global errorInfo
	global errNumber
	
	set tag "body PimGroup::send_join [info script]"
Deputs "----- TAG: $tag -----"
	
	foreach int $rb_interface {
		ixNet setA $hJoinPrune -enabled True	
	}
	ixNet commit
	return [GetStandardReturnHeader]
}

body PimGroup::send_prune {} {
	global errorInfo
	global errNumber
	
	set tag "body PimGroup::send_prune [info script]"
Deputs "----- TAG: $tag -----"
	foreach int $rb_interface {
		ixNet setA $hJoinPrune -enabled False	
	}
	ixNet commit
	return [GetStandardReturnHeader]
}