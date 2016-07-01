
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 2.16
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1.1.1
#       1. Add get_status method to achieve status of port
#       2. Add sub-interface configuration in config method
# Version 1.2.1.2
#		3. Add ping method
# Version 1.3.1.8
#		4. Add reset method
# Version 1.4.1.16
#		5. Add multi-interface in Port::config
# Version 1.5.2.1
#		6. Clear ownership in GetRealPort
# Version 1.6.2.4
#		7. Add get_stats method
#		8. Add Host class to emulate a host
# Version 1.7.2.6
#		9. Add Connect method to connect to hardware port
# Version 1.8.2.7
#		10. Add check strange port in ctor
# Version 1.9.2.9
#		11. Enable Ping defaultly
# Version 1.10.2.10
#		12. Add port_mac_addr param in Port.get_status
# Version 1.11.2.11
#		13. Port reborn
# Version 1.12.2.12
#		14. Add default mac and ip in properties
# Version 1.13.2.17
#		15. Replace connectedTo to AssignPorts to fix no license problem
# Version 1.14.3.0
#		16. Replace autoInstrumentation to floating to adapt with 10GE
#		17. Add data integrity stats when rx equals 0
# Version 1.15.3.5
#		18. Add ipv6 int addr in config
# Version 1.16.3.10
#		19. Add Host.ping
# Version 1.17.4.18
#		20. Add set_port_stream_load to set load of all stream under certain port
# Version 1.18.4.19
#		21. configure "transmit ignore link" after assign port
#		22. use assign ports when ctor and usual connectedTo ports when reborn and cleanup reserve port
# Version 1.19.4.20
#		23. add oversize stat in rx_frame_count
# Version 1.20.4.23
#		24. add total_frame_count in Port::get_stats
#		25. add Port::break_link and Port::restore_link
# Version 1.20.4.26
#       26. Create Port obj by existing port handle in Port.ctor
#       26. modify Port::set_port_stream_load
# Version 1.21.4.27
#       27. modify Host::config  src_mac format
# Version 1.22.4.28
#       28. Add catch for Data Plane Port Statistics command
#       29. modify Port::set_port_stream_load , change stream_load into L1 speed
# Version 1.23.4.29
#       30. modify port.set_dhcpv4,add lease_time
# Version 1.24.4.30
#       31. modify port.set_dhcpv4,add max_request_rate,request_rate_step,
#                                  add max_release_rate,release_rate_step
#       32. add port.start_traffic,port.stop_traffic
# Version 1.25.4.31
#		33. add resume method to resume all streams under port
# Version 1.26.4.32
#       34. remove vlan configure in Port.config
#       35. add method set_dot1x
# Version 2.08.4.33
#       36. remove vlan configure in Port.config
# Version 2.10.4.34
#		37. add ipv4_gw_step/ipv6_gw_step in Host.config
# Version 2.11.4.44
#		38. use dynamic port type for flow-control in port.config
# Version 2.12.4.46
#		39. don't check link on port in ctor
#		40. set auto_instrumentation default to endOfFrame
# Version 2.13.4.49
#		41. modify port.start_traffic to fix bug of apply traffic
# Version 2.14.4.53
#		42. fix bug in Host.config
# Version 2.15.4.54
#		43. add Port.set_port_dynamic_rate
# Version 2.16.4.59
#		44. remove param validation in port.config

