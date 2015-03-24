
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.3
#===============================================================================
# Change made
# Version 1.1 
#       1. Create
# Version 1.2.3.5
#		2. Add multiSession support in reborn

class LldpDcbxHost {
	
    inherit ProtocolStackObject
    constructor { port } { chain $port } {} 
    method reborn {} {}
    method config { args } {}
    method pause {} {}
    method resume {} {}
    method get_lldp_host_stats {} {}
    method get_lldp_neighbor_stats {} {}

    public variable hDcbx
}

body LldpDcbxHost::reborn {} {
	set tag "body LldpDcbxHost::reborn [info script]"
Deputs "----- TAG: $tag -----"
	
	set root [ ixNet getRoot ]
	if { [ llength [ixNet getL $root/globals/protocolStack dcbxGlobals] ] > 0 } {
		set dcbGlobal [ lindex [ixNet getL $root/globals/protocolStack dcbxGlobals] 0 ]
	} else {
		set dcbGlobal [ixNet add $root/globals/protocolStack dcbxGlobals]
		ixNet commit
		set dcbGlobal [ixNet remapIds $dcbGlobal]
	}
Deputs "dcb global:$dcbGlobal"
	ixNet setA $dcbGlobal -allowMultipleSessions True
	ixNet commit
	chain
	set stackLen [ llength [ ixNet getL $hPort/protocolStack ethernet ] ]
	if { $stackLen == 0 } {
		#chain
		#-- add dcbx endpoint stack
		set sg_dcbxEndpoint [ixNet add $stack dcbxEndpoint]
		ixNet setA $sg_dcbxEndpoint -name $this
		ixNet commit
		set sg_dcbxEndpoint [lindex [ixNet remapIds $sg_dcbxEndpoint] 0]
		set hDcbx $sg_dcbxEndpoint
	} else {
		set stack [ lindex [ ixNet getL $hPort/protocolStack ethernet ] 0 ]
		set sg_dcbxEndpoint [ lindex [ ixNet getL $stack dcbxEndpoint ] 0 ]
	}
Deputs "stack:$stack"  
Deputs "sg_dcbxEndpoint:$sg_dcbxEndpoint"  
	
	#-- add range
	set sg_range [ixNet add $sg_dcbxEndpoint range]
	ixNet setMultiAttrs $sg_range/macRange \
	 -enabled True 
	
	ixNet setMultiAttrs $sg_range/vlanRange \
	 -enabled False \
	
	ixNet setMultiAttrs $sg_range/dcbxRange \
	 -name $this \
	 -enabled True 
	
	ixNet commit
	set sg_range [ixNet remapIds $sg_range]
	
	set handle $sg_range  

}
body LldpDcbxHost::config { args } {
    set tag "body LldpDcbxHost::config [info script]"
Deputs "----- TAG: $tag -----"
		
# reborn
    if { $handle == "" } {
	    reborn
    }
	
    eval chain $args
    
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -host_cnt {
            	set host_cnt $value
            }
            -msg_tx_interval {
            	set msg_tx_interval $value
            }
            -msg_tx_hold_multiplier {
            	set msg_tx_hold_multiplier $value
            }
            -reinit_delay {
            	set reinit_delay $value
            }
            -tx_delay {
            	set tx_delay $value
            }
            -dst_mac_addr {
            	set dst_mac_addr $value
            }
            -enable_vlan {
            	set enable_vlan $value
            }
            -tlv_list {
            	set tlv_list $value
            }
        }
    }

    if { [ info exists msg_tx_interval ] } {
	ixNet setA $handle/dcbxRange -txInterval $msg_tx_interval	    
    }
    if { [ info exists msg_tx_hold_multiplier ] } {
    	ixNet setA $handle/dcbxRange -holdTime $msg_tx_hold_multiplier
    }
    if { [ info exists tx_delay ] } {
    	ixNet setA $handle/dcbxRange -txDelay $tx_delay
    }
    if { [ info exists dst_mac_addr ] } {
	ixNet setA $handle/dcbxRange -destMacAddress $dst_mac_addr
    }
    if { [ info exists enable_vlan ] } {
    	ixNet setA $handle/vlanRange -enabled True
    }
	
    set notSupportFlag 0
    set log ""
	
    if { [ info exists tlv_list ] } {
	    
	    set subTlv [list]
	    
	    #-- for lldp Tlv
	    foreach tlv $tlv_list {
Deputs "tlv:$tlv"
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
						set chassis_id [ $tlv cget -chassis_id ]
Deputs "chassis_id : $chassis_id"						
			    	if { $chassis_id != "" && $chassis_id != "<undefined>" } {
						    if { [ IsMacAddress [ MacTrans $chassis_id ] ] == 0 } {
							    set notSupportFlag 1
							    set log "Only MAC address tlv_type is supported."					    					    
						    } else {
						    	ixNet setA $handle/dcbxRange -chassisId $chassis_id
						    }
				    }
			    }
			    portid {
				    set port_id [ string tolower [ $tlv cget -port_id ] ]
				    set port_id_type [ string tolower [ $tlv cget -port_id_type ] ]
Deputs "port_id_type: $port_id_type"
Deputs "port_id: $port_id"	
					if { $port_id != "" && $port_id != "<undefined>" } {
						switch $port_id_type {
							interface_name {
							ixNet setA $handle/dcbxRange -portIdSubType 1
								ixNet setA $handle/dcbxRange -portIdInterfaceName $port_id
							}
							mac_addr {
								ixNet setA $handle/dcbxRange -portIdSubType 0
								ixNet setA $handle/dcbxRange -portIdMacAddress $port_id
							}
							default {
								set notSupportFlag 1
								set log "Only interface_name & mac_addr type are supported."					    					    
							}
						}
					}
			    }
			    subtype {
				    set oui [ $tlv cget -oui ]
				    set ouidot [ string range $oui 0 1 ].[ string range $oui 2 3 ].[ string range $oui 4 5 ]
				    set org [ $tlv cget -org ]
				    lappend subTlv [ $tlv cget -val ]
Deputs "oui:$ouidot org:$org"				    
				    ixNet setA $handle/dcbxRange -oui $ouidot
				    ixNet setA $handle/dcbxRange -dcbxSubtype $org
			    }
			    ets -
			    app_pri -
			    pbfc {
		    		    set org 3
				    ixNet setA $handle/dcbxRange -dcbxSubtype $org
				    lappend subTlv $tlv
			    }
		    }
	    }
	    
	    ixNet commit
	    
	    if { [ llength $subTlv ] == 1 } {
	    	eval set subTlv $subTlv
	    }
