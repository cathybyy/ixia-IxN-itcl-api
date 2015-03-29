
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.11
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1
#       2. If the specified CSV file of RFC2544 with the same path, when run a number of times,
#          results additional to the before of previous record.
# Version 1.2
#       3. Rfc2544.config change -streams into lappend trafficSelection $stream
# Version 1.3
#       4. Rfc2544 add testtype throughput frameloss back2back
# Version 1.4.4.33
#		5. -traffic_mesh = fullmesh in rfc2544.config
#		6. -resultlvl = 0 return the aggregateresult.csv and -resultlvl=1 return the results.csv
#		7. -traffic_type = ipv6 in rfc2544.config
#		8. copy result file from server to client
# Version 1.5.4.37
#		9. add param in Rfc2544.config
# 			-binary_mode port/flow
# 			-frame_len_type incr
# 			-frame_len_step int
# 			-frame_len_max int
# Version 1.6.4.45
#		10. add generate before running rfc2544 to fix imix burst issue
# Version 1.7.6.24
#		11. Rfc2544.config -measure_jitter 1 -resultlvl 0 
#           return aggregateresult.csv with latency and jitter statstics
# Version 1.8.4.45
#		12. send mac learning only
# Version 1.9.4.46
#		13. add fix on bug not copying file when measure_jitter false
# Version 1.10.4.49
#		14. add -mac_learning in config
# Version 1.11.4.60
#		15. add net use to connect with IxNetwork Tcl Server
#       16. change server to remote_server

class Rfc2544 {
    inherit NetObject
    
    constructor {} {}
	method reborn { } {}
    method throughput { args} {}
    method frameloss { args } {}
    method back2back { args } {}
    method config { args } {}
	method unconfig {} {
		chain
		catch { 
			delete object $this.traffic
		}
	}
	
    #trafficSelection - inTest
    public variable trafficSelection
    #trafficSelection - background
    public variable trafficBackground
    public variable testtype
}

body Rfc2544::reborn { } {
    set tag "body Rfc2544::reborn [info script]"
    Deputs "----- TAG: $tag -----"
    Deputs "Rfc2544 $testtype testing"

	if { [ info exists handle ] == 0 || $handle == "" } {
		set root [ixNet getRoot]
        if { $testtype == "rfcthroughput" } {
		    set handle [ ixNet add $root/quickTest rfc2544throughput ]
        } elseif { $testtype == "rfcback2back" } {
            set handle [ ixNet add $root/quickTest rfc2544back2back ]
        } elseif { $testtype =="rfcframeloss" } {
            set handle [ ixNet add $root/quickTest rfc2544frameLoss ]
        }
		ixNet setA $handle -name $this -mode existingMode
		ixNet commit
		set handle [ixNet remapIds $handle]
		ixNet setA $handle/testConfig -frameSizeMode fixed
		ixNet commit
	}
}

body Rfc2544::constructor {} {
    
    set tag "body Rfc2544::ctor [info script]"
    Deputs "----- TAG: $tag -----"
    set testtype "rfcthroughput"
    IxDebugOn
    IxDebugCmdOn
    
	#reborn 
}

