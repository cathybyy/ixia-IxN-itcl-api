
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.16
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1.1.6
#		2. Return hex in get_content
# Version 1.3.1.15
#		3. Add Capture filter in Capture::config
# Version 1.4.1.16
#		4. Connect IxOS to get capture count
# Version 1.5.2.1
#		5. Fix bug that filter not work
# Version 1.6.2.7
#		6. Change get_content index start from 0
#		7. Add portObj public variable to keep for reborn
#		8. Reborn Capture object through portObj
# Version 1.7.2.16
#		9. Return all the capture pkt
# Version 1.8.2.18
#		10. Add code in unconfig
# Version 1.9.cgn
#		11. Add packet_content to decode
# Version 1.10.4.6
#		12. Take ownership using IxNetwork user instead of releasing port
#		13. Add method save -cap_file
# Version 1.11.4.8
#		14. Add reborn in Capture
# Version 1.12.4.20
#		15. set default readFromExplore to 0 in Capture::get_count
# Version 1.13.4.22
#		16. set max package count to 1000 in GetAllContent
# Version 1.14.4.24patch
#       17. Add slice_size to capture
# Version 1.15.4.29
#       18. Change get_count readFromExplore default to 1
#       19. Change get_content, limit packet_index = packet_index % 1000 + 1
# Version 1.16.4.62-python
#		20. Add frame delta time in frame info for packet_content

class Capture {
    
    inherit NetObject
    #--public method
    constructor { port } {
		set tag "body Capture::ctor [info script]"
        Deputs "----- TAG: $tag -----"
		set portObj $port
        
        set chassisIp ""
        set portList [list ]
        set captureStart false
        
		reborn
	}
	method reborn {} {
		set tag "body Capture::reborn [info script]"
        Deputs "----- TAG: $tag -----"
		if { [ catch {
			set hPort [ $portObj cget -handle ]
		} ] } {
			set portObj [ GetObject $portObj ]
			set hPort [ $portObj cget -handle ]
		} 
		set content  [list]
		set handle $hPort/capture
        Deputs "handle:$handle"		
	}
    method config { args } {}
    method get_content { args } {}
    method get_count { { readFromExplore 1 } { standard 1 } } {}
	method packet_content { args } {}
    method unconfig {} {
		set tag "body Capture::unconfig [info script]"
        Deputs "----- TAG: $tag -----"
        #	set flag [ ixNet getA $hPort/capture -hardwareEnabled ]
        #    	ixNet setA $hPort/capture -hardwareEnabled true
        #    	ixNet commit
        Deputs "handle:$handle portObj:$portObj"
		if { $handle == "" } { reborn }
    	CleanFilter
		set handle ""
        #    	ixNet setA $hPort/capture -hardwareEnabled $flag
        #    	ixNet commit
    	#return [ GetErrorReturnHeader "flag:$flag" ]
	return [ GetStandardReturnHeader ]
    }
    method CleanFilter {} {
		set tag "body Capture::CleanFilter [info script]"
        Deputs "----- TAG: $tag -----"
        Deputs "hPort:$hPort"		
		if { [ catch {
			ixNet setM $handle/filter \
				-captureFilterDA anyAddr \
				-captureFilterSA anyAddr \
				-captureFilterPattern anyPattern \
				-captureFilterFrameSizeEnable false
				
			ixNet commit
					
			ixNet setMultiAttrs $handle/filterPallette \
			 -DA1 {00 00 00 00 00 00} -DAMask1 {00 00 00 00 00 00} \
			 -SA1 {00 00 00 00 00 00} -SAMask1 {00 00 00 00 00 00} \
			 -pattern1 0 \
			 -patternMask1 0 \
			 -patternOffset1 0 \
			 -pattern2 0 \
			 -patternMask2 0 \
			 -patternOffset2 0 

			ixNet commit
		} err ] } {
            Deputs "err:$err"
		}
    }
	