class Port {
    inherit NetObject
    constructor { { hw_id NULL } { medium NULL } { hPort NULL } } {}
    method config { args } {}
    method get_status {} {}
    method get_stats {} {}
    method ping { args } {}
    method reset {} {}
	method start_traffic {} {}
	method stop_traffic {} {} 
    method break_link {} {}
    method restore_link {} {}
	method set_port_stream_load { args } {}
    method set_port_dynamic_rate { args } {}
	method resovle_mac { args } {
		set tag "body Port::resovle_mac [info script]"
	Deputs "----- TAG: $tag -----"
		global errorInfo
		global errNumber
	Deputs "Args:$args "
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-neighbor_ip {
					if { $value != "" } {
						if { [ IsIPv4Address $value ] } {
							set neighbor_ip $value
						} else {
							error "$errNumber(1) key:$key value:$value"
						}
					}
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		if { [ info exists neighbor_ip ] } {
Deputs "get neighbor"
			set neighbor [ ixNet getF $handle discoveredNeighbor -neighborIp $neighbor_ip ]
Deputs "neighbor:$neighbor"
Deputs "get neighbor mac"
			set neighbor_mac [ ixNet getA $neighbor -neighborMac ]
Deputs "neighbor mac:$neighbor_mac"
		}
		if { [ IsMacAddress $neighbor_mac ] } {
			return $neighbor_mac
		} else {
			return "00:00:00:00:00:00"
		}
	}
    
    method set_dhcpv4 { args } {}
    method set_dhcpv6 { args } {}
    method set_dot1x {args } {}
  	method resume {} {
		set tag "body Traffic::resume [info script]"
Deputs "----- TAG: $tag -----"
		set info [ ixNet getA $handle -connectionInfo ]
		regexp {chassis="(\d+.\d+.\d+.\d+)"} $info chas chasAddr
		regexp {card="(\d+)"} $info card cardId
		regexp {port="(\d+)"} $info port portId
		if { [ ixConnectToChassis ] == 0 } {
			set tclServer [ lindex [ split $loginInfo "/" ] 0 ]
			ixConnectToTclServer $tclServer
			ixConnectToChassis $chasAddr
		}

		chassis get $chasAddr
		set chasId [ chassis cget -id ]
		port get $chasId $cardId $portId
		set owner [ port cget -owner ]
		ixLogin $owner
		set pl [ list [ list $chasId $cardId $portId ] ]
		ixTakeOwnership $pl
		
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		set sl [ list ]
		for { set id 1 } { $id <= $streamCount } { incr id } {
			lappend sl $id
		}
		
		return stream resume $chasId $cardId $portId $sl
	}
	
    
    method GetRealPort { chas card port } {}
    method Connect { location { medium NULL } { checkLink 0 } } {}
    method CheckStrangePort {} {}
    
    public variable location
    public variable intf_mac
    public variable intf_ipv4
    public variable inter_burst_gap
	public variable PortNo
}

body Port::constructor { { hw_id NULL } { medium NULL } { hPort NULL } } {
    set tag "body Port::ctor [info script]"
Deputs "----- TAG: $tag -----"

# -- Check for Multiuser Login
	set portObjList [ GetAllPortObj ]
	if { [ llength $portObjList ] == 0 } {
Deputs "All port obj:[GetAllPortObj]"
		set strangePort [ CheckStrangePort ]
Deputs "Strange port:$strangePort"		
		if { $strangePort == 0 } {
			global loginInfo
			Login $loginInfo
		}
	}
	set handle ""

Deputs Step10
    if { $hw_id != "NULL" } {
Deputs "hw_id:$hw_id"	
# -- check hardware
		set locationInfo [ split $hw_id "/" ]
		set chassis     [ lindex $locationInfo 0 ]
		set ModuleNo    [ lindex $locationInfo 1 ]
		set PortNo      [ lindex $locationInfo 2 ]
		if { [ GetRealPort $chassis $ModuleNo $PortNo ] == [ ixNet getNull ] } {
			error "Port hardware not found: $hw_id"
		}
Deputs Step20	
		catch {
			if { $medium != "NULL" } {
				set handle [ Connect $hw_id $medium 1 ]
			} else {
				set handle [ Connect $hw_id NULL 0]
			}
		}
		set location $hw_id
Deputs "location:$location" 
    } else {
        if { $hPort != "NULL" } {
			set chassis ""
			set card ""
			set port ""

			set handle $hPort
			set connectionInfo [ ixNet getA $handle -connectionInfo ]
		Deputs "connectionInfo :$connectionInfo"
			regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
		Deputs "chas:$chassis card:$card port$port"
			set location ${chassis}/${card}/${port}
			ixNet setA $handle -name $this
			ixNet commit
		}   
    }
	set intf_mac 	 ""
	set intf_ipv4	 ""
	set inter_burst_gap 12
}

body Port::CheckStrangePort {} {
    set tag "body Port::CheckStrangePort [info script]"
Deputs "----- TAG: $tag -----"
	set root [ ixNet getRoot]
	for { set index 0 } { $index < 6 } { incr index } {
		if { [ llength [ ixNet getL $root vport ] ] > 0 } {
			Deputs "The connecting optional port $port is ocuppied, try next port..."
			return 0
		} 
		after 500
	}
	return 1
}

body Port::Connect { location { medium NULL } { checkLink 0 } } {
    set tag "body Port::Connect [info script]"
Deputs "----- TAG: $tag -----"
# -- add vport

    set root [ ixNet getRoot ]
	Deputs "vport handle: $handle"

	
    if {$handle == ""} {
	   
       set vport   [ ixNet add $root vport ]
       ixNet setA $vport -name $this
	   ixNet commit
	   set vport [ixNet remapIds $vport]
       set handle $vport
	}
   
    
	if { $medium != "NULL" } {
Deputs "connect medium:$medium"	
		ixNet setA $handle/l1Config/ethernet -media $medium
	}
    ixNet commit
   
# -- connect to hardware
	set locationInfo [ split $location "/" ]
	set chassis     [ lindex $locationInfo 0 ]
	set ModuleNo    [ lindex $locationInfo 1 ]
	set PortNo      [ lindex $locationInfo 2 ]

	if { [ string tolower [ ixNet getA $root/statistics -guardrailEnabled ] ] != "true" } {
Deputs "guardrail: false"
		catch {
			ixNet setA $root/statistics -guardrailEnabled True
			ixNet commit
		}
Deputs "guardrail:[ ixNet getA $root/statistics -guardrailEnabled  ]"
	}

	if { $checkLink } {
		#fix license issue
		ixTclNet::AssignPorts [ list [ list $chassis $ModuleNo $PortNo ] ] {} $handle true
	} else {
		ixNet setA $handle -connectedTo [ GetRealPort $chassis $ModuleNo $PortNo ] 
		ixNet commit
	}
	set handle [ixNet remapIds $handle]
Deputs "handle:$handle"	
	ixNet setA $handle -transmitIgnoreLinkStatus True
       ixNet commit       
 
	return $handle
}

body Port::GetRealPort { chassis card port } {
    set tag "body Port::GetRealPort [info script]"
Deputs "----- TAG: $tag -----"
    set root    [ixNet getRoot]
Deputs "chassis:$chassis"        
	set root [ixNet getRoot]
	if { [ llength [ixNet getList $root/availableHardware chassis] ] == 0 } {
Deputs Step20
		set chas [ixNet add $root/availableHardware chassis]
		ixNet setA $chas -hostname $chassis
		ixNet commit
		set chas [ixNet remapIds $chas]
	} else {
Deputs Step30
		set chas [ixNet getList $root/availableHardware chassis]
		set hostname [ixNet getA $chas -hostname]
		if { $hostname != $chassis } {
			ixNet remove $chas
			ixNet commit
			set chas [ixNet add $root/availableHardware chassis]
			ixNet setA $chas -hostname $chassis
			ixNet commit
			set chas [ixNet remapIds $chas]
		}
	}
	set chassis $chas
    set realCard $chassis/card:$card
Deputs "card:$realCard"
    set cardList [ixNet getList $chassis card]
Deputs "cardList:$cardList"
    set findCard 0
    foreach ca $cardList {
        eval set ca $ca
        eval set realCard $realCard
Deputs "realCard:$realCard"
Deputs "ca:$ca"
        if { $ca == $realCard } {
            set findCard 1
            break
        } 
    }
Deputs Step10
Deputs "findCard:$findCard"
    if { $findCard == 0} {
        return [ixNet getNull]
    }
    set realPort $chassis/card:$card/port:$port
Deputs "port:$realPort"
    set portList [ ixNet getList $chassis/card:$card port ]
Deputs "portList:$portList"
    set findPort 0
    foreach po $portList {
        eval set po $po
        eval set realPort $realPort
        if { $po == $realPort } {
            set findPort 1
            break
        }
    }
Deputs "findPort:$findPort"
    if { $findPort } {
Deputs "real port:	$chassis/card:$card/port:$port"
		ixNet exec clearOwnership $chassis/card:$card/port:$port
        return $chassis/card:$card/port:$port
    } else {
        return [ixNet getNull]
    }
}

body Port::config { args } {
    
# object reborn
	if { $handle == "" } {
		if { $location != "NULL" } {
			catch {
				set handle [ Connect $location ]
			}
			set inter_burst_gap 12
		} else {
			return [ GetErrorReturnHeader "No port information or wrong port information." ]
		}
	}
#
    global errorInfo
    global errNumber

    set EType [ list eth pos atm 10g_lan 10g_wan 40g_lan 100g_lan 40gpos ]
    set EMedia [ list copper fiber ]
    # set ESpeed [ list 10M 100M 1G 10G 40G 100G 155M 622M 2.5G 40GPOS ]
    set EDuplex [ list full half ]
    
    set flagInnerVlan   0
    set flagOuterVlan   0
    
    set inner_vlan_id   100
    set inner_vlan_step 1
    set inner_vlan_num  1
    set inner_vlan_priority 0
    set outer_vlan_id   100
    set outer_vlan_step 1
    set outer_vlan_num  1
    set outer_vlan_priority 0
    
    set enable_arp 1
    set intf_ip_num	1
    set intf_ip_step 0
    set intf_ip_mod	32
    set dut_ip_num	1
    set dut_ip_step 0
    set dut_ip_mod	32
    
    set mask 24
    set ipv6_mask 64
    set intf_num 1
    set ip_version "ipv4"
	
    set flow_control 0
	set sig_end 1
	
    set tag "body Port::config [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -location {
                #set location $value
            }
            -intf_ip {
                if { $value != "" } {
                	if { [ IsIPv4Address $value ] } {
                		set intf_ip $value
                	} else {
                		error "$errNumber(1) key:$key value:$value"
                	}
                }
            }
            -intf_ip_num -
            -intf_num -
            -ipv6_addr_num -
            -dut_ip_num {
                if { [ string is integer $value ] && ( $value >= 0 ) } {
                    set intf_num $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-intf_ip_step {
                if { [ string is integer $value ] && ( $value >= 0 ) } {
                    set intf_ip_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-intf_ip_mod {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
                    set intf_ip_mod $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                    
			}
            -dut_ip {
                if { [ IsIPv4Address $value ] } {
                    set dut_ip $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -dut_ip_step {
                if { [ string is integer $value ] && ( $value >= 0 ) } {
                    set dut_ip_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -dut_ip_mod {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
                    set dut_ip_mod $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                    
            }
            -mask {
                if { [ string is integer $value ] && $value <= 30 } {
                    set mask $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -type {
                set value [ string tolower $value ]
                if { [ lsearch -exact $EType $value ] >= 0 } {
                    
                    set type $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -media {
                set value [ string tolower $value ]
                if { [ lsearch -exact $EMedia $value ] >= 0 } {
                    set media $value
Deputs "media:$media"                    
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -speed {
                switch $value {
                    10M {
                        set speed 10
                    }
                    100M {
Deputs "speed:$speed"					
                        set speed 100
                    }
                    1G {
                        set speed 1000
                    }
                }
            }
            -auto_neg {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set auto_neg $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -duplex {
                set value [ string tolower $value ]
                if { [ lsearch -exact $EDuplex $value ] >= 0 } {
                    
                    set duplex $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -enable_arp -
            -enable_arp_reply {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_arp $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            # -inner_vlan_id {
                # if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
                    # set inner_vlan_id $value
                    # set flagInnerVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -inner_vlan_step {
                # if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
                    # set inner_vlan_step $value
                    # set flagInnerVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -inner_vlan_num {
                # if { [ string is integer $value ] && ( $value >= 0 ) } {
                    # set inner_vlan_num $value
                    # set flagInnerVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -inner_vlan_priority {
                # if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
                    # set inner_vlan_priority $value
                    # set flagInnerVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -outer_vlan_id {
                # if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
                    # set outer_vlan_id $value
                    # set flagOuterVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -outer_vlan_step {
                # if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
                    # set outer_vlan_step $value
                    # set flagOuterVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -outer_vlan_num {
                # if { [ string is integer $value ] && ( $value >= 0 ) } {
                    # set outer_vlan_num $value
                    # set flagOuterVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            # -outer_vlan_priority {
                # if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
                    # set outer_vlan_priority $value
                    # set flagOuterVlan   1
                # } else {
                    # error "$errNumber(1) key:$key value:$value"
                # }
            # }
            -ipv6_addr {
            	set ipv6_addr $value
            }
            -ipv6_addr_step {
                if { [ string is integer $value ] && ( $value >= 0 ) } {
                    set ipv6_addr_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -ipv6_addr_mod {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] && $trans <= 128 && $trans >= 1 } {
                    set ipv6_addr_mod $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                    
            }
		   -ipv6_prefix_len -
            -ipv6_mask {
                if { [ string is integer $value ] && $value <= 128 } {
                    set ipv6_mask $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
		   -ipv6_gw -
            -dut_ipv6 {
            	set dut_ipv6 $value
            }
            -flow_control {
		    set trans [ BoolTrans $value ]
		    if { $trans == "1" || $trans == "0" } {
			set flow_control $trans
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
             }
            -inter_burst_gap {
				set inter_burst_gap $value
            }
			-ip_version {
				set ip_version $value
			}
			-sig_end {
				set sig_end $value
			}
        }
    }
# IxDebugOn    
Deputs "add interface on port..."
	set intLen [ llength [ ixNet getList $handle interface ] ] 
Deputs "interface count:$intLen"
    if { $intLen == 0 } {
		set interface [list]
    } else {
        set interface [ ixNet getList $handle interface ]
		foreach int $interface {
			ixNet remove $int
		}
		ixNet commit
		set interface [list]
    }
	for { set index 0 } { $index < $intf_num } { incr index } {
		set newInt  [ ixNet add $handle interface ]
		# ixNet setA $newInt -enabled True
		ixNet commit
		set newInt [ixNet remapIds $newInt]
		lappend interface $newInt
		lappend intf_mac [ ixNet getA $newInt/ethernet -macAddress ]
	}
Deputs "port interface mac:$intf_mac"		
    
# -- enable ping defaultly
    ixNet setA $handle/protocols/ping -enabled true
# -- change the autoInstrumentation defaultly
    # ixNet setA $handle/l1Config/ethernet -autoInstrumentation floating
    ixNet commit
	if { [ info exists ip_version ] == 0 || $ip_version != "ipv4" } {
		if { [ info exists ipv6_addr ] == 0 && [ info exists intf_ip ] } {
			set a [ lindex [ split $intf_ip "." ] 0 ]
			set b [ lindex [ split $intf_ip "." ] 1 ]
			set c [ lindex [ split $intf_ip "." ] 2 ]
			set d [ lindex [ split $intf_ip "." ] 3 ]
			set ipv6_addr "::${a}:${b}:${c}:${d}"	
		}
	}
Deputs "set ipv6 on interface..."
    if { [ info exists ipv6_addr ] } {
	
		foreach int $interface {
			if { [ llength [ ixNet getList $int ipv6 ] ] == 0 } {
				set ipv6Int   [ ixNet add $int ipv6 ]
			} else {
				set ipv6Int   [ lindex [ ixNet getList $int ipv6 ] 0 ]
			}
			ixNet setA $int -enabled True

			ixNet setA $ipv6Int -ip $ipv6_addr 
			ixNet setA $ipv6Int -prefixLength $ipv6_mask
#==			increment not supported 
		}
	    ixNet commit
    }	
Deputs "set dut ipv6 address..."	
    if { [ info exists dut_ipv6 ] } {
		foreach int $interface {
			if { [ llength [ ixNet getList $int ipv6 ] ] == 0 } {
				set ipv6Int   [ ixNet add $int ipv6 ]
			} else {
				set ipv6Int   [ lindex [ ixNet getList $int ipv6 ] 0 ]
			}
			ixNet setA $ipv6Int -gateway $dut_ipv6
			ixNet setA $ipv6Int -prefixLength $ipv6_mask
			# set dut_ip [ IncrementIPAddr $dut_ip $dut_ip_mod $dut_ip_step ]
# Deputs "dut_ip: $dut_ip"
		}
	    ixNet commit
    }	
	
Deputs "set ipv4 on interface..."
    if { [ info exists intf_ip ] } {
	
		foreach int $interface {
			if { [ llength [ ixNet getList $int ipv4 ] ] == 0 } {
				set ipv4Int   [ ixNet add $int ipv4 ]
			} else {
				set ipv4Int   [ lindex [ ixNet getList $int ipv4 ] 0 ]
			}
			ixNet setA $int -enabled True
			
			ixNet setA $ipv4Int -ip $intf_ip 
			ixNet setA $ipv4Int -maskWidth $mask
Deputs "int_ip increment:$intf_ip $intf_ip_mod $intf_ip_step"
			lappend intf_ipv4 $intf_ip
			set intf_ip [ IncrementIPAddr $intf_ip $intf_ip_mod $intf_ip_step ]
Deputs "int_ip: $intf_ip"
		}
    }
Deputs "port intf_ipv4:$intf_ipv4"
ixNet commit

Deputs "set dut ipv4 address..."	
    if { [ info exists dut_ip ] } {
		foreach int $interface {
			if { [ llength [ ixNet getList $int ipv4 ] ] == 0 } {
				set ipv4Int   [ ixNet add $int ipv4 ]
			} else {
				set ipv4Int   [ lindex [ ixNet getList $int ipv4 ] 0 ]
			}
			ixNet setA $ipv4Int -gateway $dut_ip
			ixNet setA $ipv4Int -maskWidth $mask
			set dut_ip [ IncrementIPAddr $dut_ip $dut_ip_mod $dut_ip_step ]
Deputs "dut_ip: $dut_ip"
		}
    }
ixNet commit
  
# Deputs "set vlan on interface"
    # if { $flagInnerVlan } {
		# foreach int $interface {
			# if { [ llength [ixNet getL $int vlan] ] > 0 } {
				# set vlan [ lindex [ixNet getL $int vlan] 0 ]
			# } else {
				# set vlan [ ixNet add $int vlan ]
			# }
			
			# ixNet setM $vlan \
				# -vlanId         $inner_vlan_id \
				# -vlanEnable     true \
				# -vlanCount      $inner_vlan_num \
				# -vlanPriority   $inner_vlan_priority
		# }
    # }
    
    # if { $flagOuterVlan } {
		# foreach int $interface {
			# if { [ llength [ixNet getL $int vlan] ] > 1 } {
				# set vlan [ lindex [ixNet getL $int vlan] 1 ]
			# } else {
				# set vlan [ ixNet add $int vlan ]
			# }
			
			# ixNet setM $vlan \
				# -vlanId         $outer_vlan_id \
				# -vlanEnable     true \
				# -vlanCount      $outer_vlan_num \
				# -vlanPriority   $outer_vlan_priority
		# }
    # }
ixNet commit    
    
    if { [ info exists type ] } {
		set flagIntType 0
        switch $type  {
            eth {
                set ix_type ethernet
            }
            pos -
            atm {
                set ix_type $type
            }
            10g_lan {
                set ix_type tenGigLan
            }
            10g_wan {
                set ix_type tenGigWan
				set flagIntType 1
            }
        }
        ixNet setA $handle -type $ix_type
		if { $flagIntType } {
			ixNet setA $handle/l1Config/tenGigWan -interfaceType wanSdh
		}
    }
    
    if { [ info exists media ] } {
        ixNet setA $handle/l1Config/ethernet -media $media
    }
    
    if { [ info exists auto_neg ] } {
        if { $auto_neg } {
            set auto_neg True
        } else {
            set auto_neg False
        }
		catch {
			ixNet setA $handle/l1Config/ethernet -autoNegotiate $auto_neg 
			
		}
    } 
    if { [ info exists speed ] } {
        set ori_speed [ ixNet getA $handle/l1Config/ethernet -speed ]
Deputs "ori speed:$ori_speed"
		if { $ori_speed == "null" } {
			set ori_speed auto
		}
        if { $speed == 1000 } {
            ixNet setA $handle/l1Config/ethernet -speed speed1000
        } else {
            if { ($ori_speed == "auto") || ($ori_speed == "speed1000") } {
                set duplex fd
            } else {
                regexp {\d+([fh]d)} $ori_speed match duplex
            }
            ixNet setA $handle/l1Config/ethernet -speed speed$speed$duplex
        }
    }
    if { [ info exists duplex ] } {
        switch $duplex {
            full { set duplex fd }
            half { set duplex hd }
        }
        set speed [ ixNet getA $handle/l1Config/ethernet -speed ]
        if { ( $speed == "speed1000" ) || ( $speed == "auto" ) } {
Deputs "wrong configuration for duplex with speed1000 or auto speed"
        } else {
            if { [ regexp {(\d+)} $speed match speed ] } {
                ixNet setA $handle/l1Config/ethernet -speed speed$speed$duplex
            }
        }
    }
    
    if { [ info exists enable_arp ] } {
        set root [ixNet getRoot]
        ixNet setA $root/globals/interfaces -arpOnLinkup $enable_arp
    }
    if { [ info exists flow_control ] } {
Deputs "flow_control:$flow_control"
		ixNet setA $handle/l1Config/[ixNet getA $handle -type] -enabledFlowControl $flow_control
		ixNet commit
    }
	if { [ info exists sig_end ] } {
		if { $sig_end } {
			ixNet setA $handle/l1Config/[ixNet getA $handle -type] -autoInstrumentation endOfFrame
		} else {
			ixNet setA $handle/l1Config/[ixNet getA $handle -type] -autoInstrumentation floating			
		}
		ixNet commit
	}
	
    if { [ catch { ixNet  commit } err ] } {
		Deputs "commit err:$err"
	}
    
    return [GetStandardReturnHeader]
}

body Port::get_status { } {
    global errorInfo
    global errNumber

    set tag "body Port::get_status [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "handle:$handle"
    set phy_status [ ixNet getA $handle -state ]
Deputs Step10
    set neighbor [ lindex [ ixNet getL $handle discoveredNeighbor ] 0 ]
Deputs Step20
Deputs "neighbor:$neighbor"
    if { [ catch {
    	set dutMac	[ MacTrans [ ixNet getA $neighbor -neighborMac ] 1 ]
    } ] } {
		set dutMac 00-00-00-00-00-00
    }
Deputs Step30
    if { [ catch {
		set dutIp	 [ ixNet getA $neighbor -neighborIp ]
    } ] } {
		set dutIp 0.0.0.0
    }
Deputs Step40    
    if { [ catch {
Deputs Step50   
    	set interface [ lindex [ ixNet getL $handle interface ] 0 ]
Deputs Step60
    	set ipv4Int   [ lindex [ ixNet getL $interface ipv4 ] 0 ]
Deputs Step70
    	set ipv4Addr [ ixNet getA $ipv4Int -ip ]
Deputs Step80
    } log ] } {
Deputs Step90
    	set ipv4Addr 0.0.0.0
    }
Deputs Step100  
	if { [ catch {
    	set interface [ lindex [ ixNet getL $handle interface ] 0 ]
		set port_mac	[ MacTrans [ ixNet getA $interface/ethernet -macAddress ] 1 ]
Deputs "port_mac:$port_mac"
		} ] } {
		set port_mac	00-00-00-00-00-00
	}
    set ret [ GetStandardReturnHeader ]
    set ret $ret[ GetStandardReturnBody "phy_state" $phy_status ]
    set ret $ret[ GetStandardReturnBody "dut_mac" $dutMac ]
    set ret $ret[ GetStandardReturnBody "port_ipv4_addr" $ipv4Addr ]
	set ret $ret[ GetStandardReturnBody "port_mac_addr" $port_mac ]
   
	return $ret
}

body Port::ping { args } {
    set tag "body Port::ping [info script]"
Deputs "----- TAG: $tag -----"

	set count 		1
	set interval 	1000
	set flag 		1

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -src {
                if { [ IsIPv4Address $value ] } {
                    set intf_ip $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -dst {
                if { [ IsIPv4Address $value ] } {
                    set dut_ip $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -count {
                if { [ string is integer $value ] } {
                    set count $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -interval {
                if { [ string is integer $value ] } {
                    set interval    $value

                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -flag {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_arp $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            default {
                error "$errNumber(3) key:$key value:$value"
            }
        }
    }
    
	set pingTrue	0
	set pingFalse	0

Deputs "add pint interface..."	
	if { [ info exists intf_ip ] } {
		set int [ixNet add $handle interface]
		ixNet setA $int/ipv4 -ip $intf_ip
		ixNet commit
		
	} else {
		set int [ ixNet getL $handle interface ]
		if { [ llength $int ] == 0 } {
			return [ GetErrorReturnHeader "No ping source identified or no interface created under current port." ]
		}
		
	}

Deputs Step10
	set pingResult [ list ]
	for { set index 0 } { $index < $count } { incr index } {
		
		lappend pingResult [ ixNet exec sendPing $int $dut_ip ]
		after $interval
	}
	
Deputs Step20
	set pingPass	0
	foreach result $pingResult {
		if { [ regexp {failed} $result ] } {
			incr pingFalse
			set pingPass 0
		} else {
			incr pingTrue
			set pingPass 1
		}
	}

Deputs Step30
	if { [ info exists intf_ip ] } {
		ixNet remove $int
		ixNet commit		
	}
	
Deputs Step40
	set loss [ expr $pingFalse / $count.00 * 100 ]
	
Deputs Step50
	if { $pingPass == $flag } {
		set ret  [ GetStandardReturnHeader ]
	} else {
		set ret  [ GetErrorReturnHeader "Unexpected result $pingPass" ]
	}
	
Deputs Step60
	lappend ret [ GetStandardReturnBody "loss" $loss ]
	
	return $ret
}

body Port::set_dhcpv4 { args } {
    set tag "body Port::set_dhcpv4 [info script]"
Deputs "----- TAG: $tag -----"

	global errNumber
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-request_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set request_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-max_request_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set max_request_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-request_rate_step {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set request_rate_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
            -lease_time {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set lease_time $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-release_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set release_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-max_release_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set max_release_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-release_rate_step {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set release_rate_step $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-max_outstanding_session {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set max_outstanding_session $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
		}
	}
	
	set root [ixNet getRoot]
	set globalSetting [ ixNet getL $root/globals/protocolStack dhcpGlobals ]
    if { $globalSetting == ""} {
	    set globalSetting [ ixNet add $root/globals/protocolStack dhcpGlobals ]
	}
	if { [ info exists request_rate ] } {
		ixNet setA $globalSetting -setupRateInitial $request_rate
	}
	if { [ info exists max_request_rate ] } {
		ixNet setA $globalSetting -setupRateMax $max_request_rate
	}
	if { [ info exists request_rate_step ] } {
		ixNet setA $globalSetting -setupRateIncrement $request_rate_step
	}
	
    if { [ info exists lease_time ] } {
		ixNet setA $globalSetting  -dhcp4AddrLeaseTime  $lease_time
	}
	if { [ info exists release_rate ] } {
		ixNet setA $globalSetting -teardownRateInitial $release_rate
	}
	if { [ info exists max_release_rate ] } {
		ixNet setA $globalSetting -teardownRateMax $max_release_rate
	}
	if { [ info exists release_rate_step ] } {
		ixNet setA $globalSetting -teardownRateIncrement $release_rate_step
	}
	if { [ info exists max_outstanding_session ] } {
		ixNet setA $globalSetting -maxOutstandingRequests $max_outstanding_session
	}
	
	ixNet commit
	return [ GetStandardReturnHeader ]
}

body Port::set_dhcpv6 { args } {
    set tag "body Port::set_dhcpv6 [info script]"
Deputs "----- TAG: $tag -----"
	set result  [ eval set_dhcpv4 $args ]
	return $result
}

body Port::set_dot1x { args } {
    set tag "body Port::set_dot1x [info script]"
Deputs "----- TAG: $tag -----"

	global errNumber
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-auth_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 100000 ) } {
                    set auth_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-logoff_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 1000 ) } {
                    set logoff_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-outstanding_rate {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 1000 ) } {
                    set outstanding_rate $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
            -retry_count {
                if { [ string is integer $value ] && ( $value >= 0 ) && ( $value <= 1000 ) } {
                    set max_start [expr $value +1]
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}	
		}
	}
    
    set root [ixNet getRoot]
	set globalSetting [ ixNet getL $root/globals/protocolStack dot1xGlobals ]
    if { $globalSetting == ""} {
	    set globalSetting [ ixNet add $root/globals/protocolStack dot1xGlobals ]
	}
	if { [ info exists auth_rate ] } {
		ixNet setA $globalSetting -maxClientsPerSecond $auth_rate
	}
	if { [ info exists logoff_rate ] } {
		ixNet setA $globalSetting -logoffMaxClientsPerSecond $logoff_rate
	}
	if { [ info exists outstanding_rate ] } {
		ixNet setA $globalSetting -maxOutstandingRequests $outstanding_rate
	}
	
    if { [ info exists max_start ] } {
		ixNet setA $globalSetting  -maxStart  $max_start
	}
	
	
	ixNet commit
	return [ GetStandardReturnHeader ]
}

body Port::reset {} {
    set tag "body Port::reset [info script]"
Deputs "----- TAG: $tag -----"
    ixNet exec setFactoryDefaults $handle
    ixNet commit
	return [ GetStandardReturnHeader ]
}

body Port::start_traffic {} {
    set tag "body Port::start_traffic [info script]"
Deputs "----- TAG: $tag -----"

Deputs "handle:$handle"
		set root [ ixNet getRoot]
		set trafficList [ ixNet getL $root/traffic trafficItem ]
		foreach traffic $trafficList {
			if { [ ixNet getA $traffic -state ] == "unapplied" } {
				Tester::apply_traffic
			} 
			lappend flowList [ ixNet getL $traffic highLevelStream]
		}
		
Deputs "flowList: $flowList"
		set flagApply 0
		foreach flow $flowList {
			foreach deepFlow $flow {
				set txPort [ ixNet getA $deepFlow -txPortId ]
				set state [ ixNet getA $deepFlow -state]
				
				if { $state != "started"} {
					if { $txPort == $handle } {
						lappend txList $deepFlow
					}
				}
			}
		}
		
Deputs "TxList: $txList"
				
		foreach  startTx $txList {
		    ixNet exec startStatelessTraffic $startTx
		    # after 3000
		}
			
Deputs "All streams are transtmitting!"
		return [ GetStandardReturnHeader ]
}

body Port::stop_traffic {} {
    set tag "body Port::stop_traffic [info script]"
Deputs "----- TAG: $tag -----"

Deputs "handle:$handle"
		set root [ ixNet getRoot]
		set trafficList [ ixNet getL $root/traffic trafficItem ]
		foreach traffic $trafficList {
			lappend flowList [ ixNet getL $traffic highLevelStream]
		}
Deputs "flowList: $flowList"
		set flagApply 0
		foreach flow $flowList {
			foreach deepFlow $flow {
				set txPort [ ixNet getA $deepFlow -txPortId ]
				if { $txPort == $handle } {
					set state [ ixNet getA $deepFlow -state]
					if { $state != "stopped"} {
						lappend txList $deepFlow
					}
				}
				
			}
		}
			
		foreach  stopTx $txList {
		    ixNet exec stopStatelessTraffic $stopTx
		    after 3000
		}
Deputs "All streams are stopped!"

		return [ GetStandardReturnHeader ]
}

body Port::break_link {} {
    set tag "body Port::break_link [info script]"
Deputs "----- TAG: $tag -----"
    ixNet exec linkUpDn $handle down
    ixNet commit
	return [ GetStandardReturnHeader ]
}

body Port::restore_link {} {
    set tag "body Port::restore_link [info script]"
Deputs "----- TAG: $tag -----"
    ixNet exec linkUpDn $handle up
    ixNet commit
	return [ GetStandardReturnHeader ]
}

body Port::get_stats {} {

    set tag "body Port::get_stats [info script]"
Deputs "----- TAG: $tag -----"
    
	#{::ixNet::OBJ-/statistics/view:"Port Statistics"}
    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"Port Statistics"}
    set rxview {::ixNet::OBJ-/statistics/view:"Data Plane Port Statistics"}
	set proview {::ixNet::OBJ-/statistics/view:"Global Protocol Statistics"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
Deputs "view:$view"
Deputs "rxview:$rxview"
Deputs "proview:$proview"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
	#set rxcaptionList [ ixNet getA $rxview/page -columnCaptions ]
    if { [catch { set rxcaptionList [ ixNet getA $rxview/page -columnCaptions ] } ]  } {
	    set rxcaptionList [list Port {Rx Frames}]
	} 
	set proCaptionList [ ixNet getA $proview/page -columnCaptions ]
Deputs "caption list:$captionList"
Deputs "rxcaptionList:$rxcaptionList"
Deputs "pro caption list:$proCaptionList"
	set port_name				[ lsearch -exact $captionList {Stat Name} ]
    set tx_frame_count          [ lsearch -exact $captionList {Frames Tx.} ]
    set total_frame_count       [ lsearch -exact $captionList {Valid Frames Rx.} ]
    set tx_frame_rate         	[ lsearch -exact $captionList {Frames Tx. Rate} ]
    set rx_frame_rate         	[ lsearch -exact $captionList {Valid Frames Rx. Rate} ]
    set tx_bit_rate         	[ lsearch -exact $captionList {Tx. Rate (bps)} ]
    set rx_bit_rate       		[ lsearch -exact $captionList {Rx. Rate (bps)} ]
    set fcs_error_frame        	[ lsearch -exact $captionList {CRC Errors} ]
    set rx_data_integrity	    [ lsearch -exact $captionList {Data Integrity Frames Rx.} ]
    
	set rx_frame_count          [ lsearch -exact $rxcaptionList {Rx Frames}]
    set rx_port                 [ lsearch -exact $rxcaptionList Port]

	set control_pkt_tx			[ lsearch -exact $proCaptionList {Control Packet Tx.} ]
	set control_pkt_rx			[ lsearch -exact $proCaptionList {Control Packet Rx.} ]
	set ping_reply_tx			[ lsearch -exact $proCaptionList {Ping Reply Tx.} ]
	set ping_request_tx			[ lsearch -exact $proCaptionList {Ping Request Tx.} ]
	set ping_reply_rx			[ lsearch -exact $proCaptionList {Ping Reply Rx.} ]
	set ping_request_rx			[ lsearch -exact $proCaptionList {Ping Request Rx.} ]
	set arp_reply_tx			[ lsearch -exact $proCaptionList {Arp Reply Tx.} ]
	set arp_reply_rx			[ lsearch -exact $proCaptionList {Arp Reply Rx.} ]
	set arp_request_tx			[ lsearch -exact $proCaptionList {Arp Request Tx.} ]
	set arp_request_rx			[ lsearch -exact $proCaptionList {Arp Request Rx.} ]
	
    set ret [ GetStandardReturnHeader ]
	
    set stats    [ ixNet getA $view/page -rowValues ]
    #set rxstats  [ ixNet getA $rxview/page -rowValues ]
	if { [catch { set rxstats  [ ixNet getA $rxview/page -rowValues ] } ]} {
	    set rxstats [list $this  "0"]
	}
	set proStats [ ixNet getA $proview/page -rowValues ]
	
Deputs "stats:$stats"
Deputs "pro stats:$proStats"

    set connectionInfo [ ixNet getA $handle -connectionInfo ]
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

        set statsItem   "tx_frame_count"
        set statsVal    [ lindex $row $tx_frame_count ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "total_frame_count"
        set statsVal    [ lindex $row $total_frame_count ]
Deputs "stats val:$statsVal"
    	if { $statsVal < 1 } {
		    set statsVal [ lindex $row $rx_data_integrity ]
Deputs "stats val:$statsVal"
    	}
		if { $statsVal < 1 } {
		    ixConnectToTclServer $chassis
			ixConnectToChassis $chassis
			set chas [chassis cget -id]
		    
		    stat get statAllStats $chas $card $port
            set statsVal [ stat cget -oversize ]
		    
Deputs "stats val:$statsVal"
    	}
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
              
        set statsItem   "tx_frame_rate"
        set statsVal    [ lindex $row $tx_frame_rate ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "rx_frame_rate"
        set statsVal    [ lindex $row $rx_frame_rate ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_bit_rate"
        set statsVal    [ lindex $row $tx_bit_rate ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "rx_bit_rate"
        set statsVal    [ lindex $row $rx_bit_rate ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]          

    }
    
    foreach rxrow $rxstats {
        
        eval {set rxrow} $rxrow
Deputs "rxrow:$rxrow"

	
		if { $this != [ lindex $rxrow $rx_port ] } {
			continue
		}

        set statsItem   "rx_frame_count"
        set statsVal    [ lindex $rxrow $rx_frame_count ]
Deputs "stats val:$statsVal"
        if { $statsVal =="" } {
		    set statsVal "0"
Deputs "stats val:$statsVal"
    	}
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
    }
    
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
              
        set statsItem   "fcs_error_frame"
        set statsVal    [ lindex $row $fcs_error_frame ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "ipv4_rrame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "ipv6_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "jumbo_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "mpls_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "oversize_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "prbs_bit_error_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tcp_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "udp_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "vlan_frame_count"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

Deputs "ret:$ret"

    }
        
    foreach row $proStats {
        
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
              
        set statsItem   "control_pkt_tx"
        set statsVal    [ lindex $row $control_pkt_tx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "control_pkt_rx"
        set statsVal    [ lindex $row $control_pkt_rx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "ping_reply_tx"
        set statsVal    [ lindex $row $ping_reply_tx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "ping_reply_rx"
        set statsVal    [ lindex $row $ping_reply_rx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "ping_request_tx"
        set statsVal    [ lindex $row $ping_request_tx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "ping_request_rx"
        set statsVal    [ lindex $row $ping_request_rx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
	    set statsItem   "arp_reply_tx"
        set statsVal    [ lindex $row $ping_reply_tx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "arp_reply_rx"
        set statsVal    [ lindex $row $ping_reply_rx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "arp_request_tx"
        set statsVal    [ lindex $row $ping_request_tx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "arp_request_rx"
        set statsVal    [ lindex $row $ping_request_rx ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
Deputs "ret:$ret"

    }
        
    return $ret

}

body Port::set_port_stream_load { args } {
    set tag "body Port::set_port_stream_load [info script]"
Deputs "----- TAG: $tag -----"

Deputs "hport:$handle"

	global errNumber
	
    set ELoadUnit	[ list KBPS MBPS BPS FPS PERCENT ]
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-stream_load {
				if { [ string is integer $value ] || [ string is double $value ] } {
					set stream_load $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-load_unit {
				set value [ string toupper $value ]
				if { [ lsearch -exact $ELoadUnit $value ] >= 0 } {

					set load_unit $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}			
			}
		}
	}
	
	set root [ixNet getRoot]
	set allObj [ find objects ]
	set trafficObj [ list ]
	foreach obj $allObj {
		if { [ $obj isa Traffic ] } {
			if { [ $obj cget -hPort ] == $handle } {
Deputs "trafficObj: $obj; hport :$handle"
			    set objhandle [ $obj cget -handle]
Deputs "$obj:$objhandle"
                if {$objhandle != ""} {
		
				    lappend trafficObj $obj
				}
			}
		}
	}
	if { [ llength $trafficObj ] == 0 } {
	   return [ GetErrorReturnHeader "No Traffic found under current port." ]
	}
	if { $load_unit == "MBPS" } {
	    set portspeed [ixNet getA $handle -actualSpeed]
		set stream_load [expr $stream_load *100/ $portspeed.0]
		set load_unit "PERCENT"
	}
	set unitLoad [ expr $stream_load / [ llength $trafficObj ].0 ]
Deputs "unitLoad : $unitLoad"
	foreach obj $trafficObj {
	
		$obj config -stream_load $unitLoad -load_unit $load_unit 
	}
	
	return [GetStandardReturnHeader]

}

body Port::set_port_dynamic_rate { args } {
    set tag "body Port::set_port_dynamic_rate [info script]"
Deputs "----- TAG: $tag -----"

Deputs "hport:$handle"

	global errNumber
	
    set ELoadUnit	[ list KBPS MBPS BPS FPS PERCENT ]
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-stream_load {
				if { [ string is integer $value ] || [ string is double $value ] } {
					set stream_load $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-load_unit {
				set value [ string toupper $value ]
				if { [ lsearch -exact $ELoadUnit $value ] >= 0 } {

					set load_unit $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}			
			}
		}
	}
	
	set root [ixNet getRoot]
	set allObj [ find objects ]
	set trafficObj [ list ]
	foreach obj $allObj {
		if { [ $obj isa Traffic ] } {
			if { [ $obj cget -hPort ] == $handle } {
Deputs "trafficObj: $obj; hport :$handle"
			    set objhandle [ $obj cget -handle]
Deputs "$obj:$objhandle"
                if {$objhandle != ""} {
		
				    lappend trafficObj $obj
				}
			}
		}
	}
    
	if { [ llength $trafficObj ] == 0 } {
	   return [ GetErrorReturnHeader "No Traffic found under current port." ]
	}
    
	if { $load_unit == "MBPS" } {
	    set portspeed [ixNet getA $handle -actualSpeed]
		set stream_load [expr $stream_load *100/ $portspeed.0]
		set load_unit "PERCENT"
	}
	set unitLoad [ expr $stream_load / [ llength $trafficObj ].0 ]
Deputs "unitLoad : $unitLoad"

    set dynamiclist [ixNet getL ::ixNet::OBJ-/traffic dynamicRate]
	foreach obj $trafficObj {
        foreach flowobj $dynamiclist {
           if { [string match *$obj* $flowobj] } {
               lappend dynamichandle $flowobj
           }
        }
	
		#$obj config -stream_load $unitLoad -load_unit $load_unit 
	}
    switch $load_unit {
        KBPS {
            set loadunit bitsPerSecond 
        }
        MBPS {
            set loadunit bitsPerSecond 			
        }
        BPS {
            set loadunit bitsPerSecond 			
        }
        FPS {
            set loadunit framesPerSecond 			
        }
        PERCENT {
            set loadunit percentLineRate 			
        }
    }
    foreach objhandle $dynamichandle {
        ixNet setA $objhandle -rateType $loadunit
    
        ixNet setA $objhandle -rate $unitLoad 
                             
    }
  
    ixNet commit
	
	return [GetStandardReturnHeader]

}

class Host {
	inherit NetObject
	constructor { port } {}
	method config { args } {}
	method unconfig {} {
    set tag "body Host::unconfig [info script]"
Deputs "----- TAG: $tag -----"
		set hPort ""
		chain
	}
	method enable {} {}
	method disable {} {}
	method ping { args } {}
	method reborn {} {
		if { [ catch {
			set hPort [ $portObj cget -handle ]
		} ] } {
			set port [ GetObject $portObj ]
			set hPort [ $port cget -handle ]
		}
	}
	
	public variable hPort
	public variable portObj
	public variable static
	public variable ip_version
}

body Host::constructor { port } {
    set portObj $port
	
	reborn
	set handle ""
}

body Host::config { args } {
    global errNumber
    
    set tag "body Host::config [info script]"
Deputs "----- TAG: $tag -----"
	
	if { $hPort == "" } {
		reborn
	}
	
	set count 			1
	# set src_mac			"00:10:94:00:00:02"
	set src_mac_step	"00:00:00:00:00:01"
	set vlan_id1_step	1
	set vlan_id2_step	1
	set ipv4_addr_step	0.0.0.1
	set ipv4_prefix_len	24
	set ipv4_gw			1.1.1.1
	set ipv6_addr_step	::1
	set ipv6_prefix_len	64
	set ipv6_gw			3ffe:3210::1
	set ip_version		ipv4
	set enabled 		True
	set unconnected		0
	set static 0
	
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-enabled {
				set  enabled $value
			}
            -count {
				set count $value
            }
            -src_mac {
			    if {[IsMacAddress $value]} {
				    set src_mac $value
				} else {
				    set src_mac [MacTrans $value]
				}
            }
            -src_mac_step {
				set src_mac_step $value
            }
            -vlan_id1 -
			-outer_vlan_id {
				set vlan_id1 $value
            }
            -vlan_id1_step -
			-outer_vlan_step {
				set vlan_id1_step $value
            }
            -vlan_id2 -
			-inner_vlan_id {
				set vlan_id2 $value
            }
            -vlan_id2_step -
			-inner_vlan_step {
				set vlan_id2_step $value
            }
            -ipv4_addr {
				set ipv4_addr $value
            }
            -ipv4_addr_step {
				set ipv4_addr_step $value
            }
			-ipv4_prefix_len -
			-ipv4_prefix_length	{
				set ipv4_prefix_len $value
			}
			-ipv4_gw {
				set ipv4_gw $value
			}
			-ipv4_gw_step {
				set ipv4_gw_step $value
			}
			-ipv6_addr {
				set ipv6_addr $value
			}
			-ipv6_addr_step {
				set ipv6_addr_step $value
			}
			-ipv6_prefix_len -
			-ipv6_prefix_length {
				set ipv6_prefix_len $value
			}
			-ipv6_gw {
				set ipv6_gw $value
			}
			-ipv6_gw_step {
				set ipv6_gw_step $value
			}
			-ip_version {
				set ip_version $value
			}
			-static {
				set static $value
			}
			-unconnected {
				set unconnected $value
			}
		}
    }	
	
	set pfxIncr 	[ GetStepPrefixlen $ipv4_addr_step ]
	if { [ info exists ipv4_gw_step ] } {
		set gwPfxIncr	[ GetStepPrefixlen $ipv4_gw_step ]
	}
Deputs "pfxIncr:$pfxIncr"	
	if { [ info exists static] == 0 } {
		if { [ info exists ipv4_addr ] } {
			set static 0
		}
		if { [ info exists ipv6_addr ] } {
			set static 0
		}
	}
	
	if { $static } {
		set handle [ixNet add $hPort/protocols/static lan]
		if { $src_mac_step != "00:00:00:00:00:01" || 
			$vlan_id1_step > 1 || $vlan_id2_step > 1 } {
			#...
		} else {
			ixNet setM $handle \
				-enabled $enabled \
				-enableIncrementMac True \
				-count $count
			ixNet commit
			set handle [ ixNet remapIds $handle ]
			
			if { [ info exists src_mac ] } {
				ixNet setA $handle -mac $src_mac
			}
			
			if { [ info exists vlan_id1 ] } {
				set enableVlanIncr False
				set vlanIncrMode parallelIncrement
				if { $vlan_id1_step || $vlan_id2_step } {
					set enableVlanIncr True
					if { $vlan_id1_step && $vlan_id2_step } {
						set vlanIncrMode parallelIncrement
					} else {
						if { $vlan_id1_step } {
							set vlanIncrMode outerFirst
						} else {
							set vlanIncrMode innerFirst
						}
					}
				} else {
					set vlanIncrMode noIncrement
				}
				ixNet setM $handle -enableVlan True \
					-enableIncrementVlan $enableVlanIncr \
					-incremetVlanMode $vlanIncrMode
				if { [ info exists vlan_id2 ] } {
					ixNet setM $handle \
						-vlanCount 2 \
						-vlanId "${vlan_id1},${vlan_id2}"
				} else {
					ixNet setM $handle \
						-vlanCount 1 \
						-vlanId $vlan_id1
				}
			} 
		}
		ixNet commit
	} else {
		for { set index 0 } { $index < $count } { incr index } {
			set int [ ixNet add $hPort interface ]
			if { $unconnected } {
Deputs "unconncted:$unconnected"
Deputs "int:$int"		
				ixNet setA $int -type routed
			}
			ixNet setA $int -description $this
			ixNet commit
			set int [ixNet remapIds $int]
			lappend handle $int

	Deputs "int:$int"	
			if { [ info exists ipv4_addr ] } {
				if { [ llength [ ixNet getL $int ipv4 ] ] == 0 } {
					ixNet add $int ipv4
					ixNet commit
				}
				ixNet setM $int/ipv4 \
					-ip $ipv4_addr \
					-gateway $ipv4_gw \
					-maskWidth $ipv4_prefix_len
				ixNet commit
	Deputs "Step10"			
				if { $pfxIncr > 0 } {
					set ipv4_addr [ IncrementIPAddr $ipv4_addr $pfxIncr ]
				}
				if { [ info exists gwPfxIncr ] && $gwPfxIncr > 0 } {
					set ipv4_gw [ IncrementIPAddr $ipv4_gw $gwPfxIncr ]
				}
			}
			if { [ string tolower $ip_version ] != "ipv4" } {
			
				if { [ llength [ ixNet getL $int ipv6 ] ] == 0 } {
					ixNet add $int ipv6
					ixNet commit
				}
	Deputs "IPv6 Addr: $ipv6_addr "
	Deputs "int/ipv6: [ ixNet getL $int ipv6 ]"
				ixNet setM [ ixNet getL $int ipv6 ] \
					-ip $ipv6_addr \
					-gateway $ipv6_gw \
					-prefixLength $ipv6_prefix_len
				ixNet commit
				if { [ info exists ipv6_addr_step ] } {
					set ipv6_addr [ IncrementIPv6Addr $ipv6_addr $ipv6_prefix_len ]
				}
				if { [ info exists ipv6_gw_step ] } {
					set ipv6_gw   [ IncrementIPv6Addr $ipv6_gw $ipv6_prefix_len ]
				}
	Deputs "ipv6 addr incr: $ipv6_addr"			
			}
Deputs "config mac"
			if { [ info exists src_mac ] } {
				ixNet setM $int/ethernet \
						-macAddress $src_mac 
				ixNet commit
				set src_mac [ IncrMacAddr $src_mac $src_mac_step ]
			}
Deputs "config vlan1"
			if { [ info exists vlan_id1 ] } {
				set vlanId	$vlan_id1
				
				ixNet setM $int/vlan \
					-count 1 \
					-vlanEnable True \
					-vlanId $vlanId
				ixNet commit
				incr vlan_id1 $vlan_id1_step
			}
			
Deputs "config vlan2"
			if { [ info exists vlan_id2 ] } {
				set vlanId	$vlan_id2

				set vlanId1	[ ixNet getA $int/vlan -vlanId ]
				set vlanId	"${vlanId1},${vlanId}"
			
				ixNet setM $int/vlan \
					-count 2 \
					-vlanEnable True \
					-vlanId $vlanId
				ixNet commit
				incr vlan_id2 $vlan_id2_step
			}
			
Deputs "enable interface"
			if { [ info exists enabled ] } {
				ixNet setA $int -enabled $enabled
				ixNet commit			
			}
		}
		

		
	}
	
	Deputs "static $static"
	return [ GetStandardReturnHeader ]
}

body Host::ping { args } {
    set tag "body Host::ping [info script]"
Deputs "----- TAG: $tag -----"

	global errNumber

	set count 		1
	set interval 	1000
	set flag 		1

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -dst {
                if { [ IsIPv4Address $value ] } {
                    set dut_ip $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -count {
                if { [ string is integer $value ] } {
                    set count $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -interval {
                if { [ string is integer $value ] } {
                    set interval    $value

                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -flag {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
                    set enable_arp $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            default {
                error "$errNumber(3) key:$key value:$value"
            }
        }
    }
    
	set pingTrue	0
	set pingFalse	0


Deputs Step10
	set pingResult [ list ]
	for { set index 0 } { $index < $count } { incr index } {
		
		foreach int $handle {
			lappend pingResult [ ixNet exec sendPing $int $dut_ip ]
		}
	
		after $interval
	}
	Deputs "The ping result is: $pingResult"
Deputs Step20
	set pingPass	0
	foreach result $pingResult {
		if { [ regexp {failed} $result ] } {
			incr pingFalse
			set pingPass 0
		} else {
			incr pingTrue
			set pingPass 1
		}
	}
	
# Deputs Step40
	# set loss [ expr $pingFalse / $count.00 * 100 ]
	
# Deputs Step50
	# if { $pingPass == $flag } {
		# set ret  [ GetStandardReturnHeader ]
	# } else {
		# set ret  [ GetErrorReturnHeader "Unexpected result $pingPass" ]
	# }
	
# Deputs Step60
	# lappend ret [ GetStandardReturnBody "loss" $loss ]
	
	return $pingPass

}




