package require Itcl
package require registry
namespace import itcl::*


set Debug 0
proc Deputs { value } {
   global Debug
   global currDir
   global logfile_name
   set timeVal  [ clock format [ clock seconds ] -format %T ]
   set clickVal [ clock clicks ]
   if { $Debug } {
		puts "\[<IXIA>TIME:$timeVal\]$value"
		set logIO [open $logfile_name a+]
		puts $logIO "\[<IXIA>TIME:$timeVal\]$value"
		close $logIO
   }
}
set DebugCmd 1
proc DeputsCMD { value { log 1 } } {
    global DebugCmd
    global currDir
	global logfile_name
    set timeVal  [ clock format [ clock seconds ] -format %T ]
    set clickVal [ clock clicks ]
    if { $DebugCmd } {
		if { $log } {
			set logIO [open $logfile_name a+]
			puts $logIO "\[<IXIACMD>TIME:$timeVal\]$value"
			close $logIO
		} else {
			puts "\[<IXIACMD>TIME:$timeVal\]$value"
		}
    }
}
proc IxDebugOn { } {
   global Debug
   set Debug 1
}
proc IxDebugOff { } {
   global Debug
   set Debug 0
}
proc IxDebugCmdOn { } {
   global DebugCmd
   set DebugCmd 1
}
proc IxDebugCmdOff { } {
   global DebugCmd
   set DebugCmd 0
}

#==================================================
# 函数名称:                                                         
#    ixConvertAllToLowerCase                                                        
# 描述:                                                               
#    转换输入参数到小写                                   
# 参数:                                                          
# 语法描述:                                                         
#     ixConvertAllToLowerCase {-speed 1G}
# 返回值：                                                          
#    所有字符都为小写的字符串                        
#==================================================
 
proc ixConvertAllToLowerCase {args} {
   set args [eval subst $args]
   set ixargs ""
   if {[expr {[llength $args] % 2}] != 0} {
      puts "ERROR--Parameters must be a list of pair, such as -Attr Value."    
   } else {
      foreach {attr val} $args {
         set attr [string tolower $attr]
         set val  [string tolower $val]
         lappend ixargs $attr $val
      }
   }
   return $ixargs
}

#==================================================
# 函数名称:                                                         
#    ixCheckParas                                                        
# 描述:                                                               
#    检查参数是否正确                                   
# 参数:                                                          
# 语法描述:                                                         
#     ixCheckParas {-location 1/3/1 -intf_ip 1.1.1.2 -dut_ip 1.1.1.1 -speed 1G}\
#     	{-location -intf_ip -dut_ip} {-speed}                            
# 返回值：                                                          
#    成功1，失败0；                        
#==================================================
proc ixCheckParas {args_list man_list opt_list} {
  set flag 1
  array set args_array $args_list
  foreach man $man_list {
	  if {[lsearch [array names args_array] $man]<0} {
		  lappend ::ERRINFO "No mandatory para: $man"
		  set flag 0
		}
	}

  foreach para [array names args_array] {
  	if {[lsearch $man_list $para]<0} {
		  if {[lsearch $opt_list $para]<0} {
			  lappend ::ERRINFO "Error optional para: $para"
			  set flag 0
			}
	  }
	}
  return $flag
}

#==================================================
# 函数名称:                                                         
#    ixNumber2Ipmask                                                        
# 描述:                                                               
#    将10进制掩码转换为*.*.*.*格式                                   
# 参数:                                                          
# 语法描述:                                                         
#     ixNumber2Ipmask 24                           
# 返回值：                                                          
#    IP掩码格式；                        
#==================================================
proc ixNumber2Ipmask {number} {
	if {[regexp {\d+.\d+.\d+.\d+} $number]} {
	    return $number
	} else {
    set maskend [expr (255<<(8-[expr $number%8]))%256]
    set zero [expr 4-(($number+7)/8)]
    if {[expr $number%8]!=0} {
      return [string repeat 255. [expr $number/8]]$maskend[string repeat .0 $zero]
    } else {
      return [string repeat 255. [expr [expr $number/8]-1]]255[string repeat .0 $zero]
    } 
	}
}