Deputs "subTlv:$subTlv len:[llength $subTlv]"
	    #-- remove all dcbx Tlv
	    if { [ llength $subTlv ] > 0 } {
		    switch $org {
			    1 -
			    2 {
                        	    set dcbxTlvList [ ixNet getL $handle/dcbxRange dcbxTlv ]
			    }
			    3 {
				    set dcbxTlvList [ ixNet getL $handle/dcbxRange dcbxTlvQaz ]
			    }
		    }
        	    foreach dcbxRemove $dcbxTlvList {
        		    ixNet remove $dcbxRemove
        		    ixNet commit
        	    }
	    }
	    #-- add new dcbx Tlv
Deputs "handle:$handle"
	    foreach tlv $subTlv {
Deputs "tlv:$tlv"
		    if { [ $tlv isa DcbxTlv ] == 0 } {
			    error "$errNumber(1) key:tlv_list value:$tlv"					    			    
		    }
		    switch $org {
			    1 -
			    2 {
			    	set dcbxTlv [ ixNet add $handle/dcbxRange dcbxTlv ]
			    }
			    3 {
				set dcbxTlv [ ixNet add $handle/dcbxRange dcbxTlvQaz ]
			    }
		    }
		    ixNet commit
		    set dcbxTlv [ ixNet remapIds $dcbxTlv ]
#Deputs "dcbxTlv:$dcbxTlv"		    
    		    set tlv_type [ $tlv cget -tlv_type ]
Deputs "tlv_type:$tlv_type"
		    switch $tlv_type {
			    ignore {
				    ixNet remove $dcbxTlv
				    ixNet commit
				    continue
			    }
			    pg {
				    ixNet setM $dcbxTlv \
				    	-featureType 2 \
				    	-featureEnable True
				    ixNet commit
				    				    
				    set bgw_pct [ $tlv cget -bgw_pct ]
Deputs "bgw_pct:$bgw_pct"					
						    array set pg_attr [ $tlv getPG ]
Deputs "pg_attr: [array names pg_attr]"							
				    switch $org {
        				    1 {
						    set pgTlv $dcbxTlv/tlvSettings/dcbxTlvPgIntel
						   
						    for { set index 0 } { $index < 8 } { incr index } {
							    set attr [ lindex [ ixNet getL $pgTlv dcbxBandwidthAtt ] $index ]
							    if { [ info exists pg_attr($index,id) ] } {
								    ixNet setA $attr -bwGroupId $pg_attr($index,id) 
							    }
							    if { [ info exists pg_attr($index,pri) ] } {
								    ixNet setA $attr -strictPriority $pg_attr($index,pri)
							    }
							    if { [ info exists pg_attr($index,pct) ] } {
Deputs "pg pct:$pg_attr($index,pct)"
								ixNet setA $attr -bwPercentage $pg_attr($index,pct)
							    }
						    }
Deputs "bgw_pct:$bgw_pct"
Deputs "pgTlv:$pgTlv"					
						    ixNet setA $pgTlv -bwGroupPercentageMap $bgw_pct
Deputs "[ixNet getA $pgTlv -bwGroupPercentageMap]"						    
        				    } 
        				    2 {
						set num_tcs_supported [ $tlv cget -num_tcs_supported ]
        				    	set pgTlv $dcbxTlv/tlvSettings/dcbxTlvPgIeee
Deputs "[ixNet help $pgTlv]"	
								set pgId [ list ]
						    for { set index 0 } { $index < 8 } { incr index } {
							    if { [ info exists pg_attr($index,id) ] } {
								     lappend pgId  $pg_attr($index,id)
							    } else {
							    	lappend pgId 0
							    }
						    }			
Deputs "pgId:$pgId"						    			    
						ixNet setM $pgTlv \
						    -tcsSupported $num_tcs_supported \
						    -priorityGroupPercentageMap $bgw_pct \
						    -priorityGroupIdMap $pgId


					    }
				    }
				    ixNet commit				    
				    
			    }
			    pfc {
				    ixNet setM $dcbxTlv \
				    	-featureType 3 \
				    	-featureEnable True
				    ixNet commit
			    

				    switch $org {
					    1 {
						    set pfcTlv $dcbxTlv/tlvSettings/dcbxTlvPfcIntel
					    }
					    2 {
						    set pfcTlv $dcbxTlv/tlvSettings/dcbxTlvPfcIeee
						    
						    set num_tcs_supported [ $tlv cget -num_tcs_supported ]						    
						    ixNet setA $dcbxTlv -tcsSupported $num_tcs_supported
					    }
				    }
				    
				    set pe [ $tlv cget -pe ]
Deputs "pe:$pe"		
Deputs "dcbxTlv:$dcbxTlv"			
				    ixNet setA $pfcTlv -priorityMap $pe
				    ixNet commit
			    }
			    custom {
				    set hdr_type [ $tlv cget -hdr_type ]
				    ixNet setM $dcbxTlv \
				    	-featureType $hdr_type \
				    	-featureEnable True
				    
				    set customTlv $dcbxTlv/tlvSettings/dcbxTlvCustom
				    set featureVal [ $tlv cget -val ]
				    ixNet setA $customTlv -featureTlv $featureVal
				    ixNet commit
			    }
			    app {
				    ixNet setM $dcbxTlv \
        				    -featureType 4 \
        				    -featureEnable True
				    ixNet commit
				    
				    set appTlv $dcbxTlv/tlvSettings/dcbxTlvFcoeIeee
				    
				    array set app_array [ $tlv get_app ]
Deputs "app array:[ array names app_array]"
					if { [ info exists app_array(index) ] } {
						set appIndex $app_array(index)
						
						set tlvAttr [ ixNet getL $appTlv dcbxAppProtocolAtt ]
						
						for { set index 1 } { $index <= 8 } { incr index } {
							
							set attrIndex [ expr $index - 1 ]
							set attr [ lindex $tlvAttr $attrIndex ]
								
							if { [ lsearch $appIndex $index ] >= 0 } {
									
								ixNet setA $attr -enabled True
								
								if { [ info exists app_array($index,pri) ] } {
								set priMap [list]    
								for { set priIndex 0 } { $priIndex < [ string length $app_array($index,pri) ] } { incr priIndex } {
									lappend priMap [ string index $app_array($index,pri) $priIndex ]
								}
									ixNet setA $attr -priorityMap $priMap
								}
								
								if { [ info exists app_array($index,sel) ] } {
									set sel 0
									switch $app_array($index,sel) {
										01 {
											set sel 1
										}
										10 {
											set sel 2
										}
										11 {
											set sel 3
										}
									}
									ixNet setA $attr -sel $sel
								}
								
								if { [ info exists app_array($index,id) ] } {
									ixNet setA $attr -protocolId $app_array($index,id)
								}
								
							} else {
									ixNet setA $attr -enabled False
							}
							ixNet commit
							}
					}
				}
			    app_pri {
				    ixNet setM $dcbxTlv \
        				    -featureType 12 \
        				    -featureEnable True
        			    ixNet commit
				    
				    set appTlv $dcbxTlv/tlvSettings/dcbxTlvAppQaz
				    				    
				    set ap_list [ $tlv cget -hdr_apppriority_list ]
				    set index 0
				    foreach ap $ap_list {
					    
					    set att [ lindex [ ixNet getL $appTlv dcbxAppPriorityAtt ] $index ]
					    
					    set priority [ $ap cget -hdr_priority ]
					    set protocol_id [ $ap cget -hdr_protocol_id ]
					    set sel [ $ap cget -hdr_sel ]
					    
					    ixNet setM $att -enabled True \
					    	-priority $priority \
					    	-protocolId  $protocol_id \
					    	-sel $sel
					    
					    incr index
				    }
			    }
			    ets {
				    ixNet setM $dcbxTlv \
        				    -featureType 10 \
        				    -featureEnable True
        			    ixNet commit
			    
        			    set etsTlv $dcbxTlv/tlvSettings/dcbxTlvEtsQaz

				    set factory [ $tlv cget -factory ]
				    switch $factory {
					    configuration {
						    set restrict 1
					    }
					    recommendation {
						    set restrict 2
					    }
					    default {
						    set restrict 1
					    }
				    }
				    
				    set pri [ $tlv cget -pri ]
				    set tcg [ $tlv cget -tcg ]
				    set tsa [ $tlv cget -tsa ]
				    
				    ixNet setM $etsTlv \
				    	-tlvSendRestriction $restrict \
				    	-tcGroupPriorityMap $pri \
				    	-tcGroupTsaMap $tsa \
				    	-tcGroupBwPercentMap $tcg
				    ixNet commit
			    }
			    pbfc {
				    ixNet setM $dcbxTlv \
        				    -featureType 11 \
        				    -featureEnable True
        			    ixNet commit
        		    
        			    set pbfcTlv $dcbxTlv/tlvSettings/dcbxTlvPfcQaz
Deputs "pbfcTlv: $pbfcTlv"				    
				    set pe [ $tlv cget -pe ]
				    set hdr_pfc_cap [ $tlv cget -hdr_pfc_cap ]
				    set hdr_mbc [ $tlv cget -hdr_mbc ]
Deputs "pe:$pe hdr_pfc_cap:$hdr_pfc_cap hdr_mbc:$hdr_mbc"
				    
				    ixNet setM $pbfcTlv \
				    	-mbc $hdr_mbc \
				    	-pfcCapability $hdr_pfc_cap \
				    	-pfcEnableVector $pe
				    ixNet commit
			    }
		    }
		    
		    if { $org != 3 } {
        		    set hdr_en [ $tlv cget -hdr_en ]
        		    set hdr_willing [ $tlv cget -hdr_willing ]
        		    set hdr_err [ $tlv cget -hdr_err ]
        		    set hdr_sub_type [ $tlv cget -hdr_sub_type ]
        		    set hdr_max_ver [ $tlv cget -hdr_max_ver ]
        		    
        		    ixNet setM $dcbxTlv \
        		    	-errorOveride True \
        		    	-error $hdr_err \
        		    	-maxVersion $hdr_max_ver \
        		    	-subType $hdr_sub_type \
        		    	-featureEnable $hdr_en \
        		    	-willing $hdr_en
        		    ixNet commit
		    }
		    
	    }
    }
	
    ixNet commit
	
    if { $notSupportFlag } {
	    return [ GetErrorReturnHeader $log ]
	    	    
    }
    return  [ GetStandardReturnHeader ]
	
}
body LldpDcbxHost::pause {} {
	set tag "body LldpDcbxHost::pause [info script]"
Deputs "----- TAG: $tag -----"
	return [ GetErrorReturnHeader "Method not supported yet." ]
	
}
body LldpDcbxHost::resume {} {
	set tag "body LldpDcbxHost::resume [info script]"
Deputs "----- TAG: $tag -----"
	return [ GetErrorReturnHeader "Method not supported yet." ]
	
}
body LldpDcbxHost::get_lldp_host_stats {} {
	set tag "body LldpDcbxHost::get_lldp_host_stats [info script]"
	Deputs "----- TAG: $tag -----"
	set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"DCBX"}