	method GetAllContent {} {
		set tag "body Capture::GetAllContent [info script]"
        Deputs "----- TAG: $tag -----"
		
		set content  [list]

		set portInfo [ixNet getA $hPort -connectionInfo]
        #--chassis="10.137.144.57" card="9" port="3" portip="10.0.9.3"
		regexp {chassis=([0-9\.\"]+) card=([\"0-9]+) port=([\"0-9]+)} $portInfo match chas card port
        Deputs "chas:$chas card:$card port:$port"
        # Deputs "release port:$hPort"
		# ixNet exec releasePort $hPort
        
        # set timeout 10
        # while { [ ixNet getA $hPort -isAvailable ] } {
        # Deputs "Port connect state:[ ixNet getA $hPort -isAvailable ]"
            # incr timeout -1
            # after 1000
            # if { !$timeout } {
                # break
            # }
        # }

		set rsConnectToOS [ ixConnectToChassis $chas ]
        Deputs "result connecting to OS:$rsConnectToOS"
		set chasId	[ chassis cget -id ]
        Deputs "capture get on $chasId $card $port"
		
		set readPortRes [ eval port get $chasId $card $port ]
        Deputs "read port result:$readPortRes"		
		set owner [port cget -owner]
        Deputs "owner:$owner"		

		# Login before taking ownership
		ixLogin $owner
		# Take ownership of the ports we¡¯ll use
		set portList [ list [ eval list $chasId $card $port ] ]
Deputs "portList:$portList"		
		#ixTakeOwnership $portList

		set rsGetCap [ eval capture get $chasId $card $port ]
Deputs "result get capture: $rsGetCap"
		set pktCnt [ capture cget -nPackets ]
Deputs "pkt count:$pktCnt"

		set err ""
		if { $pktCnt == 0 } {
			set err "No packet captured"
		} else {
			if { $pktCnt > 1000 } {
				set pktCnt 1000
			}
		}

		if { $err == "" } {
			set rsGetBuffer [ eval captureBuffer get $chasId $card $port 1 $pktCnt ]
	Deputs "result get buffer:$rsGetBuffer"
			for { set packet_index 1 } { $packet_index <= $pktCnt } { incr packet_index } {
				set rsGetFrame [ captureBuffer getframe $packet_index ]
	Deputs "result get frame:$rsGetFrame"
				set hex [ captureBuffer cget -frame ]
				lappend content $hex
	# Deputs "hex:$hex"
			}
		}
		
		# ixNet exec connectPort $hPort
		
        # set timeout 10
        # while { ![ ixNet getA $hPort -isAvailable ] } {
# Deputs "Port connect state:[ ixNet getA $hPort -isAvailable ]"
            # incr timeout -1
            # after 1000
            # if { !$timeout } {
                # break
            # }
        # }
        
		if { $err != "" } {
			error $err
		}
        	
		return $pktCnt
		
	}
    
	method start {} {
		set tag "body Capture::start [info script]"
        Deputs "----- TAG: $tag -----"
		if { $handle == "" } { reborn }
        
        if { ![ ixNet getA $hPort/capture -hardwareEnabled ] } {
            ixNet setA $hPort/capture  -hardwareEnabled True
            ixNet commit
        }
		if { [ ixNet getA $hPort -rxMode ] != "captureAndMeasure" && [ ixNet getA $hPort -rxMode ] != "capture" } {
            ixNet setA $hPort -rxMode capture
            ixNet commit
		}
        
		ixNet exec start $handle
		set content  [list]
		return [ GetStandardReturnHeader ]
	}
	method stop {} {
		set tag "body Capture::stop [info script]"
        Deputs "----- TAG: $tag -----"
		if { $handle == "" } { reborn }
		ixNet exec stop $handle
		return [ GetStandardReturnHeader ]
	}
    method save { args } {}
	method enable {} {
		set tag "body Capture::enable [info script]"
Deputs "----- TAG: $tag -----"
		if { $handle == "" } { reborn }
		ixNet setA $handle -hardwareEnabled True
		ixNet commit
		return [ GetStandardReturnHeader ]
	}
	method disable {} {
		set tag "body Capture::disable [info script]"
Deputs "----- TAG: $tag -----"
		if { $handle == "" } { reborn }
		ixNet setA $handle -hardwareEnabled False
		ixNet commit
		return [ GetStandardReturnHeader ]
	}
	method start_hal_capture { args } {}
	method stop_hal_capture { } {}
	method save_hal_capture { args } {}
	method update_info { } {}
    
	public variable portObj
    public variable hPort
    public variable filter
    public variable capfile
    public variable contentProMap
	public variable content
    
    public variable chassisIp
    public variable portList
    public variable captureStart
}

body Capture::config { args } {
    global errorInfo
    global errNumber
    
    set tag "body Capture::config [info script]"
    Deputs "----- TAG: $tag -----"
    #param collection
    Deputs "Args:$args "
	
	if { $handle == "" } { reborn }

	ixNet setA $hPort/capture    -hardwareEnabled True
	ixNet commit   

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -cap_filter {
                set cap_filter $value
            }
			-slice_size {
			    if { [ string is integer $value ] } {
				set slice_size $value
			 } else {
				error "$errNumber(1) key:$key value:$value"
			 }
			    
			}
			-cap_mode {}
			-cap_file {
				set capfile $value
			}
            default {
                error "$errNumber(3) key:$key value:$value"
            }
        }
    }
	
	if { [ info exists slice_size] } {
	} else {
	set slice_size 0
	}
Deputs "hPort:$hPort"	
        ixNet setM $hPort/capture \
			-afterTriggerFilter captureAfterTriggerAll \
			-beforeTriggerFilter captureBeforeTriggerAll \
			-captureMode captureContinuousMode \
			-continuousFilters captureContinuousFilter \
			-displayFiltersDataCapture {} \
			-hardwareEnabled True \
			-sliceSize $slice_size \
			-softwareEnabled False \
			-triggerPosition 1
		ixNet commit
	

	if { [ info exists cap_filter ] } {
Deputs "hPort:$hPort"	
		
		ixNet setM $hPort/capture/filter -captureFilterEnable True \
			-captureFilterError errAnyFrame \
			-captureFilterFrameSizeEnable False \
			-captureFilterFrameSizeFrom 64 \
			-captureFilterFrameSizeTo 1518 \
		ixNet commit
		
		set index 1
		foreach filter $cap_filter {
			set filter [ GetObject $filter ]
			if { $filter == "" } {
				return [ GetErrorReturnHeader "Wrong value of filter, which is not a valid CaptureFilter Object" ]
			}
			if { $index == 3 } {
				return [ GetErrorReturnHeader "Out of bound for supported filter count" ]
			}
			set field_value [ $filter cget -field_value ]
			set ip_offset 	[ $filter cget -ip_offset ]
			set vlan_offset [ $filter cget -vlan_offset ]
			set mpls_offset [ $filter cget -mpls_offset ]
			set arp_offset	[ $filter cget -arp_offset ]
			set udp_offset	[ $filter cget -udp_offset ]
			set sip_offset	[ $filter cget -sip_offset ]
			set field_offset [ $filter cget -field_offset ]
			set field_mask [ $filter cget -field_mask ]
			set eth_dst		[ $filter cget -eth_dst ]
			set eth_src		[ $filter cget -eth_src ]
# IxDebugOn
Deputs "field_value:$field_value ip_offset:$ip_offset vlan_offset:$vlan_offset mpls_offset:$mpls_offset arp_offset:$arp_offset udp_offset:$udp_offset sip_offset:$sip_offset field_offset:$field_offset field_mask:$field_mask eth_dst:$eth_dst eth_src:$eth_src"
Deputs Step100
			if { [ info exists eth_dst ] && ( $eth_dst != "" ) } {
Deputs Step200
Deputs "dst:$eth_dst"
				ixNet setMultiAttrs $hPort/capture/filterPallette \
				 -DA$index $eth_dst \
				 -DAMask$index {00 00 00 00 00 00}
				 
				ixNet setA $hPort/capture/filter -captureFilterDA addr$index
			} else {
Deputs Step300
			
				ixNet setA $hPort/capture/filter -captureFilterDA anyAddr
				
			}
			ixNet commit
			if { [ info exists eth_src ] && ( $eth_src != "" ) } {
Deputs Step400						
				ixNet setMultiAttrs $hPort/capture/filterPallette \
				 -SA$index  $eth_src \
				 -SAMask$index {00 00 00 00 00 00}
				 
				ixNet setA $hPort/capture/filter -captureFilterSA addr$index
			} else {
			
				ixNet setA $hPort/capture/filter -captureFilterSA anyAddr
			
			}
#IxDebugOff			
			ixNet commit

			if { ( $field_value != "" ) && ( $field_offset >= 0 ) } {
Deputs Step500			
				ixNet setMultiAttrs $hPort/capture/filterPallette \
				 -pattern$index $field_value \
				 -patternMask$index $field_mask \
				 -patternOffset$index $field_offset \
				 -patternOffsetType$index filterPalletteOffsetStartOfFrame
				ixNet commit
				
				#ixNet setM $hPort/capture/filter -captureFilterFrameSizeFrom $field_offset -captureFilterFrameSizeEnable True
				#ixNet commit
				if { $index == 1 } {
Deputs "index:$index"
				ixNet setA $hPort/capture/filter \
						-captureFilterPattern pattern$index
				} else {
					ixNet setA $hPort/capture/filter \
						-captureFilterPattern pattern1AndPattern2
				}
				ixNet commit
			} else {
Deputs "index:$index"
Deputs Step600				
				ixNet setM $hPort/capture/filter \
					-captureFilterPattern anyPattern
				ixNet commit
			}
			
			incr index
		}
	}
	ixNet commit
	# ixNet exec apply [ixNet getRoot]/traffic
	return [ GetStandardReturnHeader ]
    
}

body Capture::get_content { args } {
# IxDebugOn
    global errorInfo
    global errNumber

    set tag "body Capture::get_content [info script]"
Deputs "----- TAG: $tag -----"

    set protocol_instance  0
	set packet_index	   1
	set userIndex 		   0
	set first             -1
	set last              -1
	set offset            -1
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -packet_index {
			    if { $value > 1000} {
				    set packet_index [expr $value % 1000 + 1]
				    set userIndex 1
				} else {
                    set packet_index [ expr $value + 1 ]
				    set userIndex 1
				}
            }
            -header {
                set header $value
            }
            -field {
                set field $value
            }
		-index {
			set first [ expr $value*3 ]
		}
		-offset {
			set offset [ expr $value*3 ]
		}
		-start {
			set first [ expr $value*3 ]
		}
		-end {
			set last [ expr $value*3 ]
		}
            -protocol_instance {
                set protocol_instance $value
            }
            default {
                error "$errNumber(3) key:$key value:$value"
            }
        }
    }
	if { $handle == "" } { reborn }
	if { $offset != -1 } {
		set last [ expr $first+$offset]
	}
    if { [ info exists packet_index ] } {
Deputs "content count: [ llength $content ]"
		if { [ llength $content ] == 0 } {
			if { [ catch {
				GetAllContent
			} err ] } {
				return [ GetErrorReturnHeader "$err" ]
			}
		}
Deputs "content count: [ llength $content ]"
		if { [ llength $content ] < $packet_index } {
			return [ GetErrorReturnHeader "No package index $packet_index captured." ]
		}
		set hex [ lindex $content [ expr $packet_index - 1 ] ]
		if { $first != -1 && $last != -1} {
		set last [ expr $last+2]
			set hex [string range $hex $first $last]
		}
		return [GetStandardReturnHeader][ GetStandardReturnBody Content "$hex" ]
	}
        
}

