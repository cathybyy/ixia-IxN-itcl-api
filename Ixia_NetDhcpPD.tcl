# Copyright (c) Ixia technologies 201-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class DhcpPDHost {
    inherit ProtocolStackObject
    
    #public variable type
	#public variable stack
    public variable optionSet
    
    public variable rangeStats
    public variable hostCnt
    public variable hPppox
	public variable hDhcp
	public variable hDhcpv6PdClient
    public variable requestDuration
	
	public variable statsView
	
    constructor { port { onStack null } } { chain $port $onStack } {}
    method reborn { { onStack null } } {
	    set tag "body DhcpPDHost::reborn [info script]"
	    Deputs "----- TAG: $tag -----"
		    
	    array set rangeStats [list]
	    if { $onStack == "null" } {
			chain 
		} else {
			Deputs "based on existing stack:$onStack"		
			set hDhcp $onStack
		}
	
    }
	
    method config { args } {}
    method request {} {}
    method release {} {}
    method renew {} {}
    method resume {} {}
    method pause {} {}
    method rebind {} {}
    method set_dhcp_msg_option { args } {}
    method get_summary_stats {} {}
    method get_detailed_stats {} {}
    method set_igmp_over_dhcp { args } {}
    method unset_igmp_over_dhcp {} {}
    method wait_request_complete { args } {}
    method wait_release_complete { args } {}
    method get_port_summary_stats { view } {}
	
    method CreateDhcpPerSessionView {} {
        set tag "body DhcpPDHost::CreateDhcpPerSessionView [info script]"
		Deputs "----- TAG: $tag -----"
        set root [ixNet getRoot]
        set customView          [ ixNet add $root/statistics view ]
        ixNet setM  $customView -caption "dhcpPerSessionView" -type layer23ProtocolStack -visible true
        ixNet commit
        set customView          [ ixNet remapIds $customView ]
		Deputs "view:$customView"
        set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
		Deputs "available filter:$availableFilter"
        set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
		Deputs "filter:$filter"
		Deputs "handle:$handle"
        set dhcpRange [ixNet getList $handle dhcpRange]
		Deputs "dhcpRange:$dhcpRange"
        set rangeName [ ixNet getA $dhcpRange -name ]
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
    
    
    method CreateDhcpPerRangeView {} {
        set tag "body DhcpPDHost::CreateDhcpPerRangeView [info script]"
		Deputs "----- TAG: $tag -----"
        set root [ixNet getRoot]
        set customView          [ ixNet add $root/statistics view ]
        ixNet setM  $customView -caption "dhcpPerRangeView" -type layer23ProtocolStack -visible true
        ixNet commit
        set customView          [ ixNet remapIds $customView ]
		Deputs "view:customView"
        set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
		Deputs "available filter:$availableFilter"
        set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
		Deputs "filter:$filter"
		Deputs "handle:$handle"
        set dhcpRange [ixNet getList $handle dhcpHostsRange]
		Deputs "dhcpRange:$dhcpRange"
        set rangeName [ ixNet getA $dhcpRange -name ]
		Deputs "range name:$rangeName"
        foreach afil $availableFilter {
			Deputs "$afil"
            if { [ regexp $rangeName $afil ] } {
                set stackFilter $afil
            }
        }
		Deputs "stack filter:$stackFilter"
        ixNet setM $filter -drilldownType perRange -protocolStackFilterId $stackFilter
        ixNet commit
        set srtStat [lindex [ixNet getF $customView statistic -caption {Range Name}] 0]
		Deputs "sorting stats:$srtStat"
        ixNet setA $filter -sortAscending true -sortingStatistic $srtStat
        ixNet commit
		Deputs "enable view..."
        foreach s [ixNet getL $customView statistic] {
            ixNet setA $s -enabled true
        }
        ixNet setA $customView -enabled true
        ixNet commit
        return $customView
    }    
}
body DhcpPDHost::config { args } {

    global errorInfo
    global errNumber
    set tag "body DhcpPDHost::config [info script]"
	Deputs "----- TAG: $tag -----"
	#disable the interface

    eval { chain } $args
	
	#param collection
	Deputs "Args:$args "
	set hOuterVlan [lindex [ixNet getL $handle/vlanRange vlanIdInfo] 0]
	set hInnerVlan [lindex [ixNet getL $handle/vlanRange vlanIdInfo] 1]
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key { 
            -count {
                if { [ string is integer $value ] && ( $value <= 65535 ) } {
                    set count $value
					set hostCnt $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
		  -outer_vlan_enable {
			set outer_vlan_enable $value
			ixNet setA $hOuterVlan -enabled $value
		  }
		  -outer_vlan_id {
			set outer_vlan_enable $value
			ixNet setA $hOuterVlan -firstId $value
		  }
		  -oute_vlan_step {
			set outer_vlan_enable $value
			ixNet setA $hOuterVlan -incrementStep $value
		  }
		  -outer_vlan_num {
			set outer_vlan_enable $value
			ixNet setA $hOuterVlan -uniqueCount $value
		  }
		  -outer_vlan_priority {
			set outer_vlan_enable $value
			ixNet setA $hOuterVlan -priority $value
		  }
		  -outer_vlan_cfi {
			set outer_vlan_enable $value
		  }
		  -inner_vlan_enable {
			set inner_vlan_enable $value
			ixNet setA $hInnerVlan -enabled $value
		  }
		  -inner_vlan_id {
			set inner_vlan_enable $value
			ixNet setA $hInnerVlan -firstId $value
		  }
		  -inner_vlan_step {
			set inner_vlan_enable $value
			ixNet setA $hInnerVlan -incrementStep $value
		  }
		  -inner_vlan_num {
			set inner_vlan_enable $value
			ixNet setA $hInnerVlan -uniqueCount $value
		  }
		  -inner_vlan_priority {
			set inner_vlan_enable $value
			ixNet setA $hInnerVlan -priority $value
		  }
		  -inner_vlan_cfi {
			set inner_vlan_enable $value
		  }
        }
    }
	set range $handle
    if { [ info exists count ] } {
        ixNet setA $range/dhcpHostsRange -count $count
    }
    ixNet commit
    return [GetStandardReturnHeader]
}
body DhcpPDHost::request {} {
    set tag "body DhcpPDHost::request [info script]"
	Deputs "----- TAG: $tag -----"
	Deputs "handle :$handle"
	# after 3000
	set requestTimestamp [ clock seconds ]
    if { [ catch {
    	ixNet exec start $handle
    } err ] } {
		Deputs "err:$err"
		after 3000
		set requestTimestamp [ clock seconds ]
		ixNet exec start $handle
    }
	set completeTimestamp [ clock seconds ]
	set requestDuration [ expr $completeTimestamp - $requestTimestamp ]
	#-- make sure the stats will be updated
    return [GetStandardReturnHeader]
}
body DhcpPDHost::release {} {
    set tag "body DhcpPDHost::release [info script]"
	Deputs "----- TAG: $tag -----"
    ixNet exec stop $handle
	#ixNet exec dhcpClientClearStats $hDhcp
	ixNet commit
    return [GetStandardReturnHeader]
}
body DhcpPDHost::renew {} {
    set tag "body DhcpPDHost::renew [info script]"
	Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpv6PdClientRenew $hDhcpv6PdClient
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDHost::resume {} {
    set tag "body DhcpPDHost::resume [info script]"
	Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpHostsResume $handle
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDHost::pause {} {
    set tag "body DhcpPDHost::pause [info script]"
	Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpHostsPause $handle
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDHost::rebind {} {
    set tag "body DhcpPDHost::rebind [info script]"
	Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpv6PdClientRebind $hDhcpv6PdClient
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDHost::wait_request_complete { args } {
    set tag "body DhcpPDHost::wait_request_complete [info script]"
	Deputs "----- TAG: $tag -----"

	set timeout 300

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -timeout {
				set trans [ TimeTrans $value ]
                if { [ string is integer $trans ] } {
                    set timeout $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }

        }
    }
	
	set startClick [ clock seconds ]
	
	while { 1 } {
		set click [ clock seconds ]
		if { [ expr $click - $startClick ] >= $timeout } {
			return [ GetErrorReturnHeader "timeout" ]
		}
		
		set root [ixNet getRoot]
		set view $statsView
		# set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
		Deputs "view:$view"
		set captionList             [ ixNet getA $view/page -columnCaptions ]
		Deputs "caption list:$captionList"
		set port_name				[ lsearch -exact $captionList {Stat Name} ]
		set initStatsIndex          [ lsearch -exact $captionList {Sessions Initiated} ]
		set succStatsIndex          [ lsearch -exact $captionList {Sessions Succeeded} ]
		set ackRcvIndex          	[ lsearch -exact $captionList {ACKs Received} ]
		
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

			set initStats    [ lindex $row $initStatsIndex ]
			set succStats    [ lindex $row $succStatsIndex ]
			set ackRcvStats  [ lindex $row $ackRcvIndex ]
			
			break
		}

		Deputs "initStats:$initStats == succStats:$succStats == ackRcvStats:$ackRcvStats ?"		
		if { $succStats != "" && $succStats >= $initStats && $initStats > 0 && $ackRcvStats >= $succStats } {
			break	
		}
		
		after 1000
	}
	
	return [GetStandardReturnHeader]
}
body DhcpPDHost::wait_release_complete { args } {
    set tag "body DhcpPDHost::wait_release_complete [info script]"
	Deputs "----- TAG: $tag -----"

	set timeout 10

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-timeout {
				set timeout $value
			}
		}
    }

	set timerStart [ clock second ]

    set root [ixNet getRoot]
    set view [ lindex [ ixNet getF $root/statistics view -caption "dhcpPerSessionView" ] 0 ]
    if { $view == "" } {
		if { [ catch {
			set view [ CreateDhcpPerSessionView ]
		} ] } {
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }
    set captionList         [ ixNet getA $view/page -columnCaptions ]
    set ipIndex             [ lsearch -exact $captionList {IP Address} ]

	set pageCount [ ixNet getA $view/page -totalPages ]
	
	while { [ expr [ clock second ] - $timeStart ] > $timeout } {
		for { set index 1 } { $index <= $pageCount } { incr index } {

			ixNet setA $view/page -currentPage $index
			ixNet commit 
			
			set stats [ ixNet getA $view/page -rowValues ]
			Deputs "stats:$stats"
			
			foreach row $stats {

				eval {set row} $row
				
				set statsItem   "ipv4_addr"
				set statsVal    [ lindex $row $ipIndex ]
				Deputs "stats val:$statsVal"
				if { $statsVal != "0.0.0.0" } {
					ixNet remove $view
					ixNet commit
					return [ GetErrorReturnHeader "" ]
				}
			}
				
			Deputs "ret:$ret"
		}
		
		after 1000
		ixNet exec refresh $view
	}
	
	ixNet remove $view
	ixNet commit
    return  [ GetStandardReturnHeader ]
}

body DhcpPDHost::get_summary_stats {} {
    set tag "body DhcpPDHost::get_summary_stats [info script]"
	Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
	Deputs "root $root"
    #set view [ lindex [ ixNet getF $root/statistics view -caption "dhcpPerRangeView" ] 0 ]
	set view {::ixNet::OBJ-/statistics/view:"DHCPv6Client"}
    if { $view == "" } {
		if { [ catch {
			set view [ CreateDhcpPerRangeView ]
		} ] } {
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }
    
    set captionList         [ ixNet getA $view/page -columnCaptions ]
    set rangeIndex          [ lsearch -exact $captionList {Range Name} ]
	Deputs "index:$rangeIndex"
	set solicitsSentIndex   [ lsearch -exact $captionList {Solicits Sent} ]
	Deputs "index:$solicitsSentIndex"
	set repliesRecIndex       [ lsearch -exact $captionList {Replies Received} ]
	Deputs "index:$repliesRecIndex"
    set reqSentIndex        [ lsearch -exact $captionList {Requests Sent} ]
	Deputs "index:$reqSentIndex"
	set advRecIndex       [ lsearch -exact $captionList {Advertisements Received} ]
	Deputs "index:$advRecIndex"
	set advIgnoreIndex       [ lsearch -exact $captionList {Advertisements Ignored} ]
	Deputs "index:$advIgnoreIndex"
    set releaseSentIndex    [ lsearch -exact $captionList {Releases Sent} ]
	Deputs "index:$releaseSentIndex"
    set renewSentIndex    [ lsearch -exact $captionList {Renews Sent} ]
	Deputs "index:$renewSentIndex"
    set retriedSentIndex    [ lsearch -exact $captionList {Rebinds Sent} ]
	Deputs "index:$retriedSentIndex"
		
	Deputs "handle:$handle"
    set dhcpRange [ixNet getList $handle dhcpHostsRange]
	Deputs "dhcpRange:$dhcpRange"
    set rangeName [ ixNet getA $dhcpRange -name ]
	Deputs "range name:$rangeName"

    set stats [ ixNet getA $view/page -rowValues ]
	Deputs "stats:$stats"
    set rangeFound 0
    foreach row $stats {
        eval {set row} $row
		Deputs "row:$row"
		Deputs "range index:$rangeIndex"
        set rowRangeName [ lindex $row $rangeIndex ]
		Deputs "row range name:$rowRangeName"
        if { [ regexp $rowRangeName $rangeName ] } {
            set rangeFound 1
            break
        }
    }
    
    set ret "Status : true\nLog : \n"
    
    if { $rangeFound } {
        set statsItem   "tx_solicit_count "
        set statsVal    [ lindex $row $solicitsSentIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_request_count"
		set statsVal    [ lindex $row $reqSentIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(requestSent) $statsVal
		
        set statsItem   "tx_confirm_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "tx_info_request_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "tx_rebind_count "
        set statsVal    [ lindex $row $retriedSentIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "tx_release_count"
		set statsVal    [ lindex $row $releaseSentIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(releaseSent) $statsVal

        set statsItem   "tx_renew_count"
		set statsVal    [ lindex $row $renewSentIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(releaseSent) $statsVal

        set statsItem   "rx_advertise_count "
		set statsVal    [ lindex $row $advRecIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(releaseSent) $statsVal	

        set statsItem   "rx_reconfigure_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "rx_reply_count"
		set statsVal    [ lindex $row $repliesRecIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(releaseSent) $statsVal        
    }

	Deputs "ret:$ret"

    return $ret    
}
body DhcpPDHost::get_detailed_stats {} {
    set tag "body DhcpPDHost::get_detailed_stats [info script]"
	Deputs "----- TAG: $tag -----"
	
    set root [ixNet getRoot]
    set view [ lindex [ ixNet getF $root/statistics view -caption "dhcpPerSessionView" ] 0 ]
	Deputs "view:$view"
    if { $view == "" } {
		if { [ catch {
			set view [ CreateDhcpPerSessionView ]
		} ] } {
			return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
		}
    }

    set captionList         [ ixNet getA $view/page -columnCaptions ]
    set rangeIndex          [ lsearch -exact $captionList {Session Name} ]
    set discoverSentIndex   [ lsearch -exact $captionList {Discovers Sent} ]
    set offerRecIndex       [ lsearch -exact $captionList {Offers Received} ]
    set reqSentIndex        [ lsearch -exact $captionList {Requests Sent} ]
    set ackRecIndex         [ lsearch -exact $captionList {ACKs Received} ]
    set nackRecIndex        [ lsearch -exact $captionList {NACKs Received} ]
    set releaseSentIndex    [ lsearch -exact $captionList {Release Sent} ]
    set declineSentIndex    [ lsearch -exact $captionList {Declines Sent} ]
    set ipIndex             [ lsearch -exact $captionList {IP Address} ]
    set gwIndex             [ lsearch -exact $captionList {Gateway Address} ]
    set leaseIndex          [ lsearch -exact $captionList {Lease Time} ]
    
	Deputs "handle:$handle"
    set dhcpRange [ixNet getList $handle dhcpRange]
	Deputs "dhcpRange:$dhcpRange"
    set rangeName [ ixNet getA $dhcpRange -name ]
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

			set statsItem   "disc_resp_time"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

			set statsItem   "status_code"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "host_state"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
						
			set statsItem   "ipv6_addr"
			set statsVal    [ lindex $row $ipIndex ]
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "lease_left"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "lease_rx"
			set statsVal    [ lindex $row $leaseIndex ]
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "mac_addr"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]   
			
			set statsItem   "request_resp_time"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]   
			
			set statsItem   "prefix_len"
			set statsVal    "NA"
			Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]   
			
			set statsItem   "vlan_id"
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
body DhcpPDHost::set_dhcp_msg_option { args } {
    global errorInfo
    global errNumber
    set tag "body DhcpPDHost::set_dhcp_msg_option [info script]"
	Deputs "----- TAG: $tag -----"

	set EMsgType [ list discover request solicit ]

	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -msg_type {
		set value [ string tolower $value ]
                if { [ lsearch -exact $EMsgType $value ] >= 0 } {
                    
                    set msg_type $value
                } else {
                	return [GetErrorReturnHeader "Unsupported functionality."]
                }
            }
            -option_type {
                if { [ string is integer $value ] && ( $value >= 1 ) && ( $value <= 65535 ) } {
                    set option_type $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -enable_hex_value {
                if { $value == "true" } {
            	    set optionType hexadecimal
                }
            }
            -payload {
            	set payload $value
            }
        }
    }
	
	set flagTypeDefined 0
	foreach tlv	[ ixNet getL $optionSet dhcpOptionTlv ] {
		if { [ ixNet getA $tlv -code ] == $option_type } {
			set flagTypeDefined 1
		}
	}
	
	if { ( $option_type == "53" ) || ( $option_type == "61" ) || ( $option_type == "57" ) } {
		return [ GetErrorReturnHeader "Not customized option:$option_type, IXIA has already added this option on defaultly."]
	}
	
	if { $option_type == "51" } {
		set global [ ixNet getL $root/globals/protocolStack dhcpGlobals ]
		ixNet setA $global -dhcp4AddrLeaseTime $payload
		ixNet commit
		set flagTypeDefined 1
	}
	Deputs "option type 51"	
	
	if { $option_type == "55" } {
		set payloadLen [ string length $payload ]
		set requestList ""
		for { set index 0 } { $index < $payloadLen } { incr index 2 } {
			Deputs "index:$index"
			Deputs "requestList :$requestList"
			set requestHex [ string range $payload $index [ expr $index + 1 ] ]
			Deputs "requestHex:$requestHex"
			if { [ string tolower $requestHex ] == "0x" } {
				continue
			}
			set requestInt [ format %i 0x$requestHex ]
			Deputs "requestInt:$requestInt"
			if { $requestList != "" } {
				set requestList "${requestList}\;${requestInt}"
			} else {
				set requestList ${requestList}${requestInt}
			}
		}
		Deputs "requestList final:$requestList"
		ixNet setA $handle/dhcpRange -dhcp4ParamRequestList $requestList
		ixNet commit
		set flagTypeDefined 1
	}
	Deputs "option type 55"	

	if { $option_type == "82" } {
			set payloadLen [ string length $payload ]
	Deputs "payloadLen is: $payloadLen"
			
			if {[string range $payload 0 1] == 01} {
				set circuitLenHex [string range $payload 2 3]
				set circuitLenInt [expr [ format %i 0x$circuitLenHex ]*2 ] 
	Deputs "circuitLenInt is: $circuitLenInt"
				set circuitLenTotal [expr 4 + $circuitLenInt ]
	Deputs "circuitLenTotal is: $circuitLenTotal"
				
				if {$circuitLenTotal == $payloadLen} {
					set circuitValue 0x[ string range $payload 4 end ]
	Deputs "circuitValue is: $circuitValue"
					
					ixNet setM $handle/dhcpRange \
								-useTrustedNetworkElement True \
								-relayUseCircuitId True \
								-relayCircuitId $circuitValue
				} elseif {$circuitLenTotal < $payloadLen && [string range $payload [expr $circuitLenInt + 4]  [expr $circuitLenInt + 5]] == 02} {
					set circuitValue 0x[ string range $payload 4 [expr $circuitLenInt + 3] ]
	Deputs "circuitValue is: $circuitValue"
					
					set remoteLenHex [string range $payload [expr $circuitLenInt + 6]  [expr $circuitLenInt + 7]]
	Deputs "remoteLenHex is: $remoteLenHex"
					set remoteLenInt [expr [ format %i 0x$remoteLenHex ]*2 ] 
	Deputs "remoteLenInt is: $remoteLenInt"
					set remoteValue 0x[ string range $payload [expr $circuitLenInt + 8] [expr $circuitLenInt + $remoteLenInt + 7]]
	Deputs "remoteValue is: $remoteValue"
					
					ixNet setM $handle/dhcpRange \
								-useTrustedNetworkElement True \
								-relayUseCircuitId True \
								-relayCircuitId $circuitValue \
								-relayUseRemoteId True \
								-relayRemoteId $remoteValue
				} else {
					error "error option82 format input, please refer to RFC3046"
				}
			
			} elseif {[string range $payload 0 1] == 02} {
				set remoteLenInt [string range $payload 2 3]
				set remoteLenInt [expr [ format %i 0x$remoteLenInt ]*2 ] 
	Deputs "remoteLenInt is: $remoteLenInt"
				set remoteLenTotal [expr 4 + $remoteLenInt ]
	Deputs "remoteLenTotal is: $remoteLenTotal"
				if {$remoteLenTotal == $payloadLen} {
					set remoteValue 0x[ string range $payload 4 end]
	Deputs "remoteValue is: $remoteValue"
					
					ixNet setM $handle/dhcpRange \
								-useTrustedNetworkElement True \
								-relayUseRemoteId True \
								-relayRemoteId $remoteValue
				} else {
					error "error option82 format input, please refer to RFC3046"
				}
			} else {
				error "error option82 format input, please refer to RFC3046"
			}
	
			ixNet commit
			set flagTypeDefined 1
		}
	
	if { $flagTypeDefined == 0 && [ info exists option_type ] } {
	
		switch $msg_type {
			discover -
			solicit {
				Deputs "customized TLV" 
                if { [info exists optionType] == 0 } {        
				    set optionType string
                }
				set tlv [ ixNet add $optionSet dhcpOptionTlv ]
				if { [ info exists payload ] == 0 } {
					set payload 0
				} else {
					if { [ IsIPv6Address $payload ]  } {
						set optionType ipv6Address
					}
					if { [ IsIPv4Address $payload ] } {
						set optionType ipv4Address
					}

				}
				if { [ info exists option_type ] == 0 } {
					error "$errNumber(2) option_type"

				}
				ixNet setM $tlv -type $optionType -value $payload -code $option_type -name Option[clock click]
				ixNet commit			
			}
			request {
				if { [ string tolower [ ixNet getA $handle/dhcpRange -ipType ] ] == "ipv4" } {
					set cmd -dhcp4ParamRequestList
				} else {
					set cmd -dhcp6ParamRequestList
				}

				set reqList [ ixNet getA $handle/dhcpRange $cmd ]
				set reqIndex [ string first $option_type $reqList ]
				if { $reqIndex >= 0 && [ string index [ expr $reqIndex + 1 ] ] == ";" } {
					Deputs "request exist..."
				} else {
					append reqList ";$option_type"
					Deputs "request list:$reqList"					
					ixNet setA $handle/dhcpRange $cmd $reqList
					ixNet commit
				}
			}
		}
	}
	
	return [ GetStandardReturnHeader ]
}
body DhcpPDHost::get_port_summary_stats { view } {
    set tag "body DhcpPDHost::get_port_summary_stats [info script]"
	Deputs "----- TAG: $tag -----"
	
	#set view ::ixNet::OBJ-/statistics/view:\"DHCPv6\"

    set captionList         	[ ixNet getA $view/page -columnCaptions ]
    set nameIndex          		[ lsearch -exact $captionList {Stat Name} ]
	Deputs "index:$nameIndex"
    set ackRcvIndex          	[ lsearch -exact $captionList {ACKs Received} ]
	Deputs "index:$ackRcvIndex"
    set addDiscIndex          	[ lsearch -exact $captionList {Addresses Discovered} ]
	Deputs "index:$addDiscIndex"
    set declineSntIndex          	[ lsearch -exact $captionList {Declines Sent} ]
	Deputs "index:$declineSntIndex"
    set discSntIndex          	[ lsearch -exact $captionList {Discovers Sent} ]
	Deputs "index:$discSntIndex"
    set nakRcvIndex          	[ lsearch -exact $captionList {NACKs Received} ]
	Deputs "index:$nakRcvIndex"
    set offerRcvIndex          	[ lsearch -exact $captionList {Offers Received} ]
	Deputs "index:$offerRcvIndex"
    set releaseSntIndex          	[ lsearch -exact $captionList {Releases Sent} ]
	Deputs "index:$releaseSntIndex"
    set reqSntIndex          	[ lsearch -exact $captionList {Requests Sent} ]
	Deputs "index:$reqSntIndex"
    set sessFailIndex          	[ lsearch -exact $captionList {Sessions Failed} ]
	Deputs "index:$sessFailIndex"
    set sessInitIndex          	[ lsearch -exact $captionList {Sessions Initiated} ]
	Deputs "index:$sessInitIndex"
    set sessSuccIndex          	[ lsearch -exact $captionList {Sessions Succeeded} ]
	Deputs "index:$sessSuccIndex"
    set succRateIndex          	[ lsearch -exact $captionList {Setup Success Rate} ]
	Deputs "index:$succRateIndex"

    set ret [ GetStandardReturnHeader ]
	
    set stats [ ixNet getA $view/page -rowValues ]
	Deputs "stats:$stats"

	set connectionInfo [ ixNet getA [$portObj cget -handle] -connectionInfo ]
	Deputs "connectionInfo :$connectionInfo"
	regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
	Deputs "chas:$chassis card:$card port$port"
	if { [ string length $card ] == 1 } { set card "0$card" }
	if { [ string length $port ] == 1 } { set port "0$port" }
	set statsName "${chassis}/Card${card}/Port${port}"
	Deputs "statsName:$statsName"

    foreach row $stats {      
        eval {set row} $row
		Deputs "row:$row"

        set statsVal    [ lindex $row $nameIndex ]
		if { $statsVal != $statsName } {
			Deputs "stats skipped: $statsVal != $statsName"
			continue
		}

        set statsItem   "tx_discover_count"
        set statsVal    [ lindex $row $discSntIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "rx_discover_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
              
        set statsItem   "tx_offer_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "rx_offer_count"
        set statsVal    [ lindex $row $offerRcvIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_request_count"
        set statsVal    [ lindex $row $reqSntIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "rx_request_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "tx_decline_count"
        set statsVal    [ lindex $row $declineSntIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "rx_decline_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_ack_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "rx_ack_count"
        set statsVal    [ lindex $row $ackRcvIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_nak_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_nak_count"
        set statsVal    [ lindex $row $nakRcvIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_release_count"
        set statsVal    [ lindex $row $releaseSntIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_release_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_all_packet_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_all_packet_count"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "port_session_count"
        set statsVal    [ lindex $row $sessInitIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "port_session_up_count"
        set statsVal    [ lindex $row $sessSuccIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "port_min_setup_time"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "port_max_setup_time"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "port_avg_setup_time"
        set statsVal    "NA"
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "port_setup_rate"
        set statsVal    [ lindex $row $succRateIndex ]
		Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

		Deputs "ret:$ret"
    }
        
    return $ret		
}


class DhcpPDoPppHost {

	inherit DhcpPDHost

	constructor { port { onStack null } } { chain $port $onStack } {}
	
    method retry {} {}
    method resume {} {}
    method pause {} {}
	method config { args } {}
	method get_ppp_summary_stats {} {}
	method reborn { { onStack null } } {
		set tag "body DhcpPDoPppHost::reborn [info script]"
        Deputs "----- TAG: $tag -----"
		
	    if { $onStack == "null" } {
			Deputs "new dhcp endpoint"
			chain $onStack
			#-- add dhcpPdoPpp endpoint stack
			set hPppox [ixNet add $stack pppox]
			ixNet commit
			set hPppox [lindex [ixNet remapIds $hPppox] 0]
			
			set hDhcp [ixNet add $hPppox dhcpoPppClientEndpoint]
			ixNet commit
			set hDhcp [lindex [ixNet remapIds $hDhcp] 0]
		} else {
			Deputs "based on existing stack:$onStack"		
			set hDhcp $onStack
		}
		
	    #-- add range
	    set sg_range [ixNet add $hDhcp range]
	    ixNet setMultiAttrs $sg_range/macRange \
			-enabled True 
	
	    ixNet setMultiAttrs $sg_range/vlanRange \
			-enabled False 
	
	    ixNet setMultiAttrs $sg_range/pppoxRange \
			-enabled True \
			-ncpType IPv6

		set hDhcpv6PdClient [ixNet add $sg_range dhcpv6PdClientRange]
	    ixNet setMultiAttrs $hDhcpv6PdClient \
			-enabled True \
			-ipType IPv6
		
	    ixNet setMultiAttrs $sg_range/dhcpHostsRange \
			-enabled True
		
	    ixNet commit
	    set sg_range [ixNet remapIds $sg_range]
		set handle $sg_range
		set hDhcpv6PdClient [lindex [ixNet remapIds $hDhcpv6PdClient] 0]
		Deputs "hDhcpv6PdClient:$hDhcpv6PdClient"
		
		#-- add option set
		set root [ixNet getRoot]
		set globalSetting [ ixNet getL $root/globals/protocolStack dhcpv6PdClientGlobals ]
		set optionSet [ ixNet add $globalSetting dhcpv6PdOptionSet ]
		ixNet commit
		set optionSet [ixNet remapIds $optionSet]
        Deputs "option:$optionSet"

		ixNet setA $hDhcpv6PdClient -clientOptionSet $optionSet
		ixNet commit
		ixNet setA $hDhcpv6PdClient -clientOptionSet $optionSet
		ixNet commit
		ixNet setA $optionSet -ipType IPv6
		ixNet commit
		ixNet setA $handle/dhcpHostsRange -ipType IPv6
		ixNet commit
		
		set statsView {::ixNet::OBJ-/statistics/view:"DHCPv6"}
	}
}

body DhcpPDoPppHost::retry {} {
    set tag "body DhcpPDoPppHost::retry [info script]"
	Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec pppoxRetry $handle
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDoPppHost::resume {} {
    set tag "body DhcpPDoPppHost::resume [info script]"
	Deputs "----- TAG: $tag -----"
	chain
	if { [ catch {
		ixNet exec pppoxResume $handle
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDoPppHost::pause {} {
    set tag "body DhcpPDoPppHost::pause [info script]"
	Deputs "----- TAG: $tag -----"
	chain
	if { [ catch {
		ixNet exec pppoxPause $handle
	} ] } {
		return [GetErrorReturnHeader "Unsupported functionality."]		
	}
    return [GetStandardReturnHeader]
}
body DhcpPDoPppHost::config { args } {
    set tag "body DhcpPDoPppHost::config [info script]"
	Deputs "----- TAG: $tag -----"
	
    eval { chain } $args 

    global errorInfo
    global errNumber
    
    set EDuidType [ list llt ll en ]
    set ESession  [ list iana iata iapd iana_iapd ]
	set ENCPType [ list ipv4 ipv6 dualstack ipv4v6 ]
	set EAuth      [ list none auto chap_md5 pap ]
		
	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-ncp_type {
                set value [ string tolower $value ]
                if { [ lsearch -exact $ENCPType $value ] >= 0 } {
                    set ncp_type $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
            -duid_enterprise {
                if { [ string is integer $value ] } {
                    set duid_enterprise $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -duid_start {
                if { [ string is integer $value ] } {
                    set duid_start $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -duid_step {
                if { [ string is integer $value ] } {
                    set duid_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -duid_type {
                set value [ string tolower $value ]
                if { [ lsearch -exact $EDuidType $value ] >= 0 } {
                    
                    set duid_type $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                
            }
            -t1_timer {
                if { [ string is integer $value ] } {
                    set t1_timer $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -t2_timer {
                if { [ string is integer $value ] } {
                    set t2_timer $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }		   
		    -iaid {
			    if { [ string is integer $value ] } {
				   set iaid $value
			    } else {
				   error "$errNumber(1) key:$key value:$value"
			    }
		    }		   
			-session_type -
			-client_mode -
			-ia_type {
                set value [ string tolower $value ]
                if { [ lsearch -exact $ESession $value ] >= 0 } {
                    
                    set session_type $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                
			}
			-authen_type {
                set value [ string tolower $value ]
                if { [ lsearch -exact $EAuth $value ] >= 0 } {
                    set authentication $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-enable_auth {
				set enable_auth $value
			}
			-user_name {
				set user_name $value
			}
			-password {
				set password $value
			}
            -session_num {
                set session_num $value
            }
            
			
		}
    }


    set range $handle
    if { [ info exists ncp_type ] } {
		Deputs "ncp_type: $ncp_type"
		switch -exact -- $ncp_type {
			ipv4 {
				ixNet setA $handle/pppoxRange -ncpType IPv4
			}
			ipv6 {
				ixNet setA $handle/pppoxRange -ncpType IPv6
			}
			ipv4v6 -
			dualstack {
				ixNet setA $handle/pppoxRange -ncpType DualStack
			}
		}
    }
	
	if { [ info exists authentication ] } {
		switch $authentication {			
            auto {
				set authentication papOrChap
                if { [ info exists user_name ] } {
					ixNet setMultiAttrs $handle/pppoxRange \
					 -chapName $user_name  \
					 -papUser $user_name
				}
				if { [ info exists password ] } {
					ixNet setMultiAttrs $handle/pppoxRange \
					 -chapSecret $password  \
					 -papPassword $password
				}
			}
			chap_md5 {
				set authentication chap
				if { [ info exists user_name ] } {
					ixNet setMultiAttrs $handle/pppoxRange \
					 -chapName $user_name
				}
				if { [ info exists password ] } {
					ixNet setMultiAttrs $handle/pppoxRange \
					 -chapSecret $password
				}			
			}
            pap {
				set authentication pap
				if { [ info exists user_name ] } {
					ixNet setMultiAttrs $handle/pppoxRange \
					 -papUser $user_name
				}
				if { [ info exists password ] } {
					ixNet setMultiAttrs $handle/pppoxRange \
					 -papPassword $password
				}			
			}
			
		}
		ixNet setA $handle/pppoxRange -authType $authentication
	}
     if { [ info exists session_num] } {
        ixNet setA $handle/pppoxRange -numSessions $session_num
    }
    if { [ info exists duid_type ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6DuidType "DUID-[ string toupper $duid_type ]"
    }

    if { [ info exists duid_enterprise ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6DuidEnterpriseId $duid_enterprise
    }

    if { [ info exists duid_start ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6DuidVendorId $duid_start
    }
    
    if { [ info exists duid_step ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6DuidVendorIdIncrement $duid_step
    }
    
    if { [ info exists t1_timer ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6IaT1 $t1_timer
    }
    
    if { [ info exists t2_timer ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6IaT2 $t2_timer
    }

	if { [ info exists iaid ] } {
		ixNet setA $hDhcpv6PdClient -dhcp6IaId $iaid
	}
	
	if { [ info exists session_type ] } {
        ixNet setA $hDhcpv6PdClient -dhcp6IaType [string toupper $session_type]
	}

    ixNet  commit
    
    return [GetStandardReturnHeader]    
}
body DhcpPDoPppHost::get_ppp_summary_stats {} {
    set tag "body DhcpPDoPppHost::get_summary_stats [info script]"
	Deputs "----- TAG: $tag -----"

    # Í³¼ÆÏî
    # attempted_count
    # avg_success_transaction_count
    # connected_success_count
    # disconnected_success_count
    # failed_connect_count
    # failed_disconnect_count
    # max_setup_time
    # min_setup_time
    # retry_count
    # rx_chap_count
    # rx_ipcp_count
    # rx_ipv6cp_count
    # rx_lcp_config_ack_count
    # rx_lcp_config_nak_count
    # rx_lcp_config_reject_count
    # rx_lcp_config_request_count
    # rx_lcp_echo_reply_count
    # rx_lcp_echo_request_count
    # rx_lcp_term_ack_count
    # rx_lcp_term_request_count
    # rx_pap_count
    # hosts
    # success_setup_rate
    # hosts_up
    # tx_chap_count
    # tx_ipcp_count
    # tx_ipv6cp_count
    # tx_lcp_config_ack_count
    # tx_lcp_config_nak_count
    # tx_lcp_config_reject_count
    # tx_lcp_config_request_count
    # tx_lcp_echo_reply_count
    # tx_lcp_echo_request_count
    # tx_lcp_term_ack_count
    # tx_lcp_term_request_count
    # tx_pap_count

    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"PPP General Statistics"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
    Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
    Deputs "caption list:$captionList"
	set port_name				[ lsearch -exact $captionList {Stat Name} ]
    set attempted_count          [ lsearch -exact $captionList {Sessions Initiated} ]
    set connected_success_count          [ lsearch -exact $captionList {Sessions Succeeded} ]
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
		if { [ string length $card ] == 1 } {
			set card "0$card"
		}
		if { [ string length $port ] == 1 } {
			set port "0$port"
		}
		if { "${chassis}/Card${card}/Port${port}" != [ lindex $row $port_name ] } {
			continue
		}

        set statsItem   "attempted_count"
        set statsVal    [ lindex $row $attempted_count ]
        Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
              
        set statsItem   "connected_success_count"
        set statsVal    [ lindex $row $connected_success_count ]
        Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  

        Deputs "ret:$ret"

    }
        
    return $ret
}
