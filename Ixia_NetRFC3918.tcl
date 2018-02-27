
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class Rfc3918 {
    inherit NetObject
    
    constructor {} {}
	method reborn { } {}
    method joinLeaveDelay { args} {}
    method config { args } {}
	method unconfig {} {
		chain
		catch { 
			delete object $this.traffic
		}
	}
	
    public variable testtype
    public variable ipVersion
    public variable vlanList 
    public variable frame_len_type
    public variable load_unit
    public variable resultdir 
    public variable resultfile
    public variable portHandleList
    public variable hostHandleList    
  
   
}

body Rfc3918::reborn { } {
    set tag "body Rfc3918::reborn [info script]"
    Deputs "----- TAG: $tag -----"
    Deputs "Rfc3918 $testtype testing"

	if { [ info exists handle ] == 0 || $handle == "" } {
		set root [ixNet getRoot]
        if { $testtype == "rfc3918joinLeaveDelay" } {
		    set handle [ ixNet add $root/quickTest rfc3918joinLeaveDelay ]
        } 
		ixNet setA $handle -name $this -mode newMode
		ixNet commit
		set handle [ixNet remapIds $handle]
		
	}
}

body Rfc3918::constructor {} {
    
    set tag "body Rfc3918::ctor [info script]"
    Deputs "----- TAG: $tag -----"
    set testtype "rfc3918joinLeaveDelay"
    set ipVersion "ipv4"
    set frame_len_type "custom"
    set load_unit "percent"
    set resultdir "d:/1"
    set resultfile "1.csv"
    set portHandleList ""
    set hostHandleList ""
    set vlanList {NULL NULL NULL NULL}
    IxDebugOn
    IxDebugCmdOn
    
	#reborn 
}

body Rfc3918::config { args } {
    
    global errorInfo
    global errNumber
    set tag "body Rfc3918::config [info script]"
    Deputs "----- TAG: $tag -----"
    	  
	#wangming  
	set no_run 0
    set force 1


    set EPayloadType [ list CYCBYTE INCRBYTE DECRBYTE PRBS USERDEFINE ]
    set EFillType   [ list constant incr decr prbs random ]

	set root [ixNet getRoot]
    
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -src_endpoint {
        		set src_endpoint $value
        	}
        	-dst_endpoint {
        		set dst_endpoint $value
        	}
            -timing_endpoint {
        		set timing_endpoint $value
        	}
            -igmp_version {
                #igmp_version 1|2|3
                set value [string tolower $value]
                switch -exact -- $key {
                    igmp_v1 {
                        set igmp_version 1
                    }
                    igmp_v2 {
                        set igmp_version 2
                    }
                    igmp_v3 {
                        set igmp_version 3
                    }
                }
                
            }
            -multicast_ipv4_addr {
                set igmp_group_address $value
            }
            -group_num {
                set group_num $value
            }
            -frame_len_type {
				set frame_len_type $value
			}
        	-frame_len {
				if { [ llength $value ] < 1 } {
					 error "$errNumber(1) key:$key value:$value"
				} else {
					set frame_len $value
Deputs "frame len under test:$frame_len"			 
				}
        	}
			-frame_len_step {
				set frame_len_step $value
			}
			-frame_len_max {
				set frame_len_max $value
			}       	
        	-load_unit {
        		set load_unit $value
        	}
            -initial_rate {
                set  initial_rate  $value
            }
        	-duration {
        		set duration $value
        	}        	
			-resultdir {
				set resultdir $value
			}
			-resultfile {
                	set resultfile $value
        	}
            -pdfreportdir {
				set pdfreportdir $value
			}
			-pdfreportfile {
                	set pdfreportfile $value
        	}
        	-force {
				set trans [ BoolTrans $value ]
				if { $trans == "1" || $trans == "0" } {
					set force $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
        	}
			-resultlvl {
Deputs "set result level:$value"			
				set resultLevel $value
			}
			-no_run {
				set no_run $value
			}
			-netuse_user {
				set netuse_user $value
			}
			-netuse_pw {
				set netuse_pw $value
			}
            -join_group_delay {
                set tx_delay $value
            }
            -leave_group_delay {
                set tx_delay $value
            }
        	default {
        	    error "$errNumber(3) key:$key value:$value"
        	}
		}
    }
	
    # reborn
    if { [ info exists handle ] == 0 || $handle == "" } {
		reborn
    }