Deputs "view:$view"
    	set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
	set port_name			[ lsearch -exact $captionList {Stat Name} ]
	set rx_age_outs_count          	[ lsearch -exact $captionList {LLDP Age Out Count} ]
	set rx_error_frame_count        [ lsearch -exact $captionList {LLDP Error Rx} ]
	set rx_frame_count          	[ lsearch -exact $captionList {LLDP Rx} ]
#	set rx_frame_discarded_count    [ lsearch -exact $captionList {NA} ]
#	set rx_tlvs_discarded_count     [ lsearch -exact $captionList {NA} ]
	set rx_tlvs_unrecognized_count  [ lsearch -exact $captionList {LLDP Unrecognized TLV Rx} ]
	set tx_frame_count       	[ lsearch -exact $captionList {LLDP Tx} ]

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

	set statsItem   "rx_age_outs_count"
	set statsVal    [ lindex $row $rx_age_outs_count ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	  
	set statsItem   "rx_error_frame_count"
	set statsVal    [ lindex $row $rx_error_frame_count ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	      
	set statsItem   "rx_frame_count"
	set statsVal    [ lindex $row $rx_frame_count ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
	set statsItem   "rx_frame_discarded_count"
	set statsVal    "NA"
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
	set statsItem   "rx_tlvs_discarded_count"
	set statsVal    "NA"
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	  
	set statsItem   "rx_tlvs_unrecognized_count"
	set statsVal    [ lindex $row $rx_tlvs_unrecognized_count ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	      
	set statsItem   "tx_frame_count"
	set statsVal    [ lindex $row $tx_frame_count ]
Deputs "stats val:$statsVal"
	set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
Deputs "ret:$ret"

    }
	
    return $ret

}

###---
# valid tlv_type:
#	ignore
#	chasid
#	portid
class LldpTlv {
	inherit Tlv
}

class LldpEndTlv {
	inherit LldpTlv
}

class LldpTtlTlv {
	inherit LldpTlv
}

class LldpCustomTlv {
	inherit LldpTlv
}

class LldpChassisIdTlv {
	inherit LldpTlv
	
	public variable chassis_id_type
	public variable chassis_id
	
	constructor {} { chain chasid } {}
	method config { args } {}
}
body LldpChassisIdTlv::config { args } {
	global errorInfo
	global errNumber
    	
	set tag "body LldpChassisIdTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
    	
	#param collection
	Deputs "Args:$args "
	    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
		    
		    -chassis_id {
			    set chassis_id $value
		    }
		    -chassis_id_type {
			    set chassis_id_type $value
		    }
		}
	    }

	
	return [GetStandardReturnHeader]
	
}