body Rfc2544::config { args } {
    
    global errorInfo
    global errNumber
    set tag "body Rfc2544::config [info script]"
    Deputs "----- TAG: $tag -----"
    	
    set frame_len_type custom
    set load_unit percent
    set duration 30
    set resolution 1
    set trial 1
    set traffic_mesh ""
    set bidirection 1
    set traffic_type L2
    set latency_type lilo
    set measure_jitter 0
    set resultdir "d:/1"
    set resultfile "1.csv"
    set inter_frame_gap 12
	set no_run 0
	set resultLevel 1
    set regenerate "false"
	
	set frame_len_step 64
	set frame_len_max  1518
	set binary_mode perPort

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
        	-frame_len {
				if { [ llength $value ] < 1 } {
					 error "$errNumber(1) key:$key value:$value"
				} else {
					set frame_len $value
Deputs "frame len under test:$frame_len"			 
				}
        	}
			-dif_len_type -
			-frame_len_type {
				set frame_len_type $value
			}
			-frame_len_step {
				set frame_len_step $value
			}
			-frame_len_max {
				set frame_len_max $value
			}
        	-port_load {
				if { [ llength $value ] < 3 } {
					error "$errNumber(1) key:$key value:$value"
				} else {
					set port_load $value
				}
        	}
        	-load_unit {
        		set load_unit $value
        	}
        	-duration {
        		set duration $value
        	}
        	-resolution {
        		set resolution $value
        	}
        	-trial {
        		set trial $value
        	}
        	-upstream {
				foreach stream $value {
					if { [ $stream isa Traffic ] } {
						set upstream $value
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
        	}
        	-downstream {
				foreach stream $value {
					if { [ $stream isa Traffic ] } {
						set downstream $value
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
        	}
			-streams {
				foreach stream $value {
					if { [ $stream isa Traffic ] } {
						set teststream $value
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
			}
        	-traffic_mesh {
        		set traffic_mesh $value
        	}
        	-src_endpoint {
        		set src_endpoint $value
        	}
        	-dst_endpoint {
        		set dst_endpoint $value
        	}
        	-bidirection {
        		set bidirection $value
        	}
        	-bg_traffic {
        		set bg_traffic $value
        	}
        	-traffic_type {
        		set traffic_type $value
        	}
        	-latency_type {
        		set latency_type $value
        	}
        	-measure_jitter {
				set trans [ BoolTrans $value ]
				if { $trans == "1" || $trans == "0" } {
					set measure_jitter $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}
        	}
			-resultdir {
				set resultdir $value
			}
			-resultfile {
                	set resultfile $value
        	}
			-resultlvl {
Deputs "set result level:$value"			
				set resultLevel $value
			}
        	-inter_frame_gap {
        		set inter_frame_gap $value
        	}
			-no_run {
				set no_run $value
			}
			-binary_mode {
				set binary_mode $value
			}
			-mac_learning {
				set trans [ BoolTrans $value ]
				if { $trans == "1" || $trans == "0" } {
					set mac_learning $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}				
			}
			-netuse_user {
				set netuse_user $value
			}
			-netuse_pw {
				set netuse_pw $value
			}
            -regenerate {
                set trans [ BoolTrans $value ]
				if { $trans == "1" || $trans == "0" } {
					set regenerate $value
				} else {
					error "$errNumber(1) key:$key value:$value"
				}	
        	}
        	default {
        	    error "$errNumber(3) key:$key value:$value"
        	}
		}
    }
	
    # reborn
    if { [ info exists handle ] == 0 || $handle == "" } {
Deputs "Step10"
		reborn
    }
Deputs "Step20"	
    if { [ info exists frame_len ] == 0 } {
Deputs "Step30"
    	error "$errNumber(2) key:frame_len"
    } 
	
    set trafficSelection [list]
	catch { 
		delete object $this.traffic
	}
Deputs "Step40"
    if { [ info exists upstream ] && [ info exists downstream ] } {
Deputs "Step41"
		#-- add existing traffic item
		foreach stream $upstream {
			set upTs [ ixNet add $handle trafficSelection ]
	Deputs "upTs:$upTs"
			ixNet setM $upTs \
				-id [ $stream cget -handle ] \
				-includeMode inTest \
				-itemType trafficItem \
				-type upstream
			set upTs  [ ixNet remapIds $upTs ]
			lappend trafficSelection $stream 
		}
		foreach stream $downstream {
			set dnTs [ ixNet add $handle trafficSelection ]
	Deputs "dnTs:$dnTs"		
			ixNet setM $dnTs \
				-id [ $stream cget -handle ] \
				-includeMode inTest \
				-itemType trafficItem \
				-type downstream
			ixNet commit
			
			set dnTs  [ ixNet remapIds $dnTs ]
			
			lappend trafficSelection $stream 
		}
    } elseif { [ info exists src_endpoint ] && [ info exists dst_endpoint ] } {
Deputs "Step42"
	    #-- add new traffic item
		set stream $this.traffic
		if { [ [ lindex $src_endpoint 0 ] isa Port ] } {
			Traffic $stream [ lindex $src_endpoint 0 ]
		} else {
			Traffic $stream [ [ lindex $src_endpoint 0 ] cget -portObj ]
		}
Deputs "traffic type:$traffic_type"
		if { [ string tolower $traffic_type ] == "l2" } {
			set trafficType ethernetVlan
		} elseif { [ string tolower $traffic_type ] == "ipv6" } {
			set trafficType ipv6		
		} else {
			set trafficType ipv4
		}
		
	    if { [ string tolower $traffic_mesh ] == "fullmesh" } {
Deputs "create full mesh traffic"		
			set full_mesh 1
	    } else {
Deputs "create one 2 one traffic"
			set full_mesh 0
		}

Deputs "traffic type:$trafficType"		
	    $this.traffic config \
			-src $src_endpoint -dst $dst_endpoint \
			-traffic_type $trafficType \
			-bidirection $bidirection \
			-full_mesh $full_mesh
		set ts [ ixNet add $handle trafficSelection ]
		ixNet setM $ts \
			-id [ $stream cget -handle ] \
			-includeMode inTest \
			-itemType trafficItem 
	    lappend trafficSelection $this.traffic

    } else {
Deputs "Step43"
		if { [ info exists teststream ] } {
			foreach stream $teststream {
Deputs "streams :$stream"
				set ts [ ixNet add $handle trafficSelection ]
				ixNet setM $ts \
					-id [ $stream cget -handle ] \
					-includeMode inTest \
					-itemType trafficItem
				ixNet commit
				lappend trafficSelection $stream
			}		
			#lappend trafficSelection $teststream
		} else {
			error "$errNumber(2) key:upstream/downstream src_endpoint/dst_endpoint"
		}
    }
	    
Deputs "Step50"
    if { [ info exists bg_traffic ] } {
	    #-- add bg traffic
	    foreach stream $bg_traffic {
Deputs "bg_traffic :$stream"
        	    set ts [ ixNet add $handle trafficSelection ]
        	    ixNet setM $ts \
                        -id [ $stream cget -handle ] \
                        -includeMode background \
        		-itemType trafficItem
        	    ixNet commit
	    }
		lappend trafficBackground $bg_traffic
    }
Deputs "Step60"
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
		set root [ ixNet getRoot ]
    	ixNet setA $root/traffic/statistics/latency -mode $latency_type
    	ixNet commit
		ixNet setA $handle/testConfig -latencyType $latency_type
		ixNet commit
    }
Deputs "Step70"
    if { [ info exists frame_len_type ] } {
Deputs "Step71"	
Deputs "frame len type:$frame_len_type"
    	switch $frame_len_type {
			custom {
Deputs "Step73"			
                ixNet setA $handle/testConfig -frameSizeMode custom
				ixNet commit
Deputs "Step74"				
				ixNet setA $handle/downstreamConfig -downstreamFrameSizeMode custom
				ixNet setA $handle/upstreamConfig -upstreamFrameSizeMode custom
				ixNet commit
Deputs "Step75"
Deputs "frame len:$frame_len len:[ llength $frame_len ]"		
                set customLen ""
                foreach len $frame_len {
                	set len [string trim $len]
                	set customLen "$customLen,$len"
                }
                set customLen [ string range $customLen 1 end ]
Deputs "handle:$handle custom len:$customLen"
                ixNet setA $handle/testConfig -framesizeList $customLen
                ixNet setA $handle/downstreamConfig -downstreamFramesizeList $customLen
                ixNet setA $handle/upstreamConfig -upstreamFramesizeList $customLen
                ixNet commit
            }
            imix {
Deputs "Step72"
                foreach traffic $trafficSelection {
                    set el [$traffic cget -highLevelStream]
					foreach stream $el {
						ixNet setM $stream/frameSize \
							-weightedPairs $frame_len \
							-type weightedPairs
					}
                    ixNet commit
                }
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
Deputs "Step76"				
				ixNet setA $handle/downstreamConfig \
					-downstreamFrameSizeMode increment \
					-minIncrementFrameSize $frame_len \
					-maxIncrementFrameSize $frame_len_max \
					-stepIncrementFrameSize $frame_len_step
				ixNet setA $handle/upstreamConfig \
					-upstreamFrameSizeMode increment \
					-minIncrementFrameSize $frame_len \
					-maxIncrementFrameSize $frame_len_max \
					-stepIncrementFrameSize $frame_len_step
				ixNet commit

			}
		}
    }
Deputs "Step80"	
    if { [ info exists inter_frame_gap ] } {
Deputs "traffic selection: $trafficSelection len: [ llength $trafficSelection ]"	
	    foreach traffic $trafficSelection {
		    set el [$traffic cget -highLevelStream]
			foreach highLevelStream $el {
				ixNet setA $highLevelStream/transmissionControl -minGapBytes $inter_frame_gap 
			}
		    ixNet commit
	    }
    }
	
Deputs "Step90"
    if { [ info exists port_load ] } {
	    set port_load_init [ lindex $port_load 0 ]
	    set port_load_min  [ lindex $port_load 1 ]
	    set port_load_max  [ lindex $port_load 2 ]
	    ixNet setM $handle/testConfig \
	    	-binarySearchType perPort \
		    -minBinaryLoadRate $port_load_min \
		    -maxBinaryLoadRate $port_load_max
		if { $port_load_init == "unchanged" } {
			ixNet setA $handle/testConfig -unchangedInitial True 
		} else {
			ixNet setA $handle/testConfig -initialBinaryLoadRate $port_load_init 
		}
    }
Deputs "Step100"	
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
	    ixNet setA $handle/testConfig  -binaryLoadUnit $load_unit
    }
	
Deputs "Step110"
    if { [ info exists duration ] } {
	    ixNet setA $handle/testConfig -duration $duration
    }
Deputs "Step120"  
	if { [ info exists binary_mode ] } {
		if { [ string tolower $binary_mode ] == "port" } {
			set binary_mode perPort
		}
		if { [ string tolower $binary_mode ] == "flow" } {
			set binary_mode perFlow
		}
	}
# enable latency
# type=kEnumValue=noOrdering,unchanged,val2889Ordering
	ixNet setM $handle/testConfig \
		-calculateLatency True \
		-binarySearchType $binary_mode \
		-forceRegenerate $regenerate \
		-rfc2889ordering val2889Ordering \
		-enableMinFrameSize True
	ixNet setA $handle/learnFrames \
		-learnSendMacOnly True

Deputs "Step130"
    if { [ info exists resolution ] } {
	    ixNet setA $handle/testConfig -resolution $resolution
    }
Deputs "Step140"	
    if { [ info exists trial ] } {
	    ixNet setA $handle/testConfig -numtrials $trial
    }
	
Deputs "Step150"
    if { [ info exists measure_jitter ] } {
		if { $measure_jitter } {
			if { $resultLevel } {
				ixNet setA $handle/testConfig -calculateJitter True
            } else {
				ixNet setA $handle/testConfig -calculateLatency False
				ixNet setA $handle/testConfig -calculateJitter False
            }	
		} else {
			ixNet setA $handle/testConfig -calculateJitter False
		}
    }
	if { [ info exists mac_learning ] } {
		if { $mac_learning } {
			ixNet setA $handle/learnFrames -learnFrequency oncePerTest
		} else {
			ixNet setA $handle/learnFrames -learnFrequency never
		}
	}
	
    ixNet commit
	
	Tester::apply_traffic
	
	if { !$no_run } {
		ixNet exec apply $handle
		ixNet exec run $handle
		ixNet exec waitForTest $handle
	}


	if { [ info exists resultdir ] } {
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

		if { [ catch {
			file copy $path $resultdir
		} err ] } {
Deputs "err:$err"
		}
		if { [ info exists resultfile ] } {
Deputs "result file:$resultfile"		
		    if { [file exists $resultdir/$resultfile ] } {
Deputs "result file:$resultdir/$resultfile"
			    if { [ catch {
				
					#- DC format
					set rfile [ open $resultdir/$resultfile r ]
					set rpattern [ read -nonewline $rfile ]
					close $rfile 
					file delete $resultdir/$resultfile
					
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
						if { $resultLevel == 0 } {
Deputs "copy aggregate results..."
							if { $measure_jitter } {
Deputs "run jitter test on traffic: $trafficSelection"								
								set rfile [ open $path/aggregateresults.csv r ]
								set desfile [open $resultdir/$resultfile w+]


								close $desfile
								
								ixNet setMultiAttribute $root/traffic/statistics/latency -enabled false
								ixNet commit
								ixNet setMultiAttribute $root/traffic/statistics/delayVariation \
									-enabled true \
									-statisticsMode rxDelayVariationAverage \
									-latencyMode $latency_type
								ixNet commit
								set view {::ixNet::OBJ-/statistics/view:"Traffic Item Statistics"}
								set trafficlist {}
								set trafficitemlist [ ixNet getL $root/traffic trafficItem ]
								set enableList {}
								if {[ info exists teststream ] } {
								    foreach stream $teststream {
									    lappend trafficlist [ $stream cget -handle ]
									}
								} else {
 
									set trafficlist $trafficitemlist
								}
								foreach item $trafficitemlist {
									lappend enableList [ ixNet getA $item -enabled ]
									ixNet setA $item -enabled false
									ixNet commit
									#ixNet exec generate $item
								}
								
								set trafficnum [ llength $trafficlist ]
								while {[gets $rfile line] != -1 } {
								    set desfile [open $resultdir/$resultfile a]
								    set statsinfo  [ split $line "," ]
									set fsize      [ lindex $statsinfo 1 ]
									Deputs $fsize
									if { [string is integer $fsize] } {
										set txrate     [ lindex $statsinfo 3 ]
										set itemtxrate [expr $txrate/$trafficnum]
										foreach fstream $trafficlist {
										   set celement [ixNet getL $fstream configElement  ]
										   ixNet setA $celement/frameSize -fixedSize $fsize
										   ixNet setM $celement/frameRate \
											   -type percentLineRate \
											   -rate $itemtxrate
											ixNet setA $fstream -enabled true
									        ixNet commit
											ixNet exec generate $fstream
											  										   
										}
										#ixNet commit
										# ixNet exec apply $root/traffic
										# after 10000
										# foreach fstream $trafficlist {
										   # ixNet exec startStatelessTraffic $fstream
										   # after 1000
										# }
										Tester::start_traffic
										
										after 13000
										Tester::stop_traffic
										after 2000
										set captionList    [ ixNet getA $view/page -columnCaptions ]
										set aveLatencyIndex         [ lsearch  $captionList {*Avg Latency (ns)} ]
										set minLatencyIndex         [ lsearch  $captionList {*Min Latency (ns)} ]
										set maxLatencyIndex         [ lsearch  $captionList {*Max Latency (ns)} ]
										set avejitterIndex          [ lsearch -exact $captionList {Avg Delay Variation (ns)} ]
										set minjitterIndex          [ lsearch -exact $captionList {Min Delay Variation (ns)} ]
										set maxjitterIndex          [ lsearch -exact $captionList {Max Delay Variation (ns)} ]
										
										set stats [ ixNet getA $view/page -rowValues ]
										set aveLatency   0
										set minLatency   0
										set maxLatency   0
										
										set totallatency 0
										
										set totaljitter  0
										set minjitter    0
										set maxjitter    0
										foreach row $stats {
											eval {set row} $row
										
											set rowaveLatency   [ lindex $row $aveLatencyIndex ]
											set rowminLatency   [ lindex $row $minLatencyIndex ]
											set rowmaxLatency   [ lindex $row $maxLatencyIndex ]
											set rowaveLatency   [ lindex $row $aveLatencyIndex ]
											set rowavejitter    [ lindex $row $avejitterIndex ]
											set rowminjitter    [ lindex $row $minjitterIndex ]
											set rowmaxjitter    [ lindex $row $maxjitterIndex ]
											
											set totallatency    [expr $totallatency + $rowaveLatency]
											if { $minLatency  == 0 || $rowminLatency < $minLatency } {
												set minLatency $rowminLatency
											} 
											if { $maxLatency  == 0 || $rowmaxLatency > $maxLatency } {
												set maxLatency $rowmaxLatency
											}
											set totaljitter    [expr $totaljitter + $rowavejitter]
											if { $minjitter  == 0 || $rowminjitter < $minjitter } {
												set mijitter $rowminjitter
											} 
											if { $maxjitter  == 0 || $rowmaxjitter > $maxjitter} {
												set maxjitter $rowmaxjitter
											}										
										}
										set aveLatency   [expr $totallatency/$trafficnum]
										set avejitter   [expr $totaljitter/$trafficnum]
										set rpattern "$line,$minLatency,$maxLatency,$aveLatency,$minjitter,$maxjitter,$avejitter"
									} else {
									   set rpattern "$line,Min Latency (ns),Max Latency (ns),Avg Latency (ns),Min Delay Variation (ns),Max Delay Variation (ns),Avg Delay Variation (ns)"
									}
									Deputs "rpattern:$rpattern"
									puts  $desfile $rpattern
								    close $desfile
									
								}
								#set rpattern [ read -nonewline $rfile ]
								close $rfile
								
                                ixNet setA $root/traffic/statistics/delayVariation  -enabled false	
                                ixNet commit									
								ixNet setMultiAttribute $root/traffic/statistics/latency -enabled true \
			                                                  -mode $latency_type
								ixNet commit
								
								
								foreach suspend $enableList item $trafficitemlist {
									ixNet setA $item -enabled $suspend
								}
	                            ixNet commit

							} else {
								file copy $path/aggregateresults.csv $resultdir/$resultfile
							}
						}
						if { $resultLevel == 1 } {
Deputs "copy results..."
							
							file copy $path/results.csv $resultdir/$resultfile
						}
					} err ] } {
						return [GetErrorReturnHeader $err]
			        }
			    }
		}	
	}
	
    return [GetStandardReturnHeader]

}

body Rfc2544::throughput { args } {
    set testtype "rfcthroughput"
    reborn
    eval config $args
}

body Rfc2544::frameloss { args } {
    set testtype "rfcframeloss"
    reborn
    eval config $args
}

body Rfc2544::back2back { args } {
    set testtype "rfcback2back"
    reborn
    eval config $args
}

class Async2544 {
	inherit Rfc2544
	
	method reborn {} {}
	method config { args } {}
}

body Async2544::reborn {} {
    set root [ixNet getRoot]
    set handle [ ixNet add $root/quickTest asymmetricThroughput ]
    ixNet setA $handle -name $this -mode existingMode
    ixNet commit
    set handle [ixNet remapIds $handle]
	ixNet setA $handle/downstreamConfig -downstreamFrameSizeMode unchanged
	ixNet setA $handle/upstreamConfig -upstreamFrameSizeMode unchanged
	ixNet commit
}

body Async2544::config { args } {

    global errorInfo
    global errNumber
    set tag "body Async2544::config [info script]"
    Deputs "----- TAG: $tag -----"

	set frame_len_type custom
	set no_run 0
	
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
        	-streams {
				set streams $value
				set index [ lsearch $args $key ]
				set args [ lreplace $args $index [ expr $index + 1 ] ]
			}
		}
	}	

	if { [ info exists streams ] } {
		eval chain { -streams $streams -no_run 1 } $args
	} else {
		eval chain -no_run 1 $args
	}

	if { !$no_run } {
		ixNet exec apply $handle
		ixNet exec run $handle
		ixNet exec waitForTest $handle
	}
	
    return [GetStandardReturnHeader]
}

