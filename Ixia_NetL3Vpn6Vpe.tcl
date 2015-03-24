
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
class L3Vpn {

	constructor {} {}
	method config { args } {}
	
	
	
}


body L3Vpn::config { args } {
	
    global errorInfo
    global errNumber
    set tag "body L3Vpn::config [info script]"
Deputs "----- TAG: $tag -----"
	
# -- Default value initiation
	set ce_num				0
	set pe_num				0
	set ce 					[ list ] ;#ce port handle list
	set pe					[ list ] ;#pe port handle list
	set vpn_unique_per_pe	1
	set vpn_num				0
	
	# set ce_ipv4_addr		30.30.30.2
	set ce_ipv4_step		1
	set ce_ipv4_mod			24
	set ce_ipv4_pfx			24
	set ce_ipv4_port_step	1
	set ce_ipv4_port_mod	8
	set ce_vlan_enable		0
	set ce_vlan_id			1
	set ce_vlan_step		1
	
	# set ce_dut_addr			30.30.30.1
	set ce_dut_step			1
	set ce_dut_mod			24
	array set ce_e_bgp		[ list ] ;#ce external bgp handle list
	set ce_local_as			65001
	set ce_local_as_step	1
	
	set ce_route_num		50
	set ce_route_mask		24
	set ce_route_step		1
	set ce_route_addr		22.22.22.0
	set ce_route_ce_step	1
	set ce_route_ce_mod		8

	set p_router_num		0
	set pe_router_num		1
	set Ep_pe_igp			[ list "OSPF" "ISIS" ]
	set p_pe_igp			"OSPF"
	
	# set p_ipv4_addr			20.20.20.2
	set p_ipv4_pfx			24
	set p_ipv4_mod			24
	set p_ipv4_step			1
	set p_ipv4_port_mod		8
	set p_ipv4_port_step	1
	
	# set pe_ipv4_addr			20.20.20.2
	set pe_ipv4_pfx			24
	set pe_ipv4_mod			24
	set pe_ipv4_step		1
	set pe_ipv4_port_mod	8
	set pe_ipv4_port_step	1
	
	# set p_pe_dut_addr		20.20.20.1
	set p_pe_dut_mod		24
	set p_pe_dut_step		1
	set p_pe_dut_port_mod	8
	set p_pe_dut_port_step	1
	
	set p_pe_vlan_enable	0
	set p_pe_vlan_id		1
	set p_pe_vlan_step		1
	
	set pe_loopback_ipv4_addr			2.2.2.2
	set pe_loopback_ipv4_pfx			32
	set pe_loopback_ipv4_mod			32
	set pe_loopback_ipv4_step			1
	set pe_loopback_ipv4_port_mod		16
	set pe_loopback_ipv4_port_step		1
	
	set p_pe_dut_loopback_addr			1.1.1.1
	set p_pe_dut_loopback_mod			32
	set p_pe_dut_loopback_step			0
	set p_pe_dut_loopback_port_mod		32
	set p_pe_dut_loopback_port_step		0
	
	set p_loopback_ipv4_addr			100.2.1.1
	set ce_loopback_ipv4_addr			100.1.1.1
	array set p_pe_interface	[list]
	array set p_pe_ospf			[list]
	array set p_pe_ldp			[list]
	
	set ldp_start_label		16
	set pe_bgp_as			100
	array set pe_i_bgp		[list]
	array set pe_l3site		[list]
	set pe_bgp_rt			100:1
	set pe_bgp_rt_step		0:1
	set pe_bgp_rd			100:1
	set pe_bgp_rd_step		0:1
	
	set pe_vpn_route_num		50
	set pe_vpn_route_mask		24
	set pe_vpn_route_step		1
	set pe_vpn_route_addr		55.55.55.0
	set pe_vpn_route_vrf_step	1
	set pe_vpn_route_vrf_mod	16
	
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-vpn_num {
				set vpn_num_per_pe $value
			}
			-vpn_unique_per_pe {
				set vpn_unique_per_pe $value
			}
			-ce_port {
				set ce_port $value
			}
			-ce_vlan_enable {
				set ce_vlan_enable $value
			}
			-ce_vlan_id {
				set ce_vlan_id $value
			}
			-ce_vlan_step {
				set ce_vlan_step $value
			}
			-ce_ipv4_addr {
				set ce_ipv4_addr $value
			}
			-ce_ipv4_step {
				set ce_ipv4_step $value
			}
			-ce_ipv4_mod {
				set ce_ipv4_mod $value
			}
			-ce_ipv4_pfx {
				set ce_ipv4_pfx $value
			}
			-ce_dut_addr {
				set ce_dut_addr $value
			}
			-ce_dut_step {
				set ce_dut_step $value
			}
			-ce_dut_mod {
				set ce_dut_mod $value
			}
			-ce_ipv4_port_step {
				set ce_ipv4_port_step $value
			}		
			-ce_ipv4_port_mod {
				set ce_ipv4_port_mod $value
			}
			-ce_bgp_as {
				set ce_local_as $value
			}
			-ce_bgp_as_step {
				set ce_local_as_step $value
			}
			-ce_bgp_route_num {
				set ce_route_num $value
			}
			-ce_bgp_route_mod {
				set ce_route_mask $value
			}
			-ce_bgp_route_addr {
				set ce_route_addr $value
			}
			-ce_bgp_route_step {
				set ce_route_step $value
			}
			-ce_bgp_route_ce_step {
				set ce_route_ce_step $value
			}
			-ce_bgp_route_ce_mod {
				set ce_route_ce_mod $value
			}
			
			-pe_port -
			-p_port {
				set p_pe_port	$value
			}
			-p_vlan_enable -
			-pe_vlan_enable {
				set p_pe_vlan_enable $value
			}
			-p_vlan_id -
			-pe_vlan_id {
				set p_pe_vlan_id $value
			}
			-p_vlan_step -
			-pe_vlan_step {
				set p_pe_vlan_step $value
			}
			-p_pe_igp {
				set p_pe_igp $value
			}
			-p_pe_mpls {
				set p_pe_mpls $value
			}
			-p_router_num {
				set p_router_num $value
			}
			-p_ipv4_addr {
				set p_ipv4_addr $value
			}
			-p_ipv4_pfx {
				set p_ipv4_pfx $value
			}
			-p_ipv4_mod {
				set p_ipv4_mod $value
			}
			-p_ipv4_step {
				set p_ipv4_step $value
			}		
			-p_ipv4_port_mod {
				set p_ipv4_port_mod $value
			}
			-p_ipv4_port_step {
				set p_ipv4_port_step $value
			}
			-p_loopback_ipv4_addr {
				set p_loopback_ipv4_addr $value
			}
			-pe_router_num {
				set pe_router_num $value
			}
			-pe_ipv4_addr {
				set pe_ipv4_addr $value
			}
			-pe_ipv4_pfx {
				set pe_ipv4_pfx $value
			}
			-pe_ipv4_mod {
				set pe_ipv4_mod $value
			}
			-pe_ipv4_step {
				set pe_ipv4_step $value
			}		
			-pe_ipv4_port_mod {
				set pe_ipv4_port_mod $value
			}
			-pe_ipv4_port_step {
				set pe_ipv4_port_step $value
			}
			
			-p_dut_addr -
			-pe_dut_addr {
				set p_pe_dut_addr $value
			}
			-p_dut_mod -
			-pe_dut_mod {
				set p_pe_dut_mod $value
			}
			-p_dut_step -
			-pe_dut_step {
				set p_pe_dut_step $value
			}
			-p_dut_port_mod -
			-pe_dut_port_mod {
				set p_pe_dut_port_mod $value
			}
			-p_dut_port_step -
			-pe_dut_port_step {
				set p_pe_dut_port_step $value
			}
			-pe_loopback_ipv4_addr {
				set pe_loopback_ipv4_addr $value
			}
			-pe_loopback_ipv4_step {
				set pe_loopback_ipv4_step $value
			}
			-pe_loopback_ipv4_pfx {
				set pe_loopback_ipv4_pfx $value
			}
			-pe_loopback_ipv4_mod {
				set pe_loopback_ipv4_mod $value
			}
			-pe_loopback_ipv4_port_mod {
				set pe_loopback_ipv4_port_mod $value
			}
			-pe_loopback_ipv4_port_step {
				set pe_loopback_ipv4_port_step $value
			}
			-dut_loopback_ipv4_addr {
				set p_pe_dut_loopback_addr $value
			}
			-dut_loopback_ipv4_step {
				set p_pe_dut_loopback_step $value
			}
			-dut_loopback_ipv4_mod {
				set p_pe_dut_loopback_mod $value
			}
			-dut_loopback_ipv4_port_step {
				set p_pe_dut_loopback_port_step $value
			}
			-dut_loopback_ipv4_port_mod {
				set p_pe_dut_loopback_port_mod $value
			}
			-pe_bgp_as {
				set pe_bgp_as $value
			}
			-pe_bgp_rt {
				set pe_bgp_rt $value
			}
			-pe_bgp_rt_step {
				set pe_bgp_rt_step $value
			}
			-pe_bgp_rd {
				set pe_bgp_rd $value
			}
			-pe_bgp_rd_step {
				set pe_bgp_rd_step $value
			}
			-pe_vpn_route_num {
				set pe_vpn_route_num $value
			}
			-pe_vpn_route_addr {
				set pe_vpn_route_addr $value
			}
			-pe_vpn_route_step {
				set pe_vpn_route_step $value
			}
			-pe_vpn_route_mod {
				set pe_vpn_route_mask $value
			}
			-pe_vpn_route_vrf_step {
				set pe_vpn_route_vrf_step $value
			}
			-pe_vpn_route_vrf_mod {
				set pe_vpn_route_vrf_mod $value
			}
			-ospf_area_id {
				set ospf_area_id $value
			}
			-ospf_network_type {
				set ospf_network_type $value
			}
			-ldp_start_label {
				set ldp_start_label $value
			}
		}
	}