#==================================================
# 函数名称:                                                         
#    ixConvertToByteList                                                        
# 描述:                                                               
#    将任意形式的16进制byte字符串转换为"00 01 02"列表格式                                   
# 参数:                                                          
# 语法描述:                                                         
#     ixConvertToByteList "00-01"                           
# 返回值：                                                          
#    list列表                        
#==================================================
proc ixConvertToByteList {args} {
	set size [string length $args]
	for {set i 0} {$i < $size} {incr i} {
		set char [string index $args $i]
		if {![regexp {[0-9a-fA-F]} $char]} {
		   set args [string replace $args $i $i " "]
		}
	}
	return $args
} 

proc ixConvertToUDFTableList {args} {
	set size [string length $args]
	for {set i 0} {$i < $size} {incr i} {
		set char [string index $args $i]
		if {![regexp {[0-9a-fA-F]} $char]} {
		   set args [string replace $args $i $i ""]
		}
	}
	return $args
}

#==================================================
# 函数名称:                                                         
#    ixConvertToIxiaMask                                                        
# 描述:                                                               
#    将Filter掩码转换为Ixia格式的0位生效                                   
# 参数:                                                          
# 语法描述:                                                         
#     ixConvertToIxiaMask "ff ff"                           
# 返回值：                                                          
#    list列表                        
#==================================================  
proc ixConvertToIxiaMask {mask} {
	set mask_len [llength $mask]
	set mask_dec [ixia::list2Val $mask]
	set ff_dec [ixia::list2Val [string repeat ff $mask_len]]
	set mask_bitwise_eor [expr $mask_dec ^ $ff_dec]
	return [ixia::val2Bytes $mask_bitwise_eor $mask_len]
}


# IsIPv4Address --
#   Error codes : TRUE(1)     success
#                 FALSE (0)    no match
#   Error condition :
#               1.Doesnot match A.B.C.D
#               2.{ A B C D }'s element is not an Integer between 0 and 255
proc IsIPv4Address { value } {
Deputs "Judgement: ipv4 address format"
   if { [ regexp -nocase {(\d+)\.(\d+)\.(\d+)\.(\d+)} $value ip a b c d ] } {
Deputs "Is Ipv4 address..."
        if { ( $a > 255 ) || ( $b > 255 ) || ( $c > 255 ) || ( $d > 255 ) } {
            return 0
        }
        return 1
    } else {
Deputs "Invalid ipv4 format"
        return 0
    }
}

proc IsIPv4Mask { value } {
    if { [ ixIsValidNetMask $value ] } {
        return 1
    } else {
        return 0
    }
}

proc IsIPv4MulticastAddress { value } {
    if { [ IsIPv4Address $value ] } {
        regexp {(\d+)} $value match A
        if { ( $A >= 224 ) && ( $A < 240 ) } {
            return 1
        } else {
            return 0
        }
    } else {
        return 0
    }
}

# parameter sequence is: ipaddr prefix number modifer
proc Ipv4ScopeValidate { args } {
    set tmpparameterlist {}
    foreach tmppara $args {
        set tmpparameterlist [concat $tmpparameterlist $tmppara]
    }
    set parameterlist $tmpparameterlist
    if {[llength $parameterlist] != 4} {
        return 0
    } else {
        foreach {Ipv4Addr Prefix Number Modifier} $parameterlist {
            set IpList [split $Ipv4Addr .]
            set Ipv4Addr 0
            for {set Loopi 0} {$Loopi < 4} {incr Loopi} {
                set Ipv4Addr [expr $Ipv4Addr+[expr [lindex $IpList $Loopi]*[expr pow(256, [expr 3-$Loopi])]]]
            }
            set Ipv4Addr [string range $Ipv4Addr 0 [expr [string first . $Ipv4Addr] - 1]]
            return [expr ([expr [expr $Ipv4Addr>>[expr 32-$Prefix]]+[expr [expr $Number-1]*$Modifier]] < [expr pow(2, $Prefix)])?1:0]
        }
    }
}

# IsIPv6Address --
#   Error codes : TRUE(1)     success
#                 FALSE (0)    no match
#   Error condition :
#               1.Doesnot match A:B:C:D:E:F:G:H
#               2.{ A B C D }'s element is not an sign which in the set [0-9a-f]   
proc IsIPv6Address { value } {
   set flag 1
   set hexList [ split $value ":" ]
   if { [ llength $hexList ] == 8 } {
      foreach hex $hexList {
         if { [ IsHex $hex ] == 0 } {
            set flag 0
            break
         }
      }
   } else {
      set index [ string first "::" $value ]
      if { $index < 0 } {
         return 0
      }
      
      set hexList [ split $value ":" ]
      foreach hex $hexList {
         if { $hex == "" } {
            continue
         }
         if { [ IsHex $hex ] == 0 } {
            set flag 0
            break
         }
      }

   }
   return $flag

}