class LldpPortIdTlv {
	inherit LldpTlv
	
	public variable port_id_type
	public variable port_id
	
	constructor {} { chain portid } {
		set port_id_type mac_addr
	}
	method config { args } {}
}
body LldpPortIdTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body LldpPortIdTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
	    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
		    
		    -port_id {
			    set port_id $value
		    }
		    -port_id_type {
			    set port_id_type $value
		    }
		}
	    }
		
	return [GetStandardReturnHeader]
	
}

###---
# valid tlv_type:
#	ignore
#	subtype
#	pg
class DcbxTlv {
	inherit LldpTlv
	
	public variable hdr_en
	public variable hdr_willing
	public variable hdr_err
	public variable hdr_sub_type
	public variable hdr_max_ver
	
	method config { args } {
        	global errorInfo
        	global errNumber
        	    
        	set tag "body DcbxTlv::config [info script]"
            Deputs "----- TAG: $tag -----"
        	    
        	#param collection
        	Deputs "Args:$args "
        	foreach { key value } $args {
        	    set key [string tolower $key]
        	    switch -exact -- $key {
        		
        		-hdr_en {
        			set hdr_en $value
        		}
        		-hdr_willing {
        			set hdr_willing $value
        		}
        		-hdr_err {
        			set hdr_err $value
        		}
        		-hdr_sub_type -
        		-subtype {
        			set hdr_sub_type $value
        		}
        		-hdr_max_ver -
        		-max_ver {
        			set hdr_max_ver $value
        		}
        	    }
        	}
        	return [GetStandardReturnHeader]
	}
}

