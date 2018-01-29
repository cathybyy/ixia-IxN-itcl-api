
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

# -- Class definition...
class Flow {
    inherit NetObject
    #--public method
    constructor { port { hFlow NULL } { htraffic NULL } } {}
    method config { args  } {}
	method ElementConfig { args } {}
    method enable {} {}
    method disable {} {}
    method get_stats { args } {}

    #--private method
    method GetProtocolTemp { pro } {}
    method GetField { stack field } {}

	method start {} {
		set tag "body Flow::start [info script]"
		Deputs "----- TAG: $tag -----"
		if { [ catch {
			ixNet exec startStatelessTraffic $handle
		} ] err } {
            puts $err
			after 2000
			ixNet exec startStatelessTraffic $handle
		}
		return [ GetStandardReturnHeader ]
	}
	method stop {} {
		set tag "body Flow::stop [info script]"
		Deputs "----- TAG: $tag -----"
		ixNet exec stopStatelessTraffic $handle
		return [ GetStandardReturnHeader ]
	}
	method completed {} {
		set tag "body Flow::completed [info script]"
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
		set tag "body Flow::wait_started [info script]"
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
		set tag "body Flow::wait_stopped [info script]"
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
		set tag "body Flow::suspend [info script]"
		Deputs "----- TAG: $tag -----"
		ixNet setA $handle -suspend True
		ixNet commit
	}
	
	method unsuspend {} {
		set tag "body Flow::unsuspend [info script]"
		Deputs "----- TAG: $tag -----"
		ixNet setA $handle -suspend False
		ixNet commit
	}
    public variable id
    
    #stream stats
    public variable hPort
    public variable endpointSet
    public variable highLevelStream
	public variable configElement
    public variable portObj
    public variable hTraffic
	public variable flowName
}

