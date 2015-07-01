
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.27
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1
#		1. Add create obj command in config method
#		2. Add implementation for set_igmp_over_dhcp in both DhcpHost class and his child class
# Version 1.2.1.4
#		3. Add method wait_request_complete wait_release_complete
#		4. Add exception branch in set_dhcp_msg_option for customizing default option in [ 53, 61, 51, 57, 55 ]
# Version 1.3.1.5
#		5. Read Err: "ixNet::ERROR-ErrorsOccured-6401-Error in Plugin- There is no license available for DHCP Client"
#			in DHCP::request method.
#		   Fixed by after 1000 and try again.
# Version 1.4.1.6
#		6. Add after 5000 in request to make sure the stats will be updated
#		7. Remove the view after get_detailed stats
# Version 1.5
#		8. Set DHCP option 51 to configuration -suggested_lease_time
#		9. Set DHCP option 55 to configuration of request list
# Version 1.6.1.9
#		10. Add catch retry in DHCP Client request and DHCP Server start for a license check issue
#		11. Add get_stats method in DHCP server 
# Version 1.7.1.10
#		12. Add 5seconds delay in DHCP server start
# Version 1.8.1.11
#		13. Add 
#				-ipv4_addr 
#				-ipv4_prefix_len 
#				-ipv4_gw 
#				-gw_step 
#				-mac_addr 
#				-mac_add_step 
#				-router_list
#				-domain_name_server_list
#			in DHCP Server config
# Version 1.9.2.1
#		14. Add method get_lease_address in DhcpServer
#		15. Add method get_stats in Dhcpv6Server
# Version 1.10.2.1-patch
#		16. Change dhcpPerSession naming issue
# Version 1.11
#		17. Add ia-type in Dhcpv6Server.config
# Version 1.12.2.4
#		18. Implement wait_request_complete to to get the result of ALL-OFFER or NOT
#		19. Implement wait_release_complete to to get the result of ALL-RELEASE or NOT
# Version 1.13.2.5
#		20. Add initilization method in Dhcp.config when invoked with empty object(object reborn)
# Version 1.14.2.8
#		21. Add abort method in DhcpHost
# Version 1.15.2.24
#		22. Add -ia_type in Dhcpv6.config
# Version 1.16.2.25
#		23. Add reborn to Dhcpv6.config
#		24. Add -count to DhcpServer.config
# Version 1.17.3.0
#		25. inherit from ProtocolStackObject
# Version 1.18.3.1L
#		26. add two or more dhcpServerEndpoints will prompt errors, but valid actully. Add catch to fix
# Version 1.19.3.7
#		27. add solicit msg type in set_dhcp_msg_option
# Version 1.20.3.10
#		28. add customized request msg type
# Version 1.21.4.2
#       29. add -preferred_life_time, -valid_life_time to DhcpServer.config and add -iaid to Dhcpv6Host.config
# Version 1.22.Unicom.cgn
# 		30. add dual stack host
# Version 1.22
# 		31. add option82 in DhcpHost::set_dhcp_msg_option
# Version 1.23.4.13
#		32. identify option payload type in DhcpHost::set_dhcp_msg_option
# Version 1.24.6.20
#		33. add Ipv6AutoConfigHost
# Version 1.25 11.4
#       34. DhcpHost.config add -relay_pool_ipv4_addr 
# Version 1.26 12.26
#       35. DhcpHost.set_dhcp_msg_option add -enable_hex_value
# Version 1.27 3.14
#       36. add Dot1xHost



class DhcpHost {
    inherit ProtocolStackObject
    
    #public variable type
#    public variable stack
    public variable hIgmp
    public variable optionSet
    
    public variable rangeStats
    public variable hostCnt
    public variable hDhcp
    public variable requestDuration
	
	public variable statsView
	
    constructor { port { onStack null } } { chain $port $onStack } {}
    method reborn { { onStack null } } {
	    set tag "body DhcpHost::reborn [info script]"
	    Deputs "----- TAG: $tag -----"
		    
	    array set rangeStats [list]
	    if { $onStack == "null" } {
Deputs "new dhcp endpoint"
			chain 
			set sg_ethernet $stack
			#-- add dhcp endpoint stack
			set sg_dhcpEndpoint [ixNet add $sg_ethernet dhcpEndpoint]
			ixNet setA $sg_dhcpEndpoint -name $this
			ixNet commit
			set sg_dhcpEndpoint [lindex [ixNet remapIds $sg_dhcpEndpoint] 0]
			set hDhcp $sg_dhcpEndpoint
		} else {
Deputs "based on existing stack:$onStack"		
			set hDhcp $onStack
		}
	
	    #-- add range
	    set sg_range [ixNet add $hDhcp range]
	    ixNet setMultiAttrs $sg_range/macRange \
	     -enabled True 
	
	    ixNet setMultiAttrs $sg_range/vlanRange \
	     -enabled False \
	
	    ixNet setMultiAttrs $sg_range/dhcpRange \
	     -enabled True \
	     -count 1
	
	    ixNet commit
	    set sg_range [ixNet remapIds $sg_range]
	
	    set handle $sg_range
		
		#-- add option set
		set root [ixNet getRoot]
		set globalSetting [ ixNet getL $root/globals/protocolStack dhcpGlobals ]
		set optionSet [ ixNet add $globalSetting dhcpOptionSet ]
		ixNet setA $optionSet -name "${this}_OptionSet"
		ixNet commit
		set optionSet [ixNet remapIds $optionSet]
Deputs "option:$optionSet"
Deputs "[ixNet getA $handle/dhcpRange -clientOptionSet]"
Deputs "ixNet setA $handle/dhcpRange -clientOptionSet $optionSet"
		ixNet setA $handle/dhcpRange -clientOptionSet $optionSet
		ixNet commit
		ixNet setA $handle/dhcpRange -clientOptionSet $optionSet
		ixNet commit
		
	    #set trafficObj 
	    set igmpObj ""
	    
		#disable all the interface defined on port
		foreach int [ ixNet getL $hPort interface ] {
			ixNet setA $int -enabled false
		}
		ixNet commit
    }
	
