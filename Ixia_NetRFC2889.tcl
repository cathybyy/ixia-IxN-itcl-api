
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class rfc2889 {
	inherit NetObject
	constructor { args } {}
}

body rfc2889::constructor { args } {

    global errorInfo
    global errNumber

	set type learning_rate
	
    set tag "body rfc2889::ctor [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-type {
				set type $value
			}
        }
    }

	set type [ string tolower $type ]
	switch $type {
		learning_rate {
			eval rfc2889LearningRate rfc2889lrObj[clock seconds] $args
		}
	}
	
	
}

class rfc2889addressRate {
	inherit rfc2889
	constructor { args } {}
}

body rfc2889addressRate::constructor { args } {
    global errorInfo
    global errNumber

    set tag "body rfc2889addressRate::ctor [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-type {}
			-lport_addr_num {
				set lport_addr_num $value
			}
			-init_learning_rate {
				set init_learning_rate $value
			}
			-min_learning_rate {
				set min_learning_rate $value
			}
			-max_learning_rate {
				set max_learning_rate $value
			}
			-age_time {
				set age_time $value
			}
			-lport_mac_addr_start {
				set lport_mac_addr_start $value
			}
			-tport_mac_addr {
				set tport_mac_addr $value
			}
			-mac_range_mode {
				set mac_range_mode $value
			}
			-tport {
				set tport $value
			}
			-lport {
				set lport $value
			}
			-mport {
				set mport $value
			}
			-frame_size {
				set frame_size $value
			}
			-stream_load {
				set stream_load $value
			}
			-load_unit {
				set load_unit $value
			}
			-resolution {
				set resolution $value
			}
			-result_dir {
				set result_dir $value
			}
			-result_file {
				set result_file $value
			}
            default {
                error "$errNumber(3) key:$key value:$value"
            }
        }
    }
    
	set root [ixNet getRoot]
	
	if { [ ixNet getA $root/quickTest -runningTest ] != "" } {
		error "$errNumber(4) another quick test is also running"
	}
	
	if { ( [ info exists tport ] == 0 ) && ( [ info exists lport ] == 0 ) } {
		error "$errNumber(2) key: tport/lport"
	}
	
	set handle [ ixNet add $root/quickTest rfc2889addressRate ]
	ixNet commit
	set handle [ ixNet remapIds $handle ]
	
	ixNet setA $handle -name $this
	ixNet commit
	
	
}