proc IsMacAddress { value } {

    if { [  regexp -nocase {[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]} $value ] } {
        return 1
    } else {
        return 0
    }
}

proc MacTrans { mac { huaweiFormat 0 } } {
    set value $mac
    set len [ string length $value ]
    for { set index 0 } { $index < $len } { incr index } {
        if { [ string index $value $index ] == " " || \
            [ string index $value $index ] == "-" ||
            [ string index $value $index ] == "." ||
			[ string index $value $index ] == ":" } {
			if { $huaweiFormat } {
				set value [ string replace $value $index $index "-" ] 
			} else {
				set value [ string replace $value $index $index ":" ] 
			}
        }
    }
Deputs "standard mac:$value"
    set needtrans 1
    while { $needtrans } {
        set needtrans 0
        if { [ regexp -nocase {([0-9|a-f][0-9|a-f][0-9|a-f][0-9|a-f]:??)} \
            $value match specmac ] } {
            set needtrans 1
            set index [ string first $specmac $value ]
            set len [ string length $specmac ]
			if { $huaweiFormat } {
#Deputs "huawei format..."
				set newmac \
				"[string range $specmac 0 1]-[string range $specmac 2 end]"
			} else {
				set newmac \
				"[string range $specmac 0 1]:[string range $specmac 2 end]"
			}
            set value [ string replace $value $index \
                       [expr $index + $len -1] $newmac ]
        }
    }
    return $value
}

proc UnitTrans { value } {
   set k *1000
   set K *1000
   set m *1000000
   set M *1000000
   set g *1000000000
   set G *1000000000
    if { [ string is integer $value ] || [ string is double $value ] } {
        return $value
    }
    if { [regexp {^([0-9]+(\.[0-9]+)?)([kKmMgG])$} $value match digit round unit ] } {
        if {$unit == ""} {
            return $value
        }
        return [eval expr $digit$$unit ]
    } else {
        return NAN
    }
}

proc BoolTrans { value } {
    set value [ string tolower $value ]
    if { ( $value == "enable" ) || ( $value == "success" ) || ( $value == "true" )  } {
        set value 1
    }
    if { ( $value == "disable" ) || ( $value == "fail" ) || ( $value == "false" )  } {
        set value 0
    }
    if { $value == 1 || $value == 0 } {
        return $value
    } else {
        if { [ info exists [string tolower $value] ] == 0 } {
            return $value
        }
        eval { set trans } $[string tolower $value]
        if { $trans == 1 || $trans == 0 } {
            return $trans
        } else {
            return $value
        }
    }
}

proc TimeTrans { value } {
   set ms  *0.001
   set sec *1
   set min *60
   set hour *3600
    if { [ string is integer $value ] } {
        return $value
    }
    if { [ regexp -nocase {^([0-9]+)(sec|min|hour|s|m|h|ms)$} $value match digit unit ] } {
        if { $unit == "" } {
            return $value
        } else {
            if { $unit == "s" } { set unit sec }
            if { ($unit == "m") || ($unit == "min") } { set unit min }
            if { ($unit == "h") || ($unit == "hour") } { set unit hour }
            if { $unit == "ms" } { set unit ms }
        }
        return [eval expr $digit$$unit ]
    } else {
        return NAN
    }
}

proc IntTrans { value } {
    set index [ string first "." $value ]
    if { $index >= 0 } {
        string replace $value $index end
    } else {
        return $value
    }
}

proc ObjectExist { value } {

    set objectList [ find objects ]
    if { [ lsearch -exact $objectList $value ] < 0 } {
        return 0
    } else {
        return 1
    }
}

proc IsInt {value} {
    if {[regexp {^( )*(\d)+( )*$} $value]} {
            return 1
    } else {
            return 0
    }
}

proc List2Str { value { sep " " } } {
    set retStr ""
    foreach item $value {
        set retStr $retStr$item$sep
    }
    return $retStr
}