    method config { args } {}
    method request {} {}
    method release {} {}
    method renew {} {}
    method abort {} {}
    method retry {} {}
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
        set tag "body DhcpHost::CreateDhcpPerSessionView [info script]"
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
        set tag "body DhcpHost::CreateDhcpPerRangeView [info script]"
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
body DhcpHost::config { args } {

    global errorInfo
    global errNumber
    set tag "body DhcpHost::config [info script]"
Deputs "----- TAG: $tag -----"
#disable the interface

    eval { chain } $args
	
#param collection
Deputs "Args:$args "
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
            -circuit_id {
                set circuit_id  $value
            }
            -enable_circuit_id {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_circuit_id $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -enable_relay_agent {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_relay_agent $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -enable_remote_id {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_remote_id $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -relay_pool_ipv4_addr -
            -relay_agent_ipv4_addr {
                if { [ IsIPv4Address $value ] } {
                    set relay_agent_ipv4_addr $value
                    set enable_relay_agent 1
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                
            }
            -relay_pool_ipv4_addr_step -
            -relay_agent_ipv4_addr_step {
                if { [ IsIPv4Address $value ] } {
                    set relay_agent_ipv4_addr_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                
            }
            -relay_server_ipv4_addr {
                if { [ IsIPv4Address $value ] } {
                    set relay_server_ipv4_addr $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                
            }
		   
		   -relay_client_mac_addr_start {
			  
		   }
		   
		   -relay_client_mac_addr_step {
			   
		   }
		   
            -remote_id {
                set remote_id $value
            }
            -enable_auto_retry {
                set trans [ BoolTrans $value ]
                if { $trans == "1" } {
                } elseif { $trans == "0" } {
                    set retry_attempts 0
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -retry_attempts {
                if { [ string is integer $value ] && ( $value >= 0 ) } {
                    set retry_attempts $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }

            -suggest_lease {
                if { [ string is integer $value ] && ( $value > 0 ) } {
                    set suggest_lease $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
		   
		  -use_broadcast_flag {
			  set use_broadcast_flag $value
		  }
		   
		  -relay_server_ipv4_addr_step {
			  set relay_server_ipv4_addr_step $value
		  }
        }
    }
	set range $handle
    if { [ info exists count ] } {
        ixNet setA $range/dhcpRange -count $count
    }
    if { [ info exists enable_circuit_id ] } {
        ixNet setA $range/dhcpRange -relayUseCircuitId $enable_circuit_id        
    }
    if { [ info exists circuit_id ] } {
        ixNet setA $range/dhcpRange -relayCircuitId $circuit_id
    }
    if { [ info exists enable_relay_agent ] } {
        ixNet setA $range/dhcpRange -useRelayAgent $enable_relay_agent
    }

    if { [ info exists use_broadcast_flag ] } {
	    ixNet setA $range/dhcpRange -dhcp4Broadcast $use_broadcast_flag
    }
    if { [ info exists relay_server_ipv4_addr_step ] } {
	    ixNet setA $range/dhcpRange -relayAddressIncrement $relay_server_ipv4_addr_step
    }
    if { [ info exists relay_agent_ipv4_addr ] } {
        ixNet setA $range/dhcpRange -relayFirstAddress $relay_agent_ipv4_addr
    }
    if { [ info exists relay_agent_ipv4_addr_step ] } {
        ixNet setA $range/dhcpRange -relayAddressIncrement $relay_agent_ipv4_addr_step        
    }
    if { [ info exists relay_server_ipv4_addr ] } {
        ixNet setA $range/dhcpRange -relayDestination $relay_server_ipv4_addr
        ixNet setA $range/dhcpRange -relayGateway $relay_server_ipv4_addr
    }
    if { [ info exists remote_id ] } {
        ixNet setA $range/dhcpRange -relayRemoteId $remote_id
    }
    if { [ info exists retry_attempts ] } {
        set root [ixNet getRoot]
        ixNet setA [ ixNet getList $root/globals/protocolStack dhcpGlobals ] -dhcp4NumRetry $retry_attempts
    }

    if { [ info exists suggest_lease ] } {
		set root [ixNet getRoot]
		set global [ ixNet getL $root/globals/protocolStack dhcpGlobals ]
		ixNet setA $global -dhcp4AddrLeaseTime $suggest_lease
	}
    ixNet commit
    return [GetStandardReturnHeader]
}
body DhcpHost::request {} {
# IxDebugOn
    set tag "body DhcpHost::request [info script]"
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
# IxDebugOff	
	set completeTimestamp [ clock seconds ]
	set requestDuration [ expr $completeTimestamp - $requestTimestamp ]
#-- make sure the stats will be updated
    return [GetStandardReturnHeader]
}
body DhcpHost::release {} {
    set tag "body DhcpHost::release [info script]"
Deputs "----- TAG: $tag -----"
    ixNet exec stop $handle
	#ixNet exec dhcpClientClearStats $hDhcp
	ixNet commit
    return [GetStandardReturnHeader]
}
body DhcpHost::abort {} {
    set tag "body DhcpHost::abort [info script]"
Deputs "----- TAG: $tag -----"
	ixNet exec abort $hDhcp
	ixNet commit
    return [GetStandardReturnHeader]
}
body DhcpHost::renew {} {
    set tag "body DhcpHost::renew [info script]"
Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpClientRenew $handle
	} ] } {
		return [GetErrorReturnHeader "Supported only on IxNetwork 6.30 or above."]		
	}
    return [GetErrorReturnHeader "Unsupported functionality."]
}
body DhcpHost::retry {} {
    set tag "body DhcpHost::retry [info script]"
Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpClientRetry $handle
	} ] } {
		return [GetErrorReturnHeader "Supported only on IxNetwork 6.30 or above."]		
	}
    return [GetErrorReturnHeader "Unsupported functionality."]
}
body DhcpHost::resume {} {
    set tag "body DhcpHost::resume [info script]"
Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpClientResume $handle
	} ] } {
		return [GetErrorReturnHeader "Supported only on IxNetwork 6.30 or above."]		
	}
    return [GetErrorReturnHeader "Unsupported functionality."]
}
body DhcpHost::pause {} {
    set tag "body DhcpHost::pause [info script]"
Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpClientPause $handle
	} ] } {
		return [GetErrorReturnHeader "Supported only on IxNetwork 6.30 or above."]		
	}
    return [GetErrorReturnHeader "Unsupported functionality."]
}
body DhcpHost::rebind {} {
    set tag "body DhcpHost::rebind [info script]"
Deputs "----- TAG: $tag -----"
	if { [ catch {
		ixNet exec dhcpClientRebind $handle
	} ] } {
		return [GetErrorReturnHeader "Supported only on IxNetwork 6.30 or above."]		
	}
    return [GetErrorReturnHeader "Unsupported functionality."]
}
body DhcpHost::wait_request_complete { args } {
    set tag "body DhcpHost::wait_request_complete [info script]"
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
			break
		}

