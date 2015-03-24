
# Copyright (c) Ixia technologies 2011-2012, Inc.

set releaseVersion 1.0
#===============================================================================
# Change made
# ==2014==
# Version 1.0 
#       1. Create
#		2. Delete all puts $logIO from tcl

proc GetEnvTcl { product } {
   
   set productKey     {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications}\$product
   set versionKey     [ registry keys $productKey ]
   set latestKey      [ lindex $versionKey end ]

   if { $latestKey == "Multiversion" } {
      set latestKey   [ lindex $versionKey [ expr [ llength $versionKey ] - 2 ] ]
   }
   set installInfo    [ append productKey \\ $latestKey \\ InstallInfo ]            
   return             [ registry get $installInfo  HOMEDIR ]

}

set portlist [list]
set trafficlist [list]
set portnamelist [list]
set trafficnamelist [list]
set tportlist [list]
proc loadconfig { filename } {
    global portlist
    global trafficlist
    global portnamelist
    global trafficnamelist
    global tportlist
    
    ixNet exec loadConfig [ixNet readForm $filename]
    set root [ixNet getRoot]
    set portlist [ixNet getL $root vport]
    foreach portobj $portlist {
        lappend portnamelist [ixNet getA $portobj -name]
    }
    
    set trafficlist [ixNet getL [ixNet getL $root traffic] trafficItem]
    foreach trafficItemobj $trafficlist {
        set itemlist [ixNet getL $trafficItemobj highLevelStream]
        foreach trafficobj $itemlist {
            lappend trafficnamelist [ixNet getA $trafficobj -name]
            lappend tportlist [ixNet getA $trafficobj -txPortName]
        }
    }

}

proc Login { { location "localhost/8009"} { force 0 } { filename null } } {

	global ixN_tcl_v
	global loginInfo
    
    global portlist
    global trafficlist
    global portnamelist
    global trafficnamelist
    global tportlist
    
	global server
	global serverPort
	
	set loginInfo $location

	if { $location == "" } {
		set port "localhost/8009"
	} else {
		set port $location
	}

	set portInfo [ split $port "/" ]
	set server	 [ lindex $portInfo 0 ]
	if { [ regexp {\d+\.\d+\.\d+\.\d+} $server ] || ( $server == "localhost" ) } {
		set portInfo [ lreplace $portInfo 0 0 ]
	} else {
		set server localhost
	}
	if { [ llength $portInfo ] == 0 } {
		set portInfo 8009
	}
    
    set flag 0
	foreach port $portInfo {
		ixNet disconnect
		ixNet connect $server -version $ixN_tcl_v -port $port
		set root [ ixNet getRoot]
		if { $force } {
			
			#return	
			set serverPort $port
            set flag 1            
		} else {
			if { [ llength [ ixNet getL $root vport ] ] > 0 } {
				
				continue
			} else {
				
				#return
				set serverPort $port
                set flag 1
			}
		}
        
        if { $flag == 1 } {
            if { $filename != "null" } {
                loadconfig $filename
				after 15000
                
                foreach pname $portnamelist pobj $portlist {
                    Port $pname NULL NULL $pobj
                }
                
                foreach tname $trafficnamelist tobj $trafficlist tport $portnamelist {
                    Traffic $tname $tport $tobj
                }
				
				return
                
            } else {
                return
            }
        }
	}
	
	return
}

proc GetAllPortObj {} {

	set portObj [list]
	set objList [ find objects ]
	foreach obj $objList {
		if { [ $obj isa Port ] } {
			lappend portObj [ $obj cget -handle ]
		}
	}
	return $portObj
}

set currDir [file dirname [info script]]
lappend auto_path $currDir/../IxNetwork

set logIO [open $currDir/init.log a+]

if { [ catch {
	source [file join $currDir Ixia_Util.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_Util.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetObj.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetObj.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetTester.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetTester.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetPort.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetPort.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetTraffic.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetTraffic.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetDhcp.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetDhcp.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetIgmp.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetIgmp.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetCapture.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetCapture.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetCaptureFilter.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetCaptureFilter.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetOspf.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetOspf.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
}
if { [ catch {
	source [file join $currDir Ixia_NetL3Vpn6Vpe.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetL3Vpn6Vpe.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetLdp.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetLdp.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetIsis.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetIsis.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetTrill.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetTrill.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetDcbx.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetDcbx.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetFcoe.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetFcoe.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetPPPoX.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetPPPoX.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetBgp.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetBgp.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetRFC2544.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetRFC2544.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetDot1xRate.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetDot1xRate.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetRip.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetRip.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetPim.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetPim.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir Ixia_NetBfd.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir Ixia_NetBfd.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 
if { [ catch {
	source [file join $currDir IxOperate.tcl]
} err ] } {
	if { [ catch {
			source [file join $currDir IxOperate.tbc]
	} tbcErr ] } {
		puts $logIO "load package fail...$err $tbcErr"
	}
} 

set errNumber(1)    "Bad argument value or out of range..."
set errNumber(2)    "Madatory argument missed..."
set errNumber(3)    "Unsupported parameter..."
set errNumber(4)    "Confilct argument..."


set ixN_tcl_v "6.0"

if { $::tcl_platform(platform) == "windows" } {
	
	package require registry

    if { [ catch {
	    lappend auto_path  "[ GetEnvTcl IxNetwork ]/TclScripts/lib/IxTclNetwork"
    } err ] } {
		puts $logIO "load package fail...$err $tbcErr"        
	}


	package require IxTclNetwork
	
	catch {	
		source [ GetEnvTcl IxOS ]/TclScripts/bin/ixiawish.tcl
	}
	catch {package require IxTclHal}
}

package provide IxiaNetPython $releaseVersion


# catch { console hide }

# rename ixNet IxNet
# proc ixNet { args } {
	# DeputsCMD "ixNet $args"
	# eval IxNet $args
# }

if { [file exist "c:/windows/temp/ixlogfile"] } {
} else {
    file mkdir "c:/windows/temp/ixlogfile"
}
set timeVal  [ clock format [ clock seconds ] -format %Y%m%d_%H_%M ]
set clickVal [ clock clicks ]
set logfile_name "c:/windows/temp/ixlogfile/$timeVal.txt"

# IxDebugOn
# IxDebugCmdOn