Deputs Step10
# -- Calculate vpn num
	if { [ info exists vpn_num_per_pe ] } {
Deputs "vpn num per PE:$vpn_num_per_pe"
		if { $vpn_unique_per_pe } {
			if { $p_router_num } {
				set vpn_num	[ expr $p_router_num * $pe_router_num * $vpn_num_per_pe ]
			} else {
				set vpn_num	[ expr $pe_router_num * $vpn_num_per_pe ]
			}
		} else {
			set vpn_num	$vpn_num_per_pe
		}
Deputs "vpn num:$vpn_num"
	} else {
		return [ GetErrorReturnHeader "Madatory parameters needed...p_pe_port" ]
	}
Deputs Step20
# =========================
# CE configuration
# =========================	
Deputs "===============CE Configuration============="
# -- Fetch Port CE handle
	if { [ info exists ce_port ] } {
		
		set ce_num	[ llength $ce_port ]
		
		foreach obj $ce_port {
			lappend ce [ $obj  cget -handle ]
		}
	} else {
		return [ GetErrorReturnHeader "Madatory parameters needed...ce_port" ]
	}
	
# -- Configure every single CE
	foreach port $ce_port {
		set hPort [ $port cget -handle ]
# -- Add interface/sub-interface
# -- Num of CE interface equals which of VPN
		if { [ info exists ce_ipv4_addr ] && [ info exists ce_dut_addr ] } {
				
			if { $ce_vlan_enable } {
				$port config \
					-intf_ip $ce_ipv4_addr \
					-intf_num $vpn_num \
					-intf_ip_step $ce_ipv4_step \
					-intf_ip_mod $ce_ipv4_mod \
					-mask $ce_ipv4_mod \
					-dut_ip $ce_dut_addr \
					-dut_ip_num $vpn_num \
					-dut_ip_step $ce_dut_step \
					-dut_ip_mod $ce_dut_mod \
					-inner_vlan_id $ce_vlan_id \
					-inner_vlan_step $ce_vlan_step
			} else {
				$port config \
					-intf_ip $ce_ipv4_addr \
					-intf_num $vpn_num \
					-intf_ip_step $ce_ipv4_step \
					-intf_ip_mod $ce_ipv4_mod \
					-mask $ce_ipv4_mod \
					-dut_ip $ce_dut_addr \
					-dut_ip_num $vpn_num \
					-dut_ip_step $ce_dut_step \
					-dut_ip_mod $ce_dut_mod 
			}			
			
			set ce_vlan_id	[ expr $ce_vlan_id + $ce_vlan_step * $vpn_num ]
			set ce_ipv4_addr [ IncrementIPAddr \
				$ce_ipv4_addr $ce_ipv4_port_mod $ce_ipv4_port_step ]
		}
		# increment per port
# -- Add EBGP peer
		set interface_list [ ixNet getL $hPort interface ]
		ixNet setA $hPort/protocols/bgp -enabled True
		ixNet commit
		foreach interface $interface_list {
			set hBgp [ ixNet add $hPort/protocols/bgp neighborRange ]
			set dut	 [ ixNet getA $interface/ipv4 -gateway ]
Deputs "dut:$dut"

			ixNet setM $hBgp \
				-dutIpAddress $dut \
				-interfaceType {Protocol Interface} \
				-interfaces $interface \
				-localAsNumber $ce_local_as \
				-type "external" \
				-bgpId $ce_loopback_ipv4_addr
			ixNet commit
			set hBgp [ ixNet remapIds $hBgp ]
			
			set ce_e_bgp(ROUTER,$port) $hBgp
			incr ce_local_as $ce_local_as_step
# -- Add EBGP route range
			set hRoute [ ixNet add $hBgp routeRange ]
			ixNet setM $hRoute \
				-enabled True \
				-numRoutes $ce_route_num \
				-fromPrefix $ce_route_mask \
				-networkAddress $ce_route_addr \
				-iterationStep $ce_route_step
			ixNet commit
			set hRoute [ ixNet remapIds $hRoute ]
			
			set ce_e_bgp(ROUTE,$hBgp) $hRoute
			set ce_route_addr [ IncrementIPAddr $ce_route_addr $ce_route_ce_mod $ce_route_ce_step ]
			set ce_loopback_ipv4_addr [ IncrementIPAddr $ce_loopback_ipv4_addr 32 1 ]
		}
	}
	