class DcbxSubTypeTlv {
	inherit DcbxTlv
	
	public variable oui
	public variable org
	
	method config { args } {}
}
body DcbxSubTypeTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body LldpSubTypeTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                
                -oui {
                	set oui $value
                }
                -value {
                	set val $value
                }
            }
        }
	eval chain $args
	
	return [GetStandardReturnHeader]
	
}

class DcbxSubType1Tlv {
	inherit DcbxSubTypeTlv
	constructor {} { chain subtype } { 
		set org 1 
		set oui 001b21
	}
}

class DcbxSubType2Tlv {
	inherit DcbxSubTypeTlv
	constructor {} { chain subtype } { 
		set org 2 
		set oui 001b21
	}
}

class DcbxValueControlTlv {
	inherit DcbxTlv
}

class DcbxValuePgFeatureTlv {
	inherit DcbxTlv
	
	public variable bwg_pct_array
	public variable bgw_pct
	public variable pg_attr
	public variable num_tcs_supported
	
	constructor {} { chain pg } {
		array set bwg_pct_array [ list ]
		array set pg_attr [ list ]
	}
	method config { args } {}
	method getPG {} {
		return [ array get pg_attr ]
	}
    method getBWG {} {
	    return [ array get bwg_pct_array ]
	  
	}
}
body DcbxValuePgFeatureTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body DcbxValuePgFeatureTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
	eval chain $args
	array set bwg_pct_array [list]
	array set pg_attr [list]

	foreach { key value } $args {
	    set key [string tolower $key]
	    if { [ regexp -- {-bwg_pct([0-7])} $key match index ] } {
	    	    set bwg_pct_array($index) $value
	    }
	    if { [ regexp -- {-pri([0-7])_bwg_id} $key match index ] } {
		    set pg_attr($index,id) $value
	    }
            if { [ regexp -- {-pri([0-7])_strict_pri} $key match index ] } {
            	set pg_attr($index,pri) $value
            }
            if { [ regexp -- {-pri([0-7])_bwg_pct} $key match index ] } {
            	set pg_attr($index,pct) $value
            }
            switch -exact -- $key {
		    -numtcssupported -
		    -num_tcs_supported {
			    set num_tcs_supported $value
		    }
		    
            }
		    

	}
	
	set bgw_pct [list]
	for { set index 0 } { $index < 8 } { incr index } {
		if { [ info exists bwg_pct_array($index) ] } {
			lappend bgw_pct $bwg_pct_array($index)
		} else {
			lappend bgw_pct 0
		}
	}
	return [GetStandardReturnHeader]
}

