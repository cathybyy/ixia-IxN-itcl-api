
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.52
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1
#       1. Add SingleVlan SingeMpls Hdr to represent single vlan/mpls header
#       2. add new type APPLIST to realize two headers of vlan/mpls
#       3. add custom view filtered by TrafficItem and RxPort in get_stats
# Version 1.2
#	 4. Change highLevelStream to configElement object to generate stream
# Version 1.3.1.13
#	 5. Add method get_hex_data
#	 6. CreateRawStream generate a list of highLevelStream, add foreach in traffic.config method
# Version 1.4.1.17
#	 7. Add condition before create raw stream in Traffic.config, or else there'll add one stream each config execution
# Version 1.5.2.2
#	 8. Add enable_sig param in Traffic.config
# Version 1.6.2.4
#	 9. Map config.-src = "" => = portObj
# Version 1.7.2.5
#	10. Add default value for sa in EtherHdr.config
#	11. Add Common CFM Header class
#	12. Add CCM Header class
#	13. Add default value for da in EtherHdr.config
# Version 1.8.2.6
#	14. Add condition that Traffic obj has been removed being configured (object reborn)
# Version 1.9.2.7
#	15. Set random mac for src mac and dst mac in EtherHdr.config
# Version 1.10.2.11
#	16. Add Header properties noMac and noIp to identify default mac and ip address to be filled
#	17. Modify EthHdr/Ipv4Hdr/ArpHdr src mac and src ip when noMac or noIp identified
# Version 1.11.2.12
#	18. Add exception on dest endpoint for transmitting port in CreateRawStream
# Version 1.12.2.13
#	19. Add empty argument repeat_count in Traffic.config
# Version 1.13.2.16
#	20. idn_num set to zero to disable vlan in Vlan.Config
#	21. double set suspend false in Traffic.enable
# Version 1.14.2.18
#	22. Fix the bug that confilct var name of reserved
# Version 1.15.2.18
#	23. Fix the bug that interface/ipv4 does not exist
# Version 1.16.2.19
# 	24. Fix the bug that Traffic.config fired with no arguments
#	25. Add CustomHdr class
# Version 1.17.2.20
#	26. Make enable ineditable if state is initially enable
# Version 1.18.2.22
#   27. EthHdr.config -src_range_mode -dst_range_mode
#	28. Ipv4Hdr.config -src_range_mode -dst_range_mode
# Version 1.19.2.23
#	29. Add autos reset in PDU unconfig
# Version 1.20.2.26
#	30. Add latency_type in traffic.set
# Version 1.21.3.0
#	31. Add vlan.set -pri_num
# Version 1.22.3.1L
#	32. Adjust latency to us
# Version 1.23.3.5
#	33. Disable dataIntegrity check
# Version 1.24.3.8
#	34. Add DC header
# Version 1.25.3.9
#	35. Add l1 bit rate
# Version 1.26.3.10
#	36. Add default value for sarepeat and darepeat in IPv6Hdr.config
#   37. Add host type for src/dst in Traffic.config
# Version 1.28.4.0
#	38. change get_stats to traffic item view instead of port filtered view
# Version 1.29.4.1
#	39. change eg_nickname_step to hex in TrillHdr.config
# Version 1.30.cgn
#	40. Add mesh in traffic.config Header definition
#	41. Add src/dst port mesh in UdpHdr
# Version 1.31.4.11
#   42. Set 4 octets signature
# Version 1.32.4.12
#	43. Add adapter param -need_arp in traffic.config
# Version 1.33.4.13
#	43. Modify stream_load type also integer and double in traffic.config 
# Version 1.34.4.19
#	44. check use 4bytes signature in Traffic config
#	45. check stats guard rail in Traffic config
# Version 1.35.4.23
#	46. Add IcmpHdr
# Version 1.36.4.24
#	46. Modify dscp in Ipv4Hdr	
# Version 1.37.CGN
#	47. Create Traffic by existing trafficItem obj in Traffic.ctor
# Version 1.37.4.25
#   47. traffic::enable/disable back to version 4.19,control the attribution of suspend
#   48. traffic enabled in traffic::config 
# Version 1.38 4.26
#   49. Add log information
# Version 1.38 4.27
#   50. Add tcp sequence num step
# Version 1.39 4.28
#   51. Change seq_num_count to seq_num_cnt
# Version 1.40 4.29
#   52. Add default seq_num to 123456, change the define of  seq_num_mod
# Version 1.41.4.35
#	53. Add source/destination class awareness on BGP/Host/RouteBlock/MulticastGroup in traffic.config
# Version 1.42.4.36
#	54. Add precedence increment in Traffic.config
# Version 1.43.4.42
#	55. add source/destination class awareness on VcLsp
# Version 1.44.4.43
#	56. add ipv4 precedence tracking
# Version 1.45.4.46
#	57. add conditional apply traffic in Traffic.start
# Version 1.46.4.50
#	58. add no_mesh to_raw to config
# Version 1.47.4.51
#	59. fix bug for transfer to raw check mac error
# Version 1.48.4.53
#	60. add pdu_index in config
# Version 1.49.4.55
#	61. add GreHdr
# 	62. change GreHdr.config args name
# Version 1.50.4.57
#	63.add precedence_fullmesh in IPv4Hdr.config
# Version 1.51.4.59
#	64. fix bugs in bgp route range traffic in Traffic.config
# Version 1.52.12.9
#	65. add VxlanHdr
# Version 1.53.1.15
#	66. add Traffic::traffic_enable/traffic_disable

# -- Class definition...
class Traffic {
    inherit NetObject
    #--public method
    constructor { port { hTraffic NULL } } {}
    method config { args  } {}
    method enable {} {}
    method disable {} {}
    method traffic_enable {} {}
    method traffic_disable {} {}
    method get_status {} {}
    method get_stats { args } {}
	method get_stats_per_port { args } {}
    method get_hex_data {} {}
    #--private method
    method GetProtocolTemp { pro } {}
    method GetField { stack field } {}
    method CreateRawStream { { sig 1 } } {}
    method CreateQuickStream {} {}
    method GetQuickItem {} {}
    method CreatePerPortView { rxPort } {}
	method CreatePerPrecedenceView {} {}
    
	method start {} {
		set tag "body Traffic::start [info script]"
Deputs "----- TAG: $tag -----"
		if { [ catch {
			if { [ ixNet getA $handle -state ] == "unapplied" } {
				Tester::apply_traffic
			}
		} err ] } {
Deputs "traffic start error:$err"		
		}
		if { [ catch {
			ixNet exec startStatelessTraffic $handle
		} ] } {
			after 2000
			ixNet exec startStatelessTraffic $handle
		}
		return [ GetStandardReturnHeader ]
	}
	method stop {} {
		set tag "body Traffic::stop [info script]"
Deputs "----- TAG: $tag -----"
		ixNet exec stopStatelessTraffic $handle
		return [ GetStandardReturnHeader ]
	}
	method completed {} {
		set tag "body Traffic::completed [info script]"
Deputs "----- TAG: $tag -----"
	
		set rate [ GetStatsFromReturn [ get_stats ] tx_frame_rate ]
		set tx [ GetStatsFromReturn [ get_stats ] tx_frame_count ]
		if { $rate == 0 && $tx > 0 } {
			return 1
		} else {
			return 0
		}
	}
	
	method wait_started {} {
		set tag "body Traffic::wait_started [info script]"
Deputs "----- TAG: $tag -----"
		set timeout 30
		set start_click [ clock seconds ]
		while { 1 } {
			set timeout_click \
				[ expr [ clock seconds ] - $start_click ]
			if { $timeout_click >= 30 } {
				return 0
			}
			set rate [ GetStatsFromReturn [ get_stats ] tx_frame_rate ]
			if { $rate == 0 } {
				after 1000
			} else {
				return 1
			}
		}
	}
	
	method wait_stopped {} {
		set tag "body Traffic::wait_stopped [info script]"
Deputs "----- TAG: $tag -----"
		set timeout 30
		set start_click [ clock seconds ]
		while { 1 } {
			set timeout_click \
				[ expr [ clock seconds ] - $start_click ]
			if { $timeout_click >= 30 } {
				return 0
			}
			set rate [ GetStatsFromReturn [ get_stats ] tx_frame_rate ]
			if { $rate != 0 } {
				after 1000
			} else {
				return 1
			}
		}
	}
	
	method suspend {} {
		set tag "body Traffic::suspend [info script]"
Deputs "----- TAG: $tag -----"
		ixNet setA $handle -suspend True
		ixNet commit
	}
	
	method unsuspend {} {
		set tag "body Traffic::unsuspend [info script]"
Deputs "----- TAG: $tag -----"
		ixNet setA $handle -suspend False
		ixNet commit
	}
    public variable id
    
    #stream stats
    public variable hPort
    public variable endpointSet
    public variable highLevelStream
    public variable portObj
    
    #stats var
    #public variable portView
    #public variable flowView
    
}
class Header {
    inherit NetObject
    constructor { pduPro { pduType "APP" } } {
	   #set EMode [ list Incrementing Decremeting Fixed Random ]
	   set fieldModes [ list ]
	   set fields [ list ]
	   set fieldConfigs [ list ]
	   set optionals [ list ]
	   set autos [ list ]
	   set valid 0
	   set type $pduType
	   set protocol $pduPro
Deputs "type:$type\tprotocol:$protocol"
		set noMac 1
		set noIp 1
Deputs "constructor success"		
    }
    method ConfigPdu { args } {}
    destructor {}
    public variable protocol
    # SET - set | APP - append | MOD - modify | RAW - raw data
    public variable type
    public variable fields
    public variable fieldModes
    public variable fieldConfigs
    public variable optionals
    public variable autos
	public variable meshes
    public variable raw
	
    public variable noMac
    public variable noIp
	
    private variable valid
    method ChangeType { chtype } { set type $chtype }
    method SetProtocol { value } { set protocol $value }
    method SetRaw { value } { set raw $value }
    method AddField { value { optional 0 } { auto 0 } { mesh 0 } } {
	   lappend fields $value
	   lappend optionals $optional
	   lappend autos $auto
	   lappend meshes $mesh
	   set valid 1
Deputs "fields:$fields optionals:$optionals autos:$autos meshes:$meshes"
    }
    # Fixed | List | Segment ( set a segment of bits from the beginning of certain field )
    # | Incrementing | Decrementing | Reserved ( for option and auto now )
    method AddFieldMode { value } {
	   lappend fieldModes $value
	   set valid 1
    }
    method AddFieldConfig { args } {
	   lappend fieldConfigs $args
	   set valid 1
    }
    method Clear {} {
	   set fields [ list ]
	   set fieldModes [ list ]
	   set fieldConfigs [ list ]
	   set optionals [ list ]
	   set autos [ list ]
	   set meshes [ list ]
	   set valid 0
    }
    method IsValid {} {
	   return $valid
    }
	method config { args } {
		set tag "body Header::config [info script]"
Deputs "----- TAG: $tag -----"

		set modify 0
#param collection
Deputs "Args:$args "
		foreach { key value } $args {
		   set key [string tolower $key]
			switch -exact -- $key {
				-modify {
					set modify $value
				}
			}
		}
		
		if { $modify } {
			ChangeType MOD
		}
	}
	method unconfig {} { Clear }
}
class EtherHdr {
    inherit Header
    constructor {} { chain Ethernet SET } {
		set daoffset 0
		set saoffset 0
		set daStep 1
		set saStep 1
		set daNum  1
		set saNum  1
		set sa [ RandomMacAddr ]
		set da [ RandomMacAddr ]
	}
    
	public variable daoffset
	public variable saoffset
	public variable daStep
	public variable saStep
	public variable daNum
	public variable saNum
	public variable sa
	public variable da
	
    method config { args } {}
}
class CustomHdr {
    inherit Header
    constructor {} { chain custom } {}
    
    method config { args } {}

}
class SingleVlanHdr {
    inherit Header
    constructor {} { chain vlan } {}
    
    method config { args } {}
}
class VlanHdr {
    inherit Header
    constructor {} { chain vlan APPLIST } {}
    
    method config { args } {}
    public variable objList
}
class Ipv4Hdr {
    inherit Header
    constructor {} { chain IPv4 } {}
    
    method config { args } {}
}
class Ipv6Hdr {
    inherit Header
    constructor {} { chain IPv6 } {}
    
    method config { args } {}
}
class TcpHdr {
    inherit Header
    constructor {} { chain TCP } {}
    
    method config { args } {}
}
class IcmpHdr {
    inherit Header
    constructor {} { chain ICMPV2 } {}
    
    method config { args } {}
}
class UdpHdr {
    inherit Header
    constructor {} { chain UDP } {}
    
    method config { args } {}
}
class SingleMplsHdr {
    inherit Header
    constructor {} { chain MPLS } {}
    
    method config { args } {}
}
class MplsHdr {
    inherit Header
    constructor {} { chain MPLS APPLIST } {}
    
    method config { args } {}
    public variable objList
}
class ArpHdr {
    inherit Header
    constructor {} { chain ethernetARP } {}
	    
    method config { args } {}
}
class CfmHdr {
	inherit Header
	constructor {} { chain cfm } { set opCode 0 }
	
	method config { args } {}
	
	public variable opCode
}
class CcmHdr {
	inherit CfmHdr
	constructor {} { chain } { set opCode 1 }
	
	method config { args } {}
}
class TrillHdr {
	inherit Header
	constructor {} { chain Trill } {
		set eg_nickname_mod 16
		set ing_nickname_mod 16
		set eg_nickname_step 1
		set ing_nickname_step 1
		set eg_nickname_num  1
		set ing_nickname_num  1
	}
	public variable version
	public variable reserved
	public variable mcast_flag
	public variable op_length
	public variable hop_count
	public variable eg_nickname
	public variable eg_nickname_num
	public variable eg_nickname_step
	public variable eg_nickname_mod
	public variable ing_nickname
	public variable ing_nickname_num
	public variable ing_nickname_step
	public variable ing_nickname_mod
	
	method config { args } {}
}
class GreHdr {
	inherit Header
	constructor {} { chain Gre } {
		set checksum_present 0
		set checksum 0
		set key_present 0
		set key 0
		set sn_present 0
		set sn 0
		set version 0
	}
	
	public variable version
	public variable gre_protocol
	public variable checksum_present
	public variable checksum
	public variable key_present
	public variable key
	public variable sn_present
	public variable sn

	method config { args } {}
}



# -- Traffic implmentation
body Traffic::constructor { port { hTraffic NULL } } {
    set tag "body Traffic::ctor [info script]"
Deputs "----- TAG: $tag -----"

	if { $hTraffic != "NULL" } {
		set handle $hTraffic
		set highLevelStream [ ixNet getL $handle configElement ]
		set endpointSet [ ixNet getL $handle endpointSet ]
	} else {

		set root    [ixNet getRoot]
		set handle  [ixNet add $root/traffic trafficItem]

		regexp {\d+} $handle id
		ixNet setM $handle \
			-name $this
Deputs "traffic item handle:$handle"

	}
	
	set portObj $port
Deputs "portObj:$portObj"
	if { [ catch {
		set hPort [ $port cget -handle ]
	} ] } {
Deputs "port:$port"
		set port [ GetObject $port ]
Deputs "port:$port"		
		set hPort [ $port cget -handle ]
	}
}

