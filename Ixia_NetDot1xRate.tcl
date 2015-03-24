
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create


class Dot1xRate {
    inherit NetObject
    
    constructor {} {}
	method reborn {} {}
    method config { args } {}
	method unconfig {} {
		chain
		
	}
	
  
}

body Dot1xRate::reborn {} {

	if { [ info exists handle ] == 0 || $handle == "" } {
		set root [ixNet getRoot]
		set handle [ ixNet add $root/quickTest dot1xRate ]
		ixNet setA $handle -name $this -mode existingMode
		ixNet commit
		set handle [lindex [ixNet remapIds $handle] 0]
		
		ixNet commit
	}
}

body Dot1xRate::constructor {} {
    set tag "body Dot1xRate::ctor [info script]"
    Deputs "----- TAG: $tag -----"
    
	reborn
}

body Dot1xRate::config { args } {
    
    global errorInfo
    global errNumber
    set tag "body Dot1xRate::config [info script]"
    Deputs "----- TAG: $tag -----"
    set algorithmtype "custom"
	set maxoutstandingreq 10
	set numofsupplicants 1000
    set no_run 0
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
        	-test_ports {
				set testendpoints $value
        	}			
			-max_outstanding_req {
				set maxoutstandingreq $value
			}
        	-num_of_supplicants {
				set numofsupplicants $value
				
        	}
        	-trial {
        		set trial $value
        	}
        	-algorithm_type {
        		set algorithmtype $value
        	}
        	-custom_list {
        		set customlist $value
        	}
        	-wait_time {
        		set waittime $value
        	}
            -resultdir {
				set resultdir $value
			}
			-resultfile {
                	set resultfile $value
        	}
            -no_run {
                set no_run $value
            }
        	default {
        	    error "$errNumber(3) key:$key value:$value"
        	}
		}
    }
	
    # reborn
    if { $handle == "" } {
Deputs "Step10"
		reborn
    }
Deputs "Step20"	
    if { [ info exists testendpoints ] == 0 } {
Deputs "Step30"
    	error "$errNumber(2) key:test_endpoints"
    } 
	
    foreach testport $testendpoints {
        set hPort [$testport cget -handle]
        set protocolhandle [ixNet getL $hPort/protocolStack dot1xOptions]
        if { $protocolhandle != "" } {
		    set pshandle [lindex [ixNet getL $hPort protocolStack] 0]
            set sg_resource [ixNet add $handle resource]          
            ixNet setMultiAttr $sg_resource  \
			    -groupId {StackManager}   \
                -id $pshandle
            ixNet commit
            set sg_resource [lindex [ixNet remapIds $sg_resource] 0]
        } else {
            error "err:port:$testport does not have dot1x range "
        }
    
    }
	
Deputs "Step110"
    if { [ info exists maxoutstandingreq ] } {
	    set sg_parameter [ixNet add $handle/controlPlane "parameter"]
        ixNet setMultiAttribute $sg_parameter \
            -maxValue 1024 \
			-minValue 1 \
			-parameterId session:Dot1xPlugin:maxOutstandingRequests \
			-parameterName "Max\ Outstanding\ Requests" \
			-parameterValue $maxoutstandingreq \
			-type kInteger \
			-unit requests
		ixNet commit
        set sg_parameter [lindex [ixNet remapIds $sg_parameter] 0]
    }
Deputs "Step120"   
    if { [ info exists numofsupplicants ] } {
		set sg_parameter [ixNet add $handle/controlPlane "parameter"]
        ixNet setMultiAttribute $sg_parameter \
            -maxValue 32000 \
			-minValue 1 \
			-parameterId distributed:targetRange.count \
			-parameterName "No.\ of\ Supplicants" \
			-parameterValue $numofsupplicants \
			-type kInteger \
			-unit supplicants
		ixNet commit
        set sg_parameter [lindex [ixNet remapIds $sg_parameter] 0]
    }
	
Deputs "Step130"
    if { [ info exists trial ] } {
	    ixNet setMultiA $handle/testConfig/testRun  -trials $trial
        ixNet commit
    }
Deputs "Step140"	
    if { [ info exists algorithmtype ] } {
	    ixNet setMultiAttribute $handle/testConfig/iterations \
            -algoType $algorithmtype \
			-parameterId session:Dot1xPlugin:maxClientsPerSecond \
			-parameterName "Request\ Rate"
        ixNet commit
    }
    
    if { $algorithmtype == "custom" && [ info exists customlist ] } {
	    ixNet setA $handle/testConfig/iterations/custom \
            -valueList $customlist
        ixNet commit
    }
    
    if { [ info exists waittime ] } {
	    ixNet setA $handle/testConfig/iterations \
            -waitTime $waittime
        ixNet commit
    }
    
    
	
Deputs "Step150"
# enable latency
    set sg_stat [ixNet add $handle/testConfig "stat"]
    ixNet setMultiAttribute $sg_stat \
            -statName "Supplicants\ Succeeded" \
			-inCsv true \
			-id "802.1x:Sessions\ Succeeded"
	ixNet commit
    set sg_stat [ixNet remapIds $sg_stat]
    
    set sg_stat [ixNet add $handle/testConfig "stat"]
    ixNet setMultiAttribute $sg_stat \
            -statName "Supplicants\ Failed" \
			-inCsv true \
			-id "802.1x:Sessions\ Failed"
	ixNet commit
    set sg_stat [ixNet remapIds $sg_stat]
    
    if { !$no_run } {
		ixNet exec apply $handle
		ixNet exec run $handle
		ixNet exec waitForTest $handle
	}
    
    if { [ info exists resultdir ] } {
		set path [ ixNet getA $handle/results -resultPath ]
Deputs "path:$path"
		if { [ catch {
			file copy $path $resultdir
		} err ] } {
Deputs "err:$err"
		}
		if { [ info exists resultfile ] } {
		    if { [file exists $resultdir/$resultfile ] } {
			    if { [ catch {
                   
                    set rfile [ open $resultdir/$resultfile r ]
                    set rpattern [ read -nonewline $rfile ]
					close $rfile 
				    file delete $resultdir/$resultfile
					file copy $path/results.csv $resultdir/$resultfile
					set apdfile [ open $resultdir/$resultfile a ]
					puts $apdfile "\n"
                    puts $apdfile $rpattern
                    flush $apdfile
                    close $apdfile
                 
				} err ] } {
				    return [GetErrorReturnHeader $err]
			        }
			} else {				
			    if { [ catch {
				    file copy $path/results.csv $resultdir/$resultfile
			    } err ] } {
				return [GetErrorReturnHeader $err]
			        }
			    }
		}	
	}
	
	
    return [GetStandardReturnHeader]

}