class DcbxValuePfcFeatureTlv {
	inherit DcbxTlv
	
	public variable pe_array
	public variable pe
	public variable num_tcs_supported
	
	constructor {} { chain pfc } {}
	method config { args } {}
	method getPE {} {
		return [ array get pe_array ]
	}
	
}
body DcbxValuePfcFeatureTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body DcbxValuePfcFeatureTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
	eval chain $args
	
	array set pe_array [list]
	foreach { key value } $args {
	    set key [string tolower $key]
	    if { [ regexp -- {-pe([0-7])} $key match index ] } {
			set pe_array($index) $value
	    }		
	    switch -exact -- $key {
		-tcpfc_num {
			set num_tcs_supported $value
		}
	    }
	}
	set pe [list]
	for { set index 0 } { $index < 8 } { incr index } {
		if { [ info exists pe_array($index) ] } {
			lappend pe $pe_array($index)
		} else {
			lappend pe 0
		}
	}
	return [GetStandardReturnHeader]
}

class DcbxValueAppFeatureTlv {
	inherit DcbxTlv
	
	public variable app_array
	
	constructor {} { chain app } {}
	method config { args } {}
	method get_app {} {
		return [ array get app_array ]
	}
}
body DcbxValueAppFeatureTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body DcbxValueAppFeatureTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	
	eval chain $args
	
    array set app_array [list]
    foreach { key value } $args {
	set key [string tolower $key]
	if { [ regexp -- {-pri_map([1-8])} $key match index ] } {
	    if { [ info exists app_array(index) ] == 0 } {
		    lappend app_array(index) $index
	    } else {
        	    if { [ lsearch $app_array(index) $index ] < 0 } {
			    lappend app_array(index) $index
        	    }
	    }
	    set app_array($index,pri) $value
	}
        if { [ regexp -- {-app([1-8])_id} $key match index ] } {
            if { [ info exists app_array(index) ] == 0 } {
            	lappend app_array(index) $index
            } else {
            	if { [ lsearch $app_array(index) $index ] < 0 } {
            		lappend app_array(index) $index
            	}
            }
            set app_array($index,id) $value
        }
        if { [ regexp -- {-app([1-8])_selector} $key match index ] } {
        	if { [ info exists app_array(index) ] == 0 } {
        		lappend app_array(index) $index
        	} else {
        		if { [ lsearch $app_array(index) $index ] < 0 } {
        			lappend app_array(index) $index
        		}
        	}
        	set app_array($index,sel) $value
        }
    }
    