body Capture::get_count { { readFromExplore 1 } { standard 1 } } {
    global errorInfo
    global errNumber

    set tag "body Capture::get_count [info script]"
Deputs "----- TAG: $tag -----"
	if { $handle == "" } { reborn }

	if { $readFromExplore } {
		if { [ llength $content ] == 0 } {
			if { [ catch {
				set pkg_count [ GetAllContent ]
			} err ] } {
				if { $standard } {
					return [ GetErrorReturnHeader "$err" ]
				} else {
					return 0
				}
			}
		} else {
			set pkg_count [ llength $content ]
		}
	} else {
Deputs "read packet from IxNetwork decoder"	
Deputs "capture status:[ ixNet getA $hPort/capture -hardwareEnabled ]"
		if { [ string tolower [ ixNet getA $hPort/capture -hardwareEnabled ] ] == "true" } {
			set pkg_count [ ixNet getA $hPort/capture -dataPacketCounter ]
Deputs "pkg_count:$pkg_count"			
		} else {
Deputs "capture disable"		
			ixNet setA $hPort/capture -hardwareEnabled True
			ixNet commit
			set pkg_count [ ixNet getA $hPort/capture -dataPacketCounter ]
			ixNet setA $hPort/capture -hardwareEnabled False
			ixNet commit
		}
	}
	if { $standard } {
		return [GetStandardReturnHeader][ GetStandardReturnBody count "$pkg_count" ]
	} else {
		return $pkg_count
	}
}

