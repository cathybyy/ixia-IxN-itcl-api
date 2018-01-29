
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create


class L2tpHost {
    inherit ProtocolStackObject
    
    #public variable type
	public variable optionSet
	
	public variable rangeStats
	public variable hostCnt
	public variable hPppox
    
    constructor { port } { chain $port } {}
	method reborn {} {}
	method config { args } {}
	method connect { } { start }
	method disconnect { } { stop }
	method get_summary_stats {} {}
    method CreateL2tpPerSessionView {} {
        set tag "body L2tpHost::CreateL2tpPerSessionView [info script]"
		Deputs "----- TAG: $tag -----"
        set root [ixNet getRoot]
        set customView          [ ixNet add $root/statistics view ]
        ixNet setM  $customView -caption "L2tpPerSessionView" -type layer23ProtocolStack -visible true
        ixNet commit
        set customView          [ ixNet remapIds $customView ]
        Deputs "view:$customView"
        set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
        Deputs "available filter:$availableFilter"
        set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
        Deputs "filter:$filter"
        Deputs "handle:$handle"
        set l2tpRange [ixNet getList $handle l2tpRange]
        Deputs "l2tpRange:$l2tpRange"
        set rangeName [ ixNet getA $l2tpRange -name ]
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



body L2tpHost::reborn {} {
    
	set tag "body L2tpHost::reborn [info script]"
	Deputs "----- TAG: $tag -----"
		
	chain 
    
    
    Deputs "stack: $stack"
	set sg_ethernet $stack
    #-- add pppox endpoint stack
    if { [llength [ixNet getL $stack ip]] > 0 } {
        set sg_ip [lindex [ixNet getL $stack ip] 0]
        if { [llength [ixNet getL $stack l2tpEndpoint]] > 0 } {
            set sg_l2tp [lindex  [ixNet getL $stack l2tpEndpoint] 0]
        } else {
            set sg_l2tp [ixNet add $sg_ip l2tpEndpoint]
        }
        
    } else {
        set sg_ip [ixNet add $sg_ethernet ip]
        set sg_l2tp [ixNet add $sg_ip l2tpEndpoint]
    }
    Deputs "sg_l2tp: $sg_l2tp"
    ixNet setA $sg_l2tp -name $this
    ixNet commit
    set sg_l2tp [lindex [ixNet remapIds $sg_l2tp] 0]
    set hL2tp $sg_l2tp
    
    #-- add range
    set sg_range [ixNet add $sg_l2tp range]
    ixNet setMultiAttrs $sg_range/macRange \
     -enabled True 
         
    
    ixNet setMultiAttrs $sg_range/vlanRange \
     -enabled False \
     
    ixNet setMultiAttrs $sg_range/ipRange \
     -enabled True 
    
    ixNet setMultiAttrs $sg_range/l2tpRange \
     -enabled True \
     -numSessions 1
    
    ixNet commit
    set sg_range [ixNet remapIds $sg_range]
    
    set handle $sg_range
    #set trafficObj 
	
	
	ixNet commit
}

body L2tpHost::config { args } {
    global errorInfo
    global errNumber

	set tag "body L2tpHost::config [info script]"
	Deputs "----- TAG: $tag -----"
		
    eval { chain } $args
	
    set ENcp       [ list ipv4 ipv6 ipv4v6 ]
    set EAuth      [ list none auto chap_md5 pap ]

	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {			
			-session_per_tunnel_count {
                set session_per_tunnel_count $value 
                
			}
			-session_num {
                set session_num  $value 
                
			}
			-tunnel_destination_ip {
                set tunnel_destination_ip $value
                
			}
			-tunnel_authentication {
				set tunnel_authentication $value
                
                #hostname|none
			}
			-tunnel_host {
				set tunnel_host $value
			}
			-tunnel_secret {
				set tunnel_secret $value
			}
			-ipcp_encap {
				set ipcp_encap [string tolower $value]
                #ipv4|ipv6|ipv4v6
			}
            -session_auth_type {
				set session_auth_type [string tolower $value]
			}
			-session_user {
				set session_user $value
			}
            -session_password {
				set session_password $value
			}
            -ip_type {
				set ip_type [string tolower $value]
                if { $ip_type == "ipv4" } {
                    set ip_type "IPv4"
                }
                if { $ip_type == "ipv6" } {
                    set ip_type "IPv6"
                }
			}
            -ip_address {
				set ip_address $value
			}
            -ip_gateway {
				set ip_gateway $value
			}
            -ip_mask {
				set ip_mask $value
			}
        }
    }
    
    if { [ info exists ip_type ] } {
		ixNet setMultiAttrs $handle/ipRange \
		    -ipType $ip_type
	}
    
    if { [ info exists ip_address ] } {
		ixNet setMultiAttrs $handle/ipRange \
		    -ipAddress $ip_address
	}
    
    if { [ info exists ip_gateway ] } {
		ixNet setMultiAttrs $handle/ipRange \
		    -gatewayAddress $ip_gateway
	}
    
    if { [ info exists ip_mask ] } {
		ixNet setMultiAttrs $handle/ipRange \
		    -prefix $ip_mask
	}
	
	if { [ info exists session_per_tunnel_count ] } {
		ixNet setMultiAttrs $handle/l2tpRange \
		    -sessionsPerTunnel $session_per_tunnel_count
	}
	
	if { [ info exists session_num ] } {
		ixNet setMultiAttrs $handle/l2tpRange \
		    -numSessions $session_num
	}
    
    if { [ info exists tunnel_destination_ip ] } {
		ixNet setMultiAttrs $handle/l2tpRange \
		    -tunnelDestinationIp $tunnel_destination_ip
	}
    
    if { [ info exists tunnel_authentication ] } {
		ixNet setMultiAttrs $handle/l2tpRange \
		    -tunnelAuthentication $tunnel_authentication
	}
    
    if { [ info exists tunnel_host ] } {
		ixNet setMultiAttrs $handle/l2tpRange \
		    -lacHostName $tunnel_host
	}
    
    if { [ info exists tunnel_secret ] } {
		ixNet setMultiAttrs $handle/l2tpRange \
		    -lacSecret $tunnel_secret
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
		ixNet setA $handle/l2tpRange -ncpType $ipcp_encap
	}
	
	if { [ info exists session_auth_type ] } {
		switch $session_auth_type {
			paporchap {
				set authentication papOrChap
				if { [ info exists session_user ] } {
					ixNet setMultiAttrs $handle/l2tpRange \
					    -papUser $session_user
                    ixNet setMultiAttrs $handle/l2tpRange \
					    -chapName $session_user
				}
				if { [ info exists session_password ] } {
					ixNet setMultiAttrs $handle/l2tpRange \
					   -papPassword $session_password
                    ixNet setMultiAttrs $handle/l2tpRange \
					   -chapSecret $session_password
				}
					
			}
            pap {
                set authentication pap
				if { [ info exists session_user ] } {
					ixNet setMultiAttrs $handle/l2tpRange \
					 -papUser $session_user
				}
				if { [ info exists session_password ] } {
					ixNet setMultiAttrs $handle/l2tpRange \
					 -papPassword $session_password
				}	            }
			chap {
				set authentication chap
				if { [ info exists session_user ] } {
					ixNet setMultiAttrs $handle/l2tpRange \
					 -chapName $session_user
				}
				if { [ info exists session_password ] } {
					ixNet setMultiAttrs $handle/l2tpRange \
					 -chapSecret $session_password
				}			
			}
		}
		ixNet setA $handle/l2tpRange -authType $authentication
	}
	
	

	ixNet commit
	return [GetStandardReturnHeader]
}

body L2tpHost::get_summary_stats {} {
    set tag "body L2tpHost::get_summary_stats [info script]"
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
	set view {::ixNet::OBJ-/statistics/view:"L2TP General Statistics"}
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


