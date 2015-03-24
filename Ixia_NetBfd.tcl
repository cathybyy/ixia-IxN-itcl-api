
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.1
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class BfdSession {
    inherit RouterEmulationObject
    
	public variable bfdSession
	
    constructor { port } {
		global errNumber
		
		set tag "body BfdSession::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set portObj [ GetObject $port ]
		set handle ""
		reborn
	}
	
	method reborn {} {
		set tag "body BfdSession::reborn [info script]"
Deputs "----- TAG: $tag -----"

		if { [ catch {
			set hPort   [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in DhcpHost ctor"
		}
				
		set rb_interface [ ixNet getL $hPort interface ]
		if { ![ llength $rb_interface ] } {
			set int [ ixNet add $hPort interface ]
			ixNet add $int ipv4
			ixNet commit
			lappend rb_interface [ ixNet remapIds $int ]
		}
	    Deputs "rb_interface is: $rb_interface"
		array set interface [ list ]
		
		ixNet setA $hPort/protocols/bfd -enabled True
		ixNet commit
		
		#-- add bfd protocol
		set handle [ ixNet add $hPort/protocols/bfd router ]
		ixNet setA $handle -Enabled True
		ixNet commit
		set handle [ ixNet remapIds $handle ]
		ixNet setA $handle -name $this
Deputs "handle:$handle"		
		set protocol bfd

	}
	
    method config { args } {}
	method generate_interface { args } {
		set tag "body BfdSession::generate_interface [info script]"
Deputs "----- TAG: $tag -----"
Deputs "handle:$handle"		
		foreach int $rb_interface {
			if { [ ixNet getA $int -type ] == "routed" } {
				continue
			}
			set hInt [ ixNet add $handle interface ]
			ixNet setM $hInt -interfaces $int -enabled True 
			
			ixNet commit
			set hInt [ ixNet remapIds $hInt ]
			set interface($int) $hInt	
		}
	}	
}

body BfdSession::config { args } {
	set tag "body Ospfv2Session::config [info script]"
Deputs "----- TAG: $tag -----"
	
	set ip_version ipv4
	set enable_echo 0
	set count 1
	set local_disc_step 1
	
Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-count {
				set count $value
			}
			-enable_echo {
				set trans [ BoolTrans $value ]
				if { $trans == "1" || $trans == "0" } {
					set enable_echo $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
			}
			-echo_rx_interval {
				set echo_rx_interval $value
			}
			-echo_tx_interval {
				set echo_tx_interval $value
			}
			-rx_interval {
				set rx_interval $value
			}
			-tx_interval {
				set tx_interval $value			
			}
			-detect_multiplier {
				set detect_multiplier $value
			}
			-source_ip {
				set source_ip $value
			}
			-peer_ip {
				set peer_ip $value			
			}
			-ip_version {
				set ip_version $value			
			}
			-priority {
				set priority $value			
			}
			-router_id {
				set router_id $value
			}
			-local_disc {
				set local_disc $value				
			}
			-local_disc_step {
				set local_disc_step $value				
			}
			-remote_disc {
				set remote_disc $value
			}
			-authentication {
				set authentication $value
			}
			-password {
				set password $value
			}
			-md5_key {
				set md5_key $value
			}
		}
	}
	if { $handle == "" } {
		reborn
	}
Deputs "Step10"
	if { [ info exists source_ip ] } {
		foreach rb $rb_interface {
		
			if { [ ixNet getA $rb -type ] == "routed" } {
				continue
			}
			
			ixNet setA [ ixNet getL $rb $ip_version ] \
				-ip $source_ip
			if { [ info exists peer_ip ] } {
				ixNet setA [ ixNet getL $rb $ip_version ] \
					-gateway $peer_ip
			}
			
			ixNet commit
			break
		}
		
 		generate_interface	
		
		if { $enable_echo } {
Deputs "interface:$interface([ lindex $rb_interface 0 ])"		
			ixNet setA $interface([ lindex $rb_interface 0 ]) -echoConfigureSrcIp True
			ixNet commit
			if { $ip_version == "ipv4" } {
				ixNet setA $interface([ lindex $rb_interface 0 ]) -echoSrcIpv4Address $source_ip
			} else {
				ixNet setA $interface([ lindex $rb_interface 0 ]) -echoSrcIpv6Address $source_ip
			}
		}
	}	
	
Deputs "Step70"
	if { [ info exists router_id ] } {
		ixNet setA $handle -routerId $router_id
	}
Deputs "Step100"
	if { [ info exists count ] } {
		set bfdSession [ list ]
		for { set index 0 } { $index < $count } { incr index } {
			set hSession [ ixNet add $interface([ lindex $rb_interface 0 ]) session ]
			ixNet setA $hSession -enabled True
			if { [ info exists peer_ip ] } {
				ixNet setA $hSession -remoteBfdAddress $peer_ip
			}
			ixNet setA $hSession -ipType $ip_version
			ixNet commit
			lappend bfdSession $hSession
		}
	}
Deputs "Step110"
	if { [ info exists echo_rx_interval ] } {
		ixNet setA $interface([ lindex $rb_interface 0 ]) -echoInterval $echo_rx_interval
	}
Deputs "Step120"
	if { [ info exists echo_tx_interval ] } {
		ixNet setA $interface([ lindex $rb_interface 0 ]) -echoTxInterval $echo_tx_interval
	}
Deputs "Step130"
	if { [ info exists rx_interval ] } {
		ixNet setA $interface([ lindex $rb_interface 0 ]) -minRxInterval $rx_interval
	}
Deputs "Step140"
	if { [ info exists tx_interval ] } {
		ixNet setA $interface([ lindex $rb_interface 0 ]) -txInterval $tx_interval
	}
Deputs "Step150"
	if { [ info exists priority ] } {
		ixNet setA $interface([ lindex $rb_interface 0 ]) -ipDifferentiatedServiceField $priority
	}
Deputs "Step160"
	if { [ info exists detect_multiplier ] } {
		ixNet setA $interface([ lindex $rb_interface 0 ]) -multiplier $detect_multiplier
	}
Deputs "Step170"
	if { [ info exists local_disc ] } {
		foreach session $bfdSession {
			ixNet setA $session -myDisc $local_disc
			incr local_disc $local_disc_step
		}
	}
Deputs "Step180"
	if { [ info exists remote_disc ] } {
		foreach session $bfdSession {
			ixNet setM $session -remoteDisc $remote_disc -remoteDiscLearned False
		}
	} else {
		foreach session $bfdSession {
			ixNet setM $session -remoteDiscLearned True
		}
	}

	ixNet commit
	return [GetStandardReturnHeader]

}

# (bin) 53 % set bfd [ ixNet getL $port/protocols/bfd router ]
# ::ixNet::OBJ-/vport:1/protocols/bfd/router:1
# (bin) 54 % ixNet help $bfd
# Child Lists:
	# interface (kList : add, remove, getList)
	# learnedInfo (kManaged : getList)
# Attributes:
	# -enabled (readOnly=False, type=kBool)
	# -isLearnedInfoRefreshed (readOnly=True, type=kBool)
	# -routerId (readOnly=False, type=kIPv4)
	# -trafficGroupId (readOnly=False, type=kObjref=null,/traffic/trafficGroup)
# Execs:
	# refreshLearnedInfo (kObjref=/vport/protocols/bfd/router)

# (bin) 55 % ixNet getL $bfd interface
# ::ixNet::OBJ-/vport:1/protocols/bfd/router:1/interface:1
# (bin) 56 % set pi [ixNet getL $bfd interface]
# ::ixNet::OBJ-/vport:1/protocols/bfd/router:1/interface:1
# (bin) 57 % ixNet help $pi
# Child Lists:
	# session (kList : add, remove, getList)
# Attributes:
	# -echoConfigureSrcIp (readOnly=False, type=kBool)
	# -echoInterval (readOnly=False, type=kInteger)
	# -echoSrcIpv4Address (readOnly=False, type=kIPv4)
	# -echoSrcIpv6Address (readOnly=False, type=kIPv6)
	# -echoTimeout (readOnly=False, type=kInteger)
	# -echoTxInterval (readOnly=False, type=kInteger)
	# -enableCtrlPlaneIndependent (readOnly=False, type=kBool)
	# -enabled (readOnly=False, type=kBool)
	# -enableDemandMode (readOnly=False, type=kBool)
	# -flapTxInterval (readOnly=False, type=kInteger)
	# -interfaceId (readOnly=False, type=kObjref=null,/vport/interface, deprecated)
	# -interfaceIndex (readOnly=False, type=kInteger)
	# -interfaces (readOnly=False, type=kObjref=null,/vport/interface,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/ip/l2tpEndpoint/range,/vport/protocolStack/atm/ipEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/ipEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint/range,/vport/protocolStack/ethernetEndpoint/range)
	# -interfaceType (readOnly=False, type=kString)
	# -ipDifferentiatedServiceField (readOnly=False, type=kInteger)
	# -minRxInterval (readOnly=False, type=kInteger)
	# -multiplier (readOnly=False, type=kInteger)
	# -pollInterval (readOnly=False, type=kInteger)
	# -txInterval (readOnly=False, type=kInteger)
# Execs:
	# getInterfaceAccessorIfaceList (kObjref=/vport/protocols/bfd/router/interface)

# (bin) 58 % ixNet getL $pi session
# ::ixNet::OBJ-/vport:1/protocols/bfd/router:1/interface:1/session:1
# (bin) 59 % set session [ixNet getL $pi session]
# ::ixNet::OBJ-/vport:1/protocols/bfd/router:1/interface:1/session:1
# (bin) 60 % ixNet help $session
# Attributes:
	# -bfdSessionType (readOnly=False, type=kEnumValue=singleHop,multipleHops)
	# -enabled (readOnly=False, type=kBool)
	# -enabledAutoChooseSource (readOnly=False, type=kBool)
	# -ipType (readOnly=False, type=kEnumValue=ipv4,ipv6)
	# -localBfdAddress (readOnly=False, type=kIP)
	# -myDisc (readOnly=False, type=kInteger)
	# -remoteBfdAddress (readOnly=False, type=kIP)
	# -remoteDisc (readOnly=False, type=kInteger)
	# -remoteDiscLearned (readOnly=False, type=kBool)