# #######################################
# packet_content
# ##
# ##
# arguments:
#	
# -packet_index				integer start from 0
# -header					info/ethernet/vlan/ipv4/mpls/igmp/arp/
# -field					
#							[header=info] 		frame_size/protocols/delta_time
#							[header=ethernet] 	dst/src/type
#							[header=vlan] 		pri/cfi/id/type
#							[header=ipv4]		version/length/dscp/precedence/delay/throughput/rely/cost/identification
#												not_frag/more_frag/frag_offset/ttl/protocol_type/checksum/src/dst
#							[header=mpls]		label/exp/ttl
#							[header=igmp]		version/type/max_response/checksum/multicast_addr/num_src
#							[header=arp]		hardware/protocol/ih_addr/ip_addr/arp_type/sender_mac_addr/sender_ipv4_addr
#												target_mac_addr/target_ipv4_addr
body Capture::packet_content { args } {

	set log ""
	set content ""
	set ::SUCCESS 1
	set ::FAILURE 0
	set status $::SUCCESS
	
	set packet_index 		0
	set protocol_instance	0
	set return_log 0
	set reset 1

    set tag "body Capture::packet_content [info script]"
Deputs "----- TAG: $tag -----"
	
	#param collection
Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-packet_index {
				set packet_index $value
			}
			-header {
				set header $value
			}
			-field {
				set fields $value
			}
			-protocol_instance {
				set protocol_instance $value
			}
			-return_log {
				set return_log $value
			}
			-reset {
				set reset $value
			}
		}
	}
	