proc IsHex {value} {
    if { [ regexp -nocase {^0x} $value ] } {
        set value [ string range $value 2 end ]
    }
    set strLen  [ string length $value ]
    for { set index 0 } { $index < $strLen } { incr index } {
      set checkChar   [ string index $value $index ]
      if { $checkChar == " " } {
         continue
      }
      if { [ regexp -nocase {[0-9a-f]} $checkChar ] } {
          continue
      } else {
          return 0
      }
    }
    return 1
}

proc PrefixlenToSubnetV4 {value} {
    if {$value >= 0 && $value <=8} {
            set first	[expr 256 - [expr int([expr {pow(2,[expr 8 - $value])}]) ]  ]
            return $first.0.0.0
    } elseif {$value >8 && $value <=16} {
            set second	[expr 256 - [expr int([expr {pow(2,[expr 16 - $value])}]) ]  ]
            return 255.$second.0.0 
    } elseif {$value > 16 && $value <=24} {
            set third	[expr 256 - [expr int([expr {pow(2,[expr 24 - $value])}]) ]  ]
            return 255.255.$third.0 
    } elseif {$value > 24 && $value <=32} {
            set fourth	[expr 256 - [expr int([expr {pow(2,[expr 32 - $value])}]) ]  ]
            return 255.255.255.$fourth 
    } else {
            return "NAN"
    }            
}

proc SubnetToPrefixlenV4 {value} {
    for {set c 0 } {$c <=32} {incr c} {
            if {[PrefixlenToSubnetV4 $c] ==  "$value"} {
                    return $c
            }
    }
    return -1
}

# -- Transfer the ip address to hex
#   -- prefix should be the valid length of result string like the length of
#       1c231223 is 1c23 when prefix is 16
#       the enumation of prefix should be one of 8 16 32
proc IP2Hex { ipv4 { prefix 32 } } {
    if { [ regexp {(\d+)\.(\d+)\.(\d+)\.(\d+)} $ipv4 match A B C D ] } {
        set ipHex [ Int2Hex $A ][ Int2Hex $B ][ Int2Hex $C ][ Int2Hex $D ]
        return [ string range $ipHex 0 [ expr $prefix / 4 - 1 ] ]
    } else {
        return 00000000
    }
}

proc Mac2Hex { mac } {
    set value $mac
    set len [ string length $value ]
    for { set index 0 } { $index < $len } { incr index } {
        if { [ string index $value $index ] == " " || \
            [ string index $value $index ] == "-" ||
            [ string index $value $index ] == "." ||
			[ string index $value $index ] == ":" } {

			set value [ string replace $value $index $index " " ] 

        }
    }

    return $value
	
}

# -- Transfer the integer to hex
#   -- len should be the length of result string like the length of 'abcd' is 4
proc Int2Hex { byte { len 2 } } {
    set hex [ format %x $byte ]
    set hexlen [ string length $hex ]
    if { $hexlen < $len } {
        set hex [ string repeat 0 [ expr $len - $hexlen ] ]$hex
    } elseif { $hexlen > $len } {
        set hex [ string range $hex [ expr $hexlen - $len ] end ]
    }
    return $hex
}

# 1. Int to Hex  2. Format Hex
proc FmtInt2Hex {byte btnum} {
	set len [expr 2*$btnum]
	puts "len is: $len"
	set hex [format %x $byte]
	puts "hex is: $hex"
	set hexlen [ string length $hex ]
	puts "hexlen is: $hexlen"
	if {$hexlen < $len} {
		set hex [ string repeat 0 [ expr $len - $hexlen ] ]$hex
		Deputs "hex is: $hex"
	} elseif {$hexlen > $len} {
		set hex [ string range $hex [ expr $hexlen - $len ] end ]
		Deputs "hex is: $hex"
	}
	return $hex
}