Deputs "app: [ array names app_array ]"
    return [GetStandardReturnHeader]

}

class DcbxValueCustomFeatureTlv {
	inherit DcbxTlv
		
	public variable hdr_type 
	
	constructor {} { chain custom } {}
	method config { args } {}
}
body DcbxValueCustomFeatureTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body DcbxValueCustomFeatureTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
	eval chain $args
	
	foreach { key value } $args {
	    set key [string tolower $key]	
	    switch -exact -- $key {
		-value {
			set val $value
		}
		-hdr_type {
			set hdr_type $value
		}
	    }
	}
	return [GetStandardReturnHeader]
	
}

class ApplicationPriorityTlv {
	inherit DcbxTlv
	
	constructor {} { chain app_pri } {}
	method config { args } {}
	
	public variable hdr_apppriority_list
}
body ApplicationPriorityTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body ApplicationPriorityTlv::config [info script]"
    Deputs "----- TAG: $tag -----"

	#param collection
	Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
		    -hdr_apppriority_list {
			    set hdr_apppriority_list $value
		    }
		}
	}
        eval chain $args
        return [GetStandardReturnHeader]

}
class AppPriority {
	
	inherit NetObject
	
	public variable hdr_priority
	public variable hdr_protocol_id
	public variable hdr_sel
	