Deputs Step30
	if { $status == $::SUCCESS } {
		set contentProMap(info)            "Frame"
		set contentProMap(info,delta_time) 5
		set contentProMap(info,frame_size) 6
		set contentProMap(info,protocols)  7
		
		#-- header ethernet
		set contentProMap(ethernet)        "Ethernet"
		set contentProMap(ethernet,dst)    0
		set contentProMap(ethernet,src)    1
		set contentProMap(ethernet,type)   4
		
		#-- header vlan
		set contentProMap(vlan)            "802.1Q Virtual LAN"
		set contentProMap(vlan,pri)        0
		set contentProMap(vlan,cfi)        1
		set contentProMap(vlan,id)         2
		set contentProMap(vlan,type)       3
		
		#-- header ipv4
		set contentProMap(ipv4)            "Internet Protocol"
		set contentProMap(ipv4,version)    0
		set contentProMap(ipv4,length)     1
		set contentProMap(ipv4,dscp)       2
		set contentProMap(ipv4,precedence) 5
		set contentProMap(ipv4,delay)      6
		set contentProMap(ipv4,throughput) 7
		set contentProMap(ipv4,rely)       8
		set contentProMap(ipv4,cost)       9
		set contentProMap(ipv4,identification) 12
		set contentProMap(ipv4,not_frag)   14
		set contentProMap(ipv4,more_frag)  15
		set contentProMap(ipv4,frag_offset)    16
		set contentProMap(ipv4,ttl)        17
		set contentProMap(ipv4,protocol_type)  18
		set contentProMap(ipv4,checksum)   19
		set contentProMap(ipv4,src)        20
		set contentProMap(ipv4,dst)        24
		
		#-- header mpls
		set contentProMap(mpls)            "MultiProtocol Label Switching Header"
		set contentProMap(mpls,label)      0
		set contentProMap(mpls,exp)        1
		set contentProMap(mpls,ttl)        3
		
		#-- header igmp
		set contentProMap(igmp)            "Internet Group Management Protocol"
		set contentProMap(igmp,version)    0
		set contentProMap(igmp,type)       1
		set contentProMap(igmp,max_response)    2
		set contentProMap(igmp,checksum)   3
		set contentProMap(igmp,multicast_addr)  4
		set contentProMap(igmp,num_src)    8
		
		#-- header arp
		set contentProMap(arp)            "Address Resolution Protocol"
		set contentProMap(arp,hardware)    0
		set contentProMap(arp,protocol)    1
		set contentProMap(arp,ih_addr)     2
		set contentProMap(arp,ip_addr)     3
		set contentProMap(arp,arp_type)    4
		set contentProMap(arp,sender_mac_addr)   5
		set contentProMap(arp,sender_ipv4_addr)  6
		set contentProMap(arp,target_mac_addr)   7
		set contentProMap(arp,target_ipv4_addr) 8   
		
		#-- header ipv6
		set contentProMap(ipv6)            "Internet Protocol Version 6"
		
		#-- header udp
		set contentProMap(udp) 				"User Datagram Protocol"
		set contentProMap(udp,src_port)		0
		set contentProMap(udp,dst_port)		1
		
		#-- header tcp
		set contentProMap(tcp) 				"Transmission Control Protocol"
		set contentProMap(tcp,src_port)		0
		set contentProMap(tcp,dst_port)		1
	}
	
