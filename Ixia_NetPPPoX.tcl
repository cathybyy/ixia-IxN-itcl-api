
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create


class PppoeHost {
    inherit ProtocolStackObject
    
    #public variable type
	public variable optionSet
	
	public variable rangeStats
	public variable hostCnt
	public variable hPppox
    
    constructor { port } { chain $port } {}
	method reborn {} {}
	method config { args } {}
	method get_summary_stats {} {}
	method wait_connect_complete { args } {}
    method CreatePPPoEPerSessionView {} {
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
        set pppoxRange [ixNet getList $handle pppoxRange]
Deputs "pppoxRange:$pppoxRange"
        set rangeName [ ixNet getA $pppoxRange -name ]
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
    
    
}

body PppoeHost::reborn {} {
    
	set tag "body PppoeHost::reborn [info script]"
	Deputs "----- TAG: $tag -----"
		
	chain 
      
	set sg_ethernet $stack
    #-- add dhcp endpoint stack
    set sg_pppoxEndpoint [ixNet add $sg_ethernet pppoxEndpoint]
    ixNet setA $sg_pppoxEndpoint -name $this
    ixNet commit
    set sg_pppoxEndpoint [lindex [ixNet remapIds $sg_pppoxEndpoint] 0]
    set hPppox $sg_pppoxEndpoint
    
    #-- add range
    set sg_range [ixNet add $sg_pppoxEndpoint range]
    ixNet setMultiAttrs $sg_range/macRange \
     -enabled True 
    
    ixNet setMultiAttrs $sg_range/vlanRange \
     -enabled False \
    
    ixNet setMultiAttrs $sg_range/pppoxRange \
     -enabled True \
     -numSessions 1
    
    ixNet commit
    set sg_range [ixNet remapIds $sg_range]
    
    set handle $sg_range
    #set trafficObj 
	
	#disable all the interface defined on port
	foreach int [ ixNet getL $hPort interface ] {
		ixNet setA $int -enabled false
	}
	ixNet commit
}

body PppoeHost::config { args } {
    global errorInfo
    global errNumber

	set tag "body PppoeHost::config [info script]"
	Deputs "----- TAG: $tag -----"
		
    eval { chain } $args
	
    set ENcp       [ list ipv4 ipv6 ipv4v6 ]
    set EAuth      [ list none auto chap_md5 pap ]

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
			-ipcp_encap {
                set value [ string tolower $value ]
                if { [ lsearch -exact $ENcp $value ] >= 0 } {
                    
                    set ipcp_encap $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-authentication {
                set value [ string tolower $value ]
                if { [ lsearch -exact $EAuth $value ] >= 0 } {
                    
                    set authentication $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-enable_domain {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_domain $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-domain {
				set domain $value
			}
			-user_name {
				set user_name $value
			}
			-password {
				set password $value
			}
        }
    }
	
	if { [ info exists count ] } {
		ixNet setMultiAttrs $handle/pppoxRange \
		 -numSessions $count
	}
	
	if { [ info exists ipcp_encap ] } {
		switch $ipcp_encap {
			ipv4 {
				set ipcp_encap IPv4
			}
			ipv6 {
				set ipcp_encap IPv6
			}
			ipv4v6 {
				set ipcp_encap DualStack
			}
		}
		ixNet setA $handle/pppoxRange -ncpType $ipcp_encap
	}
	
	if { [ info exists authentication ] } {
	
		switch $authentication {
			auto {
				set authentication papOrChap
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
			
		}
		ixNet setA $handle/pppoxRange -authType $authentication
	}
	
	if { [ info exists enable_domain ] } {
		
		ixNet setA $handle/pppoxRange -enableDomainGroups $enable_domain
	}
	
	if { [ info exists domain ] } {
	
		foreach domainGroup [ ixNet getL $handle/pppoxRange domainGroup ] {
			ixNet remove $domainGroup
		}
		
		foreach domainGroup $domain {
			set dg [ixNet add $handle/pppoxRange domainGroup ]
			ixNet setA $dg -baseName $domainGroup
			ixNet commit
		}
	}
	
	

	ixNet commit
	return [GetStandardReturnHeader]

}

body PppoeHost::get_summary_stats {} {

    set tag "body PppoeHost::get_summary_stats [info script]"
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

body PppoeHost::wait_connect_complete { args } {
    set tag "body PppoeHost::wait_connect_complete [info script]"
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
		
		set stats [ get_summary_stats ]
		set initStats [ GetStatsFromReturn $stats attempted_count ]
		set succStats [ GetStatsFromReturn $stats connected_success_count ]
Deputs "initStats:$initStats == succStats:$succStats ?"		
		if { $succStats != "" && $succStats >= $initStats && $initStats > 0 } {
			break	
		}
		
		after 1000
	}
	
	return [GetStandardReturnHeader]

}
# =============
# ethernet
# =============
# Child Lists:
	# dcbxEndpoint (kList : add, remove, getList)
	# dhcpEndpoint (kList : add, remove, getList)
	# dhcpServerEndpoint (kList : add, remove, getList)
	# dot1x (kList : add, remove, getList)
	# emulatedRouter (kList : add, remove, getList)
	# emulatedRouterEndpoint (kList : add, remove, getList)
	# esmc (kList : add, remove, getList)
	# fcoeClientEndpoint (kList : add, remove, getList)
	# fcoeFwdEndpoint (kList : add, remove, getList)
	# ip (kList : add, remove, getList)
	# ipEndpoint (kList : add, remove, getList)
	# pppox (kList : add, remove, getList)
	# pppoxEndpoint (kList : add, remove, getList)
	# ptp (kList : add, remove, getList)
	# vepaEndpoint (kList : add, remove, getList)
	# vicClient (kList : add, remove, getList)
# Attributes:
	# -name (readOnly=False, type=(kString))
	# -objectId (readOnly=True, type=(kString))
# Execs:
	# customProtocolStack((kArray)[(kObjref)=/vport/protocolStack/...],(kArray)[(kString)],(kEnumValue)=kAppend,kMerge,kOverwrite)
	# disableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))
	# enableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))

# =============
# pppoxEndpoint
# =============
# Child Lists:
	# ancp (kList : add, remove, getList)
	# dhcp2v6Client (kList : add, remove, getList)
	# dhcpv6Client (kList : add, remove, getList)
	# dhcpv6Server (kList : add, remove, getList)
	# igmpMld (kList : add, remove, getList)
	# igmpQuerier (kList : add, remove, getList)
	# iptv (kList : add, remove, getList)
	# range (kList : add, remove, getList)
# Attributes:
	# -name (readOnly=False, type=(kString))
	# -objectId (readOnly=True, type=(kString))
	# -perSessionStats (readOnly=True, type=(kArray)[(kString)])
# Execs:
	# customProtocolStack((kArray)[(kObjref)=/vport/protocolStack/...],(kArray)[(kString)],(kEnumValue)=kAppend,kMerge,kOverwrite)
	# disableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))
	# enableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))
	# pppoxCancel((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxClearStats((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppoxEndpoint])
	# pppoxConfigure((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxDeconfigure((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxNegotiateTo((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppoxEndpoint],(kInteger))
	# pppoxNegotiateTo((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppoxEndpoint],(kInteger),(kEnumValue)=async,sync)
	# pppoxPause((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxPause((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxResume((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxResume((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxRetry((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxRetry((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxSendNdpRs((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kInteger))
	# pppoxSendNdpRs((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kInteger),(kEnumValue)=async,sync)
	# pppoxStart((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxStart((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxStop((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxStop((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)

# =============
# pppoxEndpoint.range
# =============
	# Child Lists:
	# ancpRange (kOptional : getList)
	# dhcpv6ClientRange (kOptional : getList)
	# dhcpv6PdClientRange (kOptional : getList)
	# dhcpv6ServerRange (kOptional : getList)
	# dot1xRange (kOptional : getList)
	# esmcRange (kOptional : getList)
	# igmpMldRange (kOptional : getList)
	# igmpQuerierRange (kOptional : getList)
	# iptvRange (kOptional : getList)
	# macRange (kRequired : getList)
	# pppoxRange (kRequired : getList)
	# ptpRangeOverMac (kOptional : getList)
	# vicClientRange (kOptional : getList)
	# vlanRange (kRequired : getList)
# Execs:
	# pppoxCancel((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxConfigure((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxDeconfigure((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxPause((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxPause((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxResume((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxResume((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxRetry((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxRetry((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxSendNdpRs((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kInteger))
	# pppoxSendNdpRs((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kInteger),(kEnumValue)=async,sync)
	# pppoxStart((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxStart((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)
	# pppoxStop((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range])
	# pppoxStop((kArray)[(kObjref)=/vport/protocolStack/atm/pppox,/vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/pppox,/vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range,/vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint,/vport/protocolStack/ethernet/pppoxEndpoint/range],(kEnumValue)=async,sync)

# =============
# pppoxEndpoint.range.pppoxRange
# =============
# Child Lists:
	# acMac (kList : add, remove, getList)
	# acName (kList : add, remove, getList)
	# domainGroup (kList : add, remove, getList)
# Attributes:
	# -acName (readOnly=False, type=(kString))
	# -acOptions (readOnly=False, type=(kString))
	# -actualRateDownstream (readOnly=False, type=(kInteger64))
	# -actualRateUpstream (readOnly=False, type=(kInteger64))
	# -agentCircuitId (readOnly=False, type=(kString))
	# -agentRemoteId (readOnly=False, type=(kString))
	# -authOptions (readOnly=False, type=(kString))
	# -authRetries (readOnly=False, type=(kInteger64))
	# -authTimeout (readOnly=False, type=(kInteger64))
	# -authType (readOnly=False, type=(kString))
	# -chapName (readOnly=False, type=(kString))
	# -chapSecret (readOnly=False, type=(kString))
	# -clientBaseIid (readOnly=False, type=(kString))
	# -clientBaseIp (readOnly=False, type=(kString))
	# -clientDnsOptions (readOnly=False, type=(kString))
	# -clientIidIncr (readOnly=False, type=(kInteger64))
	# -clientIpIncr (readOnly=False, type=(kString))
	# -clientNetmask (readOnly=False, type=(kString))
	# -clientNetmaskOptions (readOnly=False, type=(kString))
	# -clientPrimaryDnsAddress (readOnly=False, type=(kString))
	# -clientSecondaryDnsAddress (readOnly=False, type=(kString))
	# -clientSignalIwf (readOnly=False, type=(kBool))
	# -clientSignalLoopChar (readOnly=False, type=(kBool))
	# -clientSignalLoopEncapsulation (readOnly=False, type=(kBool))
	# -clientSignalLoopId (readOnly=False, type=(kBool))
	# -dataLink (readOnly=False, type=(kString))
	# -dnsServerList (readOnly=False, type=(kString))
	# -domainList (readOnly=False, type=(kString))
	# -echoReqInterval (readOnly=False, type=(kInteger64))
	# -enabled (readOnly=False, type=(kBool))
	# -enableDnsRa (readOnly=False, type=(kBool))
	# -enableDomainGroups (readOnly=False, type=(kBool))
	# -enableEchoReq (readOnly=False, type=(kBool))
	# -enableEchoRsp (readOnly=False, type=(kBool))
	# -enableIncludeTagInPadi (readOnly=False, type=(kBool), deprecated)
	# -enableIncludeTagInPado (readOnly=False, type=(kBool), deprecated)
	# -enableIncludeTagInPadr (readOnly=False, type=(kBool), deprecated)
	# -enableIncludeTagInPads (readOnly=False, type=(kBool), deprecated)
	# -enableIntermediateAgentTags (readOnly=False, type=(kBool), deprecated)
	# -enableMruNegotiation (readOnly=False, type=(kBool))
	# -enablePasswordCheck (readOnly=False, type=(kBool))
	# -enableRedial (readOnly=False, type=(kBool))
	# -encaps1 (readOnly=False, type=(kString))
	# -encaps2 (readOnly=False, type=(kString))
	# -ipv6AddrPrefixLen (readOnly=False, type=(kInteger64))
	# -ipv6PoolPrefix (readOnly=False, type=(kString))
	# -ipv6PoolPrefixLen (readOnly=False, type=(kInteger64))
	# -lcpOptions (readOnly=False, type=(kString))
	# -lcpRetries (readOnly=False, type=(kInteger64))
	# -lcpTermRetries (readOnly=False, type=(kInteger64))
	# -lcpTermTimeout (readOnly=False, type=(kInteger64))
	# -lcpTimeout (readOnly=False, type=(kInteger64))
	# -mtu (readOnly=False, type=(kInteger64))
	# -name (readOnly=False, type=(kString))
	# -ncpRetries (readOnly=False, type=(kInteger64))
	# -ncpTimeout (readOnly=False, type=(kInteger64))
	# -ncpType (readOnly=False, type=(kString))
	# -numSessions (readOnly=False, type=(kInteger64))
	# -objectId (readOnly=True, type=(kString))
	# -padiRetries (readOnly=False, type=(kInteger64))
	# -padiTimeout (readOnly=False, type=(kInteger64))
	# -padrRetries (readOnly=False, type=(kInteger64))
	# -padrTimeout (readOnly=False, type=(kInteger64))
	# -papPassword (readOnly=False, type=(kString))
	# -papUser (readOnly=False, type=(kString))
	# -pppoeOptions (readOnly=False, type=(kString))
	# -redialMax (readOnly=False, type=(kInteger64))
	# -redialTimeout (readOnly=False, type=(kInteger64))
	# -serverBaseIid (readOnly=False, type=(kString))
	# -serverBaseIp (readOnly=False, type=(kString))
	# -serverDnsOptions (readOnly=False, type=(kString))
	# -serverIidIncr (readOnly=False, type=(kInteger64))
	# -serverIpIncr (readOnly=False, type=(kString), deprecated)
	# -serverNetmask (readOnly=False, type=(kString))
	# -serverNetmaskOptions (readOnly=False, type=(kString))
	# -serverPrimaryDnsAddress (readOnly=False, type=(kString))
	# -serverSecondaryDnsAddress (readOnly=False, type=(kString))
	# -serverSignalIwf (readOnly=False, type=(kBool))
	# -serverSignalLoopChar (readOnly=False, type=(kBool))
	# -serverSignalLoopEncapsulation (readOnly=False, type=(kBool))
	# -serverSignalLoopId (readOnly=False, type=(kBool))
	# -serviceName (readOnly=False, type=(kString))
	# -serviceOptions (readOnly=False, type=(kString))
	# -unlimitedRedialAttempts (readOnly=False, type=(kBool))
	# -useMagic (readOnly=False, type=(kBool))
# Execs:
	# customProtocolStack((kArray)[(kObjref)=/vport/protocolStack/...],(kArray)[(kString)],(kEnumValue)=kAppend,kMerge,kOverwrite)
	# disableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))
	# enableProtocolStack((kObjref)=/vport/protocolStack/...,(kString))