Deputs "initStats:$initStats == succStats:$succStats ?"		
		if { $succStats != "" && $succStats >= $initStats && $initStats > 0 } {
			break	
		}
		
		after 1000
	}
	
	return [GetStandardReturnHeader]

}
body DhcpHost::wait_release_complete { args } {
    set tag "body DhcpHost::wait_release_complete [info script]"
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
body DhcpHost::get_summary_stats {} {
    set tag "body DhcpHost::get_summary_stats [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view [ lindex [ ixNet getF $root/statistics view -caption "dhcpPerRangeView" ] 0 ]
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
    set discoverSentIndex   [ lsearch -exact $captionList {Discovers Sent} ]
Deputs "index:$discoverSentIndex"
	if { $discoverSentIndex < 0 } {
		set discoverSentIndex   [ lsearch -exact $captionList {Solicits Sent} ]
Deputs "index:$discoverSentIndex"
	}
    set offerRecIndex       [ lsearch -exact $captionList {Offers Received} ]
Deputs "index:$offerRecIndex"
	if { $offerRecIndex < 0 } {
		set offerRecIndex       [ lsearch -exact $captionList {Replies Received} ]
Deputs "index:$offerRecIndex"
	}
    set reqSentIndex        [ lsearch -exact $captionList {Requests Sent} ]
Deputs "index:$reqSentIndex"
    set ackRecIndex         [ lsearch -exact $captionList {ACKs Received} ]
Deputs "index:$ackRecIndex"
	if { $ackRecIndex < 0 } {
		set ackRecIndex       [ lsearch -exact $captionList {Advertisements Received} ]
Deputs "index:$ackRecIndex"
	}
    set nackRecIndex        [ lsearch -exact $captionList {NACKs Received} ]
Deputs "index:$nackRecIndex"
	if { $nackRecIndex < 0 } {
		set nackRecIndex       [ lsearch -exact $captionList {Advertisements Ignored} ]
Deputs "index:$nackRecIndex"
	}
    set releaseSentIndex    [ lsearch -exact $captionList {Releases Sent} ]
Deputs "index:$releaseSentIndex"
    set declineSentIndex    [ lsearch -exact $captionList {Declines Sent} ]
Deputs "index:$declineSentIndex"
    set renewSentIndex    [ lsearch -exact $captionList {Renews Sent} ]
Deputs "index:$renewSentIndex"
    set retriedSentIndex    [ lsearch -exact $captionList {Rebinds Sent} ]
Deputs "index:$retriedSentIndex"
    
Deputs "handle:$handle"
    set dhcpRange [ixNet getList $handle dhcpRange]
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
        set statsItem   "attempt_rate"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "bind_rate"
		if { [ info exists requestDuration ] == 0 || $requestDuration < 1 } {
			set statsVal NA
		} else {
			set statsVal    [ expr [ lindex $row $offerRecIndex ] / $requestDuration ]
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "current_attempt_count"
		if { $discoverSentIndex >= 0 } {
			set statsVal    [ lindex $row $discoverSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "current_bound_count"
		if { $offerRecIndex >= 0 } {
			set statsVal    [ lindex $row $offerRecIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "current_idle_count"
        if {  $releaseSentIndex >= 0  && [lindex $row $releaseSentIndex] >0} {
			set statsVal    [ lindex $row $releaseSentIndex ]
		} else {
            set statsVal    [ expr [ lindex $row $discoverSentIndex ] - [ lindex $row $offerRecIndex ] ]
	    }
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_ack_count"
		if { $ackRecIndex >= 0 } {
			set statsVal    [ lindex $row $ackRecIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_nak_count"
		if { $nackRecIndex >= 0 } {
			set statsVal    [ lindex $row $nackRecIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_offer_count"
		if { $offerRecIndex >= 0 } {
			set statsVal    [ lindex $row $offerRecIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "total_attempt_count"
		if { $discoverSentIndex >= 0 } {
			set statsVal    [ lindex $row $discoverSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "total_bound_count"
		if { $offerRecIndex >= 0 } {
			set statsVal    [ lindex $row $offerRecIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(offerReceived) $statsVal
        
        set statsItem   "total_failed_count"
        set statsVal    [ expr [ lindex $row $discoverSentIndex ] - [ lindex $row $offerRecIndex ] ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "total_renewed_count"
		if { $renewSentIndex >= 0 } {
			set statsVal    [ lindex $row $renewSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
        set statsItem   "total_retried_count"
		if { $retriedSentIndex >= 0 } {
			set statsVal    [ lindex $row $retriedSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "tx_discover_count"
		if { $discoverSentIndex >= 0 } {
			set statsVal    [ lindex $row $discoverSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(discoverSent) $statsVal
        
        set statsItem   "tx_release_count"
		if { $releaseSentIndex >= 0 } {
			set statsVal    [ lindex $row $releaseSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(releaseSent) $statsVal
        
        set statsItem   "tx_request_count"
		if { $reqSentIndex >= 0 } {
			set statsVal    [ lindex $row $reqSentIndex ]
		} else {
			set statsVal    "NA"
		}
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		#--temp variable to save current stats
		set rangeStats(requestSent) $statsVal
        
    }

Deputs "ret:$ret"
	ixNet remove $view
	ixNet commit
	
    return $ret
    
}
body DhcpHost::get_detailed_stats {} {
    set tag "body DhcpHost::get_detailed_stats [info script]"
Deputs "----- TAG: $tag -----"

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

			set statsItem   "error_status"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "inner_vlan_id"
			set statsVal    "NA"
Deputs "stats val:$statsVal"
			set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
			set statsItem   "ipv4_addr"
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
			
			set statsItem   "host_state"
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
body DhcpHost::set_dhcp_msg_option { args } {
    global errorInfo
    global errNumber
    set tag "body DhcpHost::set_dhcp_msg_option [info script]"
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
body DhcpHost::set_igmp_over_dhcp { args } {

    global errorInfo
    global errNumber
	
    set tag "body DhcpHost::set_igmp_over_dhcp [info script]"
Deputs "----- TAG: $tag -----"

	if { [ info exists hIgmp ] } {
		if { [ ixNet exists $hIgmp ] } {
			return
		}
	}

	if { [ catch {
		set hPort   [ $portObj cget -handle ]
	} ] } {
		error "$errNumber(1) Port Object in DhcpHost ctor"
	}
	
	#-- add igmp host
	set host [ ixNet add $hPort/protocols/igmp host ]
	ixNet setMultiAttrs $host \
		-enabled True \
		-interfaceType DHCP \
		-interfaces $handle 
	
	ixNet commit
	set host [ixNet remapIds $host]	

	set hIgmp $host
}
body DhcpHost::unset_igmp_over_dhcp {} {

	if { [ info exists hIgmp ] } {
		if { [ ixNet exists $hIgmp ] } {
			ixNet remove $hIgmp
			ixNet commit
		}
	}
}
body DhcpHost::get_port_summary_stats { view } {

    set tag "body DhcpHost::get_port_summary_stats [info script]"
Deputs "----- TAG: $tag -----"

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


class Dhcpv4Host {
    
	inherit DhcpHost
	constructor { port { onStack null } } { chain $port $onStack } {}
	method set_igmp_over_dhcp { args } {}
	method get_port_summary_stats {} {}
	method reborn { { onStack null } } {
		set tag "body Dhcpv4Host::reborn [info script]"
Deputs "----- TAG: $tag -----"

		chain $onStack
		ixNet setA $handle/dhcpRange -ipType IPv4
		ixNet commit
		
		ixNet setM $optionSet -ipType IPv4
		ixNet commit
		
		set statsView {::ixNet::OBJ-/statistics/view:"DHCPv4"}
	}
}

body Dhcpv4Host::set_igmp_over_dhcp { args } {

    set tag "body Dhcpv4Host::set_igmp_over_dhcp [info script]"
Deputs "----- TAG: $tag -----"	

	eval { chain } $args

	ixNet setA $hIgmp -version igmpv2
	
	set EAction [ list join leave ]
	set action join

#param collection
Deputs "Args:$args "
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -group {
                    foreach grp $value {
                    	if { [ $grp isa MulticastGroup ] == 0 } {
                    		error "$errNumber(1) key:$key value:$value"
                    		}
            		}
            		set group $value
        	}
        	-action {
        		set value [ string tolower $value ]
                        if { [ lsearch -exact $EAction $value ] >= 0 } {
                            
                            set action $value
                        } else {
                        	return [GetErrorReturnHeader "Unsupported functionality."]
                        }
                }
            }
        }
	
	foreach grp $group {

		set group_ip 	[ $grp cget -group_ip ]
		set group_num [ $grp cget -group_num ]
		set group_step [ $grp cget -group_step ]
		set group_modbit [ $grp cget -group_modbit ]
		
		set hGroup [ ixNet add $hIgmp group ]
		
		ixNet setM $hGroup \
			-groupFrom $group_ip \
			-incrementStep [ GetPrefixV4Step $group_modbit $group_step ] \
			-groupCount $group_num
	}
	
	ixNet commit
	return [ GetStandardReturnHeader ]

}
body Dhcpv4Host::get_port_summary_stats {} {
    set tag "body Dhcpv4Host::get_port_summary_stats [info script]"
Deputs "----- TAG: $tag -----"
#IxDebugOn
	set view ::ixNet::OBJ-/statistics/view:\"DHCPv4\"
Deputs "view:$view"	
	return [ chain $view ]
		
}

class Dhcpv6Host {

	inherit DhcpHost

	constructor { port { onStack null } } { chain $port $onStack } {}
	
	method config { args } {}
	method set_igmp_over_dhcp { args } {}
	method get_port_summary_stats {} {}
	method get_summary_stats {} {}
	method get_detailed_stats {} {}
	method reborn { { onStack null } } {
	
		set tag "body Dhcpv6Host::reborn [info script]"
Deputs "----- TAG: $tag -----"
	
		chain $onStack
		ixNet setA $handle/dhcpRange -ipType IPv6
		ixNet commit

		ixNet setA $optionSet -ipType IPv6
		ixNet commit
		
		set statsView {::ixNet::OBJ-/statistics/view:"DHCPv6"}

	}
}
body Dhcpv6Host::set_igmp_over_dhcp { args } {

    set tag "body Dhcpv6Host::set_igmp_over_dhcp [info script]"
Deputs "----- TAG: $tag -----"	

	eval { chain } $args

	ixNet setA $hIgmp -version igmpv3
	
	set EAction [ list join leave ]
	set action join

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -group {
				foreach grp $value {
					if { [ $grp isa MulticastGroup ] == 0 } {
						error "$errNumber(1) key:$key value:$value"
					}
				}
				set group $value
			}
			-action {
				set value [ string tolower $value ]
                if { [ lsearch -exact $EAction $value ] >= 0 } {
                    
                    set action $value
                } else {
					return [GetErrorReturnHeader "Unsupported functionality."]
                }
			}
        }
    }
	
	foreach grp $group {
		set filter_mode	[ $grp cget -filter_mode ]
		set source_ip 	[ $grp cget -source_ip ]
		set source_num [ $grp cget -source_num ]
		set source_step [ $grp cget -source_step ]
		set source_modbit	[ $grp cget -source_modbit ]
		set group_ip 	[ $grp cget -group_ip ]
		set group_num [ $grp cget -group_num ]
		set group_step [ $grp cget -group_step ]
		set group_modbit [ $grp cget -group_modbit ]
		
		set hGroup [ ixNet add $hIgmp group ]
		
		ixNet setM $hGroup \
			-sourceMode $filter_mode
			-groupFrom $group_ip \
			-incrementStep [ GetPrefixV4Step $group_modbit $group_step ] \
			-groupCount $group_num
		
		set hSrc [ ixNet add $hGroup source ]
		ixNet setM $hSrc \
			-sourceRangeCount $source_num \
			-sourceRangeStart $source_ip
	
	}
	ixNet commit
	return [ GetStandardReturnHeader ]

}
body Dhcpv6Host::config { args } {
    set tag "body Dhcpv6Host::config [info script]"
Deputs "----- TAG: $tag -----"
	
    eval { chain } $args 

	
    global errorInfo
    global errNumber
    
    set EDuidType [ list llt ll en ]
    set ESession  [ list iana iata iapd iana_iapd ]
    
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
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
		}
    }


    set range $handle
    
    if { [ info exists duid_type ] } {
        ixNet setA $range/dhcpRange -dhcp6DuidType "DUID-[ string toupper $duid_type ]"
    }

    if { [ info exists duid_enterprise ] } {
        ixNet setA $range/dhcpRange -dhcp6DuidEnterpriseId $duid_enterprise
    }

    if { [ info exists duid_start ] } {
        ixNet setA $range/dhcpRange -dhcp6DuidVendorId $duid_start
    }
    
    if { [ info exists duid_step ] } {
        ixNet setA $range/dhcpRange -dhcp6DuidVendorIdIncrement $duid_step
    }
    
    if { [ info exists t1_timer ] } {
        ixNet setA $range/dhcpRange -dhcp6IaT1 $t1_timer
    }
    
    if { [ info exists t2_timer ] } {
        ixNet setA $range/dhcpRange -dhcp6IaT2 $t2_timer
    }

	if { [ info exists iaid ] } {
		ixNet setA $range/dhcpRange -dhcp6IaId $iaid
	}
	
	if { [ info exists session_type ] } {
        ixNet setA $range/dhcpRange -dhcp6IaType [string toupper $session_type]
	}

    ixNet  commit
    
    return [GetStandardReturnHeader]    
}
body Dhcpv6Host::get_port_summary_stats {} {
    set tag "body Dhcpv6Host::get_port_summary_stats [info script]"
Deputs "----- TAG: $tag -----"

	set view ::ixNet::OBJ-/statistics/view:\"DHCPv6\"

	return [ chain $view ]
}
body Dhcpv6Host::get_summary_stats {} {
    set tag "body DhcpHost::get_summary_stats [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view [ lindex [ ixNet getF $root/statistics view -caption "dhcpPerRangeView" ] 0 ]
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
    set dhcpRange [ixNet getList $handle dhcpRange]
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
body Dhcpv6Host::get_detailed_stats {} {

    set tag "body Dhcpv6Host::get_detailed_stats [info script]"
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

class DhcpServer {
    inherit ProtocolStackObject
    
    public variable type
    
    constructor { port } { chain $port } {}
	method reborn { args } {}
    method config { args } {}
    method start {} {}
    method stop {} {}
    method set_dhcp_msg_option { args } {
    	return [ GetErrorReturnHeader "Unsupported functionality." ]
    }
    method get_lease_address {} {}

}
body DhcpServer::reborn { args } {
    global errNumber
    
    set tag "body DhcpServer::reborn [info script]"
Deputs "----- TAG: $tag -----"

	if { [ info exists hPort ] == 0 } {
		if { [ catch {
			set hPort   [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in DhcpHost ctor"
		}
	}
	
	set stackCnt [ llength [ ixNet getL $hPort/protocolStack ethernet ] ]
	if { $stackCnt > 0  } {
		set stack [ lindex [ ixNet getL $hPort/protocolStack ethernet ] 0 ]
		set sg_dhcpEndpoint [ ixNet getL $stack dhcpServerEndpoint ]
	} else {
		chain
		set sg_ethernet $stack
	Deputs "stack:$stack"
		#-- add dhcp endpoint stack
		set endpointCnt [ llength [ ixNet getL $sg_ethernet dhcpServerEndpoint ] ]
	Deputs "endpointCnt:$endpointCnt"	
		if { $endpointCnt  > 0 } {
			set sg_dhcpEndpoint [ lindex [ ixNet getL $sg_ethernet dhcpServerEndpoint ]  0 ]
		} else {
			set sg_dhcpEndpoint [ixNet add $sg_ethernet dhcpServerEndpoint]
		Deputs "dhcp Endpoint:$sg_dhcpEndpoint"
			ixNet setA $sg_dhcpEndpoint -name $this
			# ixNet commit
			# set sg_dhcpEndpoint [lindex [ixNet remapIds $sg_dhcpEndpoint] 0]
			##==
			# add two or more dhcpServerEndpoints will prompt errors, but valid actully
			#==
			catch { ixNet commit }
			# set sg_dhcpEndpoint [lindex [ixNet remapIds $sg_dhcpEndpoint] 0]
			# set sg_dhcpEndpoint [ lindex [ ixNet getL $sg_ethernet dhcpServerEndpoint ] end ]
		# Deputs "dhcp Endpoint:$sg_dhcpEndpoint"
			set sg_dhcpEndpoint [ ixNet remapIds $sg_dhcpEndpoint ]
		Deputs "endpoint:$sg_dhcpEndpoint"	
		}    
	}
	

    #-- add range
    set sg_range [ixNet add $sg_dhcpEndpoint range]
    ixNet setMultiAttrs $sg_range/macRange \
     -enabled True 
    
    ixNet setMultiAttrs $sg_range/vlanRange \
     -enabled False \
    
    ixNet setMultiAttrs $sg_range/dhcpServerRange \
     -enabled True \
     -count 1

    ixNet commit
    set sg_range [ixNet remapIds $sg_range]

    set handle $sg_range
    set trafficObj $handle

}
body DhcpServer::config { args } {
    set tag "body DhcpServer::config [info script]"
Deputs "----- TAG: $tag -----"
    
    global errorInfo
    global errNumber
Deputs "handle:$handle"

	eval chain $args

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -count {
            	set count $value
            }
            -pool_ip_start {
                # if { [ IsIPv4Address $value ] } {
                    set pool_ip_start $value
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            }
            -pool_ip_pfx {
                # if { [ string is integer $value ] && ( $value < 32 ) && ( $value > 0 ) } {
                    set pool_ip_pfx $value
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            }
            -pool_ip_count {
                if { [ string is integer $value ] } {
                    set pool_ip_count $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -lease_time -
		  -preferred_life_time {
                if { [ string is integer $value ] } {
                    set lease_time $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -max_lease_time -
			-max_allowed_lease_time -
		     -valid_life_time {
                if { [ string is integer $value ] } {
                    set max_lease_time $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
			-ipv4_addr -
			-ipv6_addr {
                # if { [ IsIPv4Address $value ] } {
                    set ipv4_addr $value
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
			}
			-ipv4_prefix_len -
			-ipv6_prefix_len {
                # if { [ string is integer $value ] && ( $value <= 32 ) && ( $value > 0 ) } {
                    set ipv4_prefix_len $value
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
			}
			-ipv4_gw -
			-ipv6_gw {
                # if { [ IsIPv4Address $value ] } {
                    set ipv4_gw $value
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
			}
			-gw_step {
                if { [ IsIPv4Address $value ] } {
                    set gw_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-domain_name_server_list {
				set domain_name_server_list $value
			}
			-router_list {
				set router_list $value
			}
		}
    }

Deputs Step10
    set range $handle
Deputs Step20
    if { [ info exists count ] } {
    	ixNet setA $range/dhcpServerRange -serverCount $count
    		
    }
Deputs Step25
    if { [ info exists pool_ip_start ] } {
        ixNet setA $range/dhcpServerRange -ipAddress $pool_ip_start
    }
Deputs Step30
    if { [ info exists domain_name_server_list ] } {
		set index 1
		foreach dns $domain_name_server_list {
			if { $index > 2 } {
				break
			}
			ixNet setA $range/dhcpServerRange -ipDns$index $dns
			incr index
		}
    }
    if { [ info exists ipv4_addr ] } {
        ixNet setA $range/dhcpServerRange -serverAddress $ipv4_addr
    }
    if { [ info exists ipv4_gw ] } {
        ixNet setA $range/dhcpServerRange -serverGateway $ipv4_gw
    }
    if { [ info exists router_list ] } {
        ixNet setA $range/dhcpServerRange -ipGateway [ lindex $router_list 0 ]
    }
    if { [ info exists gw_step ] } {
        ixNet setA $range/dhcpServerRange -serverGatewayIncrement $gw_step
    }
    if { [ info exists ipv4_prefix_len ] } {
        ixNet setA $range/dhcpServerRange -serverPrefix $ipv4_prefix_len
    }
    if { [ info exists pool_ip_pfx ] } {
        ixNet setA $range/dhcpServerRange -ipPrefix $pool_ip_pfx
    }
    if { [ info exists pool_ip_count ] } {
        ixNet setA $range/dhcpServerRange -count $pool_ip_count
    }
    
    if { [ info exists lease_time ] } {
        set root [ixNet getRoot]
        ixNet setA [ ixNet getList $root/globals/protocolStack dhcpServerGlobals ] -defaultLeaseTime $lease_time
    }
    if { [ info exists max_lease_time ] } {
        set root [ixNet getRoot]
        ixNet setA [ ixNet getList $root/globals/protocolStack dhcpServerGlobals ] -maxLeaseTime $max_lease_time
	} 
	
	ixNet  commit
    
    return [GetStandardReturnHeader]    
    
}
body DhcpServer::start {} {
    set tag "body DhcpServer::start [info script]"
Deputs "----- TAG: $tag -----"
	after 3000
	if { [ catch {
		ixNet exec start $handle
	} ] } {
		after 3000
		ixNet exec start $handle
	}
    return [GetStandardReturnHeader]
}
body DhcpServer::stop {} {
    set tag "body DhcpHost::stop [info script]"
Deputs "----- TAG: $tag -----"
    ixNet exec stop $handle
    return [GetStandardReturnHeader]
}
body DhcpServer::get_lease_address {} {
    set tag "body DhcpServer::get_lease_address [info script]"
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
    set stateIndex          [ lsearch -exact $captionList {Lease State} ]
    set addressIndex   		[ lsearch -exact $captionList {Lease Address} ]
    
Deputs "handle:$handle"
    set dhcpRange [ixNet getList $handle dhcpRange]
Deputs "dhcpRange:$dhcpRange"
    set rangeName [ ixNet getA $dhcpRange -name ]
Deputs "range name:$rangeName"

    set ret "Status : true\nLog : \n"
    
	set pageCount [ ixNet getA $view/page -totalPages ]
	
	set addrList [list]
	for { set index 1 } { $index <= $pageCount } { incr index } {

		ixNet setA $view/page -currentPage $index
		ixNet commit 
		
		set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
		
		foreach row $stats {
			
			eval {set row} $row
Deputs "row:$row"

			set state [ lindex $row $stateIndex ]
			if { $state == "Lease Bound" } {
				lappend addrList  [ lindex $row $addressIndex ]
			}
		}
			
Deputs "page:$addrList"
	}

	ixNet remove $view
	ixNet commit
	return [GetStandardReturnHeader][ GetStandardReturnBody count [ llength $addrList ] ][ GetStandardReturnBody address "$addrList" ]

}

class Dhcpv4Server {
    inherit DhcpServer

    constructor { port } { chain $port } {}
	method get_stats {} {}
	method reborn {} {
		chain
        ixNet setA $handle/dhcpServerRange -ipType IPv4
        ixNet commit
	}
}
body Dhcpv4Server::get_stats {} {
    set tag "body Dhcpv4Server::get_stats [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
Deputs [ixNet getL $root/statistics view]
    set view [ lindex [ ixNet getF $root/statistics view -caption "DHCPv4 Server" ] 0 ]
Deputs "view:$view"
#    eval {set view} $view
    if { $view == "" } {
		return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
    }
	
    set captionList         [ ixNet getA $view/page -columnCaptions ]
    set rxDiscoverIndex          [ lsearch -exact $captionList {Discovers Received} ]
Deputs "index:$rxDiscoverIndex"
    set txOfferIndex          	 [ lsearch -exact $captionList {Offers Sent} ]
Deputs "index:$txOfferIndex"
    set rxRequestIndex        	 [ lsearch -exact $captionList {Requests Received} ]
Deputs "index:$rxRequestIndex"
    set txACKIndex          	 [ lsearch -exact $captionList {ACKs Sent} ]
Deputs "index:$txACKIndex"
    set txNACKIndex          	 [ lsearch -exact $captionList {NACKs Sent} ]
Deputs "index:$txNACKIndex"
    set rxDeclineIndex        	 [ lsearch -exact $captionList {Declines Received} ]
Deputs "index:$rxDeclineIndex"
    set rxReleaseIndex        	 [ lsearch -exact $captionList {Releases Received} ]
Deputs "index:$rxReleaseIndex"
    #set rxInfoReqIndex        	 [ lsearch -exact $captionList {Information-Requests Received} ]
    set rxInfoReqIndex        	 [ lsearch -exact $captionList {Informs Received} ]
Deputs "index:$rxInfoReqIndex"
    set totLeaseIndex        	 [ lsearch -exact $captionList {Total Leases Allocated} ]
Deputs "index:$totLeaseIndex"
    set totRenewIndex        	 [ lsearch -exact $captionList {Total Leases Renewed} ]
Deputs "index:$totRenewIndex"
    set curLeaseIndex        	 [ lsearch -exact $captionList {Current Leases Allocated} ]
Deputs "index:$curLeaseIndex"

	set refresh [ ixNet exec refresh $view ]
Deputs "refresh:$refresh"
Deputs "after 5 seconds..."
after 5000
    set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    foreach row $stats {
        eval {set row} $row
Deputs "row:$row"
	}
	
    set ret "Status : true\nLog : \n"
    
	set statsItem   "current_bound_count"
	set statsVal    [ lindex $row $curLeaseIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	
	set statsItem   "rx_decline_count"
	set statsVal    [ lindex $row $rxDeclineIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	
	set statsItem   "rx_discover_count"
	set statsVal    [ lindex $row $rxDiscoverIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "rx_inform_count"
	set statsVal    [ lindex $row $rxInfoReqIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "rx_release_count"
	set statsVal    [ lindex $row $rxReleaseIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "rx_request_count"
	set statsVal    [ lindex $row $rxRequestIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "total_bound_count"
	set statsVal    [ lindex $row $totLeaseIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "total_expired_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "total_released_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "total_renewed_count"
	set statsVal    [ lindex $row $totRenewIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_ack_count"
	set statsVal    [ lindex $row $txACKIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_force_renew_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_nak_count"
	set statsVal    [ lindex $row $txNACKIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_offer_count"
	set statsVal    [ lindex $row $txOfferIndex ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]


Deputs "ret:$ret"
    return $ret
	
}

class Dhcpv6Server {
    inherit DhcpServer

    constructor { port } { chain $port } {}
	method get_stats {} {}
	method config { args } {}
	method reborn {} {
		chain
        ixNet setA $handle/dhcpServerRange -ipType IPv6
        ixNet commit
	}
	

}
body Dhcpv6Server::get_stats {} {
    set tag "body Dhcpv6Server::get_stats [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
Deputs [ixNet getL $root/statistics view]
    set view [ lindex [ ixNet getF $root/statistics view -caption "DHCPv6 Server" ] 0 ]
Deputs "view:$view"
#    eval {set view} $view
    if { $view == "" } {
		return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
    }


    set captionList         [ ixNet getA $view/page -columnCaptions ]
    set current_bound_count_index          [ lsearch -exact $captionList {Current Addresses Allocated} ]
    set rx_rebind_count_index          	 [ lsearch -exact $captionList {Rebinds Received} ]
    set rx_release_count_index        	 [ lsearch -exact $captionList {Releases Received} ]
    set rx_renew_count_index          	 [ lsearch -exact $captionList {Renewals Received} ]
    set rx_request_count_index          	 [ lsearch -exact $captionList {Requests Received} ]
    set rx_solicit_count_index        	 [ lsearch -exact $captionList {Solicits Received} ]
    set total_bound_count_index        	 [ lsearch -exact $captionList {Total Addresses Allocated} ]
    set tx_advertise_count_index        	 [ lsearch -exact $captionList {Advertisements Sent} ]
    set tx_reply_count_index        	 [ lsearch -exact $captionList {Replies Sent}  ]
    set rx_info_req_count_index        	 [ lsearch -exact $captionList {Replies Sent}  ]

	set refresh [ ixNet exec refresh $view ]
Deputs "refresh:$refresh"
Deputs "after 5 seconds..."
after 5000
    set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    foreach row $stats {
        eval {set row} $row
Deputs "row:$row"
	}
	
    set ret "Status : true\nLog : \n"
    
	set statsItem   "current_bound_count"
	set statsVal    [ lindex $row $current_bound_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	
	set statsItem   "rx_rebind_count"
	set statsVal    [ lindex $row $rx_rebind_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	
	set statsItem   "rx_release_count"
	set statsVal    [ lindex $row $rx_release_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	set statsItem   "total_released_count"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	

	set statsItem   "rx_renew_count"
	set statsVal    [ lindex $row $rx_renew_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	set statsItem   "total_renewed_count"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "rx_request_count"
	set statsVal    [ lindex $row $rx_request_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "rx_solicit_count"
	set statsVal    [ lindex $row $rx_solicit_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "total_bound_count"
	set statsVal    [ lindex $row $total_bound_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_advertise_count"
	set statsVal    [ lindex $row $tx_advertise_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_reply_count"
	set statsVal    [ lindex $row $tx_reply_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_reply_count"
	set statsVal    [ lindex $row $tx_reply_count_index ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "total_expired_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_reconfigure_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_reconfigure_rebind_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	set statsItem   "tx_reconfigure_renew_count"
	set statsVal    NA
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]


Deputs "ret:$ret"
    return $ret
	



}
body Dhcpv6Server::config { args } {
    set tag "body Dhcpv6Server::config [info script]"
Deputs "----- TAG: $tag -----"
    if { $handle == "" } {
    	set flagReborn 1
    } else {
    	set flagReborn 0
    }
    eval { chain } $args 
    if { $flagReborn } {
        ixNet setA $handle/dhcpServerRange -ipType IPv6
        ixNet commit    	
    }
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-ia_type {
				set ia_type [ string toupper $value ]
			}
		}
	}

	if { [ info exists ia_type ] } {
	
		ixNet setA $handle/dhcpServerRange -dhcp6IaType $ia_type
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]    

}

class DhcpDualStackHost {
    
	inherit NetObject

	public variable dhcpv4
	public variable dhcpv6
	
	constructor { port } {
		set dhcpv4 $this/dhcpv4
		set dhcpv6 $this/dhcpv6
Deputs "create dhcpv4 host"		
		Dhcpv4Host $dhcpv4 $port
		set hDhcp [ $dhcpv4 cget -hDhcp ]
Deputs "dhcp handle: $hDhcp"
Deputs "create dhcpv6 host"	
		Dhcpv6Host $dhcpv6 $port $hDhcp
	}

	method config { args } {
		set tag "body DhcpDualStackHost::config [info script]"
Deputs "----- TAG: $tag -----"

		eval $dhcpv4 config $args
		eval $dhcpv6 config $args
	}	
	
	method unconfig { args } {
		catch {
			$dhcpv4 unconfig
		}
		catch {
			$dhcpv6 unconfig
		}
	}
	method wait_request_complete { args } {
		set tag "body DhcpDualStackHost::wait_request_complete [info script]"
	Deputs "----- TAG: $tag -----"

		set timeout 60

		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-timeout {
					set timeout $value
				}
			}
		}
		
		if { ![ GetResultFromReturn \
			[ $dhcpv4 wait_request_complete $timeout ] ] } {
			return [ GetErrorReturnHeader "dhcpv4 host timeout" ]
		}
		return [ $dhcpv6 wait_request_complete $timeout ]
	}
}

class IPoEHost {

    inherit ProtocolStackObject
	
    constructor { port } { chain $port } {}
    method reborn {} {
	    set tag "body IPoEHost::reborn [info script]"
	    Deputs "----- TAG: $tag -----"
		    
	    chain 
	    	    	
	    set sg_ethernet $stack
	    #-- add dhcp endpoint stack
	    set sg_ipEndpoint [ixNet add $sg_ethernet ipEndpoint]
	    ixNet setA $sg_ipEndpoint -name $this
	    ixNet commit
	    set sg_ipEndpoint [lindex [ixNet remapIds $sg_ipEndpoint] 0]
	    set hIp $sg_ipEndpoint
	
	    #-- add range
	    set sg_range [ixNet add $sg_ipEndpoint range]
	    ixNet setMultiAttrs $sg_range/macRange \
	     -enabled True 
	
	    ixNet setMultiAttrs $sg_range/vlanRange \
	     -enabled False \
	
	    ixNet setMultiAttrs $sg_range/ipRange \
	     -enabled True \
	     -count 1
	
	    ixNet commit
	    set sg_range [ixNet remapIds $sg_range]
	
	    set handle $sg_range
	
    }
	
	method config { args } {}
}
body IPoEHost::config { args } {
    global errorInfo
    global errNumber
    set tag "body IPoEHost::config [info script]"
Deputs "----- TAG: $tag -----"
#disable the interface

    eval { chain } $args
	
	set count 			1
	set ipv4_addr		1.1.1.2
	set ipv4_addr_step	0.0.0.1
	set ipv4_prefix_len	24
	set ipv4_gw			1.1.1.1
	set ipv6_addr		"3ffe:3210::2"
	set ipv6_addr_step	::1
	set ipv6_prefix_len	64
	set ipv6_gw			3ffe:3210::1
	set ip_version		ipv4

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -count {
                if { [ string is integer $value ] } {
                    set count $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -ip_addr {
				set ip_addr $value
            }
            -ip_addr_step {
				set ip_addr_step $value
            }
			-ip_prefix_len {
				set ip_prefix_len $value
			}
			-ip_gw_addr {
				set ip_gw_addr $value
			}
			-ip_gw_addr_step {
				set ip_gw_addr_step $value
			}
			-ip_version {
				set ip_version $value
			}
			-addr_mode {
			    set ipv6auto $value
			}

        }
    }
	
	if { [ info exists count ] } {
		ixNet setA $handle/ipRange -count $count
	}
	
	if { [ info exists ip_version ] } {
		switch [ string tolower $ip_version ] {
			ipv4 {
				set ip_version IPv4
			}
			ipv6 {
				set ip_version IPv6
			}
		}
		ixNet setA $handle/ipRange -ipType $ip_version
		ixNet commit
	}
	
	if { [ info exists ip_addr ] } {
		ixNet setA $handle/ipRange -ipAddress $ip_addr
	}
	
	if { [ info exists ip_addr_step ] } {
		ixNet setA $handle/ipRange -incrementBy $ip_addr_step
	}
	
	if { [ info exists ip_prefix_len ] } {
		ixNet setA $handle/ipRange -prefix $ip_prefix_len
	}

	if { [ info exists ip_gw_addr ] } {
		ixNet setA $handle/ipRange -gatewayAddress $ip_gw_addr
	}
	
	if { [ info exists ip_gw_addr_step ] } {
		ixNet setA $handle/ipRange -gatewayIncrement $ip_gw_addr_step
	}

	ixNet commit
	
	

}


class Ipv6AutoConfigHost {

    inherit ProtocolStackObject
	public variable hIp
    constructor { port } { chain $port } {}
    method reborn {} {
	    set tag "body Ipv6AutoConfigHost::reborn [info script]"
	    Deputs "----- TAG: $tag -----"
		    
	    chain 
	    	    	
	    set sg_ethernet $stack
	    #-- add ipoe endpoint stack
	    set sg_ipEndpoint [ixNet add $sg_ethernet ipEndpoint]
	    ixNet setA $sg_ipEndpoint -name $this
	    ixNet commit
	    set sg_ipEndpoint [lindex [ixNet remapIds $sg_ipEndpoint] 0]
	    set hIp $sg_ipEndpoint
	
	    #-- add range
	    set sg_range [ixNet add $sg_ipEndpoint range]
	    ixNet setMultiAttrs $sg_range/macRange \
	     -enabled True 
	
	    ixNet setMultiAttrs $sg_range/vlanRange \
	     -enabled False \
	
	    ixNet setMultiAttrs $sg_range/ipRange \
	     -enabled True \
	     -count 1
	
	    ixNet commit
	    set sg_range [ixNet remapIds $sg_range]
	
	    set handle $sg_range
		
		set sg_ipRangeOptions [ixNet add $hPort/protocolStack ipRangeOptions]
        ixNet setAttrs $sg_ipRangeOptions \
            -ipv6AddressMode {autoconf}
		
		ixNet commit
		
		set sg_Options [ixNet add $hPort/protocolStack options]
		ixNet setMultiAttrs $sg_Options\
            -routerSolicitationDelay 1 \
            -routerSolicitationInterval 3 \
            -routerSolicitations 2 \
            -retransTime 1000 \
            -dadTransmits 1 \
            -dadEnabled True \
            -ipv4RetransTime 3000 \
            -ipv4McastSolicit 4
			
		ixNet commit
    }
	
	method config { args } {}
	method start {} {}
    method stop {} {}
}
body Ipv6AutoConfigHost::config { args } {
    global errorInfo
    global errNumber
    set tag "body Ipv6AutoConfigHost::config [info script]"
Deputs "----- TAG: $tag -----"
#disable the interface

    eval { chain } $args
	
	set count 			1
	

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -count {
                if { [ string is integer $value ] } {
                    set count $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -dup_addr_detection {
			    if {$value == "yes"} {
				    set dad_enabled "True"
				} else {
				    set dad_enabled "False"
				}
            }
            -dup_addr_detect_transmits {
				set dad_transmits $value
            }
			-retrans_timer {
				set retrans_timer $value
			}
			-router_solicitation_retrans_timer {
			    if {[ string is integer $value ] } {
				    set timer_value [expr $value/1000]
				    set router_retrans_timer $timer_value
				} else {
				     error "$errNumber(1) key:$key value:$value"
				}
			}
			-router_solicitation_retries {
				set router_solicitation_retries $value
			}
			
        }
    }
	
	
	if { [ info exists count ] } {
		ixNet setA $handle/ipRange -count $count
	}
	
	
	ixNet setA $handle/ipRange -ipType IPv6
	ixNet commit
	
	
	if { [ info exists dad_enabled ] } {
		ixNet setA $hPort/protocolStack/options \
		    -dadEnabled $dad_enabled
		ixNet commit
	}
	
	if { [ info exists dad_transmits ] } {
		ixNet setA $hPort/protocolStack/options \
		    -dadTransmits $dad_transmits
	}
	
	if { [ info exists retrans_timer ] } {
		ixNet setA $hPort/protocolStack/options \
		    -retransTime $retrans_timer
		
	}
	
	if { [ info exists router_retrans_timer ] } {
		ixNet setA $hPort/protocolStack/options \
		    -routerSolicitationInterval $router_retrans_timer \
		
	}

	if { [ info exists router_solicitation_retries ] } {
		ixNet setA $hPort/protocolStack/options \
		    -routerSolicitations $router_solicitation_retries 
		
	}
	
	ixNet commit
	
}

body Ipv6AutoConfigHost::start {} {
    set tag "body Ipv6AutoConfigHost::start [info script]"
Deputs "----- TAG: $tag -----"
Deputs "handle : $handle"
	after 3000
	if { [ catch {
		ixNet exec start $hIp async
	} ] } {
		after 3000
		ixNet exec start $hIp async
	}
    return [GetStandardReturnHeader]
}
body Ipv6AutoConfigHost::stop {} {
    set tag "body Ipv6AutoConfigHost::stop [info script]"
Deputs "----- TAG: $tag -----"
Deputs "handle : $handle"
    ixNet exec stop $hIp
    return [GetStandardReturnHeader]
}

# Child Lists:
	# ancpRange (kOptional : getList)
	# dhcpRange (kRequired : getList)
	# dot1xRange (kOptional : getList)
	# eapoUdpRange (kOptional : getList)
	# esmcRange (kOptional : getList)
	# igmpMldRange (kOptional : getList)
	# iptvRange (kOptional : getList)
	# macRange (kRequired : getList)
	# ptpRangeOverMac (kOptional : getList)
	# vicClientRange (kOptional : getList)
	# vlanRange (kRequired : getList)
	# webAuthRange (kOptional : getList)
# Execs:
	# customProtocolStack((kArray)[(kObjref)=/vport/protocolStack/...],(kArray)[(kString)],(kEnumValue)=kAppend,kMerge,kOverwrite)
	# dhcpClientPause((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientRebind((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientRenew((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientResume((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientRetry((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientStart((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientStart((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range],(kEnumValue)=async,sync)
	# dhcpClientStop((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range])
	# dhcpClientStop((kArray)[(kObjref)=/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range],(kEnumValue)=async,sync)
	# disableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))
	# enableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))
#	start((kArray)[(kObjref)=/vport/protocolStack/atm,/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/ancp,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/dhcpServerEndpoint,/vport/protocolStack/atm/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip,/vport/protocolStack/atm/emulatedRouter/ip/ancp,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/twampClient,/vport/protocolStack/atm/emulatedRouter/ip/twampServer,/vport/protocolStack/atm/emulatedRouter/ipEndpoint,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/atm/emulatedRouterEndpoint,/vport/protocolStack/atm/ip,/vport/protocolStack/atm/ip/ancp,/vport/protocolStack/atm/ip/egtpEnbEndpoint,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpUeEndpoint,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tpEndpoint,/vport/protocolStack/atm/ip/l2tpEndpoint/range,/vport/protocolStack/atm/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/smDnsEndpoint,/vport/protocolStack/atm/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/twampClient,/vport/protocolStack/atm/ip/twampServer,/vport/protocolStack/atm/ipEndpoint,/vport/protocolStack/atm/ipEndpoint/ancp,/vport/protocolStack/atm/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/ipEndpoint/twampClient,/vport/protocolStack/atm/ipEndpoint/twampServer,/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/ancp,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/ancp,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint/range/ancpRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet,/vport/protocolStack/ethernet/dcbxEndpoint,/vport/protocolStack/ethernet/dcbxEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/dhcpServerEndpoint,/vport/protocolStack/ethernet/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip,/vport/protocolStack/ethernet/emulatedRouter/ip/ancp,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ip/twampServer,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/ethernet/emulatedRouterEndpoint,/vport/protocolStack/ethernet/esmc,/vport/protocolStack/ethernet/fcoeClientEndpoint,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFdiscRange,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFlogiRange,/vport/protocolStack/ethernet/fcoeFwdEndpoint,/vport/protocolStack/ethernet/fcoeFwdEndpoint/range,/vport/protocolStack/ethernet/fcoeFwdEndpoint/secondaryRange,/vport/protocolStack/ethernet/ip,/vport/protocolStack/ethernet/ip/ancp,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/twampClient,/vport/protocolStack/ethernet/ip/twampServer,/vport/protocolStack/ethernet/ipEndpoint,/vport/protocolStack/ethernet/ipEndpoint/ancp,/vport/protocolStack/ethernet/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ipEndpoint/twampClient,/vport/protocolStack/ethernet/ipEndpoint/twampServer,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/ancp,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/ancp,/vport/protocolStack/ethernet/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/vepaEndpoint,/vport/protocolStack/ethernet/vepaEndpoint/range,/vport/protocolStack/ethernetEndpoint,/vport/protocolStack/ethernetEndpoint/esmc,/vport/protocolStack/fcClientEndpoint,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range/fcClientFdiscRange,/vport/protocolStack/fcClientEndpoint/range/fcClientFlogiRange,/vport/protocolStack/fcFportFwdEndpoint])
#	start((kArray)[(kObjref)=/vport/protocolStack/atm,/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/ancp,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/dhcpServerEndpoint,/vport/protocolStack/atm/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip,/vport/protocolStack/atm/emulatedRouter/ip/ancp,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/twampClient,/vport/protocolStack/atm/emulatedRouter/ip/twampServer,/vport/protocolStack/atm/emulatedRouter/ipEndpoint,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/atm/emulatedRouterEndpoint,/vport/protocolStack/atm/ip,/vport/protocolStack/atm/ip/ancp,/vport/protocolStack/atm/ip/egtpEnbEndpoint,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpUeEndpoint,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tpEndpoint,/vport/protocolStack/atm/ip/l2tpEndpoint/range,/vport/protocolStack/atm/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/smDnsEndpoint,/vport/protocolStack/atm/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/twampClient,/vport/protocolStack/atm/ip/twampServer,/vport/protocolStack/atm/ipEndpoint,/vport/protocolStack/atm/ipEndpoint/ancp,/vport/protocolStack/atm/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/ipEndpoint/twampClient,/vport/protocolStack/atm/ipEndpoint/twampServer,/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/ancp,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/ancp,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint/range/ancpRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet,/vport/protocolStack/ethernet/dcbxEndpoint,/vport/protocolStack/ethernet/dcbxEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/dhcpServerEndpoint,/vport/protocolStack/ethernet/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip,/vport/protocolStack/ethernet/emulatedRouter/ip/ancp,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ip/twampServer,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/ethernet/emulatedRouterEndpoint,/vport/protocolStack/ethernet/esmc,/vport/protocolStack/ethernet/fcoeClientEndpoint,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFdiscRange,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFlogiRange,/vport/protocolStack/ethernet/fcoeFwdEndpoint,/vport/protocolStack/ethernet/fcoeFwdEndpoint/range,/vport/protocolStack/ethernet/fcoeFwdEndpoint/secondaryRange,/vport/protocolStack/ethernet/ip,/vport/protocolStack/ethernet/ip/ancp,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/twampClient,/vport/protocolStack/ethernet/ip/twampServer,/vport/protocolStack/ethernet/ipEndpoint,/vport/protocolStack/ethernet/ipEndpoint/ancp,/vport/protocolStack/ethernet/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ipEndpoint/twampClient,/vport/protocolStack/ethernet/ipEndpoint/twampServer,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/ancp,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/ancp,/vport/protocolStack/ethernet/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/vepaEndpoint,/vport/protocolStack/ethernet/vepaEndpoint/range,/vport/protocolStack/ethernetEndpoint,/vport/protocolStack/ethernetEndpoint/esmc,/vport/protocolStack/fcClientEndpoint,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range/fcClientFdiscRange,/vport/protocolStack/fcClientEndpoint/range/fcClientFlogiRange,/vport/protocolStack/fcFportFwdEndpoint],(kEnumValue)=async,sync)
#	stop((kArray)[(kObjref)=/vport/protocolStack/atm,/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/ancp,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/dhcpServerEndpoint,/vport/protocolStack/atm/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip,/vport/protocolStack/atm/emulatedRouter/ip/ancp,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/twampClient,/vport/protocolStack/atm/emulatedRouter/ip/twampServer,/vport/protocolStack/atm/emulatedRouter/ipEndpoint,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/atm/emulatedRouterEndpoint,/vport/protocolStack/atm/ip,/vport/protocolStack/atm/ip/ancp,/vport/protocolStack/atm/ip/egtpEnbEndpoint,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpUeEndpoint,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tpEndpoint,/vport/protocolStack/atm/ip/l2tpEndpoint/range,/vport/protocolStack/atm/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/smDnsEndpoint,/vport/protocolStack/atm/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/twampClient,/vport/protocolStack/atm/ip/twampServer,/vport/protocolStack/atm/ipEndpoint,/vport/protocolStack/atm/ipEndpoint/ancp,/vport/protocolStack/atm/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/ipEndpoint/twampClient,/vport/protocolStack/atm/ipEndpoint/twampServer,/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/ancp,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/ancp,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint/range/ancpRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet,/vport/protocolStack/ethernet/dcbxEndpoint,/vport/protocolStack/ethernet/dcbxEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/dhcpServerEndpoint,/vport/protocolStack/ethernet/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip,/vport/protocolStack/ethernet/emulatedRouter/ip/ancp,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ip/twampServer,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/ethernet/emulatedRouterEndpoint,/vport/protocolStack/ethernet/esmc,/vport/protocolStack/ethernet/fcoeClientEndpoint,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFdiscRange,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFlogiRange,/vport/protocolStack/ethernet/fcoeFwdEndpoint,/vport/protocolStack/ethernet/fcoeFwdEndpoint/range,/vport/protocolStack/ethernet/fcoeFwdEndpoint/secondaryRange,/vport/protocolStack/ethernet/ip,/vport/protocolStack/ethernet/ip/ancp,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/twampClient,/vport/protocolStack/ethernet/ip/twampServer,/vport/protocolStack/ethernet/ipEndpoint,/vport/protocolStack/ethernet/ipEndpoint/ancp,/vport/protocolStack/ethernet/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ipEndpoint/twampClient,/vport/protocolStack/ethernet/ipEndpoint/twampServer,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/ancp,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/ancp,/vport/protocolStack/ethernet/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/vepaEndpoint,/vport/protocolStack/ethernet/vepaEndpoint/range,/vport/protocolStack/ethernetEndpoint,/vport/protocolStack/ethernetEndpoint/esmc,/vport/protocolStack/fcClientEndpoint,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range/fcClientFdiscRange,/vport/protocolStack/fcClientEndpoint/range/fcClientFlogiRange,/vport/protocolStack/fcFportFwdEndpoint])
#	stop((kArray)[(kObjref)=/vport/protocolStack/atm,/vport/protocolStack/atm/dhcpEndpoint,/vport/protocolStack/atm/dhcpEndpoint/ancp,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/dhcpServerEndpoint,/vport/protocolStack/atm/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/atm/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip,/vport/protocolStack/atm/emulatedRouter/ip/ancp,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ip/twampClient,/vport/protocolStack/atm/emulatedRouter/ip/twampServer,/vport/protocolStack/atm/emulatedRouter/ipEndpoint,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/atm/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/atm/emulatedRouterEndpoint,/vport/protocolStack/atm/ip,/vport/protocolStack/atm/ip/ancp,/vport/protocolStack/atm/ip/egtpEnbEndpoint,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/egtpUeEndpoint,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/l2tpEndpoint,/vport/protocolStack/atm/ip/l2tpEndpoint/range,/vport/protocolStack/atm/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/smDnsEndpoint,/vport/protocolStack/atm/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/atm/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/atm/ip/twampClient,/vport/protocolStack/atm/ip/twampServer,/vport/protocolStack/atm/ipEndpoint,/vport/protocolStack/atm/ipEndpoint/ancp,/vport/protocolStack/atm/ipEndpoint/range/ancpRange,/vport/protocolStack/atm/ipEndpoint/range/twampControlRange,/vport/protocolStack/atm/ipEndpoint/twampClient,/vport/protocolStack/atm/ipEndpoint/twampServer,/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/ancp,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/ancp,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint/range/ancpRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet,/vport/protocolStack/ethernet/dcbxEndpoint,/vport/protocolStack/ethernet/dcbxEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint,/vport/protocolStack/ethernet/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/dhcpServerEndpoint,/vport/protocolStack/ethernet/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/dhcpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint,/vport/protocolStack/ethernet/emulatedRouter/dhcpServerEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip,/vport/protocolStack/ethernet/emulatedRouter/ip/ancp,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/emulatedRouter/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ip/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ip/twampServer,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/ancp,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampClient,/vport/protocolStack/ethernet/emulatedRouter/ipEndpoint/twampServer,/vport/protocolStack/ethernet/emulatedRouterEndpoint,/vport/protocolStack/ethernet/esmc,/vport/protocolStack/ethernet/fcoeClientEndpoint,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFdiscRange,/vport/protocolStack/ethernet/fcoeClientEndpoint/range/fcoeClientFlogiRange,/vport/protocolStack/ethernet/fcoeFwdEndpoint,/vport/protocolStack/ethernet/fcoeFwdEndpoint/range,/vport/protocolStack/ethernet/fcoeFwdEndpoint/secondaryRange,/vport/protocolStack/ethernet/ip,/vport/protocolStack/ethernet/ip/ancp,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpEnbEndpoint/ueSecondaryRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpMmeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpPcrfEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpSgwEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/egtpUeEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ip/smDnsEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ip/twampClient,/vport/protocolStack/ethernet/ip/twampServer,/vport/protocolStack/ethernet/ipEndpoint,/vport/protocolStack/ethernet/ipEndpoint/ancp,/vport/protocolStack/ethernet/ipEndpoint/range/ancpRange,/vport/protocolStack/ethernet/ipEndpoint/range/twampControlRange,/vport/protocolStack/ethernet/ipEndpoint/twampClient,/vport/protocolStack/ethernet/ipEndpoint/twampServer,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/ancp,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/ancp,/vport/protocolStack/ethernet/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint/range/ancpRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6PdClientRange,/vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6ServerRange,/vport/protocolStack/ethernet/vepaEndpoint,/vport/protocolStack/ethernet/vepaEndpoint/range,/vport/protocolStack/ethernetEndpoint,/vport/protocolStack/ethernetEndpoint/esmc,/vport/protocolStack/fcClientEndpoint,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range,/vport/protocolStack/fcClientEndpoint/range/fcClientFdiscRange,/vport/protocolStack/fcClientEndpoint/range/fcClientFlogiRange,/vport/protocolStack/fcFportFwdEndpoint],(kEnumValue)=async,sync)

class Dot1xHost {
    inherit ProtocolStackObject
    
    public variable type
    
    constructor { port } { chain $port } {}
	method reborn { { onStack null } } {
	    set tag "body Dot1xHost::reborn [info script]"
	    Deputs "----- TAG: $tag -----"
		    
	    array set rangeStats [list]
	    if { $onStack == "null" } {
Deputs "new dot1x endpoint"
            chain
			if { [ llength [ixNet getL $hPort/protocolStack ethernetEndpoint] ] > 0 } {
				set sg_ethernet [ lindex [ixNet getL $hPort/protocolStack ethernetEndpoint] 0 ]
			} else {
				set sg_ethernet [ixNet add $hPort/protocolStack ethernetEndpoint]
				ixNet commit
				set sg_ethernet [ixNet remapIds $sg_ethernet]
			} 
			
			#-- add dhcp endpoint stack
			set sg_dot1xEndpoint [ixNet add $sg_ethernet dot1x]
			#ixNet setA $sg_dot1xEndpoint -name $this
			ixNet commit
			set sg_dot1xEndpoint [lindex [ixNet remapIds $sg_dot1xEndpoint] 0]
			set hDot1x $sg_dot1xEndpoint
		} else {
Deputs "based on existing stack:$onStack"		
			set hDot1x $onStack
		}
	
	    #-- add range
	    set sg_range [ixNet add $sg_ethernet range]
		ixNet commit
		set sg_range [ixNet remapIds $sg_range]
	    ixNet setMultiAttrs $sg_range/macRange \
	     -enabled True 
	
	    ixNet setMultiAttrs $sg_range/vlanRange \
	     -enabled False 
		ixNet commit
	
	    set dot1x_range [lindex [ixNet getL $sg_range dot1xRange] 0]
        ixNet setA $dot1x_range \
	     -enabled True
	
	    ixNet commit
	    
	
	    set handle $sg_range
		
		
		ixNet commit
    }
    method config { args } {}
    method start {} {
        set tag "body dot1xHost::start [info script]"
Deputs "----- TAG: $tag -----"
        ixNet exec start $handle
	
	    ixNet commit
        return [GetStandardReturnHeader]
    }
    method stop {} {
     set tag "body dot1xHost::stop [info script]"
Deputs "----- TAG: $tag -----"
        ixNet exec stop $handle
	
	    ixNet commit
        return [GetStandardReturnHeader]
    }
    

}

body Dot1xHost::config { args } {
    global errorInfo
    global errNumber
    set tag "body Dot1xHost::config [info script]"
Deputs "----- TAG: $tag -----"
#disable the interface

    eval { chain } $args
	
	set count 			1

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -count {
                if { [ string is integer $value ] } {
                    set count $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -auth_type {
				set authtype $value
            }
            -user_name {
				set username $value
            }
			-password {
				set password $value
			}
        }
    }
	
	if { [ info exists count ] } {
		ixNet setA $handle/macRange -count $count
        ixNet commit
	}
	
	set dot1x_range [lindex [ixNet getL $handle dot1xRange] 0]
	if { [ info exists authtype] } {
		
		ixNet setA $dot1x_range -protocol $authtype
		ixNet commit
	} else {
        ixNet setA $dot1x_range -protocol "MD5"
		ixNet commit
    
    }
	
	if { [ info exists username ] } {
		ixNet setA $dot1x_range -userName $username
        ixNet commit
	}
	
	if { [ info exists password ] } {
		ixNet setA $dot1x_range -userPassword $password
        ixNet commit
	}

}