Deputs Step40
	if { $status == $::SUCCESS } {
		if { $reset } {
			ixNet setA $hPort/capture    -hardwareEnabled True
			ixNet commit
		}
		if { [ info exists packet_index ] && [ info exists header ] && [ info exists fields ] } {
Deputs "decode process"				
			if { [ info exists contentProMap($header) ] == 0 } {
				set status $::FAILURE
				set log "Bad argument header value:$header - Unsupported packet header"
				# error "$errNumber(1) key:header value:$header (Unsupported packet header)"
			}
			
			# if { $status == $::SUCCESS } {

				# if { [ info exists contentProMap($header,$field) ] == 0 } {
					# set status $::FAILURE
					# set log "Bad argument field value:$field - Unsupported header field"
				# }
			# }
			
			if { $status == $::SUCCESS } {

				if { [ catch {
					set pkg_count    [ ixNet getA $hPort/capture -dataPacketCounter ]
Deputs "Pkt count:$pkg_count"
					ixNet exec getPacketFromDataCapture $hPort/capture/currentPacket $packet_index
				} ] } {
					set status $::FAILURE
					set log "Argument out of bound - packet_index value:$packet_index (0-[expr $pkg_count - 1])"
					# error "$errNumber(1) key:packet_index value:$packet_index (0-[expr $pkg_count - 1])"            
				}
			
			}
			
			if { $status == $::SUCCESS } {
Deputs "port handle:$hPort"
				set stackList [ ixNet getList $hPort/capture/currentPacket stack ]
Deputs "stack list:$stackList"				
				set headerFlag  0
				set fieldFlag   0
				set stackIndex  0
				foreach stack $stackList {
					if { [ regexp -nocase  "$contentProMap($header)" $stack ] } {
						if { $protocol_instance == 0 } {
							set headerFlag 1
							break
						} else {
							incr protocol_instance -1
						}
					}
					incr stackIndex
				}
				
				if { $headerFlag == 0 } {
					set status $::FAILURE
					set log "No mapping header in current packet"
				}
			}
			
			
			if { $status == $::SUCCESS } {
				set stack       [ lindex $stackList $stackIndex ]
Deputs "stack:$stack"
				set fieldList   [ ixNet getList $stack field ]
Deputs "field list:$fieldList"
				foreach field $fields {
					set fieldIndex  $contentProMap($header,$field)
Deputs "fieldIndex:$fieldIndex"
					if { $fieldIndex < 0 } {
						continue
					}
					set field       [ lindex $fieldList $fieldIndex ]
Deputs "field:$field"
					lappend content [ ixNet getA $field -fieldValue ]
Deputs "content:$content"
				}
				set log ""
				set status $::SUCCESS
			}
			
		} 

		if { $reset } {
			ixNet setA $hPort/capture    -hardwareEnabled False
			ixNet commit
		}
	}

	set result ""
	set result $result[GetStandardReturnBody status $status]
	set result $result[GetStandardReturnBody log $log]
	set result $result[GetStandardReturnBody content $content]
	
	if { $return_log } {
		return $result
	} else {
		return $content
	}
	
}

#--
# Start Hal Capture
#--
# Parameters: |key, value|
#       - mode: Capture mode, 0:capture all, 1:capture trig, 2:capture bad
# Return:
#        0 if got success
#        raise error if failed 
#--  
body Capture::start_hal_capture { args } {
	set tag "proc start_capture [info script]"
	Deputs "----- TAG: $tag -----"
	
	# Param collection --
	set mode 0
	foreach { key value } $args {
		set key [string tolower $key]
		Deputs "config $key---$value"
		switch -exact -- $key {
			-mode {
				set mode $value
			}
		}
	}
	
    stop_capture
	set timeout 0
	while { 1 } {
		# -- check capture status every 2 sec
		if { [ ixStartCapture portList ] == 0 } {
			break
		}

		# Timeout but capture not start
		if { $timeout > 30 } {
			Deputs "Could not start capture"
			error "Could not start capture"
		}
		incr timeout
		after 2000
	}

	set captureStart true
}