body Traffic::config { args  } {
# in case the handle was removed
	if { $handle == "" } {
	   
Deputs "reborn traffic...."
		set root    [ixNet getRoot]
		set handle  [ixNet add $root/traffic trafficItem]
	
		regexp {\d+} $handle id
		ixNet setA $handle -name $this
		set port $portObj
Deputs "port:$port"
		if { [ catch {
			set hPort [ $port cget -handle ]
		} ] } {
			set port [ GetObject $port ]
			set hPort [ $port cget -handle ]
		}
		    set highLevelStream ""
Deputs "hport:$hPort" 
       
	}
#

# enable l1Rate use 4 bytes signature and disable data integrity check
	set root [ixNet getRoot]
	ixNet setA $root/traffic/statistics/l1Rates -enabled True
	ixNet setA $root/traffic \
			-enableDataIntegrityCheck False \
			-enableMinFrameSize True
	ixNet commit
#

# get default port Mac and IP address
	set default_mac [ lindex [ $portObj cget -intf_mac ] 0 ]
	set default_ip  [ lindex [ $portObj cget -intf_ipv4 ] 0 ]
	if { ( $default_ip == "0.0.0.0" ) || ( $default_ip == "" ) } {
		set default_ip 1.1.1.1
	}
	if { $default_mac == "" } {
		set default_int [ lindex [ ixNet getL [ $portObj cget -handle ] interface ] 0 ]
Deputs "default interface:$default_int"
		if { $default_int != "" } {
			set default_mac [ ixNet getA $default_int/ethernet -macAddress ]
		}
		if { $default_mac == "::ixNet::OK" } {
Deputs "get mac error"		
			set default_mac "00:00:01:01:01:01"
		}
	}
Deputs "default mac:$default_mac"
Deputs "default ip:$default_ip"
#

    global errorInfo
    global errNumber
    
    set EMode       [ list continuous burst iteration auto custom ]
    set ELenType    [ list fixed incr random ]
    set EFillType   [ list constant incr decr prbs random ]
    set EPayloadType [ list CYCBYTE INCRBYTE DECRBYTE PRBS USERDEFINE ]
    set ELoadUnit	[ list KBPS MBPS BPS FPS PERCENT ]
    set ELatencyType [list lifo lilo filo fifo]
	
    # set load_unit 		KBPS
    # set stream_load 	10000
    # set frame_len		256
    set enable_sig		1
	
	set flag_modify_adv	0
	set trafficType ipv4
	set bidirection 0
	set fullMesh 0
	set selfdst 0
	set tos_tracking 0
	set no_src_dst_mesh 0
	set no_mesh 0
	set to_raw 0
	set pdu_index 1
    set burst_gap_units "bytes"
    #set burst_gap_units "nanoseconds"
    set enable_burst_gap "true"
    set burst_packet_count 1
	
    set tag "body Traffic::config [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -location {
			 set location $value
		  }
		  -src {
			 set src $value
		  }
		  -dst {
			 set dst $value
		  }
		  -full_mesh {
			set fullMesh $value
		  }
		  -pdu {
			 set pdu $value
Deputs "pdu:$pdu"
		  }
		  -pdu_index {
			set pdu_index $value
		  }
		  -tx_mode {
			 set value [ string tolower $value ]
			 if { [ lsearch -exact $EMode $value ] >= 0 } {
				
				set tx_mode $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -tx_num {
			 if { [ string is integer $value ] } {
				set tx_num $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -frame_len_type {
			 set value [ string tolower $value ]
			 if { [ lsearch -exact $ELenType $value ] >= 0 } {
				
				set frame_len_type $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -frame_len {
			 if { [ string is integer $value ] && ( $value >= 12 ) } {
				set frame_len $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -min_frame_len {
			 if { [ string is integer $value ] && ( $value >= 12 ) } {
				set min_frame_len $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -max_frame_len {
			 if { [ string is integer $value ] && ( $value >= 12 ) } {
				set max_frame_len $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -frame_len_step {
			 if { [ string is integer $value ] } {
				set frame_len_step $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -enable_fcs_error_insertion {
			 set trans [ BoolTrans $value ]
			 if { $trans == "1" || $trans == "0" } {
				set enable_fcs_error_insertion $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -fill_type {
			 set value [ string tolower $value ]
			 if { [ lsearch -exact $EFillType $value ] >= 0 } {
				
				set fill_type $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -payload_type {
				set value [ string toupper $value ]
			 if { [ lsearch -exact $EPayloadType $value ] >= 0 } {
				
				set payload_type $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -payload -
		  -fill_content {
				set payload $value
		  }
		  -enable_sig -
		  -enabel_sig -
		  -sig {
			 set trans [ BoolTrans $value ]
			 if { $trans == "1" || $trans == "0" } {
				set enable_sig $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
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
		  -latency_type {
		    set value [ string tolower $value ]
		    if { [ lsearch -exact $ELatencyType $value ] >= 0 } {
			
			set latency_type $value
		    } else {
			error "$errNumber(1) key:$key value:$value"
		    }
		  }
          -min_gap_bytes -
		  -inter_burst_gap -
		  -inter_frame_gap {
			  set inter_frame_gap $value
		  }
          -enable_burst_gap {
			  set enable_burst_gap $value
		  }
		  -burst_gap {
			  set burst_gap $value
		  }
          -burst_gap_units  {
			  set burst_gap_units $value
		  }
          -burst_packet_count {
              set burst_packet_count $value
          }
		  -peer_intf {}
		  -repeat_count {}
			-bidirection {
				set value [BoolTrans $value]
				set bidirection $value
			}
			-enable_stream_only_generation {}
			-traffic_type {
				set trafficType $value
			}
			-traffic_pattern {
				set value [ string tolower $value ]
				switch $value {
					pair {
					}
					mesh {
						set fullMesh 1
					}
					backbone {
					}
				}
			}
			-rcv_ports -
			-rcv_port {
				set rcv_ports $value
			}
		  -need_arp {}
		  -selfdst {
			set value [BoolTrans $value]
			set selfdst $value
		  }
		  -precedence_tracking {
			set value [BoolTrans $value]
			set precedence_tracking $value
		  }
		  -no_mesh {
			set value [BoolTrans $value]
			set no_mesh $value
		  }
		  -to_raw {
			set value [BoolTrans $value]
			set to_raw $value
		  }
		  default {
			 error "$errNumber(3) key:$key value:$value"
		  }
	   }
    }
    
    if { [ info exists location ] } {
	   if { [ regexp  {(\d+\.\d+\.\d+\.\d+)/(\d+)/(\d+)} $location match chas card port ] } {
		  set root    [ixNet getRoot]
		  set locObj  ""
		  foreach vport [ ixNet getList $root vport ] {
			 if { [ catch {
				set assignedTo [ixNet getA $vport -assignedTo] } ] } {
				continue
			 } else {
				set assignedInfo [ split $assignedTo ":" ]
				if { ( $chas == [ lindex $assignedInfo 0 ] ) && \
					( $card == [ lindex $assignedInfo 1 ] ) && \
					( $port == [ lindex $assignedInfo 2 ] ) } {
				    set locObj $vport
				}
			 }
		  }
		  set hPort $locObj
		  if { $locObj == "" } {
			 error "$errNumber(1) key:location value:$location (No match port found in port reserved)"
		  }
	   } else {
		  error "$errNumber(1) key:location value:$location (Format incorrect. Chas/Card/Port)"
	   }
    }    
    
    #-- quick stream and advanced stream
    if { [ info exists src ] && [ info exists dst ] } {
	   if { [ IsIPv4Address $src ] && [ IsIPv4Address $dst ] } {
#-- quick stream IPv4
Deputs "Traffic type:quick stream IPv4"
		  #-- Create quick stream
			##--add judgement for traffic reconfig
			if { ( [ info exists highLevelStream ] == 0 ) || ( [ llength $highLevelStream ] == 0 ) } {
				CreateRawStream $enable_sig
			}
		  #-- append custom stack
		  #default stack list will be ethernet and fcs
		  set stackList [ ixNet getList $highLevelStream stack ]
		  ixNet exec append [ lindex $stackList 0 ] [ GetProtocolTemp ipv4 ]
		  #-- modify the custom stack field
		  set customStack [ lindex [ ixNet getList $highLevelStream stack ] 1 ]
		  set srcIpField [ GetField $customStack srcIp ]
		  set dstIpField [ GetField $customStack dstIp ]
		  ixNet setA $srcIpField -singleValue $src
		  ixNet setA $dstIpField -singleValue $dst
		  ixNet commit
	   } elseif { [ IsIPv6Address $src ] && [ IsIPv6Address $dst ] } {
#-- quick stream IPv6
Deputs "Traffic type:quick stream IPv6"
		  #-- Create quick stream
			##--add judgement for traffic reconfig
			if { ( [ info exists highLevelStream ] == 0 ) || ( [ llength $highLevelStream ] == 0 ) } {
				CreateRawStream 
			}
		  #-- append custom stack
		  #default stack list will be ethernet and fcs
		  set stackList [ ixNet getList $highLevelStream stack ]
		  ixNet exec append [ lindex $stackList 0 ] [ GetProtocolTemp ipv6 ]
		  #-- modify the custom stack field
		  set customStack [ lindex [ ixNet getList $highLevelStream stack ] 1 ]
		  set srcIpField [ GetField $customStack srcIp ]
		  set dstIpField [ GetField $customStack dstIp ]
		  ixNet setA $srcIpField -singleValue $src
		  ixNet setA $dstIpField -singleValue $dst
		  ixNet commit            
	   } else {
Deputs "objects:[find objects]"
		set srcHandle [ list ]
Deputs "src list:$src"		
		foreach srcEndpoint $src {
# Deputs "src:$srcEndpoint"
			set srcObj [ GetObject $srcEndpoint ]
# Deputs "srcObj:$srcObj"			
			if { $srcObj == "" } {
			Deputs "illegal object...$srcObj"
				set srcObj $portObj
			# error "$errNumber(1) key:src value:$src (Not an object)"                
			}
			if { ( [ $srcObj isa Port ] == 0 ) && ( [ $srcObj isa EmulationObject ] == 0 ) && ( [ $srcObj isa Host ] == 0 ) } {
			Deputs "illegal object...$src"
			 error "$errNumber(1) key:src value:$src (Not a port or emulation object)"                
			}
			if { [ $srcObj isa Port ] } {
			Deputs Step110
				set srcHandle [ concat $srcHandle "[ $srcObj cget -handle ]/protocols" ]
			} elseif { [ $srcObj isa RouteBlock ] } {
Deputs "route block:$srcObj"
				if { [ $srcObj cget -protocol ] == "bgp" } {
					set routeBlockHandle [ $srcObj cget -handle ]
					set hBgp [ ixNet getP $routeBlockHandle ]
Deputs "bgp route block:$hBgp"
					if { [ catch {
						set rangeCnt [ llength [ ixNet getL $hBgp routeRange ] ]
					} ] } {
						set rangeCnt [ llength [ ixNet getL $hBgp vpnRouteRange ] ]
					}
					if { $rangeCnt > 1 } {
						set p [ ixNet getP $routeBlockHandle ]
						set startIndex [ string first $p $routeBlockHandle ]
						set endIndex [ expr $startIndex + [ string length $p ] - 1 ]
						set routeBlockHandle \
						[ string replace $routeBlockHandle \
						$startIndex $endIndex $p.0 ]
	Deputs "route block handle:$routeBlockHandle"		
					} else {
						set routeBlockHandle [ $srcObj cget -hPort ]/protocols/bgp
					}
					set srcHandle [ concat $srcHandle $routeBlockHandle ]
				} else {
					set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
				}
				set trafficType [ $srcObj cget -type ]
			} elseif { [ $srcObj isa Host ] } {
				if { [ $srcObj cget -static ] } {
					set trafficType "ethernetVlan"
				} else {
					set trafficType [ $srcObj cget -ip_version ]
				}
				set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
			} elseif { [ $srcObj isa MulticastGroup ] } {
				if { [ $srcObj cget -protocol ] == "mld" } {
					set trafficType "ipv6"
				} 
				set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
			} elseif { [ $srcObj isa VcLsp ] } {
				set trafficType "ethernetVlan"
				set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
			} else {
			Deputs Step120
				set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
			}
		}
Deputs "src handle:$srcHandle"

		set dstHandle [ list ]
Deputs "dst list:$dst"		
		foreach dstEndpoint $dst {
# Deputs "dst:$dstEndpoint"
			set dstObj [ GetObject $dstEndpoint ]
# Deputs "dstObj:$dstObj"			
			if { $dstObj == "" } {
			Deputs "illegal object...$dstEndpoint"
			 error "$errNumber(1) key:dst value:$dst"                
			}
			if { ( [ $dstObj isa Port ] == 0 ) && ( [ $dstObj isa EmulationObject ] == 0 ) && ( [ $dstObj isa Host ] == 0 ) } {
			Deputs "illegal object...$dst"
			 error "$errNumber(1) key:dst value:$dst (Not a port or emulation object)"                
			}
			Deputs Step100
			if { [ $dstObj isa Port ] } {
			Deputs Step130
				set dstHandle [ concat $dstHandle "[ $dstObj cget -handle ]/protocols" ]
			} elseif { [ $dstObj isa RouteBlock ] } {
				if { [ $dstObj cget -protocol ] == "bgp" } {
					set routeBlockHandle [ $dstObj cget -handle ]
					set hBgp [ ixNet getP $routeBlockHandle ]
Deputs "bgp route block:$hBgp"
					if { [ catch {
						set rangeCnt [ llength [ ixNet getL $hBgp routeRange ] ]
					} ] } {
						set rangeCnt [ llength [ ixNet getL $hBgp vpnRouteRange ] ]
					}
					if { $rangeCnt > 1 } {
						set p [ ixNet getP $routeBlockHandle ]
						set startIndex [ string first $p $routeBlockHandle ]
						set endIndex [ expr $startIndex + [ string length $p ] - 1 ]
						set routeBlockHandle \
						[ string replace $routeBlockHandle \
						$startIndex $endIndex $p.0 ]
	Deputs "route block handle:$routeBlockHandle"		
					} else {
						set routeBlockHandle [ $dstObj cget -hPort ]/protocols/bgp
					}
					set dstHandle [ concat $dstHandle $routeBlockHandle ]
				} else {
Deputs "dst obj:$dstObj"				
Deputs "route block handle:[$dstObj cget -handle]"				
					set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
				}
			} elseif { [ $dstObj isa Host ] } {
				set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
			} elseif { [ $dstObj isa MulticastGroup ] } {
				set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
			} else {
				set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
			}
		}
#-- advanced stream Ports/Emulations
Deputs "Traffic type: advanced stream:$trafficType"
		  #-- Create advanced stream
		  #-- create trafficItem      
		if { $bidirection } {
			set bi True
		} else {
			set bi False
		}
		if { $selfdst } {
			set sd True
		} else {
			set sd False
		}
		if { $fullMesh } {
			Deputs "traffic src/dst type: full mesh"		  
			  ixNet setMultiA $handle \
				 -trafficItemType l2L3 \
				 -routeMesh oneToOne \
				 -srcDestMesh fullMesh \
				 -allowSelfDestined $sd \
				 -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan

		} else {
			if { $no_mesh } {
Deputs "traffic src/dst type: none"		  		  
			  ixNet setMultiA $handle \
				 -trafficItemType l2L3 \
				 -biDirectional $bi \
				 -routeMesh oneToOne \
				 -srcDestMesh none \
				 -allowSelfDestined $sd \
				 -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan
			} else {
Deputs "traffic src/dst type: one 2 one"		  		  
			  ixNet setMultiA $handle \
				 -trafficItemType l2L3 \
				 -biDirectional $bi \
				 -routeMesh oneToOne \
				 -srcDestMesh oneToOne \
				 -allowSelfDestined $sd \
				 -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan
			}
		}
		if { $enable_sig } {
			ixNet setA $handle/tracking -trackBy sourceDestPortPair0
			ixNet commit
		}
Deputs "add endpointSet..."
		  ixNet commit
		  #-- add endpointSet
		  set endpointSet [ixNet add $handle endpointSet]
Deputs "src:$srcHandle"
		  ixNet setA $endpointSet -sources $srcHandle
Deputs "dst:$dstHandle"
		  ixNet setA $endpointSet -destinations $dstHandle
		  
		  ixNet commit
		  set handle      [ ixNet remapIds $handle ]
Deputs "handle:$handle"
Deputs Step170
		  ixNet commit
Deputs Step180
		  #-- for every stream is not bi-direction, thus only one highlevelstream will be created
#            set highLevelStream [ ixNet getList $handle highLevelStream ]
Deputs "handle:$handle"
		  set endpointSetList [ ixNet getL $handle endpointSet ]
		  set highLevelStream [ ixNet getL $handle configElement ]
Deputs "highLevelStream:$highLevelStream"
		  set endpointSet [ ixNet remapIds $endpointSet ]
Deputs "ep:$endpointSet"
Deputs Step190
	   }
		set flag_modify_adv 1
	} else {
		# if { ( [ info exists highLevelStream ] == 0 ) || ( [ llength $highLevelStream ] == 0 ) } {
			# CreateRawStream $enable_sig
		# }
	   # set hStream $highLevelStream
		set flag_modify_adv 0
    }
    #-- configure raw pdu or config advanced stream with L3+ pdu
    if { [ info exists pdu ] } {
Deputs Step100
	   # if { [ info exists src ] || [ info exists dst ] } {
		  # error "$errNumber(4) key: pdu | conflict key: src/dst"            
	   # }
	   #-- Create quick stream
Deputs "Traffic type:custom stream IPv4"
		##--add judgement for traffic reconfig
		if { ( [ info exists highLevelStream ] == 0 ) || ( [ llength $highLevelStream ] == 0 ) } {
Deputs "create raw stream..."
			CreateRawStream $enable_sig
		}
		foreach hStream $highLevelStream {
		   set flagPduObj  1
	Deputs "pdu:$pdu"
		   foreach head $pdu {
	Deputs "head:$head"
			  set head [ GetObject $head ]
	Deputs "head obj:$head"
			  if { $head != "" } {
				 #-- pdu objects
				 if { [ $head isa NetObject ] } {
					if { [ $head isa Header ] == 0 } {
						error "$errNumber(1) key: pdu value: $head (Not a Header)"                
					}
				 } else {
					error "$errNumber(1) key: pdu value: $head (Not an IxiaNet Object)"                
				 }
			  } else {
				 set flagPduObj 0
				 break
			  }
		   }
		   if { $flagPduObj } {
			  set index 0
              set pindex 0
				if { $flag_modify_adv } {
					set stackLevel [ expr [ llength [ ixNet getList $hStream stack ] ] - 1 ]
				} else {
					set stackLevel 1
				}
	Deputs "stack level:$stackLevel"			
			  foreach name $pdu {
				 set name [ GetObject $name ]
	# Read type protocol message
	Deputs Step10
				 set protocol [ $name cget -protocol ]
	Deputs "Pro: $protocol "
	Deputs Step14
				 set type [ string toupper [ $name cget -type ] ]
				 if { $type == "SET"  } {
					if { $pindex == 0 } {
		Deputs "first ethernet set..."
					 } else {
						$name ChangeType APP
                        set type [ string toupper [ $name cget -type ] ]
					 }
				 }
                 incr pindex
	Deputs "Type $type "
				 set proStack [ GetProtocolTemp $protocol ]
	Deputs "protocol stack: $proStack"
	# Set or Append pdu protocols
	Deputs Step20
				 set stack  [ lindex [ ixNet getList $hStream stack ] 0 ]
	#Deputs "type:$type"
				 set needMod 1
				 switch -exact -- $type {
					SET {
	Deputs "stream:$hStream"
						set stackList [ ixNet getList $hStream stack ]
	Deputs "Stack list:$stackList"
						while { 1 } {
						   set stackList [ ixNet getList $hStream stack ]
	Deputs "Stack list after removal:$stackList"
						   if { [ llength $stackList ] == 2 } {
							  break
						   }
						   ixNet exec remove [ lindex $stackList [ expr [ llength $stackList ] - 2  ] ]
						}
	Deputs "Stack ready to add:$stackList"
						ixNet exec append [ lindex $stackList 0 ] $proStack
						ixNet exec remove [ lindex $stackList 0 ]
						set stack  [ lindex [ ixNet getList $hStream stack ] 0 ]
					}
					APP {
	Deputs "stream:$hStream"
						set stackList [ ixNet getList $hStream stack ]
	Deputs "Stack list:$stackList"
						set appendHeader [ lindex $stackList [expr $stackLevel - 1] ]
	Deputs "appendHeader:$appendHeader"
	Deputs "stack to be added: $proStack"
						ixNet exec append $appendHeader $proStack
						set stack [lindex [ ixNet getList $hStream stack ] $stackLevel]
	Deputs "stack:$stack"
						incr stackLevel
	Deputs "stackLevel:$stackLevel"
						#set stack ${hStream}/stack:\"[ string tolower $protocol ]-${stackLevel}\"
					}
					APPLIST {
	Deputs "name:$name"
						set objList [ $name cget -objList ]
						eval set objList [ set objList ]
	Deputs "objList:$objList"                 
							set listStack [ list ]
						foreach single $objList {
					
	Deputs "stream:$hStream"
							  set stackList [ ixNet getList $hStream stack ]
	Deputs "Stack list:$stackList"
						   set appendHeader [ lindex $stackList [expr $stackLevel - 1] ]
	Deputs "appendHeader:$appendHeader"
	Deputs "stack to be added: $proStack"
						   ixNet exec append $appendHeader $proStack
						   set stack [lindex [ ixNet getList $hStream stack ] $stackLevel]
	Deputs "stack:$stack"
								lappend  listStack $stack
						   incr stackLevel
	Deputs "stackLevel:$stackLevel"
							}
					}
					MOD {
						set index 0
	Deputs "protocol:$protocol"
						foreach pro [ ixNet getList $hStream stack ] {
	Deputs "pro:$pro"
						   if { [ regexp -nocase $protocol $pro ] } {
							  if { [ regexp -nocase "${pro}\[a-z\]+" $stack ] == 0 } {
								if { $pdu_index > 1 } {
									incr pdu_index -1
									continue
								}
								break
							  }
						   }
						   incr index
						}
						set stack $pro
					}
					default { }
				 }
				 ixNet commit
				 catch {
					set stack [ ixNet remapIds $stack ]
				 }
	Deputs "Stack:$stack"
				 set appendHeader $stack
	Deputs "Stack list:[ ixNet getList $hStream stack ]"

	Deputs Step43
				 # Modify fields
				 # -- modify eth src mac
				 if { [ $name isa EtherHdr ] } {
					 if { [ $name cget -noMac ] } {
						if { $default_mac != "" } {
				 Deputs "config default mac..."
							$name config -src $default_mac
						}
					 }
				 }
				 # -- modify ip src ip
				 if { [ $name isa Ipv4Hdr ] } {
					 if { [ $name cget -noIp ] } {
						if { $default_ip != "" } {
				 Deputs "config default ip..."
							$name config -src $default_ip
						}
					 }
				 }
				 # -- modify arp src mac and src ip
				 # IxDebugOn
				 if { [ $name isa ArpHdr ] } {
			  Deputs "arp header"
					  if { [ $name cget -noMac ] } {
			  Deputs "config default mac..."
						  $name config -sender_mac_addr $default_mac 
					  }
					  if { [ $name cget -noIp ] } {
				 Deputs "config default ip..."
						 $name config -sender_ipv4_addr $default_ip
					 }
				 }
				 # IxDebugOff

				 if { $needMod == 0 } {
	Deputs Step45
					incr index
					continue
				 }

	# IxDebugOn
				 if { $type == "APPLIST" } {
	Deputs "name:$name"
					set objList [ $name cget -objList ]
					eval set objList [ set objList ]
	Deputs "objList:$objList"                 
					foreach single $objList stack $listStack {
	Deputs "single header name: $single"                
						set single [ GetObject $single ]
	Deputs "single header obj: $single"                    
						set fieldModes [ $single cget -fieldModes ]
						set fields [ $single cget -fields ]
						set fieldConfigs [ $single cget -fieldConfigs ]
						set optional [ $single cget -optionals ]
						set autos [ $single cget -autos ]
						set meshes [ $single cget -meshes ]
	# Deputs "PDU:\n\tModes:$fieldModes\n\tFields:$fields\n\tConfigs:$fieldConfigs\n\tOptional:$optional\n\tAutos:$autos"
						foreach mode $fieldModes field $fields conf $fieldConfigs\
						opt $optional auto $autos mesh $meshes {
	Deputs "mode $fieldModes field $fields conf $fieldConfigs opt $optional auto $autos"
	# Deputs "stack:$stack"
	# Deputs "field:$field"
						   set obj [ GetField $stack $field ]
	Deputs "Field object: $obj"
	# Deputs "optional $opt"
						   if { [ info exists opt ] } {
							  if { $opt == "" } { continue }
							  if { $opt } {
	Deputs Step46								
								 ixNet setA $obj -activeFieldChoice True
								 ixNet commit
								 continue
							  }
						   } else {
							  continue
						   }
						   if { [ info exists auto ] } {
	Deputs Step47
							  if { $auto == "" } { continue }
							  if { $auto } {
	Deputs Step48
								 ixNet setA $obj -auto True
								 continue
							  } else {
	Deputs Step49
	Deputs "obj:$obj"
								 ixNet setA $obj -auto False
							  }
						   } else {
							  continue
						   }
							if { [ info exists mesh ] } {
								if { $mesh == "" } { continue }
								if { $mesh } {
Deputs "Mesh the field:$obj"								
									ixNet setA $obj -fullMesh True
									ixNet commit
									continue
								} else {
									ixNet setA $obj -fullMesh False
									ixNet commit
								}
							}
						   if { [ info exists mode ] == 0 || [ info exists field ] == 0 ||\
							  [ info exists conf ] == 0 } {
	Deputs "continue"
							  continue
						   }
	Deputs "Mode:$mode"
						   switch -exact $mode {
							  Fixed {
	Deputs "Fixed:$protocol\t$field\t$conf"
								 ixNet setMultiAttrs $obj \
									-valueType singleValue \
									-singleValue $conf
							  }
							  List {
	Deputs "List:$protocol\t$field\t$conf"
								 ixNet setMultiAttrs $obj \
									-valueType valueList \
									-valueList $conf
							  }
							  Segment {
							  }
							  Reserved {
	Deputs "Reserved...continue"
								 continue
							  }
							  Incrementing -
							  Decrementing {
								 set mode [string range $mode 0 8]
								 set mode [string tolower $mode]
	Deputs "Mode:$mode\tProtocol:$protocol\tConfig:$conf"
								 set start [ eval lindex $conf 1]
								 set count [ eval lindex $conf 2]
								 set step  [ eval lindex $conf 3]
	Deputs "start:$start count:$count step:$step mode:$mode"
								 ixNet setMultiAttrs $obj \
									-valueType $mode \
									-countValue $count \
									-stepValue $step \
									-startValue $start
							  }
							  Commit {
								 ixNet setMultiAttrs $obj \
									-valueType singleValue \
									-singleValue $conf
								 ixNet commit
							  }
						   }
						}
		   
						incr index
						
					}
				 } else {
					set fieldModes [ $name cget -fieldModes ]
					set fields [ $name cget -fields ]
					set fieldConfigs [ $name cget -fieldConfigs ]
					set optional [ $name cget -optionals ]
					set autos [ $name cget -autos ]
					set meshes [ $name cget -meshes ]
	Deputs "PDU:\n\tModes:$fieldModes\n\tFields:$fields\n\tConfigs:$fieldConfigs\n\tOptional:$optional\n\tAutos:$autos\n\tMeshes:$meshes"
					foreach mode $fieldModes field $fields conf $fieldConfigs\
					opt $optional auto $autos mesh $meshes {
	Deputs "stack:$stack"
	Deputs "field:$field"
	Deputs "mesh:$mesh"
						set obj [ GetField $stack $field ]
	Deputs "Field object: $obj"
		
						if { [ info exists opt ] } {
							if { $opt == "" } { continue }
							if { $opt } {
								ixNet setA $obj -activeFieldChoice True
								ixNet commit
								continue
							}
						} else {
							continue
						}
						if { [ info exists auto ] } {
	Deputs Step47
							if { $auto == "" } { continue }
							if { $auto } {
	Deputs Step48
								ixNet setA $obj -auto True
								ixNet commit
								continue
							} else {
	Deputs Step49
	Deputs "obj:$obj"
							  ixNet setA $obj -auto False
							  ixNet commit
						   }
						} else {
						   continue
						}
						if { [ info exists mesh ] } {
							if { $mesh == "" } { continue }
							if { $mesh } {
Deputs "Mesh the field:$obj"
Deputs "fullMesh:[ixNet getA $obj -fullMesh ]"			
								ixNet setA $obj -fullMesh True
								ixNet commit
Deputs "fullMesh:[ixNet getA $obj -fullMesh ]"
							}
						}
						if { [ info exists mode ] == 0 || [ info exists field ] == 0 ||\
						   [ info exists conf ] == 0 } {
	Deputs "continue"
						   continue
						}
	Deputs "Mode:$mode"
						switch -exact $mode {
						   Fixed {
	Deputs "Fixed:$protocol\t$field\t$conf"
								ixNet setMultiAttrs $obj \
									-valueType singleValue \
									-singleValue $conf
								ixNet commit
						   }
						   List {
	Deputs "List:$protocol\t$field\t$conf [ llength $conf ]"
								if { [ llength $conf ] == 1 } {
									eval ixNet setMultiAttrs $obj \
										-valueType valueList \
										-valueList $conf
								} else {
									ixNet setMultiAttrs $obj \
										-valueType valueList \
										-valueList $conf
								}
								ixNet commit
						   }
						   Segment {
						   }
						   Reserved {
	Deputs "Reserved...continue"
							  continue
						   }
						   Incrementing -
						   Decrementing {
							  set mode [string range $mode 0 8]
							  set mode [string tolower $mode]
	Deputs "Mode:$mode\tProtocol:$protocol\tConfig:$conf"
							  set start [ eval lindex $conf 1]
							  set count [ eval lindex $conf 2]
							  set step  [ eval lindex $conf 3]
	Deputs "start:$start count:$count step:$step"
							  ixNet setMultiAttrs $obj \
								 -valueType $mode \
								 -countValue $count \
								 -stepValue $step \
								 -startValue $start
						   }
						   Commit {
							  ixNet setMultiAttrs $obj \
								 -valueType singleValue \
								 -singleValue $conf
							  ixNet commit
						   }
						}
					}
		
					incr index
				 }
	# IxDebugOff
				}
		   } else {
				set pdu [ List2Str $pdu ]
			  if { [ IsHex $pdu ] == 0 } {
				 error "$errNumber(2) key: pdu(pdu is not hex or object)"
			  } else {
				 #-- Create quick stream
	Deputs "Traffic type:custom stream IPv4 raw pdu"
			  #-- redundency
				 #CreateRawStream 
				 #-- append custom stack
				 #default stack list will be ethernet and fcs
	Deputs Step50
			foreach stream $highLevelStream {
				 set stackList [ ixNet getList $stream stack ]
	Deputs "Stack list:$stackList"
				 ixNet exec append [ lindex $stackList 0 ] [ GetProtocolTemp custom ]
				 #-- remove the ethernet header will remove fcs as well
	Deputs "remove stack..."
				 ixNet exec remove [ lindex $stackList 0 ]
					# # # #-- split the ethernet value
					# # # set mac [ string range $pdu 0 11 ]
					# # # set da "[ string range $mac 0 1 ]:[ string range $mac 2 3 ]:[ string range $mac 4 5 ]:[ string range $mac 6 7 ]:[ string range $mac 8 9 ]:[ string range $mac 10 11 ]"
					# # # set mac [ string range $pdu 12 23 ]
					# # # set sa "[ string range $mac 0 1 ]:[ string range $mac 2 3 ]:[ string range $mac 4 5 ]:[ string range $mac 6 7 ]:[ string range $mac 8 9 ]:[ string range $mac 10 11 ]"
					# # # # set sa [ string range $pdu 12 23 ]
					# # # set et [ string range $pdu 24 27 ]
					# # # set pdu [ string range $pdu 28 end ]
				 set pduLen [expr [string length $pdu] * 4]
	Deputs "pdu len:$pduLen"
					# # # #-- modify the eth stack field
					# # # set ethStack [ lindex [ ixNet getList $stream stack ] 0 ]
					# # # set fieldList [ ixNet getL $ethStack field ]
	# # # Deputs "field list:$fieldList"
	# # # Deputs "da:$da sa:$sa et:$et"
					# # # ixNet setA [lindex $fieldList 0] -singleValue 0x$da
					# # # ixNet setA [lindex $fieldList 1] -singleValue 0x$sa
					# # # ixNet setA [lindex $fieldList 2] -auto false
					# # # ixNet setA [lindex $fieldList 2] -singleValue 0x$et
					# # # ixNet commit
				 #-- modify the custom stack field
				 set customStack [ lindex [ ixNet getList $stream stack ] 0 ]
				 # set customStack [ lindex [ ixNet getList $stream stack ] 1 ]
	Deputs "custom stack:$customStack"
				 set fieldList [ ixNet getList $customStack field ]
	Deputs "pdu len:$pduLen pdu:$pdu"
				 ixNet setA [ lindex $fieldList 0 ] -singleValue $pduLen
			  ixNet commit
				if { [ regexp -nocase {^0x} $value ] } {
	Deputs Step51
					 ixNet setA [ lindex $fieldList 1 ] -singleValue $pdu
				} else {
	Deputs Step53
					 ixNet setA [ lindex $fieldList 1 ] -singleValue 0x$pdu
				}
			}
	Deputs Step60
				 ixNet commit
	Deputs Step70
			  }
		   }
		   
		}
   } else {
Deputs Step120	
		if { [ info exists src ] == 0 } {
			set src $portObj
		}
Deputs "src:$src"
	}
Deputs Step150    
    ixNet commit
	if { [ info exists rcv_ports ] } {
		set hDestPorts [ list ]
		foreach dest $rcv_ports {
			lappend hDestPorts [ $dest cget -handle ]/protocols
		}
		set ep [ ixNet getL $handle endpointSet ]
		ixNet setA $ep -destinations $hDestPorts
		ixNet commit
	}
    if { [ info exists tx_mode ] } {
	   if { $tx_mode == "burst" } {
			set tx_mode fixedFrameCount
	   }
	   if { $tx_mode == "iteration" } {
			set tx_mode fixedIterationCount
	   }
	   
	   foreach configElement $highLevelStream {
		   ixNet setA $configElement/transmissionControl -type $tx_mode
	   }
		ixNet commit
    }
    
    if { [ info exists tx_num ] } {
		foreach configElement $highLevelStream {
Deputs "tx_num config:$tx_num"
			ixNet setA $configElement/transmissionControl -frameCount $tx_num
		}
		ixNet commit
    }
    
    if { [ info exists frame_len_type ] } {
	   if { $frame_len_type == "incr" } {
		  set frame_len_type increment
	   }
		foreach configElement $highLevelStream {
			ixNet setA $configElement/frameSize -type $frame_len_type
		}
#		ixNet commit
    }
    
    if { [ info exists frame_len ] } {
		foreach configElement $highLevelStream {
			ixNet setA $configElement/frameSize -fixedSize $frame_len
		}
#		ixNet commit
    }
    
Deputs Step190
    if { [ info exists min_frame_len ] } {
		foreach configElement $highLevelStream {

			ixNet setA $configElement/frameSize -incrementFrom $min_frame_len
		}
#		ixNet commit
    }
    
    if { [ info exists max_frame_len ] } {
		foreach configElement $highLevelStream {
			ixNet setA $configElement/frameSize -incrementTo $max_frame_len
		}
# 		ixNet commit
   }
    
    if { [ info exists frame_len_step ] } {
		foreach configElement $highLevelStream {
			ixNet setA $configElement/frameSize -incrementStep $frame_len_step
		}
#		ixNet commit
    }
Deputs Step200    
    if { [ info exists enable_fcs_error_insertion ] } {
	   if { $enable_fcs_error_insertion } {
		  set crc badCrc
	   } else {
		  set crc goodCrc
	   }
		foreach configElement $highLevelStream {
			ixNet setA $configElement -crc $crc
		}
#		ixNet commit
    }
    if { [ info exists fill_type ] } {
	   switch $fill_type {
		  constant {
			 set fill_type custom
		  }
		  incr {
			 set fill_type incrementByte
		  }
		  decr {
			 set fill_type decrementByte
		  }
		  prbs {
			 set fill_type CRPAT
		  }
	   }
		foreach configElement $highLevelStream {
			ixNet setA $configElement/framePayload -type $fill_type
		}
#		ixNet commit
    }
    
    if { [ info exists payload_type ] } {
	   switch $payload_type {
		  CYCBYTE -
		  USERDEFINE {
			 set fill_type custom
		  }
		  INCRBYTE {
			 set fill_type incrementByte
		  }
		  DECRBYTE {
			 set fill_type decrementByte
		  }
		  PRBS {
			 set fill_type CRPAT
		  }
	   }
		foreach configElement $highLevelStream {
			ixNet setA $configElement/framePayload -type $fill_type
		}
	   if { $payload_type == "CYCBYTE" } {
			foreach configElement $highLevelStream {
				ixNet setA $configElement/framePayload -customRepeat true
			}
	   }
#		ixNet commit
    } 
    
    if { [ info exists payload ] } {
		foreach configElement $highLevelStream {
			ixNet setM $configElement/framePayload \
				-customRepeat true \
				-type custom \
				-customPattern $payload
		}
#		ixNet commit
    }
	  
    if { [ info exists load_unit ] } {
		foreach configElement $highLevelStream {
			switch $load_unit {
				KBPS {
					ixNet setM $configElement/frameRate \
						-bitRateUnitsType kbitsPerSec \
						-type bitsPerSecond 
				}
				MBPS {
					ixNet setM $configElement/frameRate \
						-bitRateUnitsType mbitsPerSec \
						-type bitsPerSecond 			
				}
				BPS {
					ixNet setM $configElement/frameRate \
						-bitRateUnitsType bitsPerSec \
						-type bitsPerSecond 			
				}
				FPS {
					ixNet setM $configElement/frameRate \
						-type framesPerSecond 			
				}
				PERCENT {
					ixNet setM $configElement/frameRate \
						-type percentLineRate 			
				}
			}
		}
#		ixNet commit

    }
Deputs Step230
    if { [ info exists inter_frame_gap ] } {
		foreach configElement $highLevelStream {
			ixNet setA $configElement/transmissionControl -minGapBytes $inter_frame_gap       
		}
    } else {
Deputs Step240	    
		set  inter_frame_gap [ $portObj cget -inter_burst_gap ]
		if { [ string is integer $inter_frame_gap ] } {
	Deputs Step250	
			foreach configElement $highLevelStream {

				ixNet setA $configElement/transmissionControl -minGapBytes $inter_frame_gap       
			}
					
		}
    }
    
    if {[info exists burst_gap ]} {
        ixNet setA $configElement/transmissionControl  \
          -frameCount $burst_packet_count \
			-interBurstGap $burst_gap \
			-interBurstGapUnits $burst_gap_units \
			-enableInterBurstGap $enable_burst_gap
        
    }
    
    if { [ info exists stream_load ] } {
		foreach configElement $highLevelStream {
			ixNet setM $configElement/frameRate \
				-rate $stream_load
		}
#		ixNet commit
    }
    if { [ info exists latency_type ] } {
	    switch $latency_type {
		    lifo {
			    set latency_type storeForward
		    }
			lilo {
				set latency_type forwardingDelay
			}
			filo {
				set latency_type mef
			}
			fifo {
				set latency_type cutThrough
			}
	    }
	    set root [ixNet getRoot]
	    ixNet setA $root/traffic/statistics/latency -mode $latency_type
    }
    
    if { [ info exists precedence_tracking ] 
		&& $precedence_tracking } {
Deputs "set precedence..."
		set trackBy [ ixNet getA $handle/tracking -trackBy ]
		lappend trackBy ipv4Precedence0
		ixNet setA $handle/tracking -trackBy $trackBy
		ixNet setA $configElement/transmissionDistribution \
			-distributions ipv4Precedence0
	}
	ixNet commit
Deputs Step250	
	ixNet setA $handle -enabled True
	ixNet commit

	set trafficItemType [ ixNet getA $handle -trafficType ]
	if { $trafficItemType == "raw" } {
		#-- check mac
		set endpointSetList [ixNet getL $handle endpointSet]
Deputs "ep set:$endpointSetList"		
		foreach ele 	[ ixNet getList $handle configElement ]  {

			set epId [ ixNet getA $ele -endpointSetId ]
Deputs "epId:$epId"			
			set endpointSet [ lindex $endpointSetList [expr $epId -1] ]
	Deputs "endpoint:$endpointSet"
			set eth [ lindex [ ixNet getL $ele stack ] 0  ]
	Deputs "ele:$ele"	
			if { $endpointSet == "" } {
				continue
			}
			set sources [ixNet getA $endpointSet -sources]
			set srcMac ""
			set dstMac ""
	Deputs "sources:$sources"
			foreach  srcPort $sources  {
	Deputs "srcPort:$srcPort"
				set hPort [ ixNet getP $srcPort ]
				set int [ lindex [ ixNet getL $hPort interface ] 0 ]
	Deputs "int:$int"
				if { $int == "" } {
					continue
				}
				if { [ ixNet exists $int/ipv4 ] == "false" } {
					continue
				}
				lappend srcMac [ ixNet getA $int/ethernet -macAddress ]
	Deputs "mac:$srcMac"		
				if { [ ixNet getF $ele stack -templateName ipv6-template.xml ] == "" } {
	Deputs "Step300"
					set gw [ ixNet getA $int/ipv4 -gateway ]
				} else {
	Deputs "Step310"
					set ipv6Int [ lindex [ixNet getL $int ipv6] 0 ]
					if { [ llength $ipv6Int ] } {
						set gw [ ixNet getA $ipv6Int -gateway ]
					} else {
						set gw ""
					}
				}
	Deputs "gw:$gw"
				set neighbor [ixNet getF $hPort discoveredNeighbor -neighborIp $gw]
				if { [ llength $neighbor ] } {
					lappend dstMac [ ixNet getA $neighbor -neighborMac ]
				} else {
					lappend dstMac "00:00:00:00:00:02"
				}
	Deputs "dstMac:$dstMac "
			}
	Deputs "eth:$eth"		
			set dst [ixNet getF $eth field -name destinationAddress]
			set src [ixNet getF $eth field -name sourceAddress]
			if { $src == "" || $dst == "" } {
				continue
			}
	Deputs "srcMac: [ixNet getA $src -singleValue]"
	Deputs "dstMac: [ixNet getA $dst -singleValue]"
	Deputs "srcMac: [ixNet getA $src -startValue]"
	Deputs "dstMac: [ixNet getA $dst -startValue]"
			set regenerate 0
			if { [ixNet getA $dst -singleValue] == "00:00:00:00:00:00" && [ixNet getA $dst -startValue] == "00:00:00:00:00:00" } {
Deputs "Step260"		
				if { [ llength $dstMac ] > 0 } {
					ixNet setM $dst -valueType valueList -valueList $dstMac
				} else {
					ixNet setM $dst -valueType valueList -valueList "00:00:00:00:00:02"
				}
				
				set regenerate 1
			}
			if { [ixNet getA $src -singleValue] == "00:00:00:00:00:00" && [ixNet getA $src -startValue] == "00:00:00:00:00:00" } {
Deputs "Step270"		
				if { [ llength $srcMac ] > 0 } {
					ixNet setM $src -valueType valueList -valueList $srcMac
				} else {
					ixNet setM $src -valueType valueList -valueList "00:00:00:00:00:01"
				}
				set regenerate 1
			}
			
			if { $regenerate } {
Deputs "Step280"			
				ixNet exec generate $handle
				ixNet commit
			}
		}
		
	}
Deputs "Step290"	
	if { $to_raw } {
Deputs "Step320"	
Deputs "handle:$handle"
		ixNet exec convertToRaw $handle
		set oldHandle $handle
		set handle [ lindex [ ixNet getL $root/traffic trafficItem ] end ]
		ixNet remove $oldHandle
		ixNet setA $handle -name $this
		ixNet commit
		
		set endpointSetList [ ixNet getL $handle endpointSet ]
		set highLevelStream [ ixNet getL $handle configElement ]
Deputs "ep:$endpointSetList"
Deputs "stream:$highLevelStream"
	}
	
    return [GetStandardReturnHeader]

}
body Traffic::enable {} {
    set tag "body Traffic::enable [info script]"
Deputs "----- TAG: $tag -----"

	if { [ string tolower [ ixNet getA $handle -enabled ] ] == "true" && [ string tolower [ ixNet getA $handle -suspend ] ] == "false" } {
Deputs "no change."	
		return [ GetStandardReturnHeader ]
	}
Deputs "enable:[ ixNet getA $handle -enabled ] suspend:[ ixNet getA $handle -suspend ]"
	#ixNet setA $handle -enabled True 
	ixNet setA $handle -suspend False
    ixNet commit
	ixNet setA $handle -suspend False
    ixNet commit
		
    return [ GetStandardReturnHeader ]
}
body Traffic::disable {} {
    set tag "body Traffic::disable [info script]"
Deputs "----- TAG: $tag -----"
	#ixNet setA $handle -enabled false
	ixNet setA $handle -suspend True
    ixNet commit
	ixNet setA $handle -suspend True
    ixNet commit
	
    return [ GetStandardReturnHeader ]

}

body Traffic::traffic_enable {} {
    set tag "body Traffic::traffic_enable [info script]"
Deputs "----- TAG: $tag -----"

	if { [ string tolower [ ixNet getA $handle -enabled ] ] == "true" && [ string tolower [ ixNet getA $handle -suspend ] ] == "false" } {
Deputs "no change."	
		return [ GetStandardReturnHeader ]
	}
Deputs "enable:[ ixNet getA $handle -enabled ] suspend:[ ixNet getA $handle -suspend ]"
	ixNet setA $handle -enabled True 
	ixNet setA $handle -suspend False
    ixNet commit
	ixNet setA $handle -suspend False
    ixNet commit
		
    return [ GetStandardReturnHeader ]
}
body Traffic::traffic_disable {} {
    set tag "body Traffic::traffic_disable [info script]"
Deputs "----- TAG: $tag -----"
	ixNet setA $handle -enabled false
	
    ixNet commit
	
    return [ GetStandardReturnHeader ]

}

body Traffic::get_status {} {
    set tag "body Traffic::get_status [info script]"
Deputs "----- TAG: $tag -----"

	set ret [ixNet getA $handle -enabled ]	
    return $ret

}

body Traffic::GetProtocolTemp { pro } {
    set tag "body Traffic::GetProtocolTemp [info script]"
Deputs "----- TAG: $tag -----"
Deputs "Get protocol..."
Deputs "protocol to match:$pro"
    set root [ixNet getRoot]
    set protocolTemplateList [ ixNet getList $root/traffic protocolTemplate ]
    set index 0
    foreach protocol $protocolTemplateList {
	   if { [ regexp -nocase $pro $protocol ] } {
		  if { [ regexp -nocase "${pro}\[a-z\]+" $protocol ] == 0 } {
			 break
		  }
	   }
	   incr index
    }
    if { $index < [llength $protocolTemplateList] } {
	   return [ lindex $protocolTemplateList $index ]
    } else {
	   return ""
    }
}

body Traffic::CreateQuickStream {} {
    set tag "body Traffic::CreateQuickStream [info script]"
Deputs "----- TAG: $tag -----"
    #-- create trafficItem
Deputs Step10
    set quickItem   [ GetQuickItem ]
    if { $quickItem == "" } {
	   ixNet setMultiA $handle -trafficItemType quick -trafficType raw
    } else {
	   set handle $quickItem 
    }
    #-- add endpointSet
Deputs "handle $handle"
    set endpointSet [ixNet add $handle endpointSet]
Deputs "port:$hPort"
    ixNet setMultiA $endpointSet -sources "$hPort/protocols"
Deputs Step40
    ixNet commit
Deputs Step50
    set handle      [ ixNet remapIds $handle ]
Deputs Step60
    set endpointSet [ ixNet remapIds $endpointSet ]
Deputs Step70
    #-- for every stream is not bi-direction, thus only one highlevelstream will be created when creating endpointSet
    set highLevelStream [ lindex [ ixNet getList $handle highLevelStream ] end ]
Deputs StepDone
}
body Traffic::CreateRawStream { { enable_sig 1 } } {
    set tag "body Traffic::CreateRawStream [info script]"
Deputs "----- TAG: $tag -----"
    #-- create trafficItem
Deputs Step10
    ixNet setMultiA $handle -trafficItemType l2L3 -trafficType raw
    #-- add endpointSet
# IxDebugOn	
Deputs "handle $handle"
    set endpointSet [ixNet add $handle endpointSet]
Deputs "port:$hPort"
    set dests [list]
    set root [ixNet getRoot]
    foreach port [ ixNet getList $root vport ] {
Deputs "dest port:$port"
		if { $port == $hPort } {
			continue
		}
Deputs "lappend dests..."
	   lappend dests "$port/protocols"
    }
Deputs "dests: $dests"
# IxDebugOff
	if { [ llength $dests ] == 0 } {
		ixNet setMultiA $endpointSet -sources "$hPort/protocols" -destinations "$hPort/protocols"
	} else {
		ixNet setMultiA $endpointSet -sources "$hPort/protocols" -destinations $dests
	}
Deputs Step40
    ixNet commit
Deputs Step50
    set handle      [ ixNet remapIds $handle ]
Deputs Step60
    set endpointSet [ ixNet remapIds $endpointSet ]
Deputs Step70
    #-- for every stream is not bi-direction, thus only one highlevelstream will be created when creating endpointSet
    set highLevelStream [ ixNet getList $handle configElement ]
Deputs "stream handle:$highLevelStream"
Deputs StepDone

	if { $enable_sig } {
		ixNet setA $handle/tracking -trackBy sourceDestPortPair0
		ixNet commit
	}

}
body Traffic::GetField { stack value } {
    set tag "body Traffic::GetField [info script]"
Deputs "----- TAG: $tag -----"
Deputs "value:$value"
    set fieldList [ixNet getList $stack field]
# Deputs "fieldList:$fieldList"
    set index 0
    foreach field $fieldList {
# Deputs "field:$field"
	   if { [ regexp -nocase "${value}-" $field ] } {
		  if { [ regexp -nocase "${value}\[a-z\]+" $field ] == 0 } {
				break
		  }
	   }
	   incr index
    }
    if { $index < [llength $fieldList] } {
	   return [ lindex $fieldList $index ]
    } else {
	   return [ ixNet getF $stack field -name $value ]
    }
}

body Traffic::GetQuickItem {} {
    set root [ixNet getRoot]
    set itemList [ixNet getList $root/traffic trafficItem]
    foreach item $itemList {
	   set trafficItemType [ ixNet getA $item -trafficItemType ]
	   if { $trafficItemType == "quick" } {
		  return $item
	   }
    }
    return ""
}
body Traffic::get_stats { args } {

	set tracking none
	
# param collection --
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		    -rx_port {
			 set rx_port $value
		    }
		    -tracking {
				set tracking $value
		    }
	    }
    }
    

	set root [ixNet getRoot]
	
	if { $tracking != "none" } {
		set view {::ixNet::OBJ-/statistics/view:"Flow Statistics"}
	} else {
		if { [ info exists rx_port ] == 0 || [ string length $rx_port ] == 0 } {
			set view {::ixNet::OBJ-/statistics/view:"Traffic Item Statistics"}
		} else {
		
			if { [ $rx_port isa Port ] == 0 } {
			   error "$errNumber(1) key:port object value:$rx_port"
			}

			set view  [ ixNet getF $root/statistics view -caption "trafficPerPortView($this:$rx_port)" ]
			if { $view == "" } {
				if { [ catch {
	Deputs "recreate view..."
					set view [ CreatePerPortView $rx_port ]
				} err ] } {
	Deputs "create stats err:$err"
					return [ GetErrorReturnHeader "Cannot fetch traffic stats, please make sure the stream was created correctly." ]
				}
			}
		}
	}
	
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
    set traNameIndex            [ lsearch -exact $captionList {Traffic Item} ]
    set txFramesIndex           [ lsearch -exact $captionList {Tx Frames} ]
    set rxFramesIndex           [ lsearch -exact $captionList {Rx Frames} ]
    set aveLatencyIndex         [ lsearch -exact $captionList {Store-Forward Avg Latency (ns)} ]
    set minLatencyIndex         [ lsearch -exact $captionList {Store-Forward Min Latency (ns)} ]
    set maxLatencyIndex         [ lsearch -exact $captionList {Store-Forward Max Latency (ns)} ]
    set firstArrivalIndex       [ lsearch -exact $captionList {First TimeStamp} ]
    set lastArrivalIndex        [ lsearch -exact $captionList {Last TimeStamp} ]
    set txFrameRateIndex        [ lsearch -exact $captionList {Tx Frame Rate} ]
    set rxFrameRateIndex        [ lsearch -exact $captionList {Rx Frame Rate} ]
    set txByteRateIndex         [ lsearch -exact $captionList {Tx Rate (Bps)} ]
    set rxByteRateIndex         [ lsearch -exact $captionList {Rx Rate (Bps)} ]
    set txBitRateIndex          [ lsearch -exact $captionList {Tx Rate (bps)} ]
    set rxBitRateIndex          [ lsearch -exact $captionList {Rx Rate (bps)} ]

	set tx_l1_bit_rate			[ lsearch -exact $captionList {Tx L1 Rate (bps)} ]
	set rx_l1_bit_rate			[ lsearch -exact $captionList {Rx L1 Rate (bps)} ]

	if { $tracking == "precedence" } {
		set ipv4PrecedenceIndex [ lsearch -exact $captionList {IPv4 :Precedence} ]
	}
    set ret [ GetStandardReturnHeader ]
	
    set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"

    foreach row $stats {
	   
	   eval {set row} $row
Deputs "row:$row"

		if { [ info exists rx_port ] == 0 } {
			if { [ lindex $row $traNameIndex ] != $this } {
				continue
			}
		}
		
		if { $tracking == "precedence" } {
		   set statsItem   "precedence"
		   set statsVal    [ lindex $row $ipv4PrecedenceIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
		}

	   set statsItem   "tx_frame_count"
	   set statsVal    [ lindex $row $txFramesIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "rx_frame_count"
	   set statsVal    [ lindex $row $rxFramesIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		    
	   set statsItem   "avg_jitter"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
	   set statsItem   "avg_latency"
	   set statsVal    [ lindex $row $aveLatencyIndex ]
		#-- adjust to us
		if { $statsVal == "" } {
			set statsVal	"NA"
		} else {
			set statsVal 	[ expr $statsVal / 1000 ] 
		}
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "duplicate_frame_count"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "in_order_frame_count"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "max_jitter"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "max_latency"
	   set statsVal    [ lindex $row $maxLatencyIndex ]
		#-- adjust to us
		if { $statsVal == "" } {
			set statsVal	"NA"
		} else {
			set statsVal 	[ expr $statsVal / 1000 ] 
		}
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "min_jitter"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "min_latency"
	   set statsVal    [ lindex $row $minLatencyIndex ]
		#-- adjust to us
		if { $statsVal == "" } {
			set statsVal	"NA"
		} else {
			set statsVal 	[ expr $statsVal / 1000 ] 
		}
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "out_seq_frame_count"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "first_arrival_time"
	   set statsVal    [ lindex $row $firstArrivalIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "last_arrival_time"
	   set statsVal    [ lindex $row $lastArrivalIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_frame_rate"
	   set statsVal    [ lindex $row $txFrameRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_frame_rate"
	   set statsVal    [ lindex $row $rxFrameRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_byte_rate"
	   set statsVal    [ lindex $row $txByteRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_byte_rate"
	   set statsVal    [ lindex $row $rxByteRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_bit_rate"
	   set statsVal    [ lindex $row $txBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_bit_rate"
	   set statsVal    [ lindex $row $rxBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	   set statsItem   "tx_l2_bit_rate"
	   set statsVal    [ lindex $row $txBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_l2_bit_rate"
	   set statsVal    [ lindex $row $rxBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	   set statsItem   "tx_l1_bit_rate"
	   set statsVal    [ lindex $row $tx_l1_bit_rate ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_l1_bit_rate"
	   set statsVal    [ lindex $row $rx_l1_bit_rate ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

Deputs "ret:$ret"

    }
	
	ixNet remove $view
	ixNet commit
	   
    return $ret
    
}
body Traffic::get_stats_per_port { args } {
    set tag "body Traffic::get_stats_per_port [info script]"
Deputs "----- TAG: $tag -----"

# param collection --
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -rx_port {
			 set rx_port $value
		  }
	   }
    }
    
    if { [ info exists rx_port ] == 0 } {
	   set rx_port $portObj
    }
    
    if { [ $rx_port isa Port ] == 0 } {
	   error "$errNumber(1) key:port object value:$rx_port"
    }

    set root [ixNet getRoot]
    set view  [ ixNet getF $root/statistics view -caption "trafficPerPortView($this:$rx_port)" ]
    if { $view == "" } {
		if { [ catch {
#IxDebugOn
			set view [ CreatePerPortView $rx_port ]
		} err ] } {
Deputs "create stats err:$err"
			return [ GetErrorReturnHeader "Cannot fetch traffic stats, please make sure the stream was created correctly." ]
		}
    }
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
    set txFramesIndex           [ lsearch -exact $captionList {Tx Frames} ]
    set rxFramesIndex           [ lsearch -exact $captionList {Rx Frames} ]
    set aveLatencyIndex         [ lsearch -exact $captionList {Store-Forward Avg Latency (ns)} ]
    set minLatencyIndex         [ lsearch -exact $captionList {Store-Forward Min Latency (ns)} ]
    set maxLatencyIndex         [ lsearch -exact $captionList {Store-Forward Max Latency (ns)} ]
    set firstArrivalIndex       [ lsearch -exact $captionList {First TimeStamp} ]
    set lastArrivalIndex        [ lsearch -exact $captionList {Last TimeStamp} ]
    set txFrameRateIndex        [ lsearch -exact $captionList {Tx Frame Rate} ]
    set rxFrameRateIndex        [ lsearch -exact $captionList {Rx Frame Rate} ]
    set txByteRateIndex         [ lsearch -exact $captionList {Tx Rate (Bps)} ]
    set rxByteRateIndex         [ lsearch -exact $captionList {Rx Rate (Bps)} ]
    set txBitRateIndex          [ lsearch -exact $captionList {Tx Rate (bps)} ]
    set rxBitRateIndex          [ lsearch -exact $captionList {Rx Rate (bps)} ]

	set tx_l1_bit_rate			[ lsearch -exact $captionList {Tx L1 Rate (bps)} ]
	set rx_l1_bit_rate			[ lsearch -exact $captionList {Rx L1 Rate (bps)} ]

    set ret [ GetStandardReturnHeader ]
	
    set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"

    foreach row $stats {
	   
	   eval {set row} $row
Deputs "row:$row"

	   set statsItem   "tx_frame_count"
	   set statsVal    [ lindex $row $txFramesIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "rx_frame_count"
	   set statsVal    [ lindex $row $rxFramesIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		    
	   set statsItem   "avg_jitter"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
	   set statsItem   "avg_latency"
	   set statsVal    [ lindex $row $aveLatencyIndex ]
		#-- adjust to us
		if { $statsVal == "" } {
			set statsVal	"NA"
		} else {
			set statsVal 	[ expr $statsVal / 1000 ] 
		}
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "duplicate_frame_count"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "in_order_frame_count"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "max_jitter"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "max_latency"
	   set statsVal    [ lindex $row $maxLatencyIndex ]
		#-- adjust to us
		if { $statsVal == "" } {
			set statsVal	"NA"
		} else {
			set statsVal 	[ expr $statsVal / 1000 ] 
		}
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "min_jitter"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		
	   set statsItem   "min_latency"
	   set statsVal    [ lindex $row $minLatencyIndex ]
		#-- adjust to us
		if { $statsVal == "" } {
			set statsVal	"NA"
		} else {
			set statsVal 	[ expr $statsVal / 1000 ] 
		}
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "out_seq_frame_count"
	   set statsVal    "NA"
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "first_arrival_time"
	   set statsVal    [ lindex $row $firstArrivalIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "last_arrival_time"
	   set statsVal    [ lindex $row $lastArrivalIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_frame_rate"
	   set statsVal    [ lindex $row $txFrameRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_frame_rate"
	   set statsVal    [ lindex $row $rxFrameRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_byte_rate"
	   set statsVal    [ lindex $row $txByteRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_byte_rate"
	   set statsVal    [ lindex $row $rxByteRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_bit_rate"
	   set statsVal    [ lindex $row $txBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_bit_rate"
	   set statsVal    [ lindex $row $rxBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	   set statsItem   "tx_l2_bit_rate"
	   set statsVal    [ lindex $row $txBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_l2_bit_rate"
	   set statsVal    [ lindex $row $rxBitRateIndex ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	   set statsItem   "tx_l1_bit_rate"
	   set statsVal    [ lindex $row $tx_l1_bit_rate ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_l1_bit_rate"
	   set statsVal    [ lindex $row $rx_l1_bit_rate ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

Deputs "ret:$ret"

    }
	
	ixNet remove $view
	ixNet commit
	   
    return $ret
    
}
body Traffic::CreatePerPortView { rxPort } {
    set tag "body Traffic::CreatePerPortView [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
    set customView          [ ixNet add $root/statistics view ]
    ixNet setM  $customView -caption "trafficPerPortView($this:$rxPort)" -type layer23TrafficFlow  -visible true
    ixNet commit
    set customView          [ ixNet remapIds $customView ]
Deputs "view:$customView"
    
Deputs "available item: [ixNet getL $customView availableTrafficItemFilter]"
Deputs "available port: [ixNet getL $customView availablePortFilter]"
 
Deputs "handle:$handle obj:$this" 
	set itemFId	[ixNet getF $customView availableTrafficItemFilter -name $this]
Deputs "item filtered Id:$itemFId"
    ixNet setA $customView/layer23TrafficItemFilter -trafficItemFilterIds $itemFId
    
    set connectionInfo [ ixNet getA [$rxPort cget -handle] -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"
Deputs "filter name: ${chassis}/Card${card}/Port${port}"
	set filteredId	[ixNet getF $customView availablePortFilter -name "${chassis}/Card${card}/Port${port}" ]
Deputs "filteredId:$filteredId"
    ixNet setA $customView/layer23TrafficPortFilter -portFilterIds [ list $filteredId ]
    
    ixNet commit
Deputs "stats :[ ixNet getL $customView statistic ]"
    foreach s [ixNet getL $customView statistic] {
	   ixNet setA $s -enabled true
    }
Deputs "stats view enabled..."
    ixNet setA $customView -enabled true
Deputs "custom view enabled"
    ixNet commit
    
    return $customView
}
body Traffic::CreatePerPrecedenceView { } {
    set tag "body Traffic::CreatePerPrecedenceView [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
    set customView          [ ixNet add $root/statistics view ]
    ixNet setM  $customView -caption "trafficPerPrecedenceView($this)" -type layer23TrafficFlow  -visible true
    ixNet commit
    set customView          [ ixNet remapIds $customView ]
Deputs "view:$customView"
    
Deputs "available filter: [ixNet getL $customView availableTrackingFilter]"
 
Deputs "handle:$handle obj:$this" 
	set itemFId	[ixNet getF $customView availableTrafficItemFilter -name $this]
Deputs "item filtered Id:$itemFId"
    ixNet setA $customView/layer23TrafficItemFilter -trafficItemFilterIds $itemFId
Deputs "handle:$handle obj:$this" 
	set itemFId	[ixNet getF $customView availableTrackingFilter -name "IPv4 :Precedence"]
Deputs "item filtered Id:$itemFId"
	set filter0 [ ixNet add $customView/layer23TrafficFlowFilter trackingFilter ]
    ixNet setM $filter \
		-trackingFilterId $itemFId \
		-value [ list 0 1 2 3 4 5 6 7 ] \
    ixNet commit
Deputs "filter:[ixNet getL $customView/layer23TrafficFlowFilter trackingFilter]"	
Deputs "stats :[ ixNet getL $customView statistic ]"
    foreach s [ixNet getL $customView statistic] {
	   ixNet setA $s -enabled true
    }
Deputs "stats view enabled..."
    ixNet setA $customView -enabled true
Deputs "custom view enabled"
    ixNet commit
    
    return $customView
}

# -- Header implmentation
body EtherHdr::config { args } {

    global errorInfo
    global errNumber


    set tag "body EtherHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    
    set EType [ list Fixed Random Incrementing Decrementing ]
    set EEthType [ list ipv4 ipv6 arp mplsunicast mplsmulticast rarp ]
    set EEthTypeVal [ list 0x0800 0x86dd 0x0806 0x8847 0x8848 0x8035 ]
    set offset 0 ;#obsolete
	set daReCnt Incrementing
	set saReCnt Incrementing
	#set ether_type 0x88B5
    #set EtherTypeMode Fixed
	set daoffset 48
	set saoffset 48
# param collection        
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -dst {
			 set value [ MacTrans $value ]
			 if { [ IsMacAddress $value ] } {
				set da $value
			 } else {
Deputs "wrong mac addr: $value"
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set daNum $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 48 && $trans >= 1 } {
				set daoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -dst_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set daStep $trans
				#set daStep [ GetMacStep $daoffset $daStep ]
Deputs "daStep:$daStep"
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src {
			 set value [ MacTrans $value ]
			 if { [ IsMacAddress $value ] } {
				set sa $value
					set noMac 0
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set saNum $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 48 && $trans >= 1 } {
				set saoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -src_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set saStep $trans
				#set saStep [ GetMacStep $saoffset $saStep ]
Deputs "saStep:$saStep"
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -type {
Deputs "type: $value"
			 if { [ string tolower $value ] == "auto" } {
Deputs Step1
				set ether_type "auto"
			 } else {
Deputs Step2
				if { [ catch { 
				      #set ether_type [ format %x $value ] 
					  set ether_type  $value 
					} ] } {
Deputs Step3
				    error "$errNumber(1) key:$key value:$value"
				}
			 }
		  }
			-src_range_mode {
				set src_range_mode [ string tolower $value ]
				switch $src_range_mode {
					incr {
						set saReCnt Incrementing
					}
					decr {
						set saReCnt Decrementing
					}
					random {
						set saReCnt Random
					}
				}
			}
			-dst_range_mode {
				set dst_range_mode [ string tolower $value ]
				switch $dst_range_mode {
					incr {
						set daReCnt Incrementing
					}
					decr {
						set daReCnt Decrementing
					}
					random {
						set daReCnt Random
					}
				}
			}
		}
    }

Deputs Step10
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "ethernet" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol Ethernet
Deputs Step40
    if { [ info exists da ] } {
Deputs Step50
	   if { [ info exists daReCnt ] } {
Deputs Step60
		  switch -exact $daReCnt {
			 Fixed {
Deputs Step70
				AddFieldMode $daReCnt
				AddField destinationAddress
				AddFieldConfig $da
Deputs "Mode:$daReCnt\tValue:$da"
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists daNum ] && [ info exists daStep ] } {
Deputs Step90
				    set daoffset [ expr 48 - $daoffset ]
				    set step [ GetMacStep $daoffset $daStep ]
Deputs "step:$step"
				    AddFieldMode $daReCnt
				    AddField destinationAddress
				    AddFieldConfig \
				    [ list $daoffset $da $daNum $step ]
				    
				} else {
				    error "$errNumber(2) key:dst_num/dst_step"
				}
			 }
		  }
	   }
    }
    if { [ info exists sa ] } {
Deputs Step100
	   if { [ info exists saReCnt ] } {
Deputs Step110
		  switch -exact $saReCnt {
			 Fixed {
				AddFieldMode $saReCnt
				AddField sourceAddress
				AddFieldConfig $sa
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists saNum ] && [ info exists saStep ] } {
				    set saoffset [ expr 48 - $saoffset ]
				    set step [ GetMacStep $saoffset $saStep ]
Deputs "step:$step"
				    AddFieldMode $saReCnt
				    AddField sourceAddress
				    AddFieldConfig [ list $saoffset $sa $saNum $step ]
				} else {
				    error "$errNumber(2) key:src_num/src_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists ether_type ] } {
Deputs Step200
	   if { $ether_type == "auto" } {
		  AddField etherType 0 1
		  AddFieldMode Reserved
		  AddFieldConfig 0
	   } else {
		  if { [ info exists EtherTypeMode ] } {
Deputs Step210
			 switch -exact $EtherTypeMode {
				Fixed {
				    AddFieldMode $EtherTypeMode
				    AddField etherType
				    AddFieldConfig $ether_type
				}
				Decrementing -
				Incrementing {
				    if { [ info exists EtherTypeCount ] && [ info exists EtherTypeStep ] } {
					   AddFieldMode $EtherTypeMode
					   AddField etherType
					   AddFieldConfig [ list 0 $ether_type $EtherTypeCount $EtherTypeStep ]
					   
				    } else {
					   error "$errNumber(2) key:src_num/src_step"
				    }
				}
			 }
		  } else {
			 AddFieldMode Fixed
			 AddField etherType
			 AddFieldConfig $ether_type
		  }
	   }
    }

	eval chain $args
Deputs "type:$type"
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body SingleVlanHdr::config { args } {
    
    global errorInfo
    global errNumber


    set tag "body SingleVlanHdr::config [info script]"
Deputs "----- TAG: $tag -----"

    set EType [ list Fixed Incrementing Decrementing ]
    set EVlanType [ list 0x8100 0x9100 0x88a8 0x9200 ]
    set offset 0
    set vlanMode Incrementing
    set vlanStep 1

    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -id1 -
		  -id {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set vlanId $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -id1_num -
		  -id_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set vlanRepeat $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                   
		  }
		  -id1_step -
		  -id_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set vlanStep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                   
			 
		  }
		  -pri1 -
		  -pri {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans < 8 } {
				set userPrior $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -pri1_num -
		  -pri_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				 set userPriorNum $trans
			 } else {
				 error "$errNumber(1) key:$key value:$value"
			 }		    
		  }
		  -cfi1 -
		  -cfi {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans < 2 } {
				set cfi $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -type1 -
		  -type {
				if { [ string tolower $value ]  == "auto" } {
				} else {
					if { [ catch { set protocolType [ format %x $value ] } ] } {
						error "$errNumber(1) key:$key value:$value"
					}
				}
		  }
	   }
    }

    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "vlan" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol Vlan

    #-----Config Vlan ID ------
    if { [ info exists vlanId ] } {
	   if { [ info exists vlanMode ] } {
Deputs Step10
		  switch -exact $vlanMode {
			 Fix -
			 Fixed {
				AddField vlanID
				AddFieldMode $vlanMode
				AddFieldConfig $vlanId
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists vlanRepeat ] && [ info exists vlanStep ] } {
				    AddField vlanID
				    AddFieldMode $vlanMode
				    AddFieldConfig \
				    [ list $offset $vlanId $vlanRepeat $vlanStep ]
				}
			 }
		  }
	   }
    }
    #--------------------------
    #-----Config Vlan User Priority-----
    if { [ info exists userPrior ] } {
	   AddField vlanUserPriority
	   AddFieldMode Incrementing
	   AddFieldConfig [ list 0 $userPrior $userPriorNum 1 ]
    }
    #--------------------------
    #-----Config Protocol ID-----
    if { [ info exists protocolType ] } {
	   AddField protocolID
	   AddFieldMode Fixed
	   AddFieldConfig $protocolType
    }
    #--------------------------
    #-----Config Vlan CFI-----
    if { [ info exists cfi ] } {
	   AddField cfi
	   AddFieldMode Fixed
	   AddFieldConfig $cfi
    }
    #--------------------------
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body VlanHdr::config { args } {
    
    global errorInfo
    global errNumber


    set tag "body VlanHdr::config [info script]"
Deputs "----- TAG: $tag -----"


    set id1         100
    set id1_num     1
    set id1_step    1
    set pri1        0
    set pri1_num    1		
    set cfi1	    0
    set type1       auto

    set id2         100
    set id2_num     1
    set id2_step    1
    set pri2        0
    set pri2_num    1
    set cfi2        0
    set type2       auto

    set flagId2     0
    set objList     [list]
    
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -id1 {
			 set id1 $value
		  }
		  -id1_num {
			 set id1_num $value
		  }
		  -id1_step {
			 set id1_step $value
		  }
		  -pri1 {
			 set pri1 $value
		  }
		  -pri1_num {
			  set pri1_num $value
		  }
		  -cfi1 {
			 set cfi1 $value
		  }
		  -type1 {
			 set type1 $value
		  }
		  -id2 {
			 set id2 $value
			 set flagId2     1
		  }
		  -id2_num {
			 set id2_num $value
			 set flagId2     1
		  }
		  -id2_step {
			 set id2_step $value
			 set flagId2     1
		  }
		  -pri2 {
			 set pri2 $value
			 set flagId2     1
		  }
	    -pri2_num {
		    set pri2_num $value
		    set flagId2 	1
	    }
		  -cfi2 {
			 set cfi2 $value
			 set flagId2     1
		  }
		  -type2 {
			 set type2 $value
			 set flagId2     1
		  }
	   }
    }

    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "vlan" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol Vlan

    
    set vlanObjId1       [clock click]
    if { $id1_num > 0 } {
    
	    SingleVlanHdr vlan$vlanObjId1
	    vlan$vlanObjId1 config -id1 $id1 -id1_num $id1_num -id1_step $id1_step \
		    -pri1 $pri1 -pri1_num $pri1_num -cfi1 $cfi1 -type1 $type1
    }
    
    if { $id2_num < 1 } {
	    set flagId2 0
    }

    if { $flagId2 } {
	    after 10
	   set vlanObjId2      [clock click]
	   SingleVlanHdr vlan$vlanObjId2
	   vlan$vlanObjId2 config -id1 $id2 -id1_num $id2_num -id1_step $id2_step \
		  -pri1 $pri2 -pri1_num $pri2_num -cfi1 $cfi2 -type1 $type2

	   lappend objList [ list vlan$vlanObjId1 vlan$vlanObjId2 ]
	   
	   if { [ vlan$vlanObjId1 IsValid ] && [ vlan$vlanObjId2 IsValid ] } {
		  return [GetStandardReturnHeader]
	   } else {
		  return [ GetErrorReturnHeader "PDU is invalid" ]
	   }
	   
    } else {
	   lappend objList [ list vlan$vlanObjId1 ]
	   if { [ vlan$vlanObjId1 IsValid ] } {
		  return [GetStandardReturnHeader]
	   } else {
		  return [ GetErrorReturnHeader "PDU is invalid" ]
	   }
	   
    }
Deputs "object list:$objList"
    

}
body Ipv4Hdr::config { args } {
# Deputs "ipv4 config"
    global errorInfo
    global errNumber

    set tag "body Ipv4Hdr::config [info script]"
Deputs "----- TAG: $tag -----"
    set EType [ list Fixed Random Incrementing Decrementing List ]
    set EPrecedence [ list routine priority immediate flash \
				 "flash_override" "critical" "internetwork_control"\
				 "network_control" ]
    set EDelay [ list normaldelay lowdelay ]
    set EThru [ list normalthruput highthruput ]
    set ERely [ list normalreliability highreliability ]
    set ECost [ list normalcost lowcost ]
    # set EFrag [ list may donot ]
    # set ELastFrag [ list last more ]
    set EQos [ list tos dscp ]
    
	set hopopt 0
	set icmp 1
	set igmp 2
	set ggp 3
	set ip 4
	set st 5
    set tcp 6
	set cbt 7
	set egp 8
	set igp 9
	set bbn-rcc-mon 10
	set nvp-ii 11
	set pup 12
	set argus 13
	set emcon 14
	set xnet 15
	set chaos 16
    set udp 17
	set mux 18
	set dcn-meas 19
	set hmp 20
	set prm 21
	set xns-idp 22
	set trunk-1 23
	set trunk-2 24
	set leaf-1 25
	set leaf-2 26
	set rdp 27
	set irtp 28
	set iso-tp4 29
	set netblt 30
	set mfe-nsp 31
	set merit-inp 32
	set sep 33
	set 3pc 34
	set idpr 35
	set xtp 36
	set ddp 37
	set idpr-cmtp 38
	set tp++ 39
	set il 40
	set ipv6 41
	set sdrp 42
	set ipv6-route 43
	set ipv6-frag 44
	set idrp 45
	set rsvp 46 
	set gre 47
	set mhrp 48
	set bna 49
	set esp 50
	set ah 51
	set i-nlsp 52
	set swipe 53
	set narp 54
	set mobile 55
	set tlsp 56
	set skip 57
	set ipv6-icmp 58
	set ipv6-nonxt 59
	set ipv6-opts 60
	set cftp 62
	set sat-expak 64
	set kryptolan 65
	set rvd 66
	set ippc 67
	set sat-mon 69
	set visa 70
	set ipcv 71
	set cpnx 72
	set cphb 73
	set wsn 74
	set pvp 75
	set br-sat-mon 76
	set sun-nd 77
	set wb-mon 78
	set wb-expak 79
	set iso-ip 80
	set vmtp 81
	set secure-vmtp 82
	set vines 83
	set ttp 84
	set nsfnet-igp 85
	set dgp 86
	set tcf 87
	set eigrp 88
	set ospfigp 89
	set sprite-rpc 90
	set larp 91
	set mtp 92
	set ax.25 93
	set ipip 94
	set micp 95
	set scc-sp 96
	set etherip 97
	set encap 98
	set gmtp 100
	set ifmp 101
	set pnni 102
	set pim 103
	set aris 104
	set scps 105
	set qnx 106
	set a/n 107
	set ipcomp 108
	set snp 109
	set compaq-peer 110
	set ipx-in-ip 111
	set vrrp 112
	set pgm 113
	set l2tp 115
	set ddx 116
	set iatp 117
	set stp 118
	set srp 119
	set uti 120
	set smp 121
	set sm 122
	set ptp 123
	set isis-over-ipv4 124
	set fire 125
	set crtp 126
	set crudp 127
	set sscopmce 128
	set iplt 129
	set sps 130
	set pipe 131
	set sctp 132
	set fc 133
	set rsvp-e2e-ignore 134
	set mobilityheader 135
	set udplite 136
	set mpls-in-ip 137
	set experimental 253
	set reserved 255

    # set tcp 6
    # set udp 17
    # set icmp 1
    
    set offset 0 ;#obsolete
    set saoffset 32
    set daoffset 32
    set samode Incrementing
    set damode Incrementing
    set sarepeat 1
    set darepeat 1
    set saStep 1
    set daStep 1
#    set protocolType 6
    set ipprotocolmode Fixed
    set precedence_mode Fixed
	set precedence_num 1
	set precedence_step 1
	set precedence_fullmesh 0
	
    set level 2
Deputs Step10
# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
			-precedence {
				if { [ string is integer $value ] && $value < 8 } {
					set precedence $value
					set EQos tos
				} elseif { [ catch { format %x $value } ] == 0 } {
				Deputs "precedence:$value"
					set precedence $value
				} else {
					set index [ lsearch -exact $EPrecedence [ string tolower $value ] ]
					if { $index < 0 } {
						error "$errNumber(1) key:$key value:$value"
					} else {
						set precedence $index
					}
				}
			}
			-precedence_num {
				set trans [ UnitTrans $value ]
				if { [ string is integer $trans ] } {
					set precedence_num $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-precedence_step {
				set trans [ UnitTrans $value ]
				if { [ string is integer $trans ] } {
					set precedence_step $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-precedence_mode {
				set precedence_mode [ string tolower $value ]
				switch $precedence_mode {
					incr {
						set precedence_mode Incrementing
					}
					decr {
						set precedence_mode Decrementing
					}
					random {
						set precedence_mode Random
					}
					list {
						set precedence_mode List
					}
					default {
						set precedence_mode Fixed
					}
				}

			}
			-precedence_fullmesh {
				 set trans [ BoolTrans $value ]
				 if { $trans == "1" || $trans == "0" } {
					set precedence_fullmesh $value
				 } else {
					error "$errNumber(1) key:$key value:$value"
				 }
				
			}
			-identification {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set identifier $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
			}
			-fragment_offset {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set fragoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
			-ttl {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set ttl $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
			-protocol_type {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set protocolType $trans
			 } else {
				if { [ info exists [ string tolower $value ] ] } {
					eval set trans $[ string tolower $value ]
					if { [ string is integer $trans ] } {
					   set protocolType $trans
					} else {
					   error "$errNumber(1) key:$key value:$value"
					}
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			 }
			}
			-src {
			Deputs "set ip address...$value"
				foreach addr $value {
					if { [ IsIPv4Address $addr ] } {
						set sa $value
						set noIp	0
					Deputs "sa:$sa"
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
			}
			-src_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set sarepeat $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
			-src_step {
			 if { [ IsIPv4Address $value ] } {
				set saStep $value
			 } else {
				set trans [ UnitTrans $value ]
				if { [ string is integer $trans ] } {
					set saStep $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			 }
			}
			-src_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
				set saoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
			}
			-dst {
			foreach addr $value {
				 if { [ IsIPv4Address $addr ] } {
					set da $value
				 } else {
					error "$errNumber(1) key:$key value:$value"
				 }
			 }
			}
			-dst_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set darepeat $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
			-dst_step {
			 if { [ IsIPv4Address $value ] } {
				set daStep $value
			 } else {
				set trans [ UnitTrans $value ]
				if { [ string is integer $trans ] } {
					set daStep $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			 }
			}
			-dst_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
				set daoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
			}
			-dscp {
			 if { [ catch { format %x $value } ] == 0 } {
				set qosval $value
				set qosmode dscp
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
			}
			-tos {
			 if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 16 ) } {
				set delay       [ expr $value / 8 ]
				set throughput  [ expr ( $value - $delay * 8 ) / 4 ]
				set rely        [ expr ( $value - $delay * 8 - $throughput * 4 ) / 2 ]
				set cost        [ expr ( $value - $delay * 8 - $throughput * 4 - $rely * 2 ) ]
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
			}
			-flag {
			 if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
				set flagreserved        [ expr $value / 4 ]
				set frag            [ expr ( $value - $flagreserved * 4 ) / 2 ]
				set lastfrag        [ expr ( $value - $flagreserved * 4 - $frag * 2 ) ]
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
			}
			-src_range_mode {
				set src_range_mode [ string tolower $value ]
				switch $src_range_mode {
					incr {
						set samode Incrementing
					}
					decr {
						set samode Decrementing
					}
					random {
						set samode Random
					}
					list {
						set samode List
					}
				}
			}
			-dst_range_mode {
				set dst_range_mode [ string tolower $value ]
				switch $dst_range_mode {
					incr {
						set damode Incrementing
					}
					decr {
						set damode Decrementing
					}
					random {
						set damode Random
					}
					list {
						set damode List
					}
				}
			}       
		}
    }

	if { [ llength $args ] == 0 } {
	   return [GetStandardReturnHeader]
	}
	
#        $pdu Clear
    set pro [ string tolower $protocol ]

Deputs "Pro: $pro"
    if { $pro != "ipv4" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
Deputs Step50
    SetProtocol IPv4
    #--------------------------
    #-----Config TOS ------
    if { [ info exists precedence ] } {
	   if { [ info exists precedence_mode ] } {
		  switch -exact $precedence_mode {
			Fixed -
			List {
				AddFieldMode $precedence_mode
				AddField precedence
				AddFieldConfig $precedence
			}
			Decrementing -
			Incrementing {
				if { [ info exists precedence_num ] && [ info exists precedence_step ] } {
					AddFieldMode $precedence_mode
					AddField precedence 0 0 $precedence_fullmesh
					AddFieldConfig [ list 0 $precedence $precedence_num $precedence_step ]
				} else {
				    error "$errNumber(2) key:src_num/src_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists delay ] } {
	   AddField delay
	   AddFieldMode Fixed
	   AddFieldConfig $delay
    }
    if { [ info exists throughput ] } {
Deputs "throughput: $throughput"
	   AddField throughput
	   AddFieldMode Fixed
	   AddFieldConfig $throughput
    }
    if { [ info exists rely ] } {
	   AddField reliability
	   AddFieldMode Fixed
	   AddFieldConfig $rely
    }
    if { [ info exists cost ] } {
Deputs "cost: $cost"
	   AddField monetary
	   AddFieldMode Fixed
	   AddFieldConfig $cost
    }
    if { [ info exists qosval ] } {
	   if { [ info exists qosmode ] } {
		  if { $qosmode == "dscp" } {
Deputs "qosval:$qosval"
				if { $qosval >= 64 } {
				error "$errNumber(1) key:dscp value:$qosval"
			 } else {
				set qosval  [ expr $qosval * 4 ]
				set qosval  [ format %x $qosval ] 
			 }
		  }
	   }
	   AddField raw 1
	   AddFieldMode Reserved
	   AddFieldConfig 0           
	   AddField raw
	   AddFieldMode Fixed
	   AddFieldConfig $qosval
    }
    #--------------------------
    #-----Config Flags-----
    if { [ info exists flagreserved ] } {
	   AddField reserved
	   AddFieldMode Fixed
	   AddFieldConfig $flagreserved
    }
    if { [ info exists frag ] } {
	   AddField fragment
	   AddFieldMode Fixed
	   AddFieldConfig $frag
    }
    if { [ info exists lastfrag ] } {
	   AddField lastFragment
	   AddFieldMode Fixed
	   AddFieldConfig $lastfrag
    }
    #--------------------------
    #-----Config Common-----
    if { [ info exists identifier ] } {
	   AddField identification
	   AddFieldMode Fixed
	   AddFieldConfig $identifier
    }
    if { [ info exists fragoffset ] } {
	   AddField fragmentOffset
	   AddFieldMode Fixed
	   AddFieldConfig $fragoffset
    }
    if { [ info exists ttl ] } {
	   AddField ttl
	   AddFieldMode Fixed
	   AddFieldConfig $ttl
    }
    if { [ info exists protocolType ] } {
	   AddFieldMode Fixed
	   AddField protocol
	   AddFieldConfig $protocolType
    }
    
    if { [ info exists version ] } {
	   AddField version
	   AddFieldMode Fixed
	   AddFieldConfig $version
    }
    
    if { [ info exists hlen ] } {
	   AddField headerLength
	   AddFieldMode Fixed
	   AddFieldConfig $hlen
    }

    #--------------------------
    #-----Config IP Address-----
Deputs Step100
    if { [ info exists sa ] } {
Deputs Step110
	   if { [ info exists samode ] } {
		  switch -exact $samode {
			 Fixed -
			List {
				AddFieldMode $samode
				AddField srcIp
				AddFieldConfig $sa
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists sarepeat ] && [ info exists saStep ] } {
Deputs "sarepeat:$sarepeat"					
Deputs "saStep:$saStep"
Deputs "saStep Ip validation...[ IsIPv4Address $saStep ]..."
				    if { [ IsIPv4Address $saStep ] == "0" } {
					   set saoffset [ expr 32 - $saoffset ]
Deputs "saoffset:$saoffset"							
					   set saStep [GetIpStep $saoffset $saStep]
				    }
Deputs "saStep:$saStep"
				    AddFieldMode $samode
				    AddField srcIp
				    AddFieldConfig [ list $saoffset $sa $sarepeat $saStep ]
				} else {
				    error "$errNumber(2) key:src_num/src_step"
				}
			 }
		  }
	   } 
    }
Deputs Step200
    if { [ info exists da ] } {
	   if { [ info exists damode ] } {
		  switch -exact $damode {
			 Fixed -
			List {
				AddFieldMode $damode
				AddField dstIp
				AddFieldConfig $da
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists darepeat ] && [ info exists daStep ] } {
				    if { [ IsIPv4Address $daStep ] == "0" } {
					   set daoffset [ expr 32 - $daoffset ]
					   set daStep [GetIpStep $daoffset $daStep]
				    }
Deputs "daStep:$daStep"
				    AddFieldMode $damode
				    AddField dstIp
				    AddFieldConfig [ list $daoffset $da $darepeat $daStep ]
				    
				} else {
				    error "$errNumber(2) key:dst_num/dst_step"
				}
			 }
		  }
	   } 
    }
    #--------------------------
    
	eval chain $args
	
    #--------------------------
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body Ipv6Hdr::config { args } {
    global errorInfo
    global errNumber


    set tag "body Ipv6Hdr::config [info script]"
Deputs "----- TAG: $tag -----"

    set saoffset 0
    set daoffset 0
    set samode Incrementing
    set damode Incrementing
    set saStep 1
    set daStep 1
	set darepeat 1
	set sarepeat 1
    set EType [ list Fixed Random Incrementing Decrementing ]
Deputs Step10
# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -traffic_class {
			 if { [ string is integer $value ] && $value < 256 } {
				set traffic_class $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -flow_label {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set flow_label $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -next_header {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set next_header $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -hop_limit {
			 if { [ string is integer $value ] && $value < 256 } {
				set hop_limit $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src {
			 set sourceAddress $value
		  }
		  -src_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set sarepeat $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_step {
			 set trans [ UnitTrans $value ]
Deputs "Unit trans result for IPv6 Header SourceAddressStep: $trans"
			 if { [ string is integer $trans ] } {
				set saStep $trans
			 } else {
				set saStep $value
			 }
Deputs "saStep:$saStep"
		  }
		  -src_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 128 && $trans >= 1 } {
				set saoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -dst {
			 set destinationAddress $value
		  }
		  -dst_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
Deputs "Dst addr num: $trans"
				set darepeat $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set daStep $trans
			 } else {
				set daStep $value
			 }
		  }
		  -dst_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 128 && $trans >= 1 } {
				set daoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
			-src_range_mode {
				set src_range_mode [ string tolower $value ]
				switch $src_range_mode {
					incr {
						set samode Incrementing
					}
					decr {
						set samode Decrementing
					}
					random {
						set samode Random
					}
				}
			}
			-dst_range_mode {
				set dst_range_mode [ string tolower $value ]
				switch $dst_range_mode {
					incr {
						set damode Incrementing
					}
					decr {
						set damode Decrementing
					}
					random {
						set damode Random
					}
				}
			}       
	   }
    }

    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "ipv6" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol IPv6
    #-----Config common-----
    if { [ info exists traffic_class ] } {
	   AddField trafficClass 1
	   AddFieldMode Reserved
	   AddFieldConfig 0
	   AddField trafficClass
	   AddFieldMode Fixed
	   AddFieldConfig $traffic_class
    }
    if { [ info exists flow_label ] } {
	   AddField flowLabel
	   AddFieldMode Fixed
	   AddFieldConfig $flow_label
    }
    #-----Config payload-----
    if { [ info exists payload_length ] } {
	   AddField payloadLength
	   AddFieldMode Fixed
	   AddFieldConfig $payload_length
    }
    #--------------------------
    if { [ info exists next_header ] } {
	   AddField nextHeader
	   AddFieldMode Fixed
	   AddFieldConfig $next_header
    }
    if { [ info exists hop_limit ] } {
	   AddField hopLimit
	   AddFieldMode Fixed
	   AddFieldConfig $hop_limit
    }
    #--------------------------
    #-----Config IP Address-----
    if { [ info exists sourceAddress ] } {
	   if { [ info exists samode ] } {
		  switch -exact $samode {
			 Fixed {
				AddFieldMode $samode
				AddField srcIP
				AddFieldConfig $sourceAddress
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists sarepeat ] && [ info exists saStep ] } {
				    if { [ IsIPv6Address $saStep ] == 0 } {
Deputs "saStep:$saStep"
Deputs "saoffset:$saoffset"							
					   set saStep [GetIpv6Step $saoffset $saStep]
Deputs "saStep:$saStep"
				    }
				    AddFieldMode $samode
				    AddField srcIP
				    AddFieldConfig \
				    [ list $saoffset $sourceAddress $sarepeat $saStep ]
				} else {
				    error "$errNumber(1) key:$key value:$value"
				}
			 }
		  }
	   } 
    }
    if { [ info exists destinationAddress ] } {
	   if { [ info exists damode ] } {
		  switch -exact $damode {
			 Fixed {
				AddFieldMode $damode
				AddField dstIP
				AddFieldConfig $destinationAddress
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists darepeat ] && [ info exists daStep ] } {
				    if { [ IsIPv6Address $daStep ] == 0 } {
					   #set daoffset [ expr 128 - $daoffset ]
Deputs "daoffset:$daoffset"							
					   set daStep [GetIpv6Step $daoffset $daStep]
Deputs "daStep:$daStep"
						}                        
						
				    AddFieldMode $damode
				    AddField dstIP
				    AddFieldConfig \
				    [ list $daoffset $destinationAddress $darepeat $daStep ]
				    
				} else {
				    error "$errNumber(1) key:$key value:$value"
				}
			 }
		  }
	   } 
    }
    #--------------------------
	eval chain $args
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body TcpHdr::config { args } {
    global errorInfo
    global errNumber


    set tag "body TcpHdr::config [info script]"
Deputs "----- TAG: $tag -----"
		  
    set EType [ list Fixed Random Incrementing Decrementing ]
    set spmode Incrementing
    set dpmode Incrementing
    set spstep 1
    set dpstep 1
    set spcount 1
    set dpcount 1
    set level 2
# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -cwr_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set cwr $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -ecn_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set ecn $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -ack_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set ack $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -fin_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set fin $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -psh_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set psh $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -rst_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set rst $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -syn_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set syn $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -urg_bit {
			 set trans [ BoolTrans $value ]
			 if { $trans == 1 || $trans == 0 } {
				set urg $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -ack_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set ack_number 0x[ format %x $trans ]
			 } else {
				set ack_number 0x[ format %x $value ]
			 }
		  }
		  -check_sum {
			 if { [ catch { format %x $value } ] == 0 } {
				set checksum [ format %x $value ]
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_port {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set destination_port $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_port_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set dpcount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_port_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set dpstep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -offset {
			 if { [ string is integer $value ] && $value < 16 } {
				set offset $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -seq_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set sequence_number 0x[ format %x $trans ]
			 } else {
				set sequence_number 0x[ format %x $value]
			 }
		  }
		  -seq_num_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set sequence_number_step 0x[ format %x $trans ]
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -seq_num_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set sequence_number_mod $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -seq_num_cnt {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set sequence_number_count $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_port {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set source_port $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_port_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set spcount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_port_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set spstep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -urgent_ptr {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set urgent_pointer 0x[ format %x $trans ]
			 } else {
				set urgent_pointer 0x[ format %x $value ]
			 }
		  }
		  -window {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set window_size 0x[ format %x $trans ]
			 } else {
				set window_size 0x[ format %x $value ]
			 }
		  }
			-reserved {
			 if { [ string is integer $value ] && $value < 8 } {
				set reserved $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
	   }
    }
	
	if { [ info exists sequence_number ] } {
	} else {
	    set sequence_number  0x[ format %x 123456]
	}
	
#        $pdu Clear
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "tcp" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol TCP
    #-----set Code Bits-----
    if { [ info exists urg ] } {
	   AddField urgBit
	   AddFieldMode Fixed
	   AddFieldConfig $urg
    }
    if { [ info exists ack ] } {
	   AddField ackBit
	   AddFieldMode Fixed
	   AddFieldConfig $ack
    }
    if { [ info exists psh ] } {
	   AddField pshBit
	   AddFieldMode Fixed
	   AddFieldConfig $psh
    }
    if { [ info exists rst ] } {
	   AddField rstBit
	   AddFieldMode Fixed
	   AddFieldConfig $rst
    }
    if { [ info exists syn ] } {
	   AddField synBit
	   AddFieldMode Fixed
	   AddFieldConfig $syn
    }
    if { [ info exists fin ] } {
	   AddField finBit
	   AddFieldMode Fixed
	   AddFieldConfig $fin
    }
    if { [ info exists cwr ] } {
	   AddField cwrBit
	   AddFieldMode Fixed
	   AddFieldConfig $cwr
    }
    if { [ info exists ecn ] } {
	   AddField ecnEchoBit
	   AddFieldMode Fixed
	   AddFieldConfig $ecn
    }

    #--------------------------
    #-----Config Checksum-----
    if { [ info exists checksum ] } {
	   AddField checksum
	   AddFieldMode Fixed
	   AddFieldConfig $checksum
	   
    }
    #--------------------------
    #-----Config Common-----
    if { [ info exists offset ] } {
Deputs "offset:$offset"
	   AddField dataOffset 0 1
	   AddFieldMode Reserved
	   AddFieldConfig 0
	   AddField dataOffset
	   AddFieldMode Fixed
	   AddFieldConfig $offset
    }
 
	if { [ info exists sequence_number ] } {
	    if {[ info exists sequence_number_step ] || [ info exists sequence_number_count ]} {
		    if {[ info exists sequence_number_mod ]} {
			} else { 
			    set sequence_number_mod 32 
			}
			if {[ info exists sequence_number_count ]} {
			} else {
			    set sequence_number_count 1
			}
			if {[ info exists sequence_number_step ]} {
			} else {
			    set sequence_number_step 1
			}
			set seq_step_max 0
			
			set hightemp  [expr $sequence_number >> $sequence_number_mod]
			set hightemp  [expr $hightemp << $sequence_number_mod]
			set stepbase [expr $hightemp ^ $sequence_number]
			for {set i 0} {$i < $sequence_number_mod } {incr i } {
			    set seq_step_max [expr $seq_step_max + pow (2,$i) ]
			
			}
			set step_num [expr ($seq_step_max - $stepbase) / $sequence_number_step ]
			if {$sequence_number_count <= $step_num} {
			} else {
			    set sequence_number_count [expr int($step_num)]
			}

			
			AddField sequenceNumber
	        AddFieldMode Incrementing
	        AddFieldConfig \
				[ list 0 $sequence_number $sequence_number_count $sequence_number_step ]
		} else {
	        AddField sequenceNumber
	        AddFieldMode Fixed
	        AddFieldConfig $sequence_number
	    }
    }
	
    if { [ info exists ack_number ] } {
	   AddField acknowledgementNumber
	   AddFieldMode Fixed
	   AddFieldConfig $ack_number
    }
    if { [ info exists window_size ] } {
	   AddField window
	   AddFieldMode Fixed
	   AddFieldConfig $window_size
    }
    if { [ info exists urgent_pointer ] } {
	   AddField urgentPtr
	   AddFieldMode Fixed
	   AddFieldConfig $urgent_pointer
    }
	if { [ info exists reserved ] } {
	   AddField reserved
	   AddFieldMode Fixed
	   AddFieldConfig $reserved
		
	}
    #--------------------------
    #-----Config Port-----
    if { [ info exists destination_port ] } {
Deputs Step110
	   if { [ info exists dpmode ] } {
Deputs Step120
		  switch -exact $dpmode {
			 Fixed {
				AddFieldMode $dpmode
				AddField dstPort
				AddFieldConfig $destination_port
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists dpcount ] && [ info exists dpstep ] } {
				    AddFieldMode $dpmode
				    AddField dstPort
				    AddFieldConfig \
				    [ list 0 $destination_port $dpcount $dpstep ]
				} else {
				    error "$errNumber(2) key:dst_port_num/dst_port_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists source_port ] } {
	   if { [ info exists spmode ] } {
		  switch -exact $spmode {
			 Fixed {
				AddFieldMode $spmode
				AddField srcPort
				AddFieldConfig $source_port
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists spcount ] && [ info exists spstep ] } {
				    AddFieldMode $spmode
				    AddField srcPort
				    AddFieldConfig \
				    [ list 0 $source_port $spcount $spstep ]
				} else {
				    error "$errNumber(2) key:src_port_num/src_port_step"
				}
			 }
		  }
	   } 
    }
    #--------------------------
	eval chain $args
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body UdpHdr::config { args } {
    global errorInfo
    global errNumber


    set tag "body UdpHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    set spmode Incrementing
    set dpmode Incrementing
    set spstep 1
    set dpstep 1
    set dpcount 1
    set dpstep 1
    set spcount 1
    set spstep 1
    set level 2
	set src_port_mesh 0
	set dst_port_mesh 0
    set EType [ list Fixed Random Incrementing Decrementing ]
# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -src_port {
			 # set trans [ UnitTrans $value ]
			 # if { [ string is integer $trans ] } {
				# set source_port $trans
			 # } else {
				# error "$errNumber(1) key:$key value:$value"
			 # }
			 set source_port $value
		  }
		  -src_port_mesh {
			set src_port_mesh $value
		  }
		  -src_port_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set spcount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -src_port_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set spstep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_port {
			 # set trans [ UnitTrans $value ]
			 # if { [ string is integer $trans ] } {
				# set destination_port $trans
			 # } else {
				# error "$errNumber(1) key:$key value:$value"
			 # }
			 set destination_port $value
		  }
		  -dst_port_mesh {
			set dst_port_mesh $value
		  }
		  -dst_port_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set dpcount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -dst_port_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set dpstep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -checksum {
Deputs "udp checksum: $value"
		if { [ string is integer $value ] } {
			set checksum [ format %x $value ]
		} else {
			 if { [ catch { format %x $value } ] == 0 } {
				set checksum $value
Deputs "udp checksum: $checksum"
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  }
		  -length {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set totallen $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
			-src_range_mode {
				set src_range_mode [ string tolower $value ]
				switch $src_range_mode {
					incr {
						set spmode Incrementing
					}
					decr {
						set spmode Decrementing
					}
					random {
						set spmode Random
					}
					list {
						set spmode List
					}
				}
			}
			-dst_range_mode {
				set dst_range_mode [ string tolower $value ]
				switch $dst_range_mode {
					incr {
						set dpmode Incrementing
					}
					decr {
						set dpmode Decrementing
					}
					random {
						set dpmode Random
					}
					list {
						set dpmode List
					}
				}
			}       
	   }
    }
    set pro [ string tolower $protocol ]
    
Deputs "Pro: $pro"
    if { $pro != "udp" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol UDP
    #-----Config Total Length-----
    set manTOT 1
    if { [ info exists totallen ] } {
	   AddField length
	   AddFieldMode Fixed
	   AddFieldConfig $totallen
    }
    #--------------------------
    #-----Config Checksum-----
    if { [ info exists checksum ] } {
	   AddField checksum 1 
	   AddFieldMode Reserved
	   AddFieldConfig 0                       
	   AddField checksum
	   AddFieldMode Fixed
	   AddFieldConfig $checksum
    }
    #--------------------------
    #-----Config Port-----
    if { [ info exists destination_port ] } {
	   if { [ info exists dpmode ] } {
		   AddField dstPort 0 0 $dst_port_mesh
		   AddFieldMode Reserved
		   AddFieldConfig 0                       

		  switch -exact $dpmode {
			 Fixed -
			 List {
				AddFieldMode $dpmode
				AddField dstPort
Deputs "dest port len:[ llength $destination_port ]"				
				AddFieldConfig $destination_port
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists dpcount ] && [ info exists dpstep ] } {
				    AddFieldMode $dpmode
				    AddField dstPort
				    AddFieldConfig \
				    [ list 0 $destination_port $dpcount $dpstep ]
				} else {
				    error "$errNumber(2) key:dst_port_num/dst_port_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists source_port ] } {
	   if { [ info exists spmode ] } {
		   AddField srcPort 0 0 $src_port_mesh
		   AddFieldMode Reserved
		   AddFieldConfig 0                       
		  switch -exact $spmode {
			 Fixed -
			 List {
				AddFieldMode $spmode
				AddField srcPort
Deputs "source port len:[ llength $source_port ]"				
				AddFieldConfig $source_port
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists spcount ] && [ info exists spstep ] } {
				    AddFieldMode $spmode
				    AddField srcPort 
				    AddFieldConfig \
				    [ list 0 $source_port $spcount $spstep ]
				} else {
				    error "$errNumber(2) key:dst_port_num/dst_port_step"
				}
			 }
		  }
	   } 
    }
    #--------------------------
	eval chain $args

    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body SingleMplsHdr::config { args } {
    global errorInfo
    global errNumber


    set tag "body SingleMplsHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    set EType [ list Fixed Random Incrementing Decrementing ]
    set labelmode Incrementing
    
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -label_id -
		  -label1_id {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set label1 $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -label1_num -
		  -label_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set labelcount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -label1_step -
		  -label_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set labelstep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -exp1 -
		  -exp {
			 if { [ string is integer $value ] && $value < 8 } {
				set exp1 $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -ttl -
		  -ttl1 {
			 if { [ string is integer $value ] && $value < 256 } {
				set ttl1 $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
	   }
    }
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "mpls" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol MPLS
    #-----Config-----
    if { [ info exists label1 ] } {
	   if { [ info exists labelmode ] } {
		  switch -exact $labelmode {
			 Fixed {
				AddFieldMode $labelmode
				AddField value
				AddFieldConfig $label1
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists labelcount ] && [ info exists labelstep ] } {
				    AddFieldMode $labelmode
				    AddField value
				    AddFieldConfig [ list 0 $label1 $labelcount $labelstep ]
				    
				} else {
				    error "$errNumber(2) key:label_num/label_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists exp1 ] } {
	   AddField experimental
	   AddFieldMode Fixed
	   AddFieldConfig $exp1
    }
    if { [ info exists ttl1 ] } {
	   AddField ttl
	   AddFieldMode Fixed
	   AddFieldConfig $ttl1
    }
    #--------------------------
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body MplsHdr::config { args } {
    global errorInfo
    global errNumber


    set tag "body MplsHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    
    set label1_id       0
    set label1_num      1
    set label1_step     1
    set exp1            0
    set ttl1            64
    
    set label2_id       0
    set label2_num      1
    set label2_step     1
    set exp2            0
    set ttl2            64
    
    set flagLabel2      0
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -label1_id {
			 set label1_id $value
		  }
		  -label1_num {
			 set label1_num $value
		  }
		  -label1_step {
			 set label1_step $value
		  }
		  -exp1 {
			 set exp1 $value
		  }
		  -ttl1 {
			 set ttl1 $value
		  }
		  -label2_id {
			 set label2_id $value
			 set flagLabel2  1
		  }
		  -label2_num {
			 set label2_num $value
			 set flagLabel2  1
		  }
		  -label2_step {
			 set label2_step $value
			 set flagLabel2  1
		  }
		  -exp2 {
			 set exp2 $value
			 set flagLabel2  1
		  }
		  -ttl2 {
			 set ttl2 $value
			 set flagLabel2  1
		  }
	   }
    }
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "mpls" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol MPLS

    set mplsObjId1       [clock click]
Deputs "mpls temp Id1: $mplsObjId1"
    SingleMplsHdr mpls$mplsObjId1
Deputs "MPLS Label1: mpls$mplsObjId1"
    mpls$mplsObjId1 config -label_id $label1_id -label_num $label1_num \
	   -label_step $label1_step -exp $exp1 -ttl $ttl1

    if { $flagLabel2 } {
	    after 10
	   set mplsObjId2       [clock click]
Deputs "mpls temp Id2: $mplsObjId2"
	   SingleMplsHdr mpls$mplsObjId2
Deputs "MPLS Label2: mpls$mplsObjId2"
	   mpls$mplsObjId2 config -label_id $label2_id -label_num $label2_num \
		  -label_step $label2_step -exp $exp2 -ttl $ttl2
	   
	   lappend objList [ list mpls$mplsObjId1 mpls$mplsObjId2 ]
	   if { [ mpls$mplsObjId1 IsValid ] && [ mpls$mplsObjId2 IsValid ] } {
		  return [GetStandardReturnHeader]
	   } else {
		  return [ GetErrorReturnHeader "PDU is invalid" ]
	   }
	} else {
	   lappend objList mpls$mplsObjId1
	   if { [ mpls$mplsObjId1 IsValid ] } {
		  return [GetStandardReturnHeader]
	   } else {
		  return [ GetErrorReturnHeader "PDU is invalid" ]
	   }
    }
    

}
body ArpHdr::config { args } {
    global errorInfo
    global errNumber

    set tag "body ArpHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    
    set EType [ list Fixed Random Incrementing Decrementing ]
    set EOperation [ list arprequest arpreply ]
    set offset 0 ;#obsolete
    set saoffset 0
    set daoffset 0
    set spoffset 0
    set dpoffset 0
    set daReCnt Incrementing
    set saReCnt Incrementing
    set daStep 1
    set saStep 1
	set saNum  1
	set daNum  1
    set dstProAddrMode Incrementing
    set srcProAddrMode Incrementing
    set dstProAddrStep 1
    set srcProAddrStep 1
    set dstProAddrCount 1
    set srcProAddrCount 1

# param collection        
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -target_mac_addr {
			 set trans [ MacTrans $value ]
			 if { [ IsMacAddress $trans ] } {
				set da $trans
Deputs "dha:$da"
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -target_mac_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set daNum $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -target_mac_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set daStep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -target_mac_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 48 && $trans >= 1 } {
				set daoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -sender_mac_addr {
			 set trans [ MacTrans $value ]
			 if { [ IsMacAddress $trans ] } {
				set sa $trans
					set  noMac	0
Deputs "sha:$sa"
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -sender_mac_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set saStep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -sender_mac_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set saNum $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -sender_mac_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 48 && $trans >= 1 } {
				set saoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -arp_type {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans < 4 } {
				set operation $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -sender_ipv4_addr {
			 if { [ IsIPv4Address $value ] } {
				set srcProAddr $value
					set  noIp	0
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -sender_ipv4_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set srcProAddrCount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -sender_ipv4_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set srcProAddrStep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -sender_ipv4_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
				set spoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -target_ipv4_addr {
			 if { [ IsIPv4Address $value ] } {
				set dstProAddr $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -target_ipv4_step {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set dstProAddrStep $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -target_ipv4_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set dstProAddrCount $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
		  -target_ipv4_mod {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
				set dpoffset $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }                    
		  }
		  -hardware {
			 set trans [ format %i $value ]
			 if { [string is integer $trans] } {
				set hardwarecode $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
		  }
			-protocol {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set protocol_type 0x[ format %x $trans ]
			 } else {
				set protocol_type 0x[ format %x $value ]
			 }				
			}
			
			-ih_addr {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set hardwareAddressLength $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }			
			}
			
			-ip_addr {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set protocolAddressLength $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
	   }
    }
Deputs Step10
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "ethernetarp" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol ethernetARP
    if { [ info exists da ] } {
	   if { [ info exists daReCnt ] } {
		  switch -exact $daReCnt {
			 Fixed {
				AddFieldMode $daReCnt
				AddField dstHardwareAddress
				AddFieldConfig $da
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists daNum ] && [ info exists daStep ] } {
				    set daoffset [expr 48 - $daoffset]
				    set daStep [ GetMacStep $daoffset $daStep ]
				    AddFieldMode $daReCnt
				    AddField dstHardwareAddress
				    AddFieldConfig \
				    [ list $daoffset $da $daNum $daStep ]
				} else {
				    error "$errNumber(2) key:target_mac_num/target_mac_step"
				}
			 }
		  }
	   }
    }

    if { [ info exists sa ] } {
Deputs Step100
	   if { [ info exists saReCnt ] } {
Deputs Step110
		  switch -exact $saReCnt {
			 Fixed {
				AddFieldMode $saReCnt
				AddField srcHardwareAddress
				AddFieldConfig $sa
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists saNum ] && [ info exists saStep ] } {
				    set saoffset [expr 48 - $saoffset]
				    set saStep [ GetMacStep $saoffset $saStep ]
				    AddFieldMode $saReCnt
				    AddField srcHardwareAddress
				    AddFieldConfig [ list $saoffset $sa $saNum $saStep ]
				} else {
				    error "$errNumber(2) key:sender_mac_num/sender_mac_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists operation ] } {
	   AddField opCode
	   AddFieldMode Fixed
	   AddFieldConfig $operation
    }
    if { [ info exists srcProAddr ] } {
	   if { [ info exists srcProAddrMode ] } {
		  switch -exact $srcProAddrMode {
			 Fixed {
				AddFieldMode $srcProAddrMode
				AddField srcIP
				AddFieldConfig $srcProAddr
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists srcProAddrCount ] && [ info exists srcProAddrStep ] } {
				    set spoffset [expr 32 - $spoffset]
				    set srcProAddrStep [ GetIpStep $spoffset $srcProAddrStep ]
				    
				    AddFieldMode $srcProAddrMode
				    AddField srcIP
				    AddFieldConfig \
				    [ list $spoffset $srcProAddr $srcProAddrCount $srcProAddrStep ]
				} else {
				    error "$errNumber(2) key:sender_ipv4_num/sender_ipv4_step"
				}
			 }
		  }
	   }
    }

    if { [ info exists dstProAddr ] } {
Deputs Step100
	   if { [ info exists dstProAddrMode ] } {
Deputs Step110
		  switch -exact $dstProAddrMode {
			 Fixed {
				AddFieldMode $dstProAddrMode
				AddField dstIP
				AddFieldConfig $dstProAddr
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists dstProAddrCount ] && [ info exists dstProAddrStep ] } {
				    set dpoffset [expr 32 - $dpoffset]
				    set dstProAddrStep [ GetIpStep $dpoffset $dstProAddrStep ]
				    
				    AddFieldMode $dstProAddrMode
				    AddField dstIP
				    AddFieldConfig [ list $dpoffset $dstProAddr $dstProAddrCount $dstProAddrStep ]
				} else {
				    error "$errNumber(2) key:target_ipv4_num/target_ipv4_step"
				}
			 }
		  }
	   } 
    }
    if { [ info exists hardwarecode ] } {
	   AddField hardwareType
	   AddFieldMode Fixed
	   AddFieldConfig $hardwarecode
    }
    
	if { [ info exists protocol_type ] } {
	   AddField protocolType
	   AddFieldMode Fixed
	   AddFieldConfig $protocol_type
    }	
	
	if { [ info exists hardwareAddressLength ] } {
	   AddField hardwareAddressLength
	   AddFieldMode Fixed
	   AddFieldConfig $hardwareAddressLength
    }
	
	if { [ info exists protocolAddressLength ] } {
	   AddField protocolAddressLength
	   AddFieldMode Fixed
	   AddFieldConfig $protocolAddressLength
    }
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body IcmpHdr::config { args } {
    global errorInfo
    global errNumber

    set tag "body IcmpHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    
    
# param collection        
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -type {
			 
			if {($value == "0x08" ) || ($value =="echo_requeset") || ($value == 0x08)} {
			    set icmp_type 8
			} elseif {($value == "0x00" ) || ($value =="echo_reply") || ($value == 0x00)} {
                set icmp_type 0
            } else {
				error "$errNumber(1) key:$key value:$value"
			}                    
		  }
	
			-code {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set code $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }			
			}
			
			-checksum {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set checksum $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
            -identifier {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set identifier $trans
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			}
            -identifier_list {
			   set identifier_list  $value 
            }
            -identifier_count {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set identifier_count $trans 
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }				
			}
            -seq_num {
			 set trans [ UnitTrans $value ]
			 if { [ string is integer $trans ] } {
				set seq_num $trans 
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }				
			}
            
	   }
    }
Deputs Step10
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "icmpv2" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol icmpv2
    
    if { [ info exists icmp_type ] } {
    } else {
        set icmp_type 8
    }
    
    AddField messageType
	AddFieldMode Fixed
	AddFieldConfig $icmp_type
    
   

    if { [ info exists code ] } {
	   AddField codeValue
	   AddFieldMode Fixed
	   AddFieldConfig $code
    }
    
	if { [ info exists checksum ] } {
	   AddField message.icmpChecksum
	   AddFieldMode Fixed
	   AddFieldConfig $checksum
    }	
    
    if { [ info exists identifier ] } {
	   AddField identifier
	   AddFieldMode Fixed
	   AddFieldConfig $identifier
    } elseif { [ info exists identifier_list ] } {
Deputs Step100
	    if { [ info exists identifier_count ] } {
        } else {
            set identifier_count 1 
        }
        
        set identifier_length [llength $identifier_list]
        set id_list [lindex $identifier_list 0]
        set id_index $identifier_count
        while { $id_index < $identifier_length} {
            lappend id_list [lindex $identifier_list $id_index]
            incr id_index $identifier_count
        }
Deputs Step110
		AddFieldMode List
		AddField identifier
		AddFieldConfig $id_list
			
    } else {
        set identifier 512
        AddField identifier
	    AddFieldMode Fixed
	    AddFieldConfig $identifier
    }
	
	
	if { [ info exists seq_num ] } {   
    } else {
        set seq_num 8704
    }
    AddField sequenceNumber
	AddFieldMode Fixed
	AddFieldConfig $seq_num
    
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body CfmHdr::config { args } {

    global errorInfo
    global errNumber

    set tag "body CfmHdr::config [info script]"
Deputs "----- TAG: $tag -----"

# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -md_level {
				set md_level $value
		  }
		  -flags {
				set flags $value
		  }
		  -first_tlv_offset  {
				set first_tlv_offset $value
		  }
	   }
    }

    set pro [ string tolower $protocol ]
    
Deputs "Pro: $pro"
    if { $pro != "cfm" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol CFM

    if { [ info exists md_level ] } {
	   AddField mdLevel
	   AddFieldMode Fixed
	   AddFieldConfig $md_level
    }
	
    if { [ info exists flags ] } {
	   AddField flags
	   AddFieldMode Fixed
	   AddFieldConfig $flags
    }
	
    if { [ info exists first_tlv_offset ] } {
	   AddField firstTLVOffset
	   AddFieldMode Fixed
	   AddFieldConfig $first_tlv_offset
    }
	
    if { [ info exists opCode ] } {
	   AddField opCode
	   AddFieldMode Fixed
	   AddFieldConfig $opCode
    }
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }


}
body CcmHdr::config { args } {
	eval chain $args

    global errorInfo
    global errNumber

    set tag "body CcmHdr::config [info script]"
Deputs "----- TAG: $tag -----"

# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -md_level {
				set md_level $value
		  }
		  -flags {
				set flags $value
		  }
		  -first_tlv_offset  {
				set first_tlv_offset $value
		  }
	   }
    }
}
body CustomHdr::config { args } {
	eval chain $args

    global errorInfo
    global errNumber

    set tag "body CustomHdr::config [info script]"
Deputs "----- TAG: $tag -----"

# param collection
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -pattern  {
				set pattern $value
		  }
	   }
    }
Deputs Step10
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "custom" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol custom
	if { [ info exists pattern ] } {
		if { [ string first 0x $pattern  ] >= 0 } {
			string replace $pattern 0 1
		}
	   set pduLen [expr [string length $pattern] * 4]
	   AddField length
	   AddFieldMode Fixed
	   AddFieldConfig $pduLen
	   AddField data
	   AddFieldMode Fixed
	   AddFieldConfig $pattern
	}
}
body TrillHdr::config { args } {

    global errorInfo
    global errNumber


    set tag "body TrillHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    
    set EType [ list Fixed Random Incrementing Decrementing ]
# param collection        
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -version {
				set version $value
		  }
		  -reserved {
			 set reserved $value
		  }
		  -mcast_flag {
				set mcast_flag $value 
		  }            
			-op_length {
				set op_length $value
		  }
		  -hop_count {
			 set hop_count $value
		  }
		  -eg_nickname {
				if { [ string first "0x" $value ] < 0 } {
					set eg_nickname 0x$value
				} else {
					set eg_nickname $value 
				}
		  }            
			-eg_nickname_num {
				set eg_nickname_num $value
				set egVarMode Incrementing
		  }
		  -eg_nickname_step {
			 set eg_nickname_step $value
				set egVarMode Incrementing
		  }
		  -eg_nickname_mod {
				set eg_nickname_mod $value 
				set egVarMode Incrementing
		  }            
			-ing_nickname {
				if { [ string first "0x" $value ] < 0 } {
					set ing_nickname 0x$value
				} else {
					set ing_nickname $value				
				}
			}
		  -ing_nickname_num {
			 set ing_nickname_num $value
				set ingVarMode Incrementing
		  }
		  -ing_nickname_step {
				set ing_nickname_step $value 
				set ingVarMode Incrementing
		  }
		  -ing_nickname_mod {
				set ing_nickname_mod $value 
				set ingVarMode Incrementing
		  }
			
		}
    }

Deputs Step10
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "trill" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol Trill
Deputs Step40
    if { [ info exists eg_nickname ] } {
Deputs Step50
	   if { [ info exists egVarMode ] } {
Deputs Step60
		  switch -exact $egVarMode {
			 Fixed {
Deputs Step70
				AddFieldMode $egVarMode
				AddField erbridge
				AddFieldConfig $eg_nickname
				}
			 Decrementing -
			 Incrementing {
					if { [ info exists eg_nickname_num ] == 0 } {
						set eg_nickname_num 1
					}
					if { [ info exists eg_nickname_step ] == 0 } {
						set eg_nickname_step 1
					}
					if { [ info exists eg_nickname_mod ] == 0 } {
						set eg_nickname_mod 16
					}
Deputs "eg_nickname_mod:$eg_nickname_mod"					
					set step [ expr round($eg_nickname_step * pow(2,16 - $eg_nickname_mod)) ]
Deputs "step:$step , 0x[ format %x $step ]"
Deputs "eg_nickname:$eg_nickname , 0x[ format %x $eg_nickname ]"
					AddFieldMode $egVarMode
					AddField erbridge
					AddFieldConfig \
					[ list 0 $eg_nickname $eg_nickname_num 0x[ format %x $step ] ]
				    
			 }
		  }
	   }
    }
    if { [ info exists ing_nickname ] } {
Deputs Step50
	   if { [ info exists ingVarMode ] } {
Deputs Step60
		  switch -exact $ingVarMode {
			 Fixed {
Deputs Step70
				AddFieldMode $ingVarMode
				AddField irbridge
				AddFieldConfig $ing_nickname
				}
			 Decrementing -
			 Incrementing {
					if { [ info exists ing_nickname_num ] == 0 } {
						set ing_nickname_num 1
					}
					if { [ info exists ing_nickname_step ] == 0 } {
						set ing_nickname_step 1
					}
					if { [ info exists ing_nickname_mod ] == 0 } {
						set ing_nickname_mod 16
					}
					set step [ expr round($ing_nickname_step * pow(2,16 - $ing_nickname_mod)) ]
Deputs "step:$step , 0x[ format %x $step ]"
					AddFieldMode $ingVarMode
					AddField irbridge
					AddFieldConfig \
					[ list 0 $ing_nickname $ing_nickname_num 0x[ format %x $step ] ]
				    
			 }
		  }
	   }
    }
    if { [ info exists version ] } {
Deputs Step200
		AddField ver
		AddFieldMode Fixed
		AddFieldConfig $version
    }
    if { [ info exists reserved ] } {
Deputs Step210
		AddField res
		AddFieldMode Fixed
		AddFieldConfig $reserved
    }    
	if { [ info exists mcast_flag ] } {
Deputs Step220
		AddField multdest
		AddFieldMode Fixed
		AddFieldConfig $mcast_flag
    }
	if { [ info exists op_length ] } {
Deputs Step230
		AddField oplen
		AddFieldMode Fixed
		AddFieldConfig $op_length
    }
	if { [ info exists hop_count ] } {
Deputs Step230
		AddField hpcnt
		AddFieldMode Fixed
		AddFieldConfig $hop_count
    }
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}
body GreHdr::config { args } {
    global errorInfo
    global errNumber

    set tag "body GreHdr::config [info script]"
Deputs "----- TAG: $tag -----"
    
    set EType [ list Fixed Random Incrementing Decrementing ]
# param collection        
    foreach { KEY value } $args {
	   set KEY [string tolower $KEY]
	   switch -exact -- $KEY {
		  -version {
			set version $value
		  }
		  -gre_protocol -
		  -protocol {
			set gre_protocol $value
		  }
		  -checksum_present -
		  -csum_bit {
			set checksum_present [ BoolTrans $value ]
		  }            
		  -checksum -
		  -csum {
			set checksum $value
		  }
		  -key_present -
		  -key_bit {
			 set key_present [ BoolTrans $value ]
		  }
		  -key {
			set key $value
		  }            
		  -sn_present -
		  -seq_num_bit {
				set sn_present [ BoolTrans $value ]
		  }
		  -sn -
		  -seq_num {
			 set sn $value
		  }
		}
    }

Deputs Step10
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "gre" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol Gre
Deputs Step40
	if { [ info exists checksum_present ] } {
	   AddField checksumPresent
	   AddFieldMode Fixed
	   AddFieldConfig $checksum_present
    }	
Deputs Step50 
	if { [ info exists key_present ] } {
	   AddField keyPresent
	   AddFieldMode Fixed
	   AddFieldConfig $key_present
    }	
    
Deputs Step60
	if { [ info exists sn_present ] } {
	   AddField sequencePresent
	   AddFieldMode Fixed
	   AddFieldConfig $sn_present
    }	
Deputs Step70    
	if { [ info exists version ] } {
	   AddField version
	   AddFieldMode Fixed
	   AddFieldConfig [ HexValue $version ]
    }	
    
Deputs Step80	
	if { [ info exists gre_protocol ] } {
	   AddField protocol 1 0
	   AddFieldMode Reserved
	   AddFieldConfig 0
	   AddField protocol
	   AddFieldMode Fixed
	   AddFieldConfig [ HexValue $gre_protocol ]
	   
    }	
Deputs Step90    
	if { [ info exists checksum ] } {
		set checksum [ format %i [ HexValue $checksum ] ]
Deputs "checksum:$checksum"
		if { $checksum } {
		   AddField withChecksum.checksum 1
		   AddFieldMode Reserved
		   AddFieldConfig 0
		   AddField withChecksum.checksum
		   AddFieldMode Fixed
		   AddFieldConfig $checksum
	    } else {
		   AddField noChecksum 1
		   AddFieldMode Reserved
		   AddFieldConfig 0
		   AddField noChecksum
		   AddFieldMode Fixed
		   AddFieldConfig 0
		}
    }	
Deputs Step100
	if { [ info exists key ] } {
		set key [ format %i [ HexValue $key ] ]
Deputs "key:$key"
		if { $key } {
		   AddField keyHolder.key 1
		   AddFieldMode Reserved
		   AddFieldConfig 0
		   AddField keyHolder.key
		   AddFieldMode Fixed
		   AddFieldConfig $key
	    } else {
		   AddField noKey 1
		   AddFieldMode Reserved
		   AddFieldConfig 0
		   AddField noKey
		   AddFieldMode Fixed
		   AddFieldConfig 0
		}
    }	
Deputs Step110
	if { [ info exists sn ] } {
Deputs "sn:$sn"
		set sn [ format %i [ HexValue $sn ] ]
Deputs "sn dec:$sn"
		if { $sn } {
		   AddField sequenceHolder.sequenceNum 1
		   AddFieldMode Reserved
		   AddFieldConfig 0
		   AddField sequenceHolder.sequenceNum
		   AddFieldMode Fixed
		   AddFieldConfig $sn
	    } else {
		   AddField noSequenceNum 1
		   AddFieldMode Reserved
		   AddFieldConfig 0
		   AddField noSequenceNum
		   AddFieldMode Fixed
		   AddFieldConfig 0
		}
    }	
    

}

# -- DC Header
class DcbxHdr {
	inherit Header
	constructor {} { chain lldp } {}
	
	method config { args } {}
}
body DcbxHdr::config { args } {

	global errorInfo
	global errNumber
	
	set tag "body DcbxHdr::config[info script]"
Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-tlv_list {
				set tlv_list $value
			}
		}
	}

	# Configure desc_list
	if { [info exists tlv_list] } {

	
		foreach tlv $tlv_list {
			
			if { [ $tlv isa LldpTlv ] == 0 } {
					error "$errNumber(1) key:tlv_list value:$tlv"				
			}
			set tlv_type [ $tlv cget -tlv_type ]
Deputs "tlv_type:$tlv_type"
			switch $tlv_type {
			    ignore {
				    continue
			    }
			    chasid {
				        set chassis_id_type [ $tlv cget -chassis_id_type ]
						set chassis_id [ $tlv cget -chassis_id ]
						
Deputs "chassis_id : $chassis_id"						
			    	    if { $chassis_id != "" && $chassis_id != "<undefined>" } {
						    if { $chassis_id_type != "" && $chassis_id_type != "<undefined>" } {
						
						        AddField header.mandatoryTlv.chassisIdTlv.subtype 1
	                            AddFieldMode Fixed
	                            AddFieldConfig $chassis_id_type
							}
						    set chassis_id [ MacTrans $chassis_id ] 
							 
							set chassis_len [expr [ llength [ List2Str $chassis_id ]/2 ] ]
							
							AddField header.mandatoryTlv.chassisIdTlv.length 1
	                        AddFieldMode Fixed
	                        AddFieldConfig $chassis_len
							    
						    AddField header.mandatoryTlv.chassisIdTlv.chassisId 1
	                        AddFieldMode Fixed
	                        AddFieldConfig $chassis_id
						    
				    }
			    }
			    portid {
				    set port_id [ string tolower [ $tlv cget -port_id ] ]
				    set port_id_type [ string tolower [ $tlv cget -port_id_type ] ]

Deputs "port_id: $port_id"	
					if { $port_id != "" && $port_id != "<undefined>" } {
					    if { $port_id_type != "" && $port_id_type != "<undefined>" } {
Deputs "port_id_type: $port_id_type"
                            AddField header.mandatoryTlv.portIdTlv.subtype 1
	                        AddFieldMode Fixed
	                        AddFieldConfig $port_id_type
						}
					    set port_len [expr [ llength [ List2Str $port_id ]/2 ] ]
						AddField header.mandatoryTlv.portIdTlv.length 1
	                    AddFieldMode Fixed
	                    AddFieldConfig $port_len
					    AddField header.mandatoryTlv.portIdTlv.portId 1
	                    AddFieldMode Fixed
	                    AddFieldConfig $port_id
					}
			    }
			    subtype {
				    set oui [ $tlv cget -oui ]
				    set ouidot [ string range $oui 0 1 ].[ string range $oui 2 3 ].[ string range $oui 4 5 ]
				    set org [ $tlv cget -org ]
				    lappend subTlv [ $tlv cget -val ]
Deputs "oui:$ouidot org:$org"				    
				    
			    }
			    ets -
			    app_pri -
			    pbfc {
		    		   
			    }
		    }
		}
		   
		if { [ llength $subTlv ] == 1 } {
	    	eval set subTlv $subTlv
	    }
		Deputs "subTlv:$subTlv len:[llength $subTlv]"
		
		foreach tlv $subTlv {
Deputs "tlv:$tlv"
		    if { [ $tlv isa DcbxTlv ] == 0 } {
			    error "$errNumber(1) key:tlv_list value:$tlv"					    			    
		    }
		    switch $org {
			    1 {
				    set orgtlv intelDcbxTlvs
				
				}
			    2 {
			    	set orgtlv ieeeDcbxTlvs
			    }
			    3 {
				    set orgtlv dot1qaz
			    }
		    }
		    
#Deputs "dcbxTlv:$dcbxTlv"		    
    		    set tlv_type [ $tlv cget -tlv_type ]
Deputs "tlv_type:$tlv_type"
		    switch $tlv_type {
			    ignore {
				  
				    continue
			    }
			    pg {
				    # AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.header.enable 1
	                # AddFieldMode Fixed
	                # AddFieldConfig 1
				    				    
				    array set bgw_pct_attr [ $tlv getBWG ]
Deputs "bgw_pct_attr:[array names bgw_pct_attr]"					
					array set pg_attr [ $tlv getPG ]
Deputs "pg_attr: [array names pg_attr]"							
				    switch $org {
        				    1 {
						        for { set index 0 } { $index < 8 } { incr index } {
							        if { [ info exists bgw_pct_attr($index) ] } {
                                        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.bwg_alloc_table.bwg_bw$index.bwPer 1
		                                AddFieldMode Reserved
		                                AddFieldConfig 0

                                        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.bwg_alloc_table.bwg_bw$index.bwPer 
	                                    AddFieldMode Fixed
	                                    AddFieldConfig $bgw_pct_attr($index)
								
							        }
Deputs "pg pct:$pg_attr($index,pct)"							    
							        if { [ info exists pg_attr($index,id) ] } {
                                        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgSet$index.id 1
	                                    AddFieldMode Reserved
		                                AddFieldConfig 0
								        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgSet$index.id 
	                                    AddFieldMode Fixed
	                                    AddFieldConfig $pg_attr($index,id)
								    
							        }
							        if { [ info exists pg_attr($index,pri) ] } {
                                        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgSet$index.prio 1
                                        AddFieldMode Reserved
		                                AddFieldConfig 0
								        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgSet$index.prio 
	                                    AddFieldMode Fixed
	                                    AddFieldConfig $pg_attr($index,pri)
								    
							        }
							        if { [ info exists pg_attr($index,pct) ] } {
Deputs "pg pct:$pg_attr($index,pct)"
                                        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgSet$index.bwPer 1
                                        AddFieldMode Reserved
		                                AddFieldConfig 0
                                        AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgSet$index.bwPer 
	                                    AddFieldMode Fixed
	                                    AddFieldConfig $pg_attr($index,pct)
								
							        }
						        }				    
        				    } 
        				    2 {
						        set num_tcs_supported [ $tlv cget -num_tcs_supported ]
        				    	AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityGroupTlv.cfg.numTCsupported 1
                                AddFieldMode Reserved
		                        AddFieldConfig 0
								AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityGroupTlv.cfg.numTCsupported 
	                            AddFieldMode Fixed
	                            AddFieldConfig $num_tcs_supported
	                           
								set pgId [ list ]
						        for { set index 0 } { $index < 8 } { incr index } {
							        if { [ info exists pg_attr($index,id) ] } {
                                        AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgid$index 1
								        AddFieldMode Reserved
		                                AddFieldConfig 0
									    AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityGroupTlv.cfg.up_alloc_table.pgid$index 
	                                    AddFieldMode Fixed
	                                    AddFieldConfig $pg_attr($index,id)
							        }
								
								    if { [ info exists bgw_pct_attr($index) ] } {
                                        AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityGroupTlv.cfg.pg_alloc_table.bwPer$index 1
								        AddFieldMode Reserved
		                                AddFieldConfig 0
									    AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityGroupTlv.cfg.pg_alloc_table.bwPer$index 
	                                    AddFieldMode Fixed
	                                    AddFieldConfig $bgw_pct_attr($index)
							        }
						        }			

					        }
				    } 				    
				    
			    }
			    pfc {
				    array set pe_attr [ $tlv getPE ]
				    switch $org {
					    1 {
						    for { set index 0 } { $index < 8 } { incr index } {
							    if { [ info exists pe_attr($index) ] } {
                                    AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityFlowTlv.cfg.adminMap.pe$index 1
								    AddFieldMode Reserved
		                            AddFieldConfig 0 
									AddField header.organizationalTlvs.tlvs.intelDcbxTlvs.protocolTlv.optionalIntelDcbxTlvs.subtlvs.priorityFlowTlv.cfg.adminMap.pe$index 
	                                AddFieldMode Fixed
	                                AddFieldConfig $pe_attr($index)
							    }	
						    }  
					    }
					    2 {  
						    set num_tcs_supported [ $tlv cget -num_tcs_supported ]
                                AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityFlowTlv.cfg.numTcpfcsSupp 1
                                AddFieldMode Reserved
		                        AddFieldConfig 0 
							    AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityFlowTlv.cfg.numTcpfcsSupp 
	                            AddFieldMode Fixed
	                            AddFieldConfig $num_tcs_supported

                            for { set index 0 } { $index < 8 } { incr index } {
							    if { [ info exists pe_attr($index) ] } {
                                    AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityFlowTlv.cfg.prioMap.pe$index 1
								    AddFieldMode Reserved
		                            AddFieldConfig 0  
									AddField header.organizationalTlvs.tlvs.ieeeDcbxTlvs.protocolTlv.optionalIeeeDcbxTlvs.subtlvs.priorityFlowTlv.cfg.prioMap.pe$index 
	                                AddFieldMode Fixed
	                                AddFieldConfig $pe_attr($index)
							    }	
						    }							
					    }
				    }
			    }
			    custom {
				  
			    }
			    app {
				    
				}
			    app_pri {
				   
			    }
			    ets {
				   
			    }
			    pbfc {
				   
			    }
		    }    
	    }
	}
}

class DescHdr {
	inherit Header
	constructor { hdr } { chain $hdr } {}
	
	method config { args } {}
}
body DescHdr::config { args } {

	global errorInfo
	global errNumber
	
	set tag "body DescHdr::config[info script]"
Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-desc_list {
				set desc $value
			}
		}
	}

	# Configure desc_list
	if { [info exists desc] } {

	
		foreach descObj $desc {
			
			if { [ $descObj isa FipDesc ] == 0 } {
					error "$errNumber(1) key:desc_list value:$descObj"				
			}

			set descType [ $descObj cget -type ]
			set descLen [ $descObj cget -len ]
			array set descVal [ $descObj getValue ]
			
			if { [ $descObj isa FipDescPriority ] } {
			
				if { $descType != "auto" } {
				
					AddField priorityDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField priorityDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField priorityDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField priorityDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(priority) ] } {
				
					AddField priorityDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField priorityDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(priority)				
					
				}

			}
			
			if { [ $descObj isa FipDescMacAddr ] } {
			
				if { $descType != "auto" } {
				
					AddField macAddressDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField macAddressDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField macAddressDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField macAddressDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(mac_addr) ] } {
				
					AddField macAddressDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField macAddressDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(mac_addr)				
					
				}

			}
			
			if { [ $descObj isa FipDescFcMap ] } {
			
				if { $descType != "auto" } {
				
					AddField fcMapDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField fcMapDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField fcMapDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fcMapDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(fc_map) ] } {
				
					AddField fcMapDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fcMapDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(fc_map)				
					
				}

			}
			
			if { [ $descObj isa FipDescNameId ] } {
			
				if { $descType != "auto" } {
				
					AddField nameIdentifierDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField nameIdentifierDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField nameIdentifierDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField nameIdentifierDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(name_id) ] } {
				
					AddField nameIdentifierDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField nameIdentifierDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(name_id)				
					
				}

			}
			
		    if { [ $descObj isa FipDescFabricName ] } {
			
				if { $descType != "auto" } {
				
					AddField fabricDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField fabricDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField fabricDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fabricDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(vf_id) ] } {
				
					AddField fabricDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fabricDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(vf_id)				
					
				}
				
				if { [ info exists descVal(fc_map) ] } {
				
					AddField fabricDescriptor.fcMap 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fabricDescriptor.fcMap
					AddFieldMode Fixed
					AddFieldConfig $descVal(fc_map)				
					
				}

			}
			
			if { [ $descObj isa FipDescMaxRcvSize ] } {
			
				if { $descType != "auto" } {
				
					AddField maxFcoeSizeDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField maxFcoeSizeDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField maxFcoeSizeDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField maxFcoeSizeDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(max_rcv_size) ] } {
				
					AddField maxFcoeSizeDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField maxFcoeSizeDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(max_rcv_size)				
					
				}

			}
			if { [ $descObj isa FipDescVxPortId ] } {
			
				if { $descType != "auto" } {
				
					AddField vxPortIdentificationDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField vxPortIdentificationDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField vxPortIdentificationDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vxPortIdentificationDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(mac_addr) ] } {
				
					AddField vxPortIdentificationDescriptor.macAddress 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vxPortIdentificationDescriptor.macAddress
					AddFieldMode Fixed
					AddFieldConfig $descVal(mac_addr)				
					
				}
				
				if { [ info exists descVal(addr_id) ] } {
				
					AddField vxPortIdentificationDescriptor.identifier 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vxPortIdentificationDescriptor.identifier
					AddFieldMode Fixed
					AddFieldConfig $descVal(addr_id)				
					
				}
				
				if { [ info exists descVal(port_name) ] } {
				
					AddField vxPortIdentificationDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vxPortIdentificationDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(port_name)				
					
				}

			}
			
			if { [ $descObj isa FipDescFkaAdvPeriod ] } {
			
				if { $descType != "auto" } {
				
					AddField fkaADVPeriodDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField fkaADVPeriodDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField fkaADVPeriodDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fkaADVPeriodDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(fka_adv_period) ] } {
				
					AddField fkaADVPeriodDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField fkaADVPeriodDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(fka_adv_period)				
					
				}
			}
			
			if { [ $descObj isa FipDescVendorId ] } {
			
				if { $descType != "auto" } {
				
					AddField vendorIDDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField vendorIDDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField vendorIDDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vendorIDDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(vendor_id) ] } {
				
					AddField vendorIDDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vendorIDDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(vendor_id)				
					
				}
			}
			
			if { [ $descObj isa FipDescVlan ] } {
			
				if { $descType != "auto" } {
				
					AddField vlanDescriptor.type 1
					AddFieldMode Reserved
					AddFieldConfig 0    
					
					AddField vlanDescriptor.type
					AddFieldMode Fixed
					AddFieldConfig $descType					
				}
				
				if { $descLen != "auto" } {
				
					AddField vlanDescriptor.length 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vlanDescriptor.length
					AddFieldMode Fixed
					AddFieldConfig $descLen					
				}
				
				if { [ info exists descVal(vlan_id) ] } {
				
					AddField vlanDescriptor.value 1
					AddFieldMode Reserved
					AddFieldConfig 0 
					
					AddField vlanDescriptor.value
					AddFieldMode Fixed
					AddFieldConfig $descVal(vlan_id)				
					
				}
			}
			
			
			
			if { [ $descObj isa FipDescFlogi ] } {
				set descFacType [ $descObj cget -descType ]
				switch -exact $descType {
					request {
					}
					accept {
					}
					reject {
					}
				}
			}
			
			
			#######
		}
	}
	
	

}

class FcoeHdr {
    inherit DescHdr
    constructor {} { chain FCoE } {}
    
    method config { args } {}
}
body FcoeHdr::config { args } {
	global errorInfo
	global errNumber
	
	set Esof [list sofi3 sofi2 sofi4 sofn2 \
	sofn3 sofn4 soff sofc4]
	
	set tag "body FcoeHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0
	set sof SOFi3
	
	
	foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-version {
					set trans [ UnitTrans $value ]				
					if { [ string is integer $trans] && $trans < 16 } {
						set version $trans
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}			
				-sof {
					if { [ string is integer $value ] && $value < 256 } {
						set sof $value
					} elseif { [ catch { format %x $value } ] == 0 } {
						Deputs "sof: $value"
						set sof [format %i $value]
					} else {
						set index [lsearch -exact $Esof [ string tolower $value ] ]
						if { $index < 0 } {
							error "errNumber(1) key:$key value:$value"
						} else {
							set value [string tolower $value]
							switch $value {							
								sofi3 {set sof 46}
								sofi2 {set sof 45}
								sofi4 {set sof 41}
								sofn2 {set sof 53}
								sofn3 {set sof 54}
								sofn4 {set sof 49}
								soff  {set sof 40}
								sofc4 {set sof 57}
							}
						}
					}
				}
			}
		}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fcoe"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fcoe
	
	# Configure version
	if { [ info exists version ] } {
		AddField version
		AddFieldMode Fixed
		AddFieldConfig $version
	}
	
	# Configure E-SOF
	if { [ info exists sof ] } {
		
		   AddField eSOF
		   AddFieldMode Fixed
		   AddFieldConfig $sof
	    }
	
	if { [ IsValid ] } {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FcHdr {
    inherit DescHdr
    constructor {} { chain FC MOD } {}
    
    method config { args } {}
}
body FcHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FcHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set r_ctl 22
	set cs_ctl 00
	set fc_type 01
	set seq_id 00
	set df_control 00
	set seq_cnt 0000
	set ox_id 0000
	set rx_id ffff
	set para 00000000
	set dst_id 00.00.00
	set src_id 00.00.00
	set fc_exg_rpd 0
	set f_ctl_seq_rec 0
	set f_ctl_exg_fst 1
	set f_ctl_exg_lst 1
	set f_ctl_cs_ctl 0
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-r_ctl {
				set trans [ IsHex $value ]
				if { $trans == 1 } {
					set r_ctl [ format %i "0x$value" ]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}	
			}
			-cs_ctl {
				set trans [ IsHex $value ]
				if { $trans == 1 } {
				    set cs_ctl "0x$value"
				} else {
				    error "$errNumber(1) key:$key value:$value"
				}		
			}
			-type {
				set trans [ IsHex $value ]
				if { $trans == 1 } {
					set fc_type "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}	
			}
			-seq_id {
				set trans [ IsHex $value ]
				if { $trans == 1 } {
					set seq_id "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-data_field_control {
				set trans [ IsHex $value ]
				set intg [ format %i "0x$value" ]
				if { $trans == 1 && $intg < 256 } {
					set df_control "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-seq_cnt {
				set trans [ IsHex $value ]
				set intg [ format %i "0x$value" ]
				if { $trans == 1 && $intg <= 65535 } {
					set seq_cnt "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-originator_exchanger_id {
				set trans [ IsHex $value ]
				set intg [ format %i "0x$value" ]
				if { $trans == 1 && $intg <= 65535 } {
					set ox_id "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-response_exchanger_id {
				set trans [ IsHex $value ]
				set intg [ format %i "0x$value" ]
				if { $trans == 1 && $intg <= 65535 } {
					set rx_id "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-offset {
				set trans [ IsHex $value ]
				set intg [ format %i "0x$value" ]
				if { $trans == 1 } {
					set para "0x$value"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-dst_id {
				if { [string match -nocase "??.??.??" $value] == 1 
					&& [string length $value ] == 8 } {
						set dst_id "$value"
					} elseif { [IsHex $value] == 1 
						&& [string length $value ] == 6} { 
							set fst [string range $value 0 1]
							set scd [string range $value 2 3]
							set thd [string range $value 4 5]
							set dst_id "$fst.$scd.$thd"
						} else {
							error "$errNumber(1) key:$key value:$value"
						}			
			}
			-src_id {
				if { [string match -nocase "??.??.??" $value] == 1 
					&& [string length $value ] == 8 } {
						set src_id "$value"
					} elseif { [IsHex $value] == 1 
						&& [string length $value ] == 6} { 
							set fst [string range $value 0 1]
							set scd [string range $value 2 3]
							set thd [string range $value 4 5]
							set src_id "$fst.$scd.$thd"
						} else {
							error "$errNumber(1) key:$key value:$value"
						}			
			}
			-frame_control {
				if {[IsHex $value] == 1} {
					set f_ctl [HexValue $value]
				} elseif {[IsInt $value] == 0} {
					set f_ctl [HexValue [format %x $value]]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fc_exg_rpd {
				set trans [ BoolTrans $value ]
				# Originator 0, Receipient 1
				if { $trans == 1 || $trans == 0 } {
				    set fc_exg_rpd $trans
				} else {
				    error "$errNumber(1) key:$key value:$value"
				}
			}
			-f_ctl_seq_rec {
				set trans [ BoolTrans $value ]
				# Initiator 0, Receipient 1
				if { $trans == 1 || $trans == 0 } {
					set f_ctl_seq_rec $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f_ctl_exg_fst {
				set trans [ BoolTrans $value ]
				# Other 0, First 1
				if { $trans == 1 || $trans == 0 } {
					set f_ctl_exg_fst $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f_ctl_exg_lst {
				set trans [ BoolTrans $value ]
				# Other 0, Last 1
				if { $trans == 1 || $trans == 0 } {
					set f_ctl_exg_lst $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f_ctl_cs_ctl {
				set trans [ BoolTrans $value ]
				# CS_CTL 0, Priority 1
				if { $trans == 1 || $trans == 0 } {
					set f_ctl_cs_ctl $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
		}
	}
	
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fc"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fc 
	
	# Configure r_ctl
	if { [ info exists r_ctl ] } {
		AddField deviceDataInfo
		AddFieldMode Fixed
		AddFieldConfig $r_ctl
	}
	
	# Configure cs_ctl
	if { [ info exists cs_ctl ] } {
		AddField csCTLPriority
		AddFieldMode Fixed
		AddFieldConfig $cs_ctl
	}
	
	# Configure type
	if { [ info exists fc_type ] } {
		AddField fcHeader.type
		AddFieldMode Fixed
		AddFieldConfig $fc_type
	}
	
	# Configure seq_id
	if { [info exists seq_id ] } {
		AddField seqID
		AddFieldMode Fixed
		AddFieldConfig $seq_id
	}
	# Configure data_field_control
	if { [info exists df_control ] } {
		AddField dfCTL
		AddFieldMode Fixed
		AddFieldConfig $df_control
	}
	
	# Configure seq_cnt
	if { [info exists seq_cnt ] } {
		AddField seqCNT
		AddFieldMode Fixed
		AddFieldConfig $seq_cnt
	}
	
	# Configure originator_exchanger_id
	if { [info exists ox_id ] } {
		AddField fcHeader.oxID
		AddFieldMode Fixed
		AddFieldConfig $ox_id
	}
	
	# Configure response_exchanger_id
	if { [info exists rx_id ] } {
		AddField fcHeader.rxID
		AddFieldMode Fixed
		AddFieldConfig $rx_id
	}
	
	# Configure offset
	if { [info exists para ] } {
		AddField fcHeader.parameter
		AddFieldMode Fixed
		AddFieldConfig $para
	}
	
	# Configure dst_id
	if { [info exists dst_id ] } {
		AddField fcHeader.dstId
		AddFieldMode Fixed
		AddFieldConfig $dst_id
	}
	
	# Configure src_id
	if { [info exists src_id ] } {
		AddField fcHeader.srcId
		AddFieldMode Fixed
		AddFieldConfig $src_id
	}
	
	# Configure fc_exg_rpd
	if {[info exists f_ctl]} {
		AddField custom 1
		AddFieldMode Reserved
		AddFieldConfig 0 
		AddField custom
		AddFieldMode Fixed
		AddFieldConfig $f_ctl		
	} 
	
	if {[info exists fc_exg_rpd]} {
		AddField exchangeContext 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField exchangeContext
		AddFieldMode Fixed
		AddFieldConfig $fc_exg_rpd
	}
		
	# Configure f_ctl_seq_rec
	if { [info exists f_ctl_seq_rec ] } {
		AddField sequenceContext 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField sequenceContext
		AddFieldMode Fixed
		AddFieldConfig $f_ctl_seq_rec
	}
		
	# Configure f_ctl_exg_fst
	if { [info exists f_ctl_exg_fst ] } {
		AddField firstSequence 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField firstSequence
		AddFieldMode Fixed
		AddFieldConfig $f_ctl_exg_fst
	}
		
	# Configure f_ctl_exg_lst
	if { [info exists f_ctl_exg_lst ] } {
		AddField lastSequence 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField lastSequence
		AddFieldMode Fixed
		AddFieldConfig $f_ctl_exg_lst
	}
		
	# Configure f_ctl_cs_ctl
	if { [info exists f_ctl_cs_ctl ] } {
		AddField csCTLPriority 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField csCTLPriority
		AddFieldMode Fixed
		AddFieldConfig $f_ctl_cs_ctl
	}
	
	if { [ IsValid ] } {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FcPlogiRjtHdr {
    inherit DescHdr
    constructor {} { chain fcPlogiLsRjt } {}
    method config { args } {}
}
body FcPlogiRjtHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FcPlogiRjtHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set cmd_code 0x01
	set r_code 0xee
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-cmd_code {
				set trans [IsHex $value]
				if {$trans == 1 && [format %i [HexValue $value]] < 256} {
					set cmd_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-reason_code {
				set trans [IsHex $value]
				if {$trans == 1} {
					set r_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
		}
	}
	
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fcplogilsrjt"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fcplogilsrjt 
	
	# Configure cmd_code
	if { [info exists cmd_code ] } {
		AddField FcElsCommandCodeLsRjt 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField FcElsCommandCodeLsRjt
		AddFieldMode Fixed
		AddFieldConfig $cmd_code
	}
	
	# Configure Reason_code
	if { [info exists r_code ] } {
		AddField FcElsLsRjtReasonCodes
		AddFieldMode Fixed
		AddFieldConfig $r_code
	}
	
	if { [ IsValid ] } {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FcPlogiRequestHdr {
    inherit DescHdr
    constructor {} { chain FcPlogiRequest } {}
    
    method config { args } {}
}
body FcPlogiRequestHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FcPlogiRequestHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set els_code 03
	set fc_ph_version 2020
	set bb_credit 1
	set common_features 0000
	set bb_sc_n 0
	set bb_rcv_data_size 0
	set e_d_tov 0
	set port_name 0000000000000000
	set node_fabic_name 0000000000000000
	set class3_s_o 0000
	set class3_i_c 0000
	set class3_r_c 0000
	set class3_r_d_s 0
	set class3_t_c_s 0
	set class3_npec 0
	set class3_ospe 0
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-els_cmd_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set els_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fc_ph_version {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fc_ph_version [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-bb_credit {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set bb_credit $value
				} elseif {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set bb_credit [format %i "0x$value"]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-common_features {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set common_features [HexValue $value]
				} elseif {[IsInt $value] == 1 && $value <= 65535} {
					set cf [format %x $value]
					set common_features "0x$cf"
				}  else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-bb_sc_n {
				if {[IsInt $value] == 1 && $value <= 15} {
					set bb_sc_n $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-bb_rcv_data_size {
				if {[IsInt $value] == 1 && $value <= 4095} {
					set bb_rcv_data_size $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-e_d_tov {
				if {[IsInt $value] == 1} {
					set edt [format %x $value]
					set e_d_tov "0x$edt"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-port_name {
				if { [ IsHex $value ] == 1 } {
					set port_name [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-node_fabic_name {
				if { [ IsHex $value ] == 1 } {
					set node_fabic_name [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_service_option {
				if { [ IsHex $value ] == 1 } {			
					set class3_s_o [HexValue $value]					
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_initiator_control {
				if { [ IsHex $value ] == 1 } {			
					set class3_i_c [HexValue $value]					
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_recipient_control {
				if { [ IsHex $value ] == 1 } {			
					set class3_r_c [HexValue $value]					
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_rcv_data_size {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set class3_r_d_s $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-class_3_total_con_seq {
				set tcs_value [format %i [HexValue $value]]
				if {[IsHex $value] == 1 && $tcs_value <= 65535} {
					set class3_t_c_s $tcs_value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-class_3_nx_port_e2e_credit {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set class3_npec $value
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}
			}
			-class_3_open_seq_per_exchange {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set class3_ospe $value
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}
			}
		}
	}
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fcplogirequest"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fcPlogiRequest 
	
	# Configure els_cmd_code
	if { [ info exists els_code ] } {
		AddField FcElsCommandCodePlogi
		AddFieldMode Fixed
		AddFieldConfig $els_code
	}
	
	# Configure fc_ph_version
	if { [ info exists fc_ph_version ] } {
		AddField FcElsCommonServiceParametersFc-phVersion
		AddFieldMode Fixed
		AddFieldConfig $fc_ph_version
	}
	
	# Configure bb_credit
	if { [ info exists bb_credit ] } {
		AddField FcElsCommonServiceParametersBuffer-to-bufferCredit
		AddFieldMode Fixed
		AddFieldConfig $bb_credit
	}
	
	# Configure common_features
	if { [ info exists common_features ] } {
		AddField FcElsCommonServiceParametersCommonFeatures
		AddFieldMode Fixed
		AddFieldConfig $common_features
	}
	
	# Configure bb_sc_n
	if { [ info exists bb_sc_n ] } {
		AddField FcElsCommonServiceParametersBbScNumber
		AddFieldMode Fixed
		AddFieldConfig $bb_sc_n
	}
	
	# Configure bb_rcv_data_size
	if { [ info exists bb_rcv_data_size ] } {
		AddField FcElsCommonServiceParametersBuffer-to-bufferReceiveDataFieldSize
		AddFieldMode Fixed
		AddFieldConfig $bb_rcv_data_size
	}
	
	# Configure e_d_tov
	if { [ info exists e_d_tov ] } {
		AddField FcElsCommonServiceParametersEDTov
		AddFieldMode Fixed
		AddFieldConfig $e_d_tov
	}
	
	# Configure port_name
	if { [ info exists port_name ] } {
		AddField FcElsCommonServiceParametersNPortPortName
		AddFieldMode Fixed
		AddFieldConfig $port_name
	}
	
	# Configure node_fabic_name
	if { [ info exists node_fabic_name ] } {
		AddField FcElsCommonServiceParametersFabricNodeName
		AddFieldMode Fixed
		AddFieldConfig $node_fabic_name
	}
	
	# Configure class_3_service_option
	if { [ info exists class3_s_o ] } {
		AddField FcElsClass3SvcParametersServiceOptions
		AddFieldMode Fixed
		AddFieldConfig $class3_s_o
	}
	
	# Configure class_3_initiator_control
	if { [ info exists class3_i_c ] } {
		AddField FcElsClass3SvcParametersInitiatorControl
		AddFieldMode Fixed
		AddFieldConfig $class3_i_c
	}
	
	# Configure class_3_recipient_control
	if { [ info exists class3_r_c ] } {
		AddField FcElsClass3SvcParametersRecipientControl
		AddFieldMode Fixed
		AddFieldConfig $class3_r_c
	}
	
	# Configure class_3_rcv_data_size
	if { [ info exists class3_r_d_s ] } {
		AddField FcElsClass3SvcParametersClassReceiveSize
		AddFieldMode Fixed
		AddFieldConfig $class3_r_d_s
	}
	
	# Configure class_3_total_con_seq
	if { [ info exists class3_t_c_s ] } {
		AddField FcElsClass3SvcParametersTotalConcurrentSequence
		AddFieldMode Fixed
		AddFieldConfig $class3_t_c_s
	}
	
	# Configure class_3_nx_port_e2e_credit
	if { [ info exists class3_npec ] } {
		AddField FcElsClass3SvcParametersEnd-to-endCredit
		AddFieldMode Fixed
		AddFieldConfig $class3_npec
	}
	
	# Configure class_3_open_seq_per_exchange
	if { [ info exists class3_ospe ] } {
		AddField FcElsClass3SvcParametersOpenSeqPerExchange
		AddFieldMode Fixed
		AddFieldConfig $class3_ospe
	}
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FcPlogiAccHdr {
    inherit DescHdr
    constructor {} { chain FcPlogiLsAcc } {}
    
    method config { args } {}
}
body FcPlogiAccHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FcPlogiAccHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set els_code 02
	set fc_ph_version 2020
	set bb_credit 1
	set common_features 0000
	set bb_sc_n 0
	set bb_rcv_data_size 0
	set e_d_tov 0
	set port_name 0000000000000000
	set node_fabic_name 0000000000000000
	set class3_s_o 0000
	set class3_i_c 0000
	set class3_r_c 0000
	set class3_r_d_s 0
	set class3_t_c_s 0
	set class3_npec 0
	set class3_ospe 0
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-els_cmd_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set els_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			} 
			-fc_ph_version {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fc_ph_version [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-bb_credit {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set bb_credit $value
				} elseif {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set bb_credit [format %i "0x$value"]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-common_features {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set common_features [HexValue $value]
				} elseif {[IsInt $value] == 1 && $value <= 65535} {
					set cf [format %x $value]
					set common_features "0x$cf"
				}  else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-bb_sc_n {
				if {[IsInt $value] == 1 && $value <= 15} {
					set bb_sc_n $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-bb_rcv_data_size {
				if {[IsInt $value] == 1 && $value <= 4095} {
					set bb_rcv_data_size $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-e_d_tov {
				if {[IsInt $value] == 1} {
					set edt [format %x $value]
					set e_d_tov "0x$edt"
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-port_name {
				if { [ IsHex $value ] == 1 } {
					set port_name [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-node_fabic_name {
				if { [ IsHex $value ] == 1 } {
					set node_fabic_name [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_service_option {
				if { [ IsHex $value ] == 1 } {			
					set class3_s_o [HexValue $value]					
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_initiator_control {
				if { [ IsHex $value ] == 1 } {			
					set class3_i_c [HexValue $value]					
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_recipient_control {
				if { [ IsHex $value ] == 1 } {			
					set class3_r_c [HexValue $value]					
				} else {
					error "$errNumber(1) key:$key value:$value"
				}		
			}
			-class_3_rcv_data_size {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set class3_r_d_s $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-class_3_total_con_seq {
				set tcs_value [format %i [HexValue $value]]
				if {[IsHex $value] == 1 && $tcs_value <= 65535} {
					set class3_t_c_s $tcs_value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-class_3_nx_port_e2e_credit {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set class3_npec $value
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}
			}
			-class_3_open_seq_per_exchange {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set class3_ospe $value
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}
			}
		}
	}
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fcplogilsacc"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fcPlogiLsAcc 
	
	# Configure els_cmd_code
	if { [ info exists els_code ] } {
		AddField FcElsCommandCodeLsAcc
		AddFieldMode Fixed
		AddFieldConfig $els_code
	}
	
	# Configure fc_ph_version
	if { [ info exists fc_ph_version ] } {
		AddField FcElsCommonServiceParametersFc-phVersion
		AddFieldMode Fixed
		AddFieldConfig $fc_ph_version
	}
	
	# Configure bb_credit
	if { [ info exists bb_credit ] } {
		AddField FcElsCommonServiceParametersBuffer-to-bufferCredit
		AddFieldMode Fixed
		AddFieldConfig $bb_credit
	}
	
	# Configure common_features
	if { [ info exists common_features ] } {
		AddField FcElsCommonServiceParametersCommonFeatures
		AddFieldMode Fixed
		AddFieldConfig $common_features
	}
	
	# Configure bb_sc_n
	if { [ info exists bb_sc_n ] } {
		AddField FcElsCommonServiceParametersBbScNumber
		AddFieldMode Fixed
		AddFieldConfig $bb_sc_n
	}
	
	# Configure bb_rcv_data_size
	if { [ info exists bb_rcv_data_size ] } {
		AddField FcElsCommonServiceParametersBuffer-to-bufferReceiveDataFieldSize
		AddFieldMode Fixed
		AddFieldConfig $bb_rcv_data_size
	}
	
	# Configure e_d_tov
	if { [ info exists e_d_tov ] } {
		AddField FcElsCommonServiceParametersEDTov
		AddFieldMode Fixed
		AddFieldConfig $e_d_tov
	}
	
	# Configure port_name
	if { [ info exists port_name ] } {
		AddField FcElsCommonServiceParametersNPortPortName
		AddFieldMode Fixed
		AddFieldConfig $port_name
	}
	
	# Configure node_fabic_name
	if { [ info exists node_fabic_name ] } {
		AddField FcElsCommonServiceParametersFabricNodeName
		AddFieldMode Fixed
		AddFieldConfig $node_fabic_name
	}
	
	# Configure class_3_service_option
	if { [ info exists class3_s_o ] } {
		AddField FcElsClass3SvcParametersServiceOptions
		AddFieldMode Fixed
		AddFieldConfig $class3_s_o
	}
	
	# Configure class_3_initiator_control
	if { [ info exists class3_i_c ] } {
		AddField FcElsClass3SvcParametersInitiatorControl
		AddFieldMode Fixed
		AddFieldConfig $class3_i_c
	}
	
	# Configure class_3_recipient_control
	if { [ info exists class3_r_c ] } {
		AddField FcElsClass3SvcParametersRecipientControl
		AddFieldMode Fixed
		AddFieldConfig $class3_r_c
	}
	
	# Configure class_3_rcv_data_size
	if { [ info exists class3_r_d_s ] } {
		AddField FcElsClass3SvcParametersClassReceiveSize
		AddFieldMode Fixed
		AddFieldConfig $class3_r_d_s
	}
	
	# Configure class_3_total_con_seq
	if { [ info exists class3_t_c_s ] } {
		AddField FcElsClass3SvcParametersTotalConcurrentSequence
		AddFieldMode Fixed
		AddFieldConfig $class3_t_c_s
	}
	
	# Configure class_3_nx_port_e2e_credit
	if { [ info exists class3_npec ] } {
		AddField FcElsClass3SvcParametersEnd-to-endCredit
		AddFieldMode Fixed
		AddFieldConfig $class3_npec
	}
	
	# Configure class_3_open_seq_per_exchange
	if { [ info exists class3_ospe ] } {
		AddField FcElsClass3SvcParametersOpenSeqPerExchange
		AddFieldMode Fixed
		AddFieldConfig $class3_ospe
	}
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipHdr {
    inherit DescHdr
    constructor {} { chain Fip } {}
    
    method config { args } {}
}
body FipHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0001
	set fip_sub_code 00
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	
	
	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fip"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fip 
	
	# Configure version
	if { [ info exists version ] } {
		AddField version
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField discovery 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField discovery
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField subcodeCustom 1
		AddFieldMode Reserved
		AddFieldConfig 0
		AddField subcodeCustom
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField descriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFP
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSP
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField aBit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField sBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipFabricLogoAccHdr {
    inherit DescHdr
    constructor {} { chain fipFabricLogoLsAccFcf } {}
    
    method config { args } {}
}
body FipFabricLogoAccHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipFabricLogoAccHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipfabriclogolsaccfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipfabriclogolsaccfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFP
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSP
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure desc_list
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipFabricLogoRjtHdr {
    inherit DescHdr
    constructor {} { chain fipFabricLogoLsRjtFcf } {}
    
    method config { args } {}
}
body FipFabricLogoRjtHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipFabricLogoRjtHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipfabriclogolsrjtfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipfabriclogolsrjtfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFP
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSP
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipFlogiReqHdr {
    inherit DescHdr
    constructor {} { chain fipFlogiRequestEnode } {}
    
    method config { args } {}
}
body FipFlogiReqHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipFlogiReqHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 01
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipflogirequestenode"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipflogirequestenode 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode01h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFP
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSP
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipFlogiAccHdr {
    inherit DescHdr
    constructor {} { chain fipFlogiLsAccFcf } {}
    
    method config { args } {}
}
body FipFlogiAccHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipFlogiAccHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipflogilsaccfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipflogilsaccfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFP
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSP
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipFlogiRjtHdr {
    inherit DescHdr
    constructor {} { chain fipFlogiLsRjtFcf } {}
    
    method config { args } {}
}
body FipFlogiRjtHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipFlogiRjtHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipflogilsrjtfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipflogilsrjtfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFP
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSP
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipKeepAliveHdr {
    inherit DescHdr
    constructor {} { chain fipKeepAliveEnode } {}
    
    method config { args } {}
}
body FipKeepAliveHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipKeepAliveHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0003
	set fip_sub_code 01
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipkeepaliveenode"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipkeepaliveenode 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipKeepaliveVirtualLink
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode01h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFp
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSp
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipNpivFdiscAccHdr {
    inherit DescHdr
    constructor {} { chain fipNpivFdicsLsAccFcf } {}
    
    method config { args } {}
}
body FipNpivFdiscAccHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipNpivFdiscAccHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipnpivfdicslsaccfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipnpivfdicslsaccfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFp
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSp
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipNpivFdiscReqHdr {
    inherit DescHdr
    constructor {} { chain fipNpivFdiscRequestEnode } {}
    
    method config { args } {}
}
body FipNpivFdiscReqHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipNpivFdiscReqHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 01
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipnpivfdiscrequestenode"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipnpivfdiscrequestenode 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode01h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFp
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSp
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipNpivFdiscRjtHdr {
    inherit DescHdr
    constructor {} { chain fipNpivFdiscLsRjtFcf } {}
    
    method config { args } {}
}
body FipNpivFdiscRjtHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipNpivFdiscRjtHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0002
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipnpivfdisclsrjtfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipnpivfdisclsrjtfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVirtualLinkInstantiation
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFp
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSp
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipVlanReqHdr {
    inherit DescHdr
    constructor {} { chain fipVlanRequest } {}
    
    method config { args } {}
}
body FipVlanReqHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipVlanReqHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0004
	set fip_sub_code 01
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipvlanrequest"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipvlanrequest 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVlanDiscovery
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode01h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFp
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSp
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}

class FipVlanResHdr {
    inherit DescHdr
    constructor {} { chain fipVlanNotificationFcf } {}
    
    method config { args } {}
}
body FipVlanResHdr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipVlanResHdr::config[info script]"
	Deputs "----- TAG: $tag -------"
	
	set version 0000
	set fip_op_code 0004
	set fip_sub_code 02
	set fp 1
	set sp 0
	set a 0
	set s 0
	set f 0

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-version {
				if {[IsInt $value] == 1 && $value <= 15} {
					set version $value
				} elseif {[IsInt [BinToDec $value]] == 1 && [BinToDec $value] <= 15} {
					set version [BinToDec $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_op_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 65535} {
					set fip_op_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_sub_code {
				if {[IsHex $value] == 1 && [format %i [HexValue $value]] <= 255} {
					set fip_sub_code [HexValue $value]
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fip_desc_list_len {
				if {[IsInt $value] == 1 && $value <= 65535} {
					set fip_dll $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-fp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set fp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-sp {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set sp $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-a {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set a $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-s {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set s $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-f {
				set trans [ BoolTrans $value ]
				# False 0, True 1
				if {$trans == 1 || $trans == 0} {
					set f $trans
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-desc_list {
				set desc $value
			}
		}
	}
		
	set pro [string tolower $protocol]
	Deputs "Pro: $pro"
	if {$pro != "fipvlannotificationfcf"} {
		error "$errNumber(3) key:protocol value:$pro"
	}
	
	# Set protocol
	SetProtocol fipvlannotificationfcf 
	
	# Configure version
	if { [ info exists version ] } {
		AddField fipVersion
		AddFieldMode Fixed
		AddFieldConfig $version
	}
		
	# Configure fip_op_code
	if { [info exists fip_op_code] } {
		AddField fipVlanDiscovery
		AddFieldMode Fixed
		AddFieldConfig $fip_op_code
	}
	
	# Configure fip_sub_code
	if { [info exists fip_sub_code] } {
		AddField fipSubcode02h
		AddFieldMode Fixed
		AddFieldConfig $fip_sub_code
	}
	
	# Configure fip_desc_list_len
	if { [ info exists fip_dll ] } {
		AddField fipDescriptorListLength
		AddFieldMode Fixed
		AddFieldConfig $fip_dll
	}
	
	# Configure fp
	if { [ info exists fp ] } {
		AddField fipFp
		AddFieldMode Fixed
		AddFieldConfig $fp
	}
	
	# Configure sp
	if { [ info exists sp ] } {
		AddField fipSp
		AddFieldMode Fixed
		AddFieldConfig $sp
	}
	
	# Configure a
	if { [ info exists a ] } {
		AddField fipABit
		AddFieldMode Fixed
		AddFieldConfig $a
	}
	
	# Configure s
	if { [ info exists s ] } {
		AddField fipSBit
		AddFieldMode Fixed
		AddFieldConfig $s
	}
	
	# Configure f
	if { [ info exists f ] } {
		AddField fipFBit
		AddFieldMode Fixed
		AddFieldConfig $f
	}
	
	# Configure descriptor
	if { [ info exists desc ] } {
		chain -desc_list $desc
	}
	
	if {[IsValid]} {
		return [ GetStandardReturnHeader ]
	} else {
		return [ GetErrorReturnHeader "PDU is invalid" ]
	}
}


#==============================================
# Descriptor
#==============================================

# FipDesc
class FipDesc {
	inherit NetObject
	
	public variable type
	public variable len
	public variable val

	method getValue {} {
		return [ array get val ]
	}
	method config { args } {}
	constructor {} { 
		set type auto
		set len auto
		array set val [ list ] 
	}
}
body FipDesc::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDesc::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-type {
				set type $value
			}
			-len {
				set len $value
			}
		}
	}
	
}

# FipDescPriority
class FipDescPriority {
	
	inherit FipDesc
	
	method config { args } {}
}
body FipDescPriority::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescPriority::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-priority {
				set val(priority) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}

# FipDescMacAddr
class FipDescMacAddr {

    inherit FipDesc
	
	method config { args } {}
}
body FipDescMacAddr::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescMacAddr::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-mac_addr {
				set val(mac_addr) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}


# FipDescFcMap
class FipDescFcMap {
  
    inherit FipDesc
	
	method config { args } {}
}
body FipDescFcMap::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescFcMap::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_map {
				set val(fc_map) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}

# FipDescNameId
class FipDescNameId {
  
    inherit FipDesc
	
	method config { args } {}
}
body FipDescNameId::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescNameId::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-name_id {
				set val(name_id) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}

# FipDescFabricName
class FipDescFabricName {
    inherit FipDesc
	
	method config { args } {}
}
body FipDescFabricName::config { args } {

	global errorInfo
	global errNumber
	
	set tag "body FipDescFabricName::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-vf_id {
				set val(vf_id) $value 
			}
			-fc_map {
				set val(fc_map) $value 
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}

# FipDescMaxRcvSize
class FipDescMaxRcvSize {
  
    inherit FipDesc
	
	method config { args } {}
}
body FipDescMaxRcvSize::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescMaxRcvSize::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-max_rcv_size {
				set val(max_rcv_size) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}

# FipDescFlogi
class FipDescFlogi {
	inherit FipDesc
	
	public variable type
	public variable len
	public variable val
	
	public variable descType
	
	method config { args } {}
	constructor {} { chain } {}
}
body FipDescFlogi::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescFlogi::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_r_ctl {
				set val(fc_r_ctl) $value
			}
			-fc_dst_id {
				set val(fc_dst_id) $value
			}
			-fc_cs_ctl {
				set val(fc_cs_ctl) $value
			}
			-fc_src_id {
				set val(fc_src_id) $value
			}
			-fc_type {
				set val(fc_type) $value
			}
			-fc_frame_control {
				set val(fc_frame_control) $value
			}
			-fc_seq_id {
				set val(fc_seq_id) $value
			}
			-fc_data_field_control {
				set val(fc_data_field_control) $value
			}
			-fc_seq_cnt {
				set val(fc_seq_cnt) $value
			}
			-fc_originator_exchanger_id {
				set val(fc_originator_exchanger_id) $value
			}
			-fc_response_exchanger_id {
				set val(fc_response_exchanger_id) $value
			}
			-fc_offset {
				set val(fc_offset) $value
			}
			-command_code {
				set val(command_code) $value
			}
		}
	}
		
	eval chain $args
	return [ GetStandardReturnHeader ]

}
class FipDescFlogiRequest {
    inherit FipDescFlogi
	
	constructor {} { chain } {
		set descType request
	}
	
    method config { args } {}
}
body FipDescFlogiRequest::config { args } {
	
	set tag "body FipDescFlogiRequest::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_ph_version_high {
				set val(fc_ph_version_high) $value
			}
			-fc_ph_version_low {
				set val(fc_ph_version_low) $value
			}
			-bb_credit {
				set val(bb_credit) $value
			}
			-common_features {
				set val(common_features) $value
			}
			-rcv_data_size {
				set val(rcv_data_size) $value
			}
			-total_con_seq {
				set val(total_con_seq) $value
			}
			-offset {
				set val(offset) $value
			}
			-e_d_tov {
				set val(e_d_tov) $value
			}
			-n_port_name {
				set val(n_port_name) $value
			}
			-node_name {
				set val(node_name) $value
			}
			-class_1_service_option {
				set val(class_1_service_option) $value
			}
			-class_1_initiator_control {
				set val(class_1_initiator_control) $value
			}
			-class_1_recipient_control {
				set val(class_1_recipient_control) $value
			}
			-class_1_rcv_data_size {
				set val(class_1_rcv_data_size) $value
			}
			-class_1_con_seq {
				set val(class_1_con_seq) $value
			}
			-class_1_e2e_credit {
				set val(class_1_e2e_credit) $value
			}
			-class_1_open_seq_per_exchange{
				set val(class_1_open_seq_per_exchange) $value
			}
			-class_2_service_option {
				set val(class_2_service_option) $value
			}
			-class_2_initiator_control {
				set val(class_2_initiator_control) $value
			}
			-class_2_recipient_control {
				set val(class_2_recipient_control) $value
			}
			-class_2_rcv_data_size {
				set val(class_2_rcv_data_size) $value
			}
			-class_2_con_seq {
				set val(class_2_con_seq) $value
			}
			-class_2_e2e_credit {
				set val(class_2_e2e_credit) $value
			}
			-class_2_open_seq_per_exchange {
				set val(class_2_open_seq_per_exchange) $value
			}
			-class_3_service_option {
				set val(class_3_service_option) $value
			}
			-class_3_initiator_control {
				set val(class_3_initiator_control) $value
			}
			-class_3_recipient_control {
				set val(class_3_recipient_control) $value
			}
			-class_3_rcv_data_size{
				set val(class_3_rcv_data_size) $value
			}
			-class_3_con_seq {
				set val(class_3_con_seq) $value
			}
			-class_3_e2e_credit {
				set val(class_3_e2e_credit) $value
			}
			-class_3_open_seq_per_exchange {
				set val(class_3_open_seq_per_exchange) $value
			}
			-class_4_service_option {
				set val(class_4_service_option) $value
			}
			-class_4_initiator_control {
				set val(class_4_initiator_control) $value
			}
			-class_4_recipient_control {
				set val(class_4_recipient_control) $value
			}
			-class_4_rcv_data_size{
				set val(class_4_rcv_data_size) $value
			}
			-class_4_con_seq {
				set val(class_4_con_seq) $value
			}
			-class_4_e2e_credit {
				set val(class_4_e2e_credit) $value
			}
			-class_4_open_seq_per_exchange {
				set val(class_4_open_seq_per_exchange) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}
class FipDescFlogiAcc {
	inherit FipDescFlogi
	
	constructor {} { chain } {
		set descType accept
	}
	
	method config { args } {}
}

body FipDescFlogiAcc::config { args } {
	
	set tag "body FipDescFlogiAcc::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_ph_version_high {
				set val(fc_ph_version_high) $value
			}
			-fc_ph_version_low {
				set val(fc_ph_version_low) $value
			}
			-bb_credit {
				set val(bb_credit) $value
			}
			-common_features {
				set val(common_features) $value
			}
			-rcv_data_size {
				set val(rcv_data_size) $value
			}
			-total_con_seq {
				set val(total_con_seq) $value
			}
			-offset {
				set val(offset) $value
			}
			-e_d_tov {
				set val(e_d_tov) $value
			}
			-n_port_name {
				set val(n_port_name) $value
			}
			-node_name {
				set val(node_name) $value
			}
			-class_1_service_option {
				set val(class_1_service_option) $value
			}
			-class_1_initiator_control {
				set val(class_1_initiator_control) $value
			}
			-class_1_recipient_control {
				set val(class_1_recipient_control) $value
			}
			-class_1_rcv_data_size {
				set val(class_1_rcv_data_size) $value
			}
			-class_1_con_seq {
				set val(class_1_con_seq) $value
			}
			-class_1_e2e_credit {
				set val(class_1_e2e_credit) $value
			}
			-class_1_open_seq_per_exchange{
				set val(class_1_open_seq_per_exchange) $value
			}
			-class_2_service_option {
				set val(class_2_service_option) $value
			}
			-class_2_initiator_control {
				set val(class_2_initiator_control) $value
			}
			-class_2_recipient_control {
				set val(class_2_recipient_control) $value
			}
			-class_2_rcv_data_size {
				set val(class_2_rcv_data_size) $value
			}
			-class_2_con_seq {
				set val(class_2_con_seq) $value
			}
			-class_2_e2e_credit {
				set val(class_2_e2e_credit) $value
			}
			-class_2_open_seq_per_exchange {
				set val(class_2_open_seq_per_exchange) $value
			}
			-class_3_service_option {
				set val(class_3_service_option) $value
			}
			-class_3_initiator_control {
				set val(class_3_initiator_control) $value
			}
			-class_3_recipient_control {
				set val(class_3_recipient_control) $value
			}
			-class_3_rcv_data_size{
				set val(class_3_rcv_data_size) $value
			}
			-class_3_con_seq {
				set val(class_3_con_seq) $value
			}
			-class_3_e2e_credit {
				set val(class_3_e2e_credit) $value
			}
			-class_3_open_seq_per_exchange {
				set val(class_3_open_seq_per_exchange) $value
			}
			-class_4_service_option {
				set val(class_4_service_option) $value
			}
			-class_4_initiator_control {
				set val(class_4_initiator_control) $value
			}
			-class_4_recipient_control {
				set val(class_4_recipient_control) $value
			}
			-class_4_rcv_data_size{
				set val(class_4_rcv_data_size) $value
			}
			-class_4_con_seq {
				set val(class_4_con_seq) $value
			}
			-class_4_e2e_credit {
				set val(class_4_e2e_credit) $value
			}
			-class_4_open_seq_per_exchange {
				set val(class_4_open_seq_per_exchange) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}

class FipDescFlogiRj {
	inherit FipDescFlogi
	
	constructor {} { chain } {
		set descType reject
	}
	
	method config { args } {}
}
body FipDescFlogiRj::config { args } {
	
	set tag "body FipDescFlogiRj::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-reason_code {
				set val(reason_code) $value
			}
			-explanation_code {
				set val(explanation_code) $value
			}
			-vendor_unique {
				set val(vendor_unique) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}

# FipDescNpivFdisc
class FipDescNpivFdisc {
	inherit FipDesc
	
	public variable type
	public variable len
	public variable val
	
	public variable descType
	
	method config { args } {}
	constructor {} { chain } {}
}
body FipDescNpivFdisc::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescNpivFdisc::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_r_ctl {
				set val(fc_r_ctl) $value
			}
			-fc_dst_id {
				set val(fc_dst_id) $value
			}
			-fc_cs_ctl {
				set val(fc_cs_ctl) $value
			}
			-fc_src_id {
				set val(fc_src_id) $value
			}
			-fc_type {
				set val(fc_type) $value
			}
			-fc_frame_control {
				set val(fc_frame_control) $value
			}
			-fc_seq_id {
				set val(fc_seq_id) $value
			}
			-fc_data_field_control {
				set val(fc_data_field_control) $value
			}
			-fc_seq_cnt {
				set val(fc_seq_cnt) $value
			}
			-fc_originator_exchanger_id {
				set val(fc_originator_exchanger_id) $value
			}
			-fc_response_exchanger_id {
				set val(fc_response_exchanger_id) $value
			}
			-fc_offset {
				set val(fc_offset) $value
			}
			-command_code {
				set val(command_code) $value
			}
		}
	}
		
	eval chain $args
	return [ GetStandardReturnHeader ]

}

class FipDescNpivFdiscRequest {
    inherit FipDescNpivFdisc
	
	constructor {} { chain } {
		set descType request
	}
	
    method config { args } {}
}
body FipDescNpivFdiscRequest::config { args } {
	
	set tag "body FipDescNpivFdiscRequest::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_ph_version_high {
				set val(fc_ph_version_high) $value
			}
			-fc_ph_version_low {
				set val(fc_ph_version_low) $value
			}
			-bb_credit {
				set val(bb_credit) $value
			}
			-common_features {
				set val(common_features) $value
			}
			-rcv_data_size {
				set val(rcv_data_size) $value
			}
			-total_con_seq {
				set val(total_con_seq) $value
			}
			-offset {
				set val(offset) $value
			}
			-e_d_tov {
				set val(e_d_tov) $value
			}
			-n_port_name {
				set val(n_port_name) $value
			}
			-node_name {
				set val(node_name) $value
			}
			-class_1_service_option {
				set val(class_1_service_option) $value
			}
			-class_1_initiator_control {
				set val(class_1_initiator_control) $value
			}
			-class_1_recipient_control {
				set val(class_1_recipient_control) $value
			}
			-class_1_rcv_data_size {
				set val(class_1_rcv_data_size) $value
			}
			-class_1_con_seq {
				set val(class_1_con_seq) $value
			}
			-class_1_e2e_credit {
				set val(class_1_e2e_credit) $value
			}
			-class_1_open_seq_per_exchange{
				set val(class_1_open_seq_per_exchange) $value
			}
			-class_2_service_option {
				set val(class_2_service_option) $value
			}
			-class_2_initiator_control {
				set val(class_2_initiator_control) $value
			}
			-class_2_recipient_control {
				set val(class_2_recipient_control) $value
			}
			-class_2_rcv_data_size {
				set val(class_2_rcv_data_size) $value
			}
			-class_2_con_seq {
				set val(class_2_con_seq) $value
			}
			-class_2_e2e_credit {
				set val(class_2_e2e_credit) $value
			}
			-class_2_open_seq_per_exchange {
				set val(class_2_open_seq_per_exchange) $value
			}
			-class_3_service_option {
				set val(class_3_service_option) $value
			}
			-class_3_initiator_control {
				set val(class_3_initiator_control) $value
			}
			-class_3_recipient_control {
				set val(class_3_recipient_control) $value
			}
			-class_3_rcv_data_size{
				set val(class_3_rcv_data_size) $value
			}
			-class_3_con_seq {
				set val(class_3_con_seq) $value
			}
			-class_3_e2e_credit {
				set val(class_3_e2e_credit) $value
			}
			-class_3_open_seq_per_exchange {
				set val(class_3_open_seq_per_exchange) $value
			}
			-class_4_service_option {
				set val(class_4_service_option) $value
			}
			-class_4_initiator_control {
				set val(class_4_initiator_control) $value
			}
			-class_4_recipient_control {
				set val(class_4_recipient_control) $value
			}
			-class_4_rcv_data_size{
				set val(class_4_rcv_data_size) $value
			}
			-class_4_con_seq {
				set val(class_4_con_seq) $value
			}
			-class_4_e2e_credit {
				set val(class_4_e2e_credit) $value
			}
			-class_4_open_seq_per_exchange {
				set val(class_4_open_seq_per_exchange) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}

class FipDescNpivFdiscAcc {
	inherit FipDescNpivFdisc
	
	constructor {} { chain } {
		set descType accept
	}
	
	method config { args } {}
}
body FipDescNpivFdiscAcc::config { args } {
	
	set tag "body FipDescNpivFdiscAcc::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_ph_version_high {
				set val(fc_ph_version_high) $value
			}
			-fc_ph_version_low {
				set val(fc_ph_version_low) $value
			}
			-bb_credit {
				set val(bb_credit) $value
			}
			-common_features {
				set val(common_features) $value
			}
			-rcv_data_size {
				set val(rcv_data_size) $value
			}
			-total_con_seq {
				set val(total_con_seq) $value
			}
			-offset {
				set val(offset) $value
			}
			-e_d_tov {
				set val(e_d_tov) $value
			}
			-n_port_name {
				set val(n_port_name) $value
			}
			-node_name {
				set val(node_name) $value
			}
			-class_1_service_option {
				set val(class_1_service_option) $value
			}
			-class_1_initiator_control {
				set val(class_1_initiator_control) $value
			}
			-class_1_recipient_control {
				set val(class_1_recipient_control) $value
			}
			-class_1_rcv_data_size {
				set val(class_1_rcv_data_size) $value
			}
			-class_1_con_seq {
				set val(class_1_con_seq) $value
			}
			-class_1_e2e_credit {
				set val(class_1_e2e_credit) $value
			}
			-class_1_open_seq_per_exchange{
				set val(class_1_open_seq_per_exchange) $value
			}
			-class_2_service_option {
				set val(class_2_service_option) $value
			}
			-class_2_initiator_control {
				set val(class_2_initiator_control) $value
			}
			-class_2_recipient_control {
				set val(class_2_recipient_control) $value
			}
			-class_2_rcv_data_size {
				set val(class_2_rcv_data_size) $value
			}
			-class_2_con_seq {
				set val(class_2_con_seq) $value
			}
			-class_2_e2e_credit {
				set val(class_2_e2e_credit) $value
			}
			-class_2_open_seq_per_exchange {
				set val(class_2_open_seq_per_exchange) $value
			}
			-class_3_service_option {
				set val(class_3_service_option) $value
			}
			-class_3_initiator_control {
				set val(class_3_initiator_control) $value
			}
			-class_3_recipient_control {
				set val(class_3_recipient_control) $value
			}
			-class_3_rcv_data_size{
				set val(class_3_rcv_data_size) $value
			}
			-class_3_con_seq {
				set val(class_3_con_seq) $value
			}
			-class_3_e2e_credit {
				set val(class_3_e2e_credit) $value
			}
			-class_3_open_seq_per_exchange {
				set val(class_3_open_seq_per_exchange) $value
			}
			-class_4_service_option {
				set val(class_4_service_option) $value
			}
			-class_4_initiator_control {
				set val(class_4_initiator_control) $value
			}
			-class_4_recipient_control {
				set val(class_4_recipient_control) $value
			}
			-class_4_rcv_data_size{
				set val(class_4_rcv_data_size) $value
			}
			-class_4_con_seq {
				set val(class_4_con_seq) $value
			}
			-class_4_e2e_credit {
				set val(class_4_e2e_credit) $value
			}
			-class_4_open_seq_per_exchange {
				set val(class_4_open_seq_per_exchange) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}

class FipDescNpivFdiscRjt {
	inherit FipDescNpivFdisc
	
	constructor {} { chain } {
		set descType reject
	}
	
	method config { args } {}
}
body FipDescNpivFdiscRjt::config { args } {
	
	set tag "body FipDescNpivFdiscRjt::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-reason_code {
				set val(reason_code) $value
			}
			-explanation_code {
				set val(explanation_code) $value
			}
			-vendor_unique {
				set val(vendor_unique) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}


# FipDescFlogo
class FipDescFlogo {
	inherit FipDesc
	
	public variable type
	public variable len
	public variable val
	
	public variable descType
	
	method config { args } {}
	constructor {} { chain } {}
}
body FipDescFlogo::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescFlogo::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_r_ctl {
				set val(fc_r_ctl) $value
			}
			-fc_dst_id {
				set val(fc_dst_id) $value
			}
			-fc_cs_ctl {
				set val(fc_cs_ctl) $value
			}
			-fc_src_id {
				set val(fc_src_id) $value
			}
			-fc_type {
				set val(fc_type) $value
			}
			-fc_frame_control {
				set val(fc_frame_control) $value
			}
			-fc_seq_id {
				set val(fc_seq_id) $value
			}
			-fc_data_field_control {
				set val(fc_data_field_control) $value
			}
			-fc_seq_cnt {
				set val(fc_seq_cnt) $value
			}
			-fc_originator_exchanger_id {
				set val(fc_originator_exchanger_id) $value
			}
			-fc_response_exchanger_id {
				set val(fc_response_exchanger_id) $value
			}
			-fc_offset {
				set val(fc_offset) $value
			}
			-command_code {
				set val(command_code) $value
			}
		}
	}
		
	eval chain $args
	return [ GetStandardReturnHeader ]

}
class FipDescFlogoRequest {
    inherit FipDescFlogo
	
	constructor {} { chain } {
		set descType request
	}
	
    method config { args } {}
}
body FipDescFlogoRequest::config { args } {
	
	set tag "body FipDescFlogoRequest::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-n_port_id {
				set val(n_port_id) $value
			}
			-port_name {
				set val(port_name) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}
class FipDescFlogoAcc {
	inherit FipDescFlogo
	
	constructor {} { chain } {
		set descType accept
	}
	

}
class FipDescFlogoRjt {
	inherit FipDescFlogo
	
	constructor {} { chain } {
		set descType reject
	}
	
	method config { args } {}
}
body FipDescFlogoRjt::config { args } {
	
	set tag "body FipDescFlogoRjt::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-reason_code {
				set val(reason_code) $value
			}
			-explanation_code {
				set val(explanation_code) $value
			}
			-vendor_unique {
				set val(vendor_unique) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}


# FipDescElp
class FipDescElp {
	inherit FipDesc
	
	public variable type
	public variable len
	public variable val
	
	public variable descType
	
	method config { args } {}
	constructor {} { chain } {}
}
body FipDescElp::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescFlogi::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fc_r_ctl {
				set val(fc_r_ctl) $value
			}
			-fc_dst_id {
				set val(fc_dst_id) $value
			}
			-fc_cs_ctl {
				set val(fc_cs_ctl) $value
			}
			-fc_src_id {
				set val(fc_src_id) $value
			}
			-fc_type {
				set val(fc_type) $value
			}
			-fc_frame_control {
				set val(fc_frame_control) $value
			}
			-fc_seq_id {
				set val(fc_seq_id) $value
			}
			-fc_data_field_control {
				set val(fc_data_field_control) $value
			}
			-fc_seq_cnt {
				set val(fc_seq_cnt) $value
			}
			-fc_originator_exchanger_id {
				set val(fc_originator_exchanger_id) $value
			}
			-fc_response_exchanger_id {
				set val(fc_response_exchanger_id) $value
			}
			-fc_offset {
				set val(fc_offset) $value
			}
			-code {
				set val(code) $value
			}
		}
	}
		
	eval chain $args
	return [ GetStandardReturnHeader ]

}
class FipDescElpRequest {
    inherit FipDescElp
	
	constructor {} { chain } {
		set descType request
	}
	
    method config { args } {}
}
body FipDescElpRequest::config { args } {
	
	set tag "body FipDescElpRequest::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-revision {
				set val(revision) $value
			}
			-flags {
				set val(flags) $value
			}
			-bb_sc_n {
				set val(bb_sc_n) $value
			}
			-r_a_tov {
				set val(r_a_tov) $value
			}
			-e_d_tov {
				set val(e_d_tov) $value
			}
			-req_port_name {
				set val(req_port_name) $value
			}
			-req_swith_name {
				set val(req_swith_name) $value
			}
			-class_f_val {
				set val(class_f_val) $value
			}
			-class_f_r {
				set val(class_f_r) $value
			}
			-class_f_xii {
				set val(class_f_xii) $value
			}
			-class_f_rcv_data_size {
				set val(class_f_rcv_data_size) $value
			}
			-class_f_con_seq {
				set val(class_f_con_seq) $value
			}
			-class_f_e2e_credit {
				set val(class_f_e2e_credit) $value
			}
			-class_f_open_seq_per_exchange {
				set val(class_f_open_seq_per_exchange) $value
			}
			-class_1_val {
				set val(class_1_val) $value
			}
			-class_1_imx {
				set val(class_1_imx) $value
			}
			-class_1_xps{
				set val(class_1_xps) $value
			}
			-class_1_lks {
				set val(class_1_lks) $value
			}
			-class_1_rcv_data_size {
				set val(class_1_rcv_data_size) $value
			}
			-class_3_val {
				set val(class_3_val) $value
			}
			-class_3_imx {
				set val(class_3_imx) $value
			}
			-class_3_xps {
				set val(class_3_xps) $value
			}
			-class_3_lks {
				set val(class_3_lks) $value
			}
			-class_3_rcv_data_size {
				set val(class_3_rcv_data_size) $value
			}
			-class_2_val {
				set val(class_2_val) $value
			}
			-class_2_imx {
				set val(class_2_imx) $value
			}
			-class_2_xps {
				set val(class_2_xps) $value
			}
			-class_2_lks{
				set val(class_2_lks) $value
			}
			-class_2_rcv_data_size {
				set val(class_2_rcv_data_size) $value
			}
			-isl_flow_control_mode {
				set val(isl_flow_control_mode) $value
			}
			-isl_flow_control_len {
				set val(isl_flow_control_len) $value
			}
			-bb_credit {
				set val(bb_credit) $value
			}
			-compatibility_param {
				set val(compatibility_param) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}
class FipDescElpSwAcc {
	inherit FipDescElp
	
	constructor {} { chain } {
		set descType accept
	}
	
	method config { args } {}
}
body FipDescElpSwAcc::config { args } {
	
	set tag "body FipDescElpSwAcc::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-revision {
				set val(revision) $value
			}
			-flags {
				set val(flags) $value
			}
			-bb_sc_n {
				set val(bb_sc_n) $value
			}
			-r_a_tov {
				set val(r_a_tov) $value
			}
			-e_d_tov {
				set val(e_d_tov) $value
			}
			-req_port_name {
				set val(req_port_name) $value
			}
			-req_swith_name {
				set val(req_swith_name) $value
			}
			-class_f_val {
				set val(class_f_val) $value
			}
			-class_f_r {
				set val(class_f_r) $value
			}
			-class_f_xii {
				set val(class_f_xii) $value
			}
			-class_f_rcv_data_size {
				set val(class_f_rcv_data_size) $value
			}
			-class_f_con_seq {
				set val(class_f_con_seq) $value
			}
			-class_f_e2e_credit {
				set val(class_f_e2e_credit) $value
			}
			-class_f_open_seq_per_exchange {
				set val(class_f_open_seq_per_exchange) $value
			}
			-class_1_val {
				set val(class_1_val) $value
			}
			-class_1_imx {
				set val(class_1_imx) $value
			}
			-class_1_xps{
				set val(class_1_xps) $value
			}
			-class_1_lks {
				set val(class_1_lks) $value
			}
			-class_1_rcv_data_size {
				set val(class_1_rcv_data_size) $value
			}
			-class_3_val {
				set val(class_3_val) $value
			}
			-class_3_imx {
				set val(class_3_imx) $value
			}
			-class_3_xps {
				set val(class_3_xps) $value
			}
			-class_3_lks {
				set val(class_3_lks) $value
			}
			-class_3_rcv_data_size {
				set val(class_3_rcv_data_size) $value
			}
			-class_2_val {
				set val(class_2_val) $value
			}
			-class_2_imx {
				set val(class_2_imx) $value
			}
			-class_2_xps {
				set val(class_2_xps) $value
			}
			-class_2_lks{
				set val(class_2_lks) $value
			}
			-class_2_rcv_data_size {
				set val(class_2_rcv_data_size) $value
			}
			-isl_flow_control_mode {
				set val(isl_flow_control_mode) $value
			}
			-isl_flow_control_len {
				set val(isl_flow_control_len) $value
			}
			-bb_credit {
				set val(bb_credit) $value
			}
			-compatibility_param {
				set val(compatibility_param) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}
class FipDescElpSwRjt {
	inherit FipDescElp
	
	constructor {} { chain } {
		set descType reject
	}
	
	method config { args } {}
}
body FipDescElpSwRjt::config { args } {
	
	set tag "body FipDescElpSwRjt::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-reason_code {
				set val(reason_code) $value
			}
			-explanation_code {
				set val(explanation_code) $value
			}
			-vendor_unique {
				set val(vendor_unique) $value
			}
		}
	}
		
	eval chain $args
	
	return [ GetStandardReturnHeader ]

}



# FipDescVxPortId
class FipDescVxPortId {
	
	inherit FipDesc
	
	method config { args } {}
}
body FipDescVxPortId::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescVxPortId::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-mac_addr {
				set val(mac_addr) $value
			}
			-addr_id {
				set val(addr_id) $value
			}
			-port_name {
				set val(port_name) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}


# FipDescFkaAdvPeriod
class FipDescFkaAdvPeriod {
	
	inherit FipDesc
	
	method config { args } {}
}
body FipDescFkaAdvPeriod::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescFkaAdvPeriod::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-fka_adv_period {
				set val(fka_adv_period) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}


# FipDescVendorId
class FipDescVendorId {
	
	inherit FipDesc
	
	method config { args } {}
}
body FipDescVendorId::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescVendorId::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-vendor_id {
				set val(vendor_id) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}


# FipDescVlan
class FipDescVlan {
	
	inherit FipDesc
	
	method config { args } {}
}
body FipDescVlan::config { args } {
	global errorInfo
	global errNumber
	
	set tag "body FipDescVlan::config[info script]"
	Deputs "----- TAG: $tag -------"

	foreach {key value} $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-vlan_id {
				set val(vlan_id) $value
			}
		}
	}
		
	return [ GetStandardReturnHeader ]

}

#Vxlan
class VxlanHdr {
	inherit Header
	constructor {} { chain vxlan } { }
	
	method config { args } {}
}

body VxlanHdr::config { args } {
    global errorInfo
    global errNumber


    set tag "body VxlanHdr::config [info script]"
Deputs "----- TAG: $tag -----"
	
    set VniType Incrementing
    set vxlan_flag 8
    set vni_count  1
    set vni_step   1    
    
  
# param collection
    foreach { key value } $args {
	    set key [string tolower $key]
	    switch -exact -- $key {
		    -flag {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set vxlan_flag $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			    
			 
		    }
		    -rev1 {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set  vxlan_rev1 $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			    			
		    }
		    -vni {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set  vxlan_vni $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			    
			
		    }
		    -rev2 {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set  vxlan_rev2 $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			   
			 
		    }
		    -vni_count {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set  vni_count $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			    
			 
		    }
		    -vni_step {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set  vni_step $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			    
			
		    }
		    -vni_step_type {
                	
                set vni_step_type [ string tolower $value ]
				switch $vni_step_type {
					incr {
						set VniType Incrementing
					}
					decr {
						set VniType Decrementing
					}
					random {
						set VniType Random
					}
				}                
			
		    }
		  
	    }
    }
		
	
#        $pdu Clear
    set pro [ string tolower $protocol ]
Deputs "Pro: $pro"
    if { $pro != "vxlan" } {
	   error "$errNumber(3) key:protocol value:$pro"
    }
    SetProtocol vxlan
    #-----set Code Bits-----
    if { [ info exists vxlan_flag ] } {
	   AddField flags
	   AddFieldMode Fixed
	   AddFieldConfig $vxlan_flag
    }
    if { [ info exists vxlan_rev1 ] } {
	   AddField reserved
	   AddFieldMode Fixed
	   AddFieldConfig $vxlan_rev1
    }
    
    if { [ info exists vxlan_rev2 ] } {
	   AddField reserved8
	   AddFieldMode Fixed
	   AddFieldConfig $vxlan_rev2
    }
    
   
    #--------------------------
    #-----Config Port-----
    if { [ info exists vxlan_vni ] } {

	   if { [ info exists VniType ] } {

		  switch -exact $VniType {
			 Fixed {
				AddFieldMode $VniType
				AddField vni
				AddFieldConfig $vxlan_vni
			 }
			 Decrementing -
			 Incrementing {
				if { [ info exists vni_count ] && [ info exists vni_step ] } {
				    AddFieldMode $VniType
				    AddField vni
				    AddFieldConfig \
				    [ list 0 $vxlan_vni $vni_count $vni_step ]
				} else {
				    error "$errNumber(2) key:vxlan_vni/vxlan_step"
				}
			 }
		  }
	   } 
    }
    
    #--------------------------
	eval chain $args
    
    if { [ IsValid ] } {
	   return [GetStandardReturnHeader]
    } else {
	   return [ GetErrorReturnHeader "PDU is invalid" ]
    }

}