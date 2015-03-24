
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.7
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1
#		2. Change mask to all zero
# Version 1.2.2.4
#		3. Add Filter Father object, inherited by StatsFilter and CaptureFilter
# Version 1.3.2.15
#		4. Change vlan_pri field to hex in Filter.config
# Version 1.4.2.16
#		5. Modify ip_dscp field value and ip_tos field value in Filter.config
# Version 1.5.3.7
#		6. Add IPv6 in Filter.config -packet_type
# Version 1.6.6.20
#		7. Change filter_mask {ff ff...ff} into {00 00 ... 00}
# Version 1.7.8.27
#       8. pattern set mode change from {AA BB CC} to {AABBCC}
#       9. clear old configuration when call Filter.config
#       10. vlan_id Int2Hex $value

class Filter {
    
    #inherit NetObject
    #--public method
    constructor {} {
		set field_value ""
		set ip_offset 	0
		set vlan_offset 0
		set mpls_offset 0
		set arp_offset	0
		set udp_offset	0
		set sip_offset	0
		set field_offset -1
		set field_mask {00}
		set eth_dst		""
		set eth_src		""
	}
	
    method config { args } {}
	method unconfig {} {}
    
    public variable hPort
	
	public variable field_value
	public variable ip_offset
	public variable vlan_offset
	public variable mpls_offset
	public variable arp_offset
	public variable udp_offset
	public variable sip_offset
	public variable field_offset
	public variable field_mask

	public variable eth_dst
	public variable eth_src
}