#--
# Stop Hal Capture
#--
#
# Return:
#        0 if got success
#        raise error if failed 
#--  
body Capture::stop_hal_capture { } {
	set tag "proc stop_capture [info script]"
	Deputs "----- TAG: $tag -----"
	
	if { $captureStart } {
		if { [ ixStopCapture portList ] != 0 } {
			Deputs "Could not stop capture"
		}
	}
	set captureStart false
}

#--
# Save Hal capture
#--
# Parameters: |key, value|
#       - prefix: Save capture file name's prefix
#       - resultDir: Result path
#       - user: Share server user
#       - password: Share server password
#       - pcap2xml: Convert pcap file to xml 
#       - keep_pcap: Keep enc file in local PC
#       -filters: Filters to get packates matched the condition, eg. -Y ip.version==4 -e ip.version
# Return:
#        0 if got success
#        raise error if failed 
#--  
body Capture::save_hal_capture { args } {
	set tag "proc save_capture [info script]"
	Deputs "----- TAG: $tag -----"
	
	# Param collection --
	set result_dir ""
	set pcap2xml false
	set keep_pcap true
	set prefix "Ixia"
	foreach { key value } $args {
		set key [string tolower $key]
		Deputs "config $key---$value"
		switch -exact -- $key {
			-result_dir {
				set result_dir $value
			}
			-prefix {
				set prefix $value
			}
			-user {
				set user $value
			}
			-password {
				set password $value
			}
			-pcap2xml {
				set pcap2xml $value
			}
			-keep_pcap {
				set keep_pcap $value
			}
            -filters {
                set filters $value
            }
		}
	}
	
	Deputs "----- Results location: $result_dir -----"
	foreach port $portList {
		set chassisId [ lindex $port 0 ]
		set cardIndex [ lindex $port 1 ]
		set portIndex [ lindex $port 2 ]
		if { [ capture get $chassisId $cardIndex $portIndex ] } {
			Deputs "Get capture from $chassisId $cardIndex $portIndex failed..."
			error "Get capture from $chassisId $cardIndex $portIndex failed..."
		}
		set PktCnt 0
		catch { set PktCnt [capture cget -nPackets] }
		Deputs "Total $PktCnt packets captured"
		
		if { $PktCnt == 0 } {
			continue
		}
		#Get all the packet from Chassis to pc.
		if { [ captureBuffer get $chassisId $cardIndex $portIndex 1 $PktCnt ] } {
			Deputs "Retrieve packets from $chassisId $cardIndex $portIndex failed..."
			error "Retrieve packets from $chassisId $cardIndex $portIndex failed..." 
		}
		
		if { [ captureBuffer export C:/Windows/Temp/${prefix}_${chassisId}_${cardIndex}_${portIndex}.enc capExportSniffer4x ] != 0 } {
			Deputs "Could not save capture"
			error "Could not save capture"
		} else {
			if { [ catch {
				#exec cmd "/k net use \\$chassisIp\Temp /del /y" &
				if { [ info exists user ] && [ info exists password ] } {
					catch { exec cmd "/k net use \\$chassisIp\Temp $password /user:$user" & }
				} else {
					catch { exec cmd "/k net use \\$chassisIp\Temp" & }
				}
				
                puts "file copy -force \\\\$chassisIp\\Temp\\${prefix}_${chassisId}_${cardIndex}_${portIndex}.enc $result_dir"
				eval "file copy -force \\\\$chassisIp\\Temp\\${prefix}_${chassisId}_${cardIndex}_${portIndex}.enc $result_dir"
				set enc [ file join $result_dir ${prefix}_${chassisId}_${cardIndex}_${portIndex}.enc ]
				if { $pcap2xml } {
					set xml [ file join $result_dir ${prefix}_${chassisId}_${cardIndex}_${portIndex}.xml ]
					exec tshark.exe -r $enc -T pdml > $xml
				}
				
				if { !$keep_pcap } {
					file delete -force $enc
				}
                
                if { [ info exists filters] } {
					set txt [ file join $result_dir ${prefix}_${chassisId}_${cardIndex}_${portIndex}.txt ]
					eval "exec tshark.exe -r $enc -T fields $filters > $txt"
                }
			} err ] } {
				Deputs "Failed to transfer capture file: $err"
				error "Failed to transfer capture file: $err"
			}
		}
	}
}