proc IncrementIPAddr { IP prefixLen { num 1 } } {
    set Increament_len [ expr 32 - $prefixLen ]
    set Increament_pow [ expr pow(2,$Increament_len) ]
    set Increament_int [ expr round($Increament_pow*$num) ]
    set IP_hex       0x[ IP2Hex $IP ]
    set IP_next_int    [ expr $IP_hex + $Increament_int ]
    if { $IP_next_int > [ format %u 0xffffffff ] } {
        error "Out of address bound"
    }
    set IP_next_hex    [ format %x $IP_next_int ]
    if { [ string length $IP_next_hex ] < 8 } {
        set IP_next_hex [ string repeat 0 [ expr 8 - [ string length $IP_next_hex ] ] ]$IP_next_hex
    } elseif { [ string length $IP_next_hex ] > 8 } {
        #...
        #error ""
    }
    set index_end  0
    set A [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
    incr index_end 2
    set B [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
    incr index_end 2
    set C [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
    incr index_end 2
    set D [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
    return [format %u 0x$A].[format %u 0x$B].[format %u 0x$C].[format %u 0x$D]
}
proc IncrementIPv6Addr { IP prefixLen { num 1 } } {
      Deputs "pfx len:$prefixLen IP:$IP num:$num"
	
      if { [ string first "::" $IP ] >= 0 } {
		while { [ llength [ split $IP ":" ] ] < 8 } {
			set colIndex [ string first "::" $IP ]
			set IP [ string replace $IP \
				[ expr $colIndex + 1 ] \
				[ expr $colIndex + 1 ] \
				":0:" \
				]
		}
		set colIndex [ string first "::" $IP ]
		set IP [ string replace $IP $colIndex $colIndex ":0" ]
	}
	set segList [ split $IP ":" ]
	set seg [ expr $prefixLen / 16 - 1 ]
      Deputs "set:$seg"
	set offset [ expr fmod($prefixLen,16) ]
   Deputs "offset:$offset"
	if { $offset  > 0 } {
		incr seg
	}
   Deputs "set:$seg"
	set segValue [ lindex $segList $seg ]
   Deputs "segValue:$segValue"
	set segInt 	 [ format %i 0x$segValue ]
   Deputs "segInt:$segInt"
	if { $offset } {
		incr segInt  [ expr round(pow(2, 16 - $offset)*$num )]
	} else {
		incr segInt $num
	}
Deputs "segInt:$segInt"
	if { $segInt > 65535 } {
		incr segInt -65536
		set segHex [format %x $segInt]
Deputs "segHex:$segHex"
		set segList [lreplace $segList $seg $seg $segHex]
		set newIp ""
		foreach segment $segList {
			set newIp ${newIp}:$segment
		}
		set IP [ string range $newIp 1 end ]
Deputs "IP:$IP"
		set ret [ IncrementIPv6Addr $IP [ expr $seg * 16 ] ]
		
	} else {
		set segHex [format %x $segInt]
		set segList [lreplace $segList $seg $seg $segHex]
		set newIp ""
		foreach segment $segList {
			set newIp ${newIp}:$segment
		}
		set IP [ string range $newIp 1 end ]
		set ret [ string tolower $IP ]

	}
	
	if { [ string index $ret end ] == ":"} {
		set ret ${ret}0
	}
	return $ret
}

proc GetMatchedMask { tester_ip sut_ip } {
    set classAddressTester  [ split $tester_ip "." ]
    set classAddressSut     [ split $sut_ip "." ]
    set mask 0
    foreach testerAddr $classAddressTester sutAddr $classAddressSut {
        if { $testerAddr == $sutAddr } {
            incr mask 8
        } else {
            break
        }
    }
    return $mask
}

proc GetMacStep { offset val } {
Deputs "offset :$offset val: $val"
    set macStep ""
    set segment [ expr $offset / 8 ]
    set remain  [ expr fmod($offset,8)]
Deputs "segment:$segment remain:$remain"
    for { set index 0 } { $index < 6 } { incr index } {
        if { $segment == $index } {
            set step [expr round(pow(2,$remain)*$val)]
            set stepHex [format %x $step]
            if { [ string length $stepHex ] < 2 } {
                set stepHex "0$stepHex"
            }
Deputs "step:$step stepHex:$stepHex"
            if { $index > 0 } {
                set macStep ${stepHex}:$macStep
            } else {
                set macStep ${stepHex}$macStep
            }
        } else {
            if { $index > 0 } {
                set macStep 00:$macStep
            } else {
                set macStep 00$macStep
            }
        }
Deputs "macStep:$macStep"
    }
    return $macStep
}

# --
# GetIpStep 0 1 => 0.0.0.1
# GetIpStep 1 1 => 0.0.0.2
proc GetIpStep { offset val } {

	if { [ catch {
		set ipStep [IncrementIPAddr 0.0.0.0 [expr 32 - $offset] $val ]
	} ] } {
		set ipStep 0.0.0.0
	}

    return $ipStep
}

proc GetIpv6Step { offset val } {
	if { [ catch {
		set ipStep [IncrementIPv6Addr 00:00:00:00:00:00:00:00 $offset $val ]
	} err ] } {
Deputs "ERR:$err"	
		set ipStep 00:00:00:00:00:00:00:00
	}

    return $ipStep
}

# --
# GetStepPrefixlen 0.0.0.1 => 32
proc GetStepPrefixlen { ip } {
   for { set index 0 } { $index < 32 } { incr index } {
      
      if { [ GetIpStep $index 1 ] == $ip } {
         return [ expr 32 - $index ]
      }
   }
   return -1
}

proc GetObject { name } {
Deputs "GetObject search..."
Deputs "objs:[find objects]"
    foreach obj [ find objects ] {
    	if { $name == $obj || $name == "::$obj"} {
    	    return $obj
    	}
        if { [ regexp $name $obj ] && ![ regexp ${name}. $obj ] && ![ regexp "\[^:\]$name" $obj ] } {
            return $obj
        }
    }
    return ""
}

proc GetStandardReturnHeader {} {
#    set statFormat "%10s : %10s"    
#    set ret "[ format $statFormat "Status" "true" ]\n"
#    set ret "$ret[ format $statFormat "Log" "" ]\n"
	set ret "Status : true\nLog:\n"
    return $ret
}

proc GetErrorReturnHeader { log } {
#    set statFormat "%10s : %10s"    
#    set ret "[ format $statFormat "Status" "false" ]\n"
#    set ret "$ret[ format $statFormat "Log" "$log" ]\n"
	set ret "Status:false\nLog:$log\n"
    return $ret
}

proc GetStandardReturnBody { key value } {
#    set statFormat "%10s : %10s"    
#    set ret "[ format $statFormat "$key" "$value" ]\n"
	set ret "$key:$value\n"
    return $ret
}

# --
# GetPrefixV4Step 32 1 => 1
# GetPrefixV4Step 24 1 => 256
proc GetPrefixV4Step { pfx { step 1 } } {
	
	return [ IntTrans [ expr pow(2, 32 - $pfx) * $step ] ]
	
}

proc DecToHex { value } {
   set value [format "%x" $value]
   if { [ expr [ string length $value ] % 2 ] != 0 } {
      set value 0$value
   }
   return $value
}

proc IncrMacAddr { mac1 { mac2 00:00:00:00:00:01 } } {
   if { [ string is integer $mac2 ] } {
      set hexVal [ DecToHex $mac2 ]
      if { [ expr [ string length $hexVal] % 2 ] != 0 } {
      	set hexVal 0$hexVal
      }
      set len [ expr [ string length $hexVal] / 2 ]
      set macStr ""
      for { set i 0 } { $i < [ expr 6 - $len] } { incr i } {
         set macStr ${macStr}00
      }
      set macStr $macStr$hexVal
      
      set mac2 ""
      for { set i 0 } { $i < 12 } { incr i 2 } {
         if { $mac2 != "" } {
            set mac2 ${mac2}:[ string range $macStr $i [ expr $i + 1 ] ]
         } else {
            set mac2 [ string range $macStr $i [ expr $i + 1 ] ]
         }
      }
   }
	set mac1List [ split $mac1 ":" ]
	set mac2List [ split $mac2 ":" ]
	set macLen [ llength $mac1List ]
	
	set macResult 	""
	set flagAdd		0
	for { set index $macLen } { $index > 0 } { incr index -1 } {
      #Deputs "loop index:$index"
		set eleIndex  	[ expr $index -1 ]
      #Deputs "index:$eleIndex"
		set mac1Ele 	[ lindex $mac1List $eleIndex ]
		set mac2Ele		[ lindex $mac2List $eleIndex ]
#Deputs "mac element:$mac1Ele $mac2Ele"
		set macAdd 		[ format %x [ expr 0x$mac1Ele + 0x$mac2Ele ] ]
#Deputs "mac plus addr:$macAdd"
		if { $flagAdd } {
			scan $macAdd %x macAddD
			incr macAddD $flagAdd
			set macAdd [ format %x $macAddD ]
		}
#Deputs "incr flag:$macAdd"
		if { [ string length $macAdd ] > 2 } {
			set flagAdd	1
			set macAdd [ string range $macAdd [ expr [ string length $macAdd ] - 2 ] end ]
		} else {
			set flagAdd 0
		}
#Deputs "flag add:$flagAdd"
		# set macTrans [ expr round(fmod($macAdd,16)) ]
# Deputs "macTrans:$macTrans"
		# set macTrans [ format %x $macTrans ]
# Deputs "macTrans hex:$macTrans"
		if { [ string length $macAdd ] == 1 } {
			set macAdd "0$macAdd"
		}
#Deputs "macTrans after add zero:$macAdd"
		set macResult ":$macAdd$macResult"
#Deputs "macResult:$macResult"
		}
	return [ string range $macResult 1 end ]
}

proc RandomMacAddr {} {
	set a [Ran255]
	set b [Ran255]
	set c [Ran255]
	return 00:00:00:$a:$b:$c
}

proc Ran255 {} {
	set ran01 [ expr rand() ]
	set ran255 [ expr $ran01 * 255 ]
	set ran255Int [ expr round($ran255) ]
	set ran255Hex [ format %x $ran255Int ]
	if { [ string length $ran255Hex ] == 1 } {
		set ran255Hex 0$ran255Hex
	}
	return $ran255Hex
}

proc HexValue {value} {
	if {[regexp -nocase {^0x} $value]} {
		return $value
	} else {
		return "0x$value"
	}
}

proc HexToDec { value } {
   set value [HexValue $value]
   scan $value %x dec
   return $dec
}
proc DecToHex { value } {
   set value [format "%x" $value]
   if { [ expr [ string length $value ] / 2 ] != 0 } {
      set value 0$value
   }
   return $value
}
proc BinToDec {value} {
	set binary_vlaue $value
	binary scan [binary format B* [format %032s $binary_vlaue]] I1 decimal_value
	return $decimal_value
}

proc IntToBin {value {len 8}} {
	set bin ""
	for { set exp [ expr $len - 1 ] } { $exp >= 0 } { incr exp -1 } {
		set pow [ expr pow(2, $exp) ]
		if { [expr $value - $pow ] >= 0 } {
			set bin ${bin}1
			set value [ expr $value - $pow ]
		} else {
			set bin ${bin}0
		}
	}
	return $bin
}

proc PutsFormatInput { input { isgets 1 } } {
	puts "<input_para>"
	foreach cin $input {
		global $cin
		if { $isgets } {
			gets stdin $cin
		}
		puts "$cin : [set $cin]"
	}
	puts "</input_para>"
}

proc PutsFormatCp { args } {
		
	puts "<cp>"
	
	foreach { key val } $args {
		puts "<$key>"
		puts "$val"
		puts "</$key>"
	}
	
	puts "</cp>"
}

# -- 
# Get key value from Huawei defined stats
proc GetStatsFromReturn { stats key } {
	set regStr "\{$key:(\\d+)\}"
	set regStr2 "\{$key:(\\d+\.\\d+)\}"
    set regStr3 "\{$key:(-\\d+\.\\d+)\}"
    set regStr4 "\{$key:(-\\d+)\}"
	Deputs "the reg key is: $key"
	if { [ eval regexp $regStr2 {$stats} match val ] } {
		return $val
	} elseif { [ eval regexp $regStr {$stats} match val ] } {
		return $val
    } elseif { [ eval regexp $regStr3 {$stats} match val ] } {
       return $val
    } elseif { [ eval regexp $regStr4 {$stats} match val ] } {
       return $val
	} else {
		return ""
	}
}

proc GetResultFromReturn { stats } {
	set regStr "\{status:true\}"
	
	if { [ eval regexp -nocase $regStr {$stats} ] } {
		return 1
	} else {
		return 0
	}
}

proc GetFileFromDir { dir name } {
    set old_dir [ pwd ]
    cd $dir
	foreach f [glob nocomplain "*.*"] {
		if { [regexp ".*$name.*" $f ] } {
            cd $old_dir
			return $f
		}
	}
    cd $old_dir
    return ""
}


proc GetObjNameFromString { str { retVal "" } } {
	set name ""
	if { [ catch {
		set name [lindex [split [lindex [split $str "\("] 1] "\)"] 0]
	} err ] } {
		return $retVal
	} 
	return $name
}