body Filter::config { args } {
    global errorInfo
    global errNumber
	
	set field_value ""
	set ip_offset 	0
	set vlan_offset 0
	set mpls_offset 0
	set arp_offset	0
	set udp_offset	0
	set sip_offset	0
	set field_offset -1
	set field_mask {00}
	set eth_dst		""
	set eth_src		""
    
    set tag "body Filter::config [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -packet_type {
                set packet_type $value
            }
			-value {
				set filter_value $value
			}
			-start {
				set filter_start $value
			}
			-end {}
			-mask {
			    if {[regsub -all "f" $value "0" newvalue]} {
				    set filter_mask $newvalue
				} else {
				    set filter_mask $value
			    }		
			}
		}
	}		
	
	
	
    if { [ info exists packet_type ] } {
		set packet_type [ string tolower $packet_type ]
		switch $packet_type {
			vlan -
			vlan_vlan {
				set vlan_offset 14
			}
			ip -
			ipv6 {
				set ip_offset 	14
			}
			vlan_ip -
			vlan_ipv6 {
				set ip_offset 	18
				set vlan_offset 14
			}
			vlan_vlan_ip -
			vlan_vlan_ipv6 {
				set ip_offset 	22
				set vlan_offset 14
			}
			mpls_ip -
			mpls_ipv6 {
				set ip_offset 	18
				set mpls_offset 14
			}
			arp {
				set arp_offset 	14
			}
			vlan_arp {
				set arp_offset 	18
				set vlan_offset 14
			}
			vlan_vlan_arp {
				set arp_offset 	22
				set vlan_offset	14
			}
			ip_udp_sip {
				set ip_offset 	14
				set udp_offset	34
			}
			ipv6_udp_sip {
				set ip_offset 	14
				set udp_offset	54				
			}
			ip_udp_dhcp {
				set ip_offset 	14
				set udp_offset	34
				set dhcp_offset	42
			}
			ipv6_udp_dhcp {
				set ip_offset 	14
				set udp_offset	54
				set dhcp_offset	62
			}
			vlan_ip_udp_dhcp {
				set vlan_offset	14
				set ip_offset 	18
				set udp_offset	38
				set dhcp_offset	46
			}
			vlan_ipv6_udp_dhcp {
				set vlan_offset	14
				set ip_offset 	18
				set udp_offset	58
				set dhcp_offset	66
			}
			vlan_vlan_ip_udp_dhcp {
				set vlan_offset	14
				set ip_offset 	22
				set udp_offset	42
				set dhcp_offset	50
			}
			vlan_vlan_ipv6_udp_dhcp {
				set vlan_offset	14
				set ip_offset 	22
				set udp_offset	62
				set dhcp_offset	70
			}
			ip_icmp {
				set ip_offset 	14
				set icmp_offset	34
			}
			vlan_ip_icmp {
				set ip_offset 	18
				set icmp_offset	38
				set vlan_offset 14
			}
			vlan_vlan_ip_icmp {
				set ip_offset 	22
				set icmp_offset	42
				set vlan_offset 14
			}
		}
	} else {
		if { [ info exists filter_value ] && [ info exists filter_start ] } {

			set field_offset	$filter_start
			set field_value 	[ Mac2PatternHex $filter_value ]
Deputs "field_value:$field_value"
			if { [ info exists filter_mask ] } {
				set field_mask 		$filter_mask
			} else {
				set field_mask ""
				for { set index 0 } { $index < [ string length $field_value ] } { incr index } {
					if { [ string index $field_value $index ] != " " } {
						set field_mask "${field_mask}0"
					}
				}
Deputs "field_mask:$field_mask"
			}			
		} else {
			# if { [ info exists filter_value ] } {
			
				# return [ GetErrorReturnHeader "Madatory parameter packet_type or value/start/end/mask can't be found." ]
			# }
		}
	}

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -eth_dst {
                set eth_dst [ Mac2Hex $value ]
            }
            -eth_src {
                set eth_src [ Mac2Hex $value ]
            }
            -eth_type {
				set field_mask {0000}
				set field_offset	12
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
            }
            -ip_src {
				set field_mask {00000000}
				set field_offset	12
				incr field_offset	$ip_offset
				set field_value 	[ IP2Hex $value ]
				
            }
			-ip_dst {
				set field_mask {00000000}
				set field_offset	16
				incr field_offset	$ip_offset
				set field_value 	[ IP2Hex $value ]
			}
			-ip_ttl {
				set field_mask {00}
				set field_offset	8
				incr field_offset	$ip_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-ip_flag {
				set field_mask {1F}
				set field_offset	6
				incr field_offset	$ip_offset
				set field_value 	[expr 0x$value<<1]
				set field_value         [format %X $field_value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value [format "%s0" $field_value]
				}
			}
			-ip_pro {
				set field_mask {00}
				set field_offset	9
				incr field_offset	$ip_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-ip_precedence {
				set field_mask {1F}
				set field_offset	1
				incr field_offset	$ip_offset
				set field_value 	[expr 0x$value<<1]
				set field_value         [format %X $field_value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	[format "%s0" $field_value]
				}
			}
			-ip_dscp {
				set field_mask {03}
				set field_offset	1
				incr field_offset	$ip_offset
				set field_value 	[expr $value<<2]
				set field_value         [format %X $field_value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-ip_tos {
				set field_mask {E1}
				set field_offset	1
				incr field_offset	$ip_offset
				set field_value 	[expr 0x$value<<1]
				set field_value         [format %X $field_value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-vlan_pri1 {
				set field_mask {1F}
				set field_offset	0
				incr field_offset	$vlan_offset
				set field_value 	[ format %x [ expr round($value * pow(2,5)) ] ]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}			
			-vlan_pri2 {
				set field_mask {1F}
				set field_offset	4
				incr field_offset	$vlan_offset
				set field_value 	[ format %x [ expr round($value * pow(2,5)) ] ]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-vlan_id1 {
				set field_mask {F000}
				set field_offset	0
				incr field_offset	$vlan_offset
				set field_value 	[Int2Hex $value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}			
			-vlan_id2 {
				set field_mask {F000}
				set field_offset	4
				incr field_offset	$vlan_offset
				set field_value 	[Int2Hex $value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-vlan_type1 {
				set field_mask {0000}
				set field_offset	2
				incr field_offset	$vlan_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-vlan_type2 {
				set field_mask {0000}
				set field_offset	6
				incr field_offset	$vlan_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-mpls_exp1 {
				set field_mask {F1}
				set field_offset	2
				incr field_offset	$mpls_offset
				set field_value 	[expr 0x$value<<1]
				set field_value         [format %X $field_value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-mpls_exp2 {
				set field_mask {F1}
				set field_offset	6
				incr field_offset	$mpls_offset
				set field_value 	[expr 0x$value<<1]
				set field_value         [format %X $field_value]
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-arp_type {
				set field_mask {0000}
				set field_offset	6
				incr field_offset	$arp_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-sender_mac {
				#set field_mask {00 00 00 00 00 00}
				set field_mask {000000000000}
				set field_offset	8
				incr field_offset	$arp_offset
				set field_value 	[ Mac2PatternHex $value ]
			}
			-sender_ip {
				set field_mask {00 00 00 00}
				set field_offset	14
				incr field_offset	$arp_offset
				set field_value 	[ IP2Hex $value ]
			}
			-target_mac {
				#set field_mask {00 00 00 00 00 00}
				set field_mask {000000000000}
				set field_offset	18
				incr field_offset	$arp_offset
				set field_value 	[ Mac2PatternHex $value ]
			}
			-target_ip {
				set field_mask {00 00 00 00}
				set field_offset	24
				incr field_offset	$arp_offset
				set field_value 	[ IP2Hex $value ]
			}
			-udp_sport {
				set field_mask {0000}
				set field_offset	0
				incr field_offset	$udp_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-udp_dport {
				set field_mask {0000}
				set field_offset	2
				incr field_offset	$udp_offset
				set field_value 	$value
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-dhcp_type {
Deputs "dhcp offset:$dhcp_offset"
				set field_mask {00}
				set field_offset	242
				incr field_offset	$dhcp_offset
				set field_value 	"$value"
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			-icmp_type {
Deputs "icmp offset:$icmp_offset"
				set field_mask {00}
				set field_offset	0
				incr field_offset	$icmp_offset
				set field_value 	"$value"
				while { [ string length $field_value ] < [ string length $field_mask ] } {
					set field_value 	"0$field_value"
				}
			}
			
        }
    }
	
	return [ GetStandardReturnHeader ]
}

class StatsFilter {
    inherit Filter
	
}

class CaptureFilter {
	inherit Filter
}

proc Mac2PatternHex { mac } {
    set value $mac
    set len [ string length $value ]
    for { set index 0 } { $index < $len } { incr index } {
        if { [ string index $value $index ] == " " || \
            [ string index $value $index ] == "-" ||
            [ string index $value $index ] == "." ||
			[ string index $value $index ] == ":" } {

			set value [ string replace $value $index $index "" ] 

        }
    }

    return $value
	
}