# set traffic config
Deputs "Add ports and map traffic: timing ,source, dest"   
    if { [ info exists src_endpoint ] && [ info exists dst_endpoint ] && [ info exists timing_endpoint ] } {

        set mapHandle [ixNet getL $handle trafficMapping] 
Deputs "Add timing port"
        set timingPortHandle [$timing_endpoint cget -hPort]
        lappend portHandleList $timingPortHandle
        lappend hostList $timing_endpoint
        regexp .+OBJ-(.+) $timingPortHandle m FormatTimingHandle
        set objHandle [ixNet add $handle ports]
        ixNet setA $objHandle -id $timingPortHandle
        ixNet commit
        set objHandle [lindex [ixNet remapIds $objHandle] 0]
        ixNet setM $mapHandle  \
        -hasTimingPort true \
        -mesh multicastManyToMany \
        -timingPortId $FormatTimingHandle \
        -usesLightMaps true
        ixNet commit
        set lmHandle [ixNet getL $mapHandle lightMap ]
        if {$lmHandle == ""} {
            set lmHandle [ixNet add $mapHandle lightMap ]
        }
            
Deputs "Add source port"
        foreach src_element $src_endpoint {
            set srcPortHandle [$src_element cget -hPort]
            lappend portHandleList $srcPortHandle
            lappend hostList $src_element 
Deputs "srcPortHandle:$srcPortHandle"
            set objHandle [ixNet add $handle ports]
            ixNet setA $objHandle -id $srcPortHandle
            ixNet commit
            set objHandle [lindex [ixNet remapIds $objHandle] 0]
            set srcHandle [ixNet add $lmHandle source]
            ixNet setA $srcHandle -portId $srcPortHandle
            ixNet commit
            set srcHandle [lindex [ixNet remapIds $srcHandle] 0]
Deputs "srcHandle:$srcHandle"            
            
           
        }
Deputs "Add destination ports" 
        set index 1    
        foreach dst_element $dst_endpoint {
            
            set dstPortHandle [$dst_element cget -hPort]
            lappend portHandleList $dstPortHandle
            lappend hostList $dst_element 
Deputs "dstPortHandle:$dstPortHandle"
            set objHandle [ixNet add $handle ports]
            ixNet setA $objHandle -id $dstPortHandle
            ixNet commit
            set objHandle [lindex [ixNet remapIds $objHandle] 0]
            #set dstHandle [ixNet add $lmHandle destination ]
            set dstHandle $lmHandle/destination:$index
            ixNet setA $dstHandle -portId $dstPortHandle
            ixNet commit
            set dstHandle [lindex [ixNet remapIds $dstHandle] 0]
Deputs "dstHandle:$dstHandle" 
            incr index                       
           
        }
        
Deputs "config frame data: ip addr and vlan"        
        puts $portHandleList
#get host config 
        set fdHandle [ixNet getL $handle frameData]
        ixNet setA $fdHandle -automatic false
        ixNet commit
        foreach hostHandle $hostList {
            $hostHandle disable
            
            set hostinfo [$hostHandle cget -hostInfo]
            set pHandle [$hostHandle cget -hPort]
            
            set count 1
            set src_mac ""
            set ipv4_addr ""
            set ipv4_gw ""
            set vlan_id1 ""
            set vlan_id2 ""
            set ipVersion "ipv4"
            set src_mac_step	"00:00:00:00:00:01"
            set vlan_id1_step	1
            set vlan_id2_step	1
            set ipv4_addr_step	0.0.0.1
            set ipv4_prefix_len	24
            set ipv4_gw_step 	0.0.0.1
           
            foreach {key value} $hostinfo {
                set key [string tolower $key]
                switch -exact -- $key {
                    -count {
                        set count $value
                    }
                    -src_mac {
                        if {[IsMacAddress $value]} {
                            set src_mac $value
                        } else {
                            set src_mac [MacTrans $value]
                        }
                        Deputs "src_mac:$src_mac"
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
                    -vlan_pri1 {
                        set vlan_pri1 $value
                    }
                    -vlan_id2 -
                    -inner_vlan_id {
                        set vlan_id2 $value
                    }
                    -vlan_id2_step -
                    -inner_vlan_step {
                        set vlan_id2_step $value
                    }
                    -vlan_pri2 {
                        set vlan_pri2 $value
                    }
                    -ip_version {
                        set ipVersion [string tolower $value]
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
                   
                }
            }
            
            
           
            if {$ipVersion == "ipv4"} {
                set manualIpHandle [ixNet add $fdHandle manualIp ]
                ixNet setA $manualIpHandle -portId $pHandle
                set ipHandle [ixNet getL $manualIpHandle ip]
                ixNet remapIds $manualIpHandle
                
                
            } elseif {$ipVersion == "ipv6"} {
            
                set manualIpHandle [ixNet add $fdHandle manualIpv6 ]
                ixNet setA $manualIpHandle -portId $pHandle
                set ipHandle [ixNet getL $manualIpHandle ipv6]               
                ixNet remapIds $manualIpHandle
                ixNet commit                
         
            }
            
            
            
            if {$vlan_id1 != ""} {
                set vlanHandle [ixNet getL $manualIpHandle vlan]
                set outerHandle [ixNet getL $vlanHandle outer]
                if {$outerHandle == ""} {
                    set outerHandle [ixNet add $vlanHandle outer]
                }              
            }
            if {$vlan_id2 != ""} {
                set vlanHandle [ixNet getL $manualIpHandle vlan]
                set innerHandle [ixNet getL $vlanHandle inner]
                if {$innerHandle == ""} {
                    set innerHandle [ixNet add $vlanHandle inner]
                }              
            }
            
            if { $count != 1 } {
                if {$ipv4_addr != ""} {
                    ixNet setA $ipHandle \
                        -srcIpAddr [list mvIncr [list $ipv4_addr $ipv4_addr_step $count] ] 
                }
                if {$ipv4_gw != ""} {
                    ixNet setA $ipHandle \
                        -gwIpAddr [list mvIncr [list $ipv4_gw $ipv4_gw_step $count] ] 
                }
                if {$vlan_id1 != ""} {
                    ixNet setM $outerHandle \
                        -enabled true  \
                        -id [list mvIncr [list $vlan_id1 $vlan_id1_step $count] ] 
                       
                        
                } 
                if {$vlan_id2 != ""} {
                    ixNet setM $innerHandle \
                        -enabled true  \
                        -id [list mvIncr [list $vlan_id2 $vlan_id2_step $count] ] 
                        
                }
                if {$src_mac != ""} {
                    set manualMacHandle [ixNet add $fdHandle manualMac]
                    Deputs "manualMacHandle:$manualMacHandle"
                    ixNet setM $manualMacHandle -portId $pHandle \
                       -srcMacMv [list mvIncr [list $src_mac $src_mac_step $count] ] 
                    ixNet remapIds $manualMacHandle
                    ixNet commit   
                    
                    
                }
            } else {
                if {$ipv4_addr != ""} {
                    ixNet setA $ipHandle \
                        -srcIpAddr [list mvSingle [list $ipv4_addr] ] 
                }
                if {$ipv4_gw != ""} {
                    ixNet setA $ipHandle \
                        -gwIpAddr [list mvSingle [list $ipv4_gw] ] 
                }
                if {$vlan_id1 != ""} {
                    ixNet setM $outerHandle \
                        -enabled true  \
                        -id [list mvSingle [list $vlan_id1]]
                        
                } 
                if {$vlan_id2 != ""} {
                    ixNet setM $innerHandle \
                        -enabled true  \
                        -id [list mvSingle [list $vlan_id2]]
                        
                }
                if {$src_mac != ""} {
                    set manualMacHandle [ixNet add $fdHandle manualMac]
                    ixNet setM $manualMacHandle -portId $pHandle \
                       -srcMacMv [list mvSingle [list $src_mac ] ] 
                    ixNet remapIds $manualMacHandle
                    ixNet commit   
                    
                    
                }
                                               
            }
            
            ixNet setA $ipHandle -mask $ipv4_prefix_len
                        
            ixNet commit
            
        }       
        
        	   

    } else {
        set err "Less of ports elements,source:$src_endpoint;destination:$dst_endpoint;timing port: $timing_endpoint"
        return [GetErrorReturnHeader $err]
    }	    
        
#igmp config        
    
    if {$ipVersion == "ipv4"} {
        ixNet setA $handle/testConfig -isIPv6 false 
        if { [ info exists igmp_version ] } {
            ixNet setA $handle/testConfig -igmpVersion $igmp_version        
        }        
        if { [ info exists igmp_group_address ] } {
            ixNet setA $handle/testConfig -ipv4Address $igmp_group_address       
        }
        if { [ info exists group_num ] } {
            ixNet setA $handle/testConfig -numAddresses $group_num   
        }        
    } else {
        ixNet setA $handle/testConfig -isIPv6 true
    }
    ixNet commit
    
        
#frame len config    
    
    if { [ info exists frame_len_type ] } {

Deputs "frame len type:$frame_len_type"
    	switch $frame_len_type {
			custom {
		
                ixNet setA $handle/testConfig -frameSizeMode custom
				ixNet commit

Deputs "frame len:$frame_len len:[ llength $frame_len ]"		
                set customLen ""
                foreach len $frame_len {
                	set len [string trim $len]
                	set customLen "$customLen,$len"
                }
                set customLen [ string range $customLen 1 end ]
Deputs "handle:$handle custom len:$customLen"
                ixNet setA $handle/testConfig -framesizeList $customLen              
                ixNet commit
            }
			random {
                ixNet setM $handle/testConfig \
					-frameSizeMode random \
					-minRandomFrameSize [ lindex $frame_len 0 ] \
					-maxRandomFrameSize [ lindex $frame_len end ]
				ixNet commit
			}
			incr {
                ixNet setM $handle/testConfig \
					-frameSizeMode increment \
					-minIncrementFrameSize $frame_len \
					-maxIncrementFrameSize $frame_len_max \
					-stepIncrementFrameSize $frame_len_step
				ixNet commit
			
				
			}
		}
    }
    
    

#load config	
	
    if { [ info exists load_unit ] } {
	    set load_unit [ string tolower $load_unit ]
	    switch $load_unit {
		    fps {
		    	set load_unit fpsRate
		    }
		    mbps {
		    	set load_unit mbpsRate
		    }
		    kbps {
		    	set load_unit kbpsRate
    		    }
		    percent {
		    	set load_unit percentMaxRate
		    
		    }
		    default {
		    	set load_unit percentMaxRate
			    
			    
		    }
		   
	    }
	    ixNet setA $handle/testConfig  -loadUnit $load_unit
    }
   
	if { [ info exists initial_rate ] } {
	    ixNet setA $handle/testConfig -initialRate $initial_rate
    }
#duration config
    if { [ info exists duration ] } {
	    ixNet setA $handle/testConfig -duration $duration
    }

 
    if { [ info exists tx_delay ] } {
	    ixNet setA $handle/testConfig -offsetTime $tx_delay
    }
#tx_delay config 
    ixNet setM $handle/testConfig  \
        -joinLeaveMode joinLeave  \
        -joinLeaveAlgorithm joinNew
    ixNet commit
        
    #enable pdf report generate
    if { [info exists pdfreportdir] && [info exists pdfreportfile ]} {
        ixNet setA ::ixNet::OBJ-/quickTest/globals  \
             -enableGenerateReportAfterRun true
        ixNet commit
    }
	
	ixNet exec apply $handle
	
	if { !$no_run } {
	
		ixNet exec run $handle
		ixNet exec waitForTest $handle
	}
       
	if { [ info exists resultdir ] } {
		global remote_server
        Deputs "remote_server:$remote_server"
		set path [ ixNet getA $handle/results -resultPath ]
        Deputs "path:$path"
		
		if { $remote_server == "localhost" } {
			
		} else {
            set colonIndex [ string first ":" $path ]
            set path [ string replace $path $colonIndex $colonIndex "$" ]
			set path "//${remote_server}/$path"
			catch {
                # net use \\10.206.25.116\c$\ixia ixia2014! /user:YL
				exec cmd "/k net use $path $netuse_pw /user:$netuse_user" &
			}
		}
        Deputs "path:$path"					

		if { [ catch {
            if { !$force } {
                file copy $path $resultdir
            } else {
                file copy -force $path $resultdir
            }
		} err ] } {
            Deputs "err:$err"
		}
		if { [ info exists resultfile ] } {
            Deputs "result file:$resultfile"		
		   
            file copy $path/aggregateresults.csv $resultdir/$resultfile
		}	
	}
    
    if { [info exists pdfreportdir] && [info exists pdfreportfile ]} {
        global remote_server
Deputs "remote_server:$remote_server"
		set path [ ixNet getA $handle/results -resultPath ]
Deputs "path:$path"
		set colonIndex [ string first ":" $path ]
		set path [ string replace $path $colonIndex $colonIndex "$" ]
		if { $remote_server == "localhost" } {
			set path "//127.0.0.1/$path"
		} else {
			set path "//${remote_server}/$path"
			catch {
			# net use \\10.206.25.116\c$\ixia ixia2014! /user:YL
				exec cmd "/k net use $path $netuse_pw /user:$netuse_user" &
			}
		}
Deputs "path:$path"

        if { [file exists $path/TestReport.pdf ]} {
            file copy $path/TestReport.pdf $pdfreportdir/$pdfreportfile
        } else {
            set err "No testReport.pdf created in $path"
            return [GetErrorReturnHeader $err]
            
        }
        
        
    }
	
    return [GetStandardReturnHeader]

}

body Rfc3918::joinLeaveDelay { args } {
    set testtype "rfc3918joinLeaveDelay"
    reborn
    eval config $args
}