# =========================
# PE configuration
# =========================		
Deputs "===============PE Configuration============="
	if { [ info exists p_pe_port ] } {
		
		set pe_num	[ llength $p_pe_port ]
Deputs "pe_num:$pe_num"		
		foreach obj $p_pe_port {
			lappend pe [ $obj  cget -handle ]
		}
	} else {
		return [ GetErrorReturnHeader "Madatory parameters needed...p_pe_port" ]
	}
	

	foreach port $p_pe_port {
# -- Num of PE interface equals which of P or PE
		set hPort [ $port cget -handle ]
# -- Enable ospf routers 
		ixNet setM $hPort/protocols/ospf \
				-enabled True \
				-enableDrOrBdr True
		ixNet commit
# -- Enable ldp routers 
		ixNet setM $hPort/protocols/ldp \
				-enabled True 
		ixNet commit
# -- Enable bgp routers
		ixNet setM $hPort/protocols/bgp \
				-enabled True 
		ixNet commit
		
# -- translate rt
		set targetList		[ list ]
		set rtInfo			[ split $pe_bgp_rt ":" ]
		set asip			[ lindex $rtInfo 0 ]
		set assigned 		[ lindex $rtInfo 1 ]
		set rtstepInfo		[ split $pe_bgp_rt_step ":" ]
		set asipStep		[ lindex $rtstepInfo 0 ]
		set assignedStep	[ lindex $rtstepInfo 1 ]

# -- translate rd
		set distinguisherList [ list ]
		set rdInfo			[ split $pe_bgp_rd ":" ]
		set d_asip			[ lindex $rdInfo 0 ]
		set d_assigned		[ lindex $rdInfo 1 ]
		set rdStepInfo		[ split $pe_bgp_rd_step ":" ]
		set d_asipStep		[ lindex $rdStepInfo 0 ]
		set d_assignedStep	[ lindex $rdStepInfo 1 ]

		if { $p_router_num } {
# -- Config P interface
Deputs "===============P interface============="
				if { [ info exists p_ipv4_addr ] && [ info exists p_pe_dut_addr ] } {

					if { $p_pe_vlan_enable } {
						$port config \
							-intf_ip $p_ipv4_addr \
							-intf_num $p_router_num \
							-intf_ip_step $p_ipv4_step \
							-intf_ip_mod $p_ipv4_mod \
							-mask $p_ipv4_pfx \
							-dut_ip $p_pe_dut_addr \
							-dut_ip_num $p_router_num \
							-dut_ip_step $p_pe_dut_step \
							-dut_ip_mod $p_pe_dut_mod \
							-inner_vlan_id $p_pe_vlan_id \
							-inner_vlan_step $p_pe_vlan_step
					} else {
						$port config \
							-intf_ip $p_ipv4_addr \
							-intf_num $p_router_num \
							-intf_ip_step $p_ipv4_step \
							-intf_ip_mod $p_ipv4_mod \
							-mask $p_ipv4_pfx \
							-dut_ip $p_pe_dut_addr \
							-dut_ip_num $p_router_num \
							-dut_ip_step $p_pe_dut_step \
							-dut_ip_mod $p_pe_dut_mod
					}
						
					set p_pe_vlan_id	[ expr $p_pe_vlan_id + $p_pe_vlan_step * $p_router_num ]
					set p_ipv4_addr [ IncrementIPAddr $p_ipv4_addr $p_ipv4_port_mod $p_ipv4_port_step ]
					set p_pe_dut_addr [ IncrementIPAddr $p_pe_dut_addr $p_pe_dut_port_mod $p_pe_dut_port_step ]
				} 
				
				set p_int	[ ixNet getL $hPort interface ]
Deputs "P interface: $p_int"
				set p_pe_interface(CONNECTED,$port) $p_int

# -- Config PE loopback interface
Deputs "===============PE interface============="
				if { [ info exists pe_loopback_ipv4_addr ] && [ info exists p_pe_dut_loopback_addr ] } {
					set pe_lpback_addr $pe_loopback_ipv4_addr
					set dut_lpback_addr $p_pe_dut_loopback_addr
Deputs "loopback addr:$pe_lpback_addr"
					set pe_co_vpn_route_addr	$pe_vpn_route_addr
Deputs "pe co-vpn route addr: $pe_co_vpn_route_addr"
					set p_lpback_addr $p_loopback_ipv4_addr
					foreach p $p_int {
Deputs Step20
# -- add ldp routers 
						set ldp [ ixNet add $hPort/protocols/ldp router ]
Deputs "ldp:$ldp"
						ixNet setA $ldp -enabled True
						ixNet commit
						set ldp [ ixNet remapIds $ldp ]
						ixNet setA $ldp -routerId $p_loopback_ipv4_addr
						# ixNet setA $ldp -routerId $pe_int_ip
						ixNet commit
# -- add ldp interface
						set p_pe_ldp(ROUTER,$port) $ldp
						set ldpInt	[ ixNet add $ldp interface ]
						ixNet setM $ldpInt -enabled True -protocolInterface $p
						ixNet commit
# -- add unconnected interface via each p interface
Deputs "pe num:$pe_router_num"
						for { set index 0 } { $index < $pe_router_num } { incr index } {
Deputs Step30
							set int [ ixNet add $hPort interface ]
							ixNet setM $int -type routed \
											-enabled True
							ixNet commit
							set int [ ixNet remapIds $int ]
Deputs "unconnected interface: $int connected via: $p"
							ixNet setA $int/unconnected -connectedVia $p
							ixNet commit
							set ip [ ixNet add $int ipv4 ]
							ixNet setM $ip \
								-ip $pe_loopback_ipv4_addr \
								-gateway $p_pe_dut_loopback_addr \
								-maskWidth $pe_loopback_ipv4_pfx
							ixNet commit
							
							lappend p_pe_interface(UNCONNECTED,$p) $int
Deputs "unconnected interface saved: $p_pe_interface(UNCONNECTED,$p)"
Deputs "saved elements: [ array names p_pe_interface ]"
								
# -- set interface between P and PE
							if { [ info exists pe_ipv4_addr ] == 0 } {
								set pe_ipv4_addr	11.11.11.1
							} 

# -- add ldp FEC range
							set range [ ixNet add $ldp advFecRange ]
							ixNet setM $range \
								-enabled True \
								-firstNetwork $pe_loopback_ipv4_addr \
								-maskWidth $pe_loopback_ipv4_pfx \
								-labelValueStart $ldp_start_label
							ixNet commit
							
# -- add ibgp via unconnected interface
							set ibgp [ ixNet add $hPort/protocols/bgp neighborRange ]
							ixNet setM $ibgp \
								-bgpId $pe_loopback_ipv4_addr \
								-interfaceType {Protocol Interface} \
								-interfaces $int \
								-localAsNumber $pe_bgp_as \
								-dutIpAddress $p_pe_dut_loopback_addr \
								-type "internal"
							ixNet commit
							set ibgp [ixNet remapIds $ibgp]
							lappend pe_i_bgp(ROUTER,$port) $ibgp
# -- add l3 site
							if { $vpn_unique_per_pe == 0 } {
								set pe_vpn_route_addr $pe_co_vpn_route_addr
							}
							for { set vpnIndex 0 } { $vpnIndex < $vpn_num_per_pe } { incr vpnIndex } {
Deputs Step40
								set site [ ixNet add $ibgp l3Site ]
								ixNet setM $site \
									-enabled True \
									-vrfCount 1 
								ixNet commit
								set site [ixNet remapIds $site]
								lappend pe_l3site(SITE,$ibgp) $site
# -- set RT
								set targetList [ list ]
								if { [ string is integer $asip ] } {
Deputs Step50								
									lappend targetList as
									lappend targetList $asip
									lappend targetList 0.0.0.0
								
									incr asip 		$asipStep
Deputs "asipStep:$asipStep"									
Deputs "asip:$asip"									
								} else {
Deputs Step60
									lappend targetList ip
									lappend targetList 100
									lappend targetList $asip
									
									set pfxLen [ SubnetToPrefixlenV4 $asipStep ]
									set asip   [ IncrementIPAddr $pfxLen ]
								}
								lappend targetList $assigned
Deputs "target list:$targetList"
								ixNet setA $site/target -targetList [ list $targetList ]
								ixNet setA $site/importTarget -importTargetList [ list $targetList ]
								ixNet commit
								
								incr assigned 	$assignedStep
		
# -- set vpn route
								set vpnRoute [ ixNet add $site vpnRouteRange ]
								ixNet setM $vpnRoute \
									-enabled True \
									-ipType ipv4 \
									-numRoutes $pe_vpn_route_num \
									-networkAddress $pe_vpn_route_addr \
									-fromPrefix $pe_vpn_route_mask \
									-iterationStep $pe_vpn_route_step \
									-routeStepAcrossVRFs [ GetIpStep \
										[ expr 32 - $pe_vpn_route_vrf_mod ] \
										$pe_vpn_route_vrf_step ]
								ixNet commit
# -- set vpn route RD
								if { [ string is integer $asip ] } {
									ixNet setM $vpnRoute \
										-distinguisherType as \
										-distinguisherAsNumber $d_asip \
										-distinguisherAsNumberStepAcrossVrfs $d_asipStep \
										-distinguisherAssignedNumber $d_assigned \
										-distinguisherAssignedNumberStepAcrossVrfs $d_assignedStep
										
									incr d_asip $d_asipStep	
								} else {
									ixNet setM $vpnRoute \
										-distinguisherType as \
										-distinguisherAsNumber $d_asip \
										-distinguisherAsNumberStepAcrossVrfs $d_asipStep \
										-distinguisherAssignedNumber $d_assigned \
										-distinguisherAssignedNumberStepAcrossVrfs $d_assignedStep
										
									set pfxLen [ SubnetToPrefixlenV4 $d_asipStep ]
									set d_asip [ IncrementIPAddr $pfxLen ]
								}
								incr d_assigned $d_assignedStep
Deputs "rt: ${asip}:${assigned} rd: ${d_asip}:${d_assigned}"								


								set pe_vpn_route_addr [ IncrementIPAddr \
									$pe_vpn_route_addr $pe_vpn_route_vrf_mod \
									$pe_vpn_route_vrf_step ]
							}	


							incr ldp_start_label
							set p_pe_interface(IP,$int) $pe_ipv4_addr
							set p_pe_interface(PFX,$int) $pe_ipv4_pfx
							set pe_ipv4_addr \
								[ IncrementIPAddr $pe_ipv4_addr \
								$pe_ipv4_mod $pe_ipv4_step ]
							set pe_loopback_ipv4_addr \
								[ IncrementIPAddr $pe_loopback_ipv4_addr \
								$pe_loopback_ipv4_mod $pe_loopback_ipv4_step ]
							set p_pe_dut_loopback_addr \
								[ IncrementIPAddr $p_pe_dut_loopback_addr \
								$p_pe_dut_loopback_mod $p_pe_dut_loopback_step ]
								
# -- same VPN per PE
							if { $vpn_unique_per_pe == 0 } {
								# -- translate rt
									set rtInfo			[ split $pe_bgp_rt ":" ]
									set asip			[ lindex $rtInfo 0 ]
									set assigned 		[ lindex $rtInfo 1 ]
									set rtstepInfo		[ split $pe_bgp_rt_step ":" ]
									set asipStep		[ lindex $rtstepInfo 0 ]
									set assignedStep	[ lindex $rtstepInfo 1 ]
								# -- translate rd
									set rdInfo			[ split $pe_bgp_rd ":" ]
									set d_asip			[ lindex $rdInfo 0 ]
									set d_assigned		[ lindex $rdInfo 1 ]
									set rdStepInfo		[ split $pe_bgp_rd_step ":" ]
									set d_asipStep		[ lindex $rdStepInfo 0 ]
									set d_assignedStep	[ lindex $rdStepInfo 1 ]
Deputs Step100
Deputs "rt: ${asip}:${assigned} rd: ${d_asip}:${d_assigned}"								
								set pe_co_vpn_route_addr [ IncrementIPAddr \
									$pe_co_vpn_route_addr $pe_vpn_route_mask \
									$pe_vpn_route_num ]
							}
						}

						set p_loopback_ipv4_addr [ IncrementIPAddr $p_loopback_ipv4_addr 16 1 ]
					}
					set p_loopback_ipv4_addr $p_lpback_addr
					set pe_loopback_ipv4_addr [ IncrementIPAddr \
						$pe_lpback_addr $pe_loopback_ipv4_port_mod $pe_loopback_ipv4_port_step ]
					set p_pe_dut_loopback_addr [ IncrementIPAddr \
						$dut_lpback_addr $p_pe_dut_loopback_port_mod $p_pe_dut_loopback_port_step ]
				}

			} else {
# -- No P router
# -- Config PE interface		
				if { [ info exists pe_ipv4_addr ] && [ info exists p_pe_dut_addr ] } {
						
					if { $p_pe_vlan_enable } {
						$port config \
							-intf_ip $pe_ipv4_addr \
							-intf_num $pe_router_num \
							-intf_ip_step $pe_ipv4_step \
							-intf_ip_mod $pe_ipv4_mod \
							-mask $pe_ipv4_pfx \
							-dut_ip $p_pe_dut_addr \
							-dut_ip_num $pe_router_num \
							-dut_ip_step $p_pe_dut_step \
							-dut_ip_mod $p_pe_dut_mod \
							-inner_vlan_id $p_pe_vlan_id \
							-inner_vlan_step $p_pe_vlan_step
					} else {
						$port config \
							-intf_ip $pe_ipv4_addr \
							-intf_num $pe_router_num \
							-intf_ip_step $pe_ipv4_step \
							-intf_ip_mod $pe_ipv4_mod \
							-mask $pe_ipv4_pfx \
							-dut_ip $p_pe_dut_addr \
							-dut_ip_num $pe_router_num \
							-dut_ip_step $p_pe_dut_step \
							-dut_ip_mod $p_pe_dut_mod 
					}
					
					set p_pe_vlan_id	[ expr $p_pe_vlan_id + $p_pe_vlan_step * $pe_router_num ]
					set pe_ipv4_addr [ IncrementIPAddr $pe_ipv4_addr $pe_ipv4_port_mod $pe_ipv4_port_step ]
					set p_pe_dut_addr [ IncrementIPAddr $p_pe_dut_addr $p_pe_dut_port_mod $p_pe_dut_port_step ]
				} 	

# -- Config PE loopback interface
				if { [ info exists pe_loopback_ipv4_addr ] && [ info exists p_pe_dut_loopback_addr ] } {
					set pe_lpback_addr $pe_loopback_ipv4_addr
					set dut_lpback_addr $p_pe_dut_loopback_addr
Deputs "loopback addr:$pe_lpback_addr"
				
					set pe_int	[ ixNet getL $hPort interface ]
					set p_pe_interface(CONNECTED,$port) $pe_int
# -- add unconnected interface via each p interface
					foreach pe $pe_int {					
						set int [ ixNet add $hPort interface ]
						ixNet setM $int -type routed \
										-enabled True
						ixNet commit
						set int [ ixNet remapIds $int ]
						ixNet setA $int/unconnected -connectedVia $pe
						ixNet commit
						set ip [ ixNet add $int ipv4 ]
						ixNet setM $ip \
							-ip $pe_loopback_ipv4_addr \
							-gateway $p_pe_dut_loopback_addr \
							-maskWidth $pe_loopback_ipv4_pfx
						ixNet commit
						
						lappend p_pe_interface(UNCONNECTED,$pe) $int
						set p_pe_interface(IP,$int) $pe_loopback_ipv4_addr
						set p_pe_interface(PFX,$int) $pe_loopback_ipv4_pfx

						set pe_loopback_ipv4_addr \
							[ IncrementIPAddr $pe_loopback_ipv4_addr \
							$pe_loopback_ipv4_mod $pe_loopback_ipv4_step ]
						set p_pe_dut_loopback_addr \
							[ IncrementIPAddr $p_pe_dut_loopback_addr \
							$p_pe_dut_loopback_mod $p_pe_dut_loopback_step ]
					}
					set pe_loopback_ipv4_addr [ IncrementIPAddr \
						$pe_lpback_addr $pe_loopback_ipv4_port_mod $pe_loopback_ipv4_port_step ]
					set p_pe_dut_loopback_addr [ IncrementIPAddr \
						$dut_lpback_addr $p_pe_dut_loopback_port_mod $p_pe_dut_loopback_port_step ]
					
				}			
			}
# -- Add ospf routers 
		foreach p $p_pe_interface(CONNECTED,$port) {
Deputs "unconnected interface via $p : $p_pe_interface(UNCONNECTED,$p)"
			set ospf [ ixNet add $hPort/protocols/ospf router ]
Deputs "ospf:$ospf"
			ixNet setA $ospf -enabled True
			ixNet commit
			set ospf [ ixNet remapIds $ospf ]
			
			set p_pe_ospf(ROUTER,$port) $ospf
			set ospfInt	[ ixNet add $ospf interface ]
			ixNet setM $ospfInt -connectedToDut True -interfaces $p -enabled True
			ixNet commit
			
			foreach pe $p_pe_interface(UNCONNECTED,$p) {
# -- Add ospf interface
				set pe_int_ip $p_pe_interface(IP,$pe)
				set pe_int_pfx $p_pe_interface(PFX,$pe)
Deputs "connected ip via $pe : $pe_int_ip / $pe_int_pfx"
				set ospfInt	[ ixNet add $ospf interface ]
				ixNet setM $ospfInt \
					-enabled True \
					-connectedToDut False \
					-interfaceIpAddress $pe_int_ip \
					-advertiseNetworkRange True \
					-networkRangeIp $pe_loopback_ipv4_addr \
					-networkRangeIpMask $pe_loopback_ipv4_pfx \
					-networkRangeIpByMask True \
					-networkRangeLinkType pointToPoint \
					-networkRangeRouterId $pe_loopback_ipv4_addr \
					-interfaceIpMaskAddress [ PrefixlenToSubnetV4 $pe_int_pfx ]
				if { $p_router_num } {
					ixNet setA $ospf -routerId $p_loopback_ipv4_addr
				} else {
					ixNet setA $ospf -routerId $pe_int_ip
				}
				ixNet commit
				set pe_loopback_ipv4_addr [ IncrementIPAddr \
				$pe_loopback_ipv4_addr $pe_loopback_ipv4_mod $pe_loopback_ipv4_step ]

			}
			set p_loopback_ipv4_addr [ IncrementIPAddr $p_loopback_ipv4_addr 16 1 ]
Deputs "P router id:$p_loopback_ipv4_addr"
		}


	}



    return [GetStandardReturnHeader]
	
}


