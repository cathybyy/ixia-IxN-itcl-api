 package req IxiaNet
Login 190.2.152.81/8012
IxDebugOff
Port @tester_to_dta1 190.2.152.82/5/1
Port @tester_to_dta2 190.2.152.82/5/2
Port @tester_to_dta3 190.2.152.82/5/3


 @tester_to_dta1 config -dut_ip "20.13.14.1" -intf_ip "20.13.14.2"
 @tester_to_dta2 config -dut_ip "21.13.14.1" -intf_ip "21.13.14.2"
 @tester_to_dta3 config -dut_ip "22.13.14.1" -intf_ip "22.13.14.2"
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -tx_mode "burst" -src "@tester_to_dta1 @tester_to_dta2 @tester_to_dta3" -tx_num "100000" -frame_len_type "fixed" -dst "@tester_to_dta1 @tester_to_dta2 @tester_to_dta3" -frame_len "256" -stream_load "100" -traffic_pattern "mesh" -load_unit "percent"
 Tester::start_traffic
 @tester_to_dta1.traffic(1) get_stats