# -- Flow implmentation
body Flow::constructor { port { hFlow NULL } { htraffic NULL }  } {
    set tag "body Flow::ctor [info script]"
	Deputs "----- TAG: $tag -----"

	if { $hFlow != "NULL" } {
		set handle $hFlow
		#set highLevelStream [ ixNet getL $handle configElement ]
        set highLevelStream $hFlow
		set configElement ""
        if { $htraffic != "NULL" } {
            set hTraffic $htraffic        
		    set endpointSet [ ixNet getL $hTraffic endpointSet ]
        }
	} else {
        if { $htraffic != "NULL" } {
            set hTraffic $htraffic        
        } else {
			set root    [ixNet getRoot]
			set hTraffic  [ixNet add $root/traffic trafficItem]
			ixNet setMultiA $hTraffic -trafficItemType l2L3 -trafficType raw
			ixNet commit
			ixNet setA $hTraffic/tracking -trackBy [list flowGroup0 trackingenabled0]
			ixNet commit
			Deputs "hTraffic: $hTraffic"
            ixNet setA $hTraffic -name "${this}_item"
            ixNet commit
			set hTraffic [ixNet remapIds $hTraffic ]
			Deputs "hTraffic: $hTraffic"
		
		}
		set endpointSet [ ixNet add $hTraffic endpointSet ]   
        set highLevelStream ""
        set configElement ""		
        set handle ""
		set flowName $this
		#Deputs "flow group handle:$handle"
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

body Flow::config { args  } {
	# in case the handle was removed
	set root [ixNet getRoot]
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


    global errorInfo
    global errNumber
    
    set EMode       [ list continuous burst iteration ]
    set ELenType    [ list fixed incr random auto ]
    set EFillType   [ list constant incr decr prbs random ]
    set EPayloadType [ list CYCBYTE INCRBYTE DECRBYTE PRBS USERDEFINE ]
    set ELoadUnit	[ list KBPS MBPS BPS FPS PERCENT ]
    set ELatencyType [list lifo lilo filo fifo]
	
    set enable_sig		1
	
	set flag_modify_adv	0
	set trafficType ipv4
	set bidirection 0
	
    set tag "body Flow::config [info script]"
	Deputs "----- TAG: $tag -----"
	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
			-name {
				set flowName $value
			}
		  -location {
			 set location $value
		  }
		  -src {
			 set src $value
		  }
		  -dst {
			 set dst $value
		  }
		  -pdu {
				set pdu $value
				Deputs "pdu:$pdu"
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
		  -inter_burst_gap -
		  -inter_frame_gap {
			  set inter_frame_gap $value
		  }
		  -peer_intf {}
		  -repeat_count {}
			-bidirection {
				set bidirection $value
			}
			-enable_stream_only_generation {}
			-traffic_type {
				set trafficType $value
			}
			-rcv_ports {
				set rcv_ports $value
			}
		  -need_arp {}
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

    if { [ info exists rcv_ports ] } {
		set hDestPorts [ list ]
		foreach dest $rcv_ports {
			lappend hDestPorts [ $dest cget -handle ]/protocols
		}
		
		
	Deputs "ep:$endpointSet"
	    ixNet setA $endpointSet -sources "$hPort/protocols"
		ixNet setA $endpointSet -destinations $hDestPorts
		ixNet commit
		
		set endpointSet [ixNet  remapIds $endpointSet]
		set highLevelStream [ lindex [ ixNet getL $hTraffic highLevelStream ] end ]		
		#set configElement [ lindex [ ixNet getL $hTraffic configElement ] end ]
		set configElement $highLevelStream
		#set handle $highLevelStream
		set handle $configElement
		Deputs "handle: $handle "
		Deputs "endpointSet: $endpointSet"
		
	  
		set ethStack [lindex [ ixNet getList $configElement stack ] 0]
		set obj [ GetField $ethStack destinationAddress ]
		ixNet setMultiAttrs $obj \
				-valueType singleValue \
				-singleValue "00:00:94:00:00:01"
		set obj [ GetField $ethStack sourceAddress ]
		ixNet setMultiAttrs $obj \
				-valueType singleValue \
				-singleValue "00:00:00:00:00:01"
	
	}	
    
    #-- quick stream and advanced stream
    if { [ info exists src ] && [ info exists dst ] } {
	   if { [ IsIPv4Address $src ] && [ IsIPv4Address $dst ] } {
#-- quick stream IPv4
Deputs "Traffic type:quick stream IPv4"
		  #-- Create quick stream
			##--add judgement for traffic reconfig
			
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
		foreach srcEndpoint $src {
Deputs "src:$srcEndpoint"
			set srcObj [ GetObject $srcEndpoint ]
Deputs "srcObj:$srcObj"			
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
			} else {
			Deputs Step120
				set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
			}
		}
Deputs "src handle:$srcHandle"

		set dstHandle [ list ]
Deputs "dst list:$dst"		
		foreach dstEndpoint $dst {
Deputs "dst:$dstEndpoint"
			set dstObj [ GetObject $dstEndpoint ]
Deputs "dstObj:$dstObj"			
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
		  ixNet setMultiA $hTraffic \
			 -trafficItemType l2L3 \
			 -biDirectional $bi \
			 -routeMesh oneToOne \
			 -srcDestMesh oneToOne \
			 -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan
			if { $enable_sig } {
				#ixNet setA $hTraffic/tracking -trackBy sourceDestPortPair0
				ixNet setA $hTraffic/tracking -trackBy [list flowGroup0 trackingenabled0]
				ixNet commit
			}
Deputs "add endpointSet..."
		  #-- add endpointSet
		  #set endpointSet [ixNet add $hTraffic endpointSet]
Deputs "src:$srcHandle"
		  ixNet setA $endpointSet -sources $srcHandle
Deputs "dst:$dstHandle"
		  ixNet setA $endpointSet -destinations $dstHandle
Deputs Step170
		  ixNet commit
          set hTraffic      [ ixNet remapIds $hTraffic ]
Deputs Step180
		
Deputs "handle:$handle"
		  set endpointSet [ ixNet remapIds $endpointSet ]
Deputs "ep:$endpointSet"
		set highLevelStream [ lindex [ ixNet getL $hTraffic highLevelStream ] end ]
		#set configElement [ lindex [ ixNet getL $hTraffic configElement ] end ]
		set configElement $highLevelStream
		set handle $configElement
		Deputs "handle: $handle "
Deputs "highLevelStream:$highLevelStream"
       
		set ethStack [lindex [ ixNet getList $configElement stack ] 0]
		set obj [ GetField $ethStack destinationAddress ]
		ixNet setMultiAttrs $obj \
				-valueType singleValue \
				-singleValue "00:00:94:00:00:01"
		set obj [ GetField $ethStack sourceAddress ]
		ixNet setMultiAttrs $obj \
				-valueType singleValue \
				-singleValue "00:00:00:00:00:01"
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
	
	#configElement
	# if {$configElement != ""} {
	    # eval ElementConfig $args
	# }
	
	
    #-- configure raw pdu or config advanced stream with L3+ pdu
    if { [ info exists pdu ] } {
		Deputs Step100
	  
		#-- Create quick stream
		Deputs "Traffic type:custom stream IPv4"
		##--add judgement for traffic reconfig
	
		foreach hStream $configElement {
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
					if { [ string tolower $protocol ] == "ethernet"  } {
						if {[$name cget -type ] != "MOD"} {
							if { $index == 0 } {
								Deputs "first ethernet set..."
								$name ChangeType SET
							} else {
								$name ChangeType APP
							}
						}
					}
					set type [ string toupper [ $name cget -type ] ]
					Deputs "Type $type "
					if {$protocol == "Vlan2" } {
						set protocol Vlan
					}
					set proStack [ GetProtocolTemp $protocol ]
					Deputs "protocol stack: $proStack"
					# Set or Append pdu protocols
					Deputs Step20
					set stack  [ lindex [ ixNet getList $hStream stack ] 0 ]
					Deputs "stack:$stack"
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
							set oripro [ $name cget -protocol ]
							Deputs "protocol:$oripro"
							if {$oripro == "Vlan2"} {
								set prolist [ ixNet getList $hStream stack ]
								set tempstack1 [lindex $prolist 1]
								Deputs "protocol:$tempstack1"
								set tempstack2 [lindex $prolist 2]
								Deputs "protocol:$tempstack2"
								if { [ regexp -nocase "vlan" $tempstack1  ] } {
									set stack $tempstack1 
								}
								if { [ regexp -nocase "vlan" $tempstack2  ] } {
									set stack $tempstack2 
								}
							} else {
								foreach pro [ ixNet getList $hStream stack ] {
									Deputs "pro:$pro"
									if { [ regexp -nocase $oripro $pro ] } {
										if { [ regexp -nocase "${pro}\[a-z\]+" $stack ] == 0 } {
											break
										}
									}
									incr index
								}
								set stack $pro
							}
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
						if {[$name cget -type ] != "MOD"} {
							if { [ $name cget -noMac ] } {
								Deputs "config default mac..."
								$name config -src $default_mac
							}
						}
					}
					# -- modify ip src ip
					if { [ $name isa Ipv4Hdr ] } {
						if {[$name cget -type ] != "MOD"} {
							if { [ $name cget -noIp ] } {
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

					if { $needMod == 0 } {
						Deputs Step45
						incr index
						continue
					}
	
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
						foreach mode $fieldModes field $fields conf $fieldConfigs \
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
									ixNet commit
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
					
						set pduLen [expr [string length $pdu] * 4]
						Deputs "pdu len:$pduLen"
						
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
	
    if { [ info exists tx_mode ] } {
	   if { $tx_mode == "burst" } {
			set tx_mode fixedFrameCount
	   }
	   if { $tx_mode == "iteration" } {
			set tx_mode fixedIterationCount
	   }
	   
	
		   ixNet setA $configElement/transmissionControl -type $tx_mode
	  
		ixNet commit
    }
    
    if { [ info exists tx_num ] } {
		
			ixNet setA $configElement/transmissionControl -frameCount $tx_num
		
		ixNet commit
    }
    
    if { [ info exists frame_len_type ] } {
	   if { $frame_len_type == "incr" } {
		  set frame_len_type increment
	   }	
		ixNet setA $configElement/frameSize -type $frame_len_type
#		ixNet commit
    }
    
    if { [ info exists frame_len ] } {
	
		ixNet setA $configElement/frameSize -fixedSize $frame_len
#		ixNet commit
    }
    
Deputs Step190
    if { [ info exists min_frame_len ] } {
		

			ixNet setA $configElement/frameSize -incrementFrom $min_frame_len
		
#		ixNet commit
    }
    
    if { [ info exists max_frame_len ] } {
		
			ixNet setA $configElement/frameSize -incrementTo $max_frame_len
		
# 		ixNet commit
   }
    
    if { [ info exists frame_len_step ] } {
		
			ixNet setA $configElement/frameSize -incrementStep $frame_len_step
		
#		ixNet commit
    }
Deputs Step200    
    if { [ info exists enable_fcs_error_insertion ] } {
	   if { $enable_fcs_error_insertion } {
		  set crc badCrc
	   } else {
		  set crc goodCrc
	   }
		
			ixNet setA $configElement -crc $crc
		
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
		
			ixNet setA $configElement/framePayload -type $fill_type
		
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
		
			ixNet setA $configElement/framePayload -type $fill_type
		
	   if { $payload_type == "CYCBYTE" } {
			
			ixNet setA $configElement/framePayload -customRepeat true
			
	   }
#		ixNet commit
    } 
    
    if { [ info exists payload ] } {
		
			ixNet setM $configElement/framePayload \
				-customRepeat true \
				-type custom \
				-customPattern $payload
		
#		ixNet commit
    }
	  
    if { [ info exists load_unit ] } {
	
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
		
#		ixNet commit

    }
Deputs Step230
    if { [ info exists inter_frame_gap ] } {
		
			ixNet setA $configElement/transmissionControl -minGapBytes $inter_frame_gap       
		
    }
   
    
    if { [ info exists stream_load ] } {
		
			ixNet setM $configElement/frameRate \
				-rate $stream_load
		
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
    
    ixNet commit
Deputs Step250	
    if { $enable_sig } {
		#ixNet setA $hTraffic/tracking -trackBy sourceDestPortPair0
		ixNet setA $hTraffic/tracking -trackBy [list flowGroup0 trackingenabled0]
		ixNet commit
	}

	ixNet setA $configElement -enabled True
	ixNet commit
	Deputs Step251
	ixNet setA $highLevelStream -enabled True
	ixNet commit
	
	#ixNet exec generate $hTraffic
	#ixNet commit
	ixNet setA $highLevelStream -name $flowName
	ixNet commit

    return [GetStandardReturnHeader]

}

body Flow::ElementConfig { args  } {
# in case the handle was removed

	set root [ixNet getRoot]

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


    global errorInfo
    global errNumber
    
    set EMode       [ list continuous burst iteration ]
    set ELenType    [ list fixed incr random auto ]
    set EFillType   [ list constant incr decr prbs random ]
    set EPayloadType [ list CYCBYTE INCRBYTE DECRBYTE PRBS USERDEFINE ]
    set ELoadUnit	[ list KBPS MBPS BPS FPS PERCENT ]
    set ELatencyType [list lifo lilo filo fifo]
	
    # set load_unit 		KBPS
    # set stream_load 	10000
    set frame_len		128
    set enable_sig		1
	
	set flag_modify_adv	0
	set trafficType ipv4
	set bidirection 0
	
    set tag "body Flow::ElementConfig [info script]"
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
		  -pdu {
			 set pdu $value
Deputs "pdu:$pdu"
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
		  -inter_burst_gap -
		  -inter_frame_gap {
			  set inter_frame_gap $value
		  }
		  -peer_intf {}
		  -repeat_count {}
			-bidirection {
				set bidirection $value
			}
			-enable_stream_only_generation {}
			-traffic_type {
				set trafficType $value
			}
			-rcv_ports {
				set rcv_ports $value
			}
		  -need_arp {}
		  default {
			 error "$errNumber(3) key:$key value:$value"
		  }
	   }
    }
    
   

    
    
    #-- quick stream and advanced stream
    
    #-- configure raw pdu or config advanced stream with L3+ pdu
    if { [ info exists pdu ] } {
Deputs Step100
	
Deputs "Traffic type:custom stream IPv4"
		##--add judgement for traffic reconfig
	
		foreach hStream $configElement {
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
				 if { [ string tolower $protocol ] == "ethernet"  } {
				    if {[$name cget -type ] != "MOD"} {
						if { $index == 0 } {
			Deputs "first ethernet set..."
							$name ChangeType SET
						 } else {
							$name ChangeType APP
						 }
					 }
				 }
				 set type [ string toupper [ $name cget -type ] ]
	Deputs "Type $type "
	            if {$protocol == "Vlan2" } {
				    set protocol Vlan
				}
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
						set oripro [ $name cget -protocol ]
	Deputs "protocol:$oripro"
	                    if {$oripro == "Vlan2"} {
						    set prolist [ ixNet getList $hStream stack ]
							set tempstack1 [lindex $prolist 1]
		Deputs "protocol:$tempstack1"
							set tempstack2 [lindex $prolist 2]
		Deputs "protocol:$tempstack2"
							if { [ regexp -nocase "vlan" $tempstack1  ] } {
							    set stack $tempstack1 
							}
							if { [ regexp -nocase "vlan" $tempstack2  ] } {
							    set stack $tempstack2 
							}
		
							   
							
						} else {
							foreach pro [ ixNet getList $hStream stack ] {
		Deputs "pro:$pro"
							   if { [ regexp -nocase $oripro $pro ] } {
								  if { [ regexp -nocase "${pro}\[a-z\]+" $stack ] == 0 } {
									 break
								  }
							   }
							   incr index
							}
							set stack $pro
						}
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
				    if {[$name cget -type ] != "MOD"} {
						 if { [ $name cget -noMac ] } {
					 Deputs "config default mac..."
							 $name config -src $default_mac
						 }
					}
				 }
				 # -- modify ip src ip
				 if { [ $name isa Ipv4Hdr ] } {
				    if {[$name cget -type ] != "MOD"} {
						 if { [ $name cget -noIp ] } {
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
					foreach mode $fieldModes field $fields conf $fieldConfigs \
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
	
    if { [ info exists tx_mode ] } {
	   if { $tx_mode == "burst" } {
			set tx_mode fixedFrameCount
	   }
	   if { $tx_mode == "iteration" } {
			set tx_mode fixedIterationCount
	   }
	   
	  
		   ixNet setA $configElement/transmissionControl -type $tx_mode
	  
		ixNet commit
    }
    
    if { [ info exists tx_num ] } {
		
			ixNet setA $configElement/transmissionControl -frameCount $tx_num
		
		ixNet commit
    }
    
    if { [ info exists frame_len_type ] } {
	   if { $frame_len_type == "incr" } {
		  set frame_len_type increment
	   }
		
		ixNet setA $configElement/frameSize -type $frame_len_type
		
#		ixNet commit
    }
    
    if { [ info exists frame_len ] } {
		
		ixNet setA $configElement/frameSize -fixedSize $frame_len
		
#		ixNet commit
    }
    
Deputs Step190
    if { [ info exists min_frame_len ] } {
		

			ixNet setA $configElement/frameSize -incrementFrom $min_frame_len
		
#		ixNet commit
    }
    
    if { [ info exists max_frame_len ] } {
		
			ixNet setA $configElement/frameSize -incrementTo $max_frame_len
		
# 		ixNet commit
   }
    
    if { [ info exists frame_len_step ] } {
	
			ixNet setA $configElement/frameSize -incrementStep $frame_len_step
		
#		ixNet commit
    }
Deputs Step200    
    if { [ info exists enable_fcs_error_insertion ] } {
	   if { $enable_fcs_error_insertion } {
		  set crc badCrc
	   } else {
		  set crc goodCrc
	   }
		
			ixNet setA $configElement -crc $crc
		
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
		
			ixNet setA $configElement/framePayload -type $fill_type
		
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
		
			ixNet setA $configElement/framePayload -type $fill_type
		
	   if { $payload_type == "CYCBYTE" } {
			
				ixNet setA $configElement/framePayload -customRepeat true
			
	   }
#		ixNet commit
    } 
    
    if { [ info exists payload ] } {
		
			ixNet setM $configElement/framePayload \
				-customRepeat true \
				-type custom \
				-customPattern $payload
		
#		ixNet commit
    }
	  
    if { [ info exists load_unit ] } {
		
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
		
#		ixNet commit

    }
Deputs Step230
    if { [ info exists inter_frame_gap ] } {
		
			ixNet setA $configElement/transmissionControl -minGapBytes $inter_frame_gap       
		
    }
    # if { [ info exists inter_frame_gap ] } {
		# foreach configElement $highLevelStream {
			# ixNet setA $configElement/transmissionControl -minGapBytes $inter_frame_gap       
		# }
    # } else {
# Deputs Step240	    
		# set  inter_frame_gap [ $portObj cget -inter_burst_gap ]
		# if { [ string is integer $inter_frame_gap ] } {
	# Deputs Step250	
			# foreach configElement $highLevelStream {

				# ixNet setA $configElement/transmissionControl -minGapBytes $inter_frame_gap       
			# }
					
		# }
    # }
    
    if { [ info exists stream_load ] } {
		
			ixNet setM $configElement/frameRate \
				-rate $stream_load
		
#		ixNet commit
    }
   
    ixNet commit
Deputs Step250	
   
	
Deputs Step251
# set handle [ ixNet remapIds $handle ]
# Deputs "handle : $handle"
# set newhandle [ lindex [ ixNet getL $hTraffic highLevelStream ] end ]
# Deputs "newhandle : $newhandle"
		
    return [GetStandardReturnHeader]

}
body Flow::enable {} {
    set tag "body Flow::enable [info script]"
Deputs "----- TAG: $tag -----"

	#ixNet setA $handle -enabled True 
	ixNet setA $handle -suspend False
    ixNet commit
	ixNet setA $handle -suspend False
    ixNet commit
		
    return [ GetStandardReturnHeader ]
}
body Flow::disable {} {
    set tag "body Flow::disable [info script]"
Deputs "----- TAG: $tag -----"
	#ixNet setA $handle -enabled false
	ixNet setA $handle -suspend True
    ixNet commit
	ixNet setA $handle -suspend True
    ixNet commit
	
    return [ GetStandardReturnHeader ]

}
body Flow::GetProtocolTemp { pro } {
    set tag "body Flow::GetProtocolTemp [info script]"
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



body Flow::GetField { stack value } {
    set tag "body Flow::GetField [info script]"
Deputs "----- TAG: $tag -----"
#Deputs "value:$value"
    set fieldList [ixNet getList $stack field]
#Deputs "fieldList:$fieldList"
    set index 0
    foreach field $fieldList {
#Deputs "field:$field"
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


body Flow::get_stats { args } {

    set tag "body Flow::get_stats [info script]"
    Deputs "----- TAG: $tag -----"
    # param collection --
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  -fhflag {
			 set fhflag $value
		  }
	   }
    }
    
   
	set view {::ixNet::OBJ-/statistics/view:"Flow Statistics"}
    
    Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
    Deputs "caption list:$captionList"
    set traNameIndex            [ lsearch -exact $captionList {Flow Group} ]
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
	set fhlist {}
	
	set ssflag 0
	set sindex 1
	
	set pagnum [ixNet getA {::ixNet::OBJ-/statistics/view:"Flow Statistics"/page} -totalPages]
	while {$sindex <= $pagnum} {
	    
		ixNet setA {::ixNet::OBJ-/statistics/view:"Flow Statistics"/page} -currentPage $sindex
        ixNet commit
        Deputs "pagenum:$sindex"			
	
	
		set stats [ ixNet getA $view/page -rowValues ]
	Deputs "stats:$stats"

		foreach row $stats {
		   
		   eval {set row} $row
	Deputs "row:$row"

			# if { [ info exists rx_port ] == 0 } {
				# if { [ lindex $row $traNameIndex ] != $this } {
				# Deputs "$traNameIndex $this"
					# continue
				# }
			
			# }
			
			if {[info exists fhflag]} {
                set streamname [ lindex $row $traNameIndex ]
                Deputs "streamname: $streamname"
                if { "::IxiaFH::${streamname}" != $this } {
                Deputs "$traNameIndex $this"
                    continue
                }
            
            } else {
                set streamname [ lindex $row $traNameIndex ]
                Deputs "streamname: $streamname"
                if { "::${streamname}" != $this } {
                Deputs "$traNameIndex $this"
                    continue
                }
            }
			
			

		   set statsItem   "tx_frame_count"
		   set statsVal    [ lindex $row $txFramesIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}TxFrameCount
			   lappend fhlist $statitem $statsVal
			   set tx_count $statsVal
		   }
			
		   set statsItem   "rx_frame_count"
		   set statsVal    [ lindex $row $rxFramesIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}RxFrameCount
			   lappend fhlist $statitem $statsVal
			   set rx_count $statsVal
		   }
			
		   set statsItem   "tx_frame_rate"
		   set statsVal    [ lindex $row $txFrameRateIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}TxFrameRate
			   lappend fhlist $statitem $statsVal
		   }
		   
		   set statsItem   "rx_frame_rate"
		   set statsVal    [ lindex $row $rxFrameRateIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}RxFrameRate
			   lappend fhlist $statitem $statsVal
		   }

		   set statsItem   "tx_l1_bit_rate"
		   set statsVal    [ lindex $row $tx_l1_bit_rate ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}TxL1BitRate
			   lappend fhlist $statitem $statsVal
		   }
		   
		   set statsItem   "rx_l1_bit_rate"
		   set statsVal    [ lindex $row $rx_l1_bit_rate ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}RxL1BitRate
			   lappend fhlist $statitem $statsVal
		   }
		   
		   
		   set statsItem   "tx_l2_bit_rate"
		   set statsVal    [ lindex $row $txBitRateIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}TxL2BitRate
			   lappend fhlist $statitem $statsVal
		   }
		   
		   set statsItem   "rx_l2_bit_rate"
		   set statsVal    [ lindex $row $rxBitRateIndex ]
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}RxL2BitRate
			   lappend fhlist $statitem $statsVal
		   }

		   			
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
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}minLatency
			   lappend fhlist $statitem $statsVal
		   }
		   
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
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}maxLatency
			   lappend fhlist $statitem $statsVal
		   }


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
		   if {[info exists fhflag]} {
			   set statitem ${fhflag}avgLatenvy
			   lappend fhlist $statitem $statsVal
		   }


		   set statsItem   "min_jitter"
		   set statsVal    "NA"
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if { [info exists fhflag ] } {
				set statitem ${fhflag}minJitter
				lappend fhlist $statitem $statsVal
			}
			
			
		   set statsItem   "max_jitter"
		   set statsVal    "NA"
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if { [info exists fhflag ] } {
				set statitem ${fhflag}maxJitter
				lappend fhlist $statitem $statsVal
			}
		   
		   
		   set statsItem   "avg_jitter"
		   set statsVal    "NA"
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
		   if { [info exists fhflag ] } {
				set statitem ${fhflag}avgJitter
				lappend fhlist $statitem $statsVal
			}	  
		   
			set statsItem  "DroppedCount"
			set statsVal   [ expr $tx_count - $rx_count ]
			if { [ info exists fhflag ] } {
				set statitem ${fhflag}DroppedCount
				lappend fhlist $statitem $statsVal
			}

			
		   set statsItem   "duplicate_frame_count"
		   set statsVal    "NA"
	Deputs "stats val:$statsVal"
		   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			
		   set statsItem   "in_order_frame_count"
		   set statsVal    "NA"
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



	#Deputs "ret:$ret"
	       set ssflag 1

		}
		
		#ixNet remove $view
		#ixNet commit
		
		if {$ssflag ==1 } {
			if {[info exists fhflag]} {
				return $fhlist
			}
			   
			return $ret
		}
		incr sindex
	}
		
}