	method config { args } {}
}
body AppPriority::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body AppPriority::config [info script]"
    Deputs "----- TAG: $tag -----"

	#param collection
	Deputs "Args:$args "
        foreach { key value } $args {
        	set key [string tolower $key]
        	switch -exact -- $key {
        	    -hdr_priority {
        		    set hdr_priority $value
        	    }
        	    -hdr_protocol_id {
			    set hdr_protocol_id $value
        	    }
        	    -hdr_sel {
			    set hdr_sel $value
        	    }
        	}
        }
	return [GetStandardReturnHeader]
			
}

class ETSTlv {
	
	inherit DcbxTlv
	constructor {} { chain ets } {}
	method config { args } {}
	
	public variable pri_array
	public variable tcg_array
	public variable tsa_array
	
	public variable pri
	public variable tcg
	public variable tsa
	
	public variable factory
}
body ETSTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body EtsTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
	eval chain $args
	
	array set pri_array [list]
	array set tcg_array [list]
	array set tsa_array [list]
	
	foreach { key value } $args {
	    set key [string tolower $key]
	    if { [ regexp -- {-priority([0-7])} $key match index ] } {
			set pri_array($index) $value
	    }
	    if { [ regexp -- {-tcg_percentage([0-7])} $key match index ] } {
			set tcg_array($index) $value
	    }
            if { [ regexp -- {-tsa([0-7])} $key match index ] } {
            	    set tsa_array($index) $value
            }
	}
	
	set pri [list]
	for { set index 0 } { $index < 8 } { incr index } {
		if { [ info exists pri_array($index) ] } {
			lappend pri $pri_array($index)
		} else {
			lappend pri 0
		}
	}
	
	set tcg [list]
	for { set index 0 } { $index < 8 } { incr index } {
		if { [ info exists tcg_array($index) ] } {
			lappend tcg $tcg_array($index)
		} else {
			lappend tcg 0
		}
	}
	
	set tsa [list]
	for { set index 0 } { $index < 8 } { incr index } {
		if { [ info exists tsa_array($index) ] } {
			lappend tsa $tsa_array($index)
		} else {
			lappend tsa 0
		}
	}
	
	return [GetStandardReturnHeader]

}

class ETSConfigurationTlv {
	
	inherit ETSTlv
	constructor {} { chain } {
		set factory configuration
	}
}

class ETSRecommendationTlv {
	
	inherit ETSTlv
	constructor {} { chain } {
		set factory recommendation
	}
}

class PriorityBasedFlowControlTlv {
	inherit DcbxTlv
	
	public variable pe_array
	public variable pe

	public variable hdr_pfc_cap
	public variable hdr_mbc
	
	constructor {} { chain pbfc } {}
	method config { args } {}

}
body PriorityBasedFlowControlTlv::config { args } {
	global errorInfo
	global errNumber
	    
	set tag "body PriorityBasedFlowControlTlv::config [info script]"
    Deputs "----- TAG: $tag -----"
	    
	#param collection
	Deputs "Args:$args "
	eval chain $args
	
	array set pe_array [list]
	foreach { key value } $args {
	    set key [string tolower $key]
	    if { [ regexp -- {-pe([0-7])} $key match index ] } {
			set pe_array($index) $value
	    }		
	    switch -exact -- $key {
		-hdr_mbc {
			set hdr_mbc $value
		}
		-hdr_pfc_cap {
			set hdr_pfc_cap $value
		}
	    }
	}
	set pe [list]
	for { set index 0 } { $index < 8 } { incr index } {
		if { [ info exists pe_array($index) ] } {
			lappend pe $pe_array($index)
		} else {
			lappend pe 0
		}
	}
Deputs "pe:$pe"	
	return [GetStandardReturnHeader]
}