body Capture::update_info { } {
	# Update Hal information to start capture
    set root [ixNet getRoot]
    if { $chassisIp == "" } {
        set availableHardware [ lindex [ ixNet getL $root availableHardware ] 0 ]
        set chassis [ lindex [ ixNet getL $availableHardware chassis ] 0 ]
        set chassisIp [ ixNet getA $chassis -ip ]
    }
	
    if { [ ixConnectToTclServer $chassisIp ] } {
        Deputs "Failed to connect Tcl Server: $chassisIp:4555"
        error "Failed to connect Tcl Server: $chassisIp:4555"
    }
    
    if { [ ixConnectToChassis $chassisIp ] } {
        Deputs "Failed to connect Chassis: $chassisIp"
        error "Failed to connect Chassis: $chassisIp"
    }
    
    if { [ llength $portList ] == 0 } { 
		set p [ $portObj cget -handle ]
        set info [ ixNet getA $p -connectionInfo ]
        regexp {card="(\d+)"} $info card cardId
        regexp {port="(\d+)"} $info port portId
        chassis get $chassisIp
        set chassisId [ chassis get -id ]
        lappend portList [ list $chassisId $cardId $portId ]   
	}
    foreach p $portList {
        set chassisId [ lindex $p 0 ]
        set cardIndex [ lindex $p 1 ]
        set portIndex [ lindex $p 2 ]
        eval port get $chassisId $cardIndex $portIndex
        set owner [ eval port cget -owner ]
        if { $owner != "" } {
            ixLogin $owner
            break
        }
    }
}

#--
# Save capture
#--
# Parameters: |key, value|
#       - result_dir: Directory which we'll put the capture files
#       - suffix: Suffix name appended to capture file name
#       - pcap2xml: If we set xml, we'll convert pcap file to xml under capture_dir.  
#       - keep_pcap: Keep cap file in local PC
#       - filters: Filters to get packates matched the condition, eg. -Y ip.version==4 -e ip.version
# Return:
#        0 if got success
#        raise error if failed 
#--  
body Capture::save { args } {
	set tag "proc save $args [info script]"
	Deputs "----- TAG: $tag -----"
	
	# Param collection --
	set capture_dir [ pwd ]
	set pcap2xml false
	set keep_pcap true
	set suffix ""
	foreach { key value } $args {
		set key [string tolower $key]
		Deputs "config $key---$value"
		switch -exact -- $key {
			-result_dir {
				set capture_dir $value
			}
			-suffix {
				set prefix $value
			}
			-pcap2xml {
				set pcap2xml $value
			}
			-keep_pcap {
				set keep_pcap $value
			}
            -filters {
                set filters $value
            }
		}
	}
	
    if { [ catch {
        Tester::save_capture -capture_dir $capture_dir -suffix $suffix
        
        set captureFullPath ""
        set portName [ ixNet getA $hPort -name ]
        if { [ string range $portName 0 1 ] == "::" } {
            set captureFileName [ string range $portName 2 end ]
        }
        set waitCaptureToSave 60000
        while { $waitCaptureToSave > 0 } {
            set captureFullPath [ GetFileFromDir $capture_dir $captureFileName ]
            if { $captureFullPath != "" } {
                if { ![ file exists $captureFullPath ] } {
                    set captureFullPath [ file join $capture_dir $captureFullPath ]
                }
                break
            }
            incr waitCaptureToSave -2000
        }

        if { $captureFullPath == "" } {
            error "No capture file found!!!"
        }
        if { $pcap2xml } {
            set xml $captureFullPath.xml
            exec tshark.exe -r $captureFullPath -T pdml > $xml
        }
        
        if { [ info exists filters] } {
            set txt $captureFullPath.txt
            eval "exec tshark.exe -r $captureFullPath -T fields $filters > $txt"
        }
        
        if { !$keep_pcap } {
            file delete -force $captureFullPath
        }
    } err ] } {
        error "Failed to analyze capture file: $err"
    }
}
