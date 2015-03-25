 package req IxiaNet
Login 111.207.146.100/8009
IxDebugOff

Port @tester_to_dta1 192.168.0.21/1/9
Port @tester_to_dta2 192.168.0.21/1/10
Port @tester_to_dta3 192.168.0.21/1/11

 @tester_to_dta1 config -location "190.2.152.82/5/1" -dut_ip "15.13.14.1" -intf_ip "15.13.14.2"
 
 BgpSession @tester_to_dta1.bgp(1) @tester_to_dta1
 @tester_to_dta1.bgp(1) config -type "external" -as "200" -dut_as "100" -ipv4_addr "15.13.14.2" -dut_ip "15.13.14.1" -ip_version "ipv4"
 
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -start "150.0.0.1" -step "1" -num "3" -prefix_len "255.255.255.0"
 @tester_to_dta1.bgp(1) set_route -route_block "@tester.route_block(1)"
 
 RouteBlock @tester.route_block(4)
 @tester.route_block(4) config -start "65.0.0.1" -step "1" -num "300" -prefix_len "255.255.255.0"
 @tester_to_dta1.bgp(1) set_route -route_block "@tester.route_block(4)"
 
 @tester_to_dta2 config -location "190.2.152.82/5/2" -dut_ip "16.13.14.1" -intf_ip "16.13.14.2"
 
 BgpSession @tester_to_dta2.bgp(2) @tester_to_dta2
 @tester_to_dta2.bgp(2) config -type "external" -as "200" -dut_as "100" -ipv4_addr "16.13.14.2" -dut_ip "16.13.14.1" -ip_version "ipv4"
 
 RouteBlock @tester.route_block(2)
 @tester.route_block(2) config -start "151.0.0.1" -step "1" -num "3" -prefix_len "255.255.255.0"
 @tester_to_dta2.bgp(2) set_route -route_block "@tester.route_block(2)"
 
 RouteBlock @tester.route_block(5)
 @tester.route_block(5) config -start "66.0.0.1" -step "1" -num "300" -prefix_len "255.255.255.0"
 @tester_to_dta2.bgp(2) set_route -route_block "@tester.route_block(5)"
 
 @tester_to_dta3 config -location "190.2.152.82/5/3" -dut_ip "17.13.14.1" -intf_ip "17.13.14.2"
 
 BgpSession @tester_to_dta3.bgp(3) @tester_to_dta3
 @tester_to_dta3.bgp(3) config -type "external" -as "200" -dut_as "100" -ipv4_addr "17.13.14.2" -dut_ip "17.13.14.1" -ip_version "ipv4"
 
 RouteBlock @tester.route_block(3)
 @tester.route_block(3) config -start "152.0.0.1" -step "1" -num "3" -prefix_len "255.255.255.0"
 @tester_to_dta3.bgp(3) set_route -route_block "@tester.route_block(3)"
 
 RouteBlock @tester.route_block(6)
 @tester.route_block(6) config -start "67.0.0.1" -step "1" -num "300" -prefix_len "255.255.255.0"
 @tester_to_dta3.bgp(3) set_route -route_block "@tester.route_block(6)"
 
 @tester_to_dta1.bgp(1) start
 @tester_to_dta2.bgp(2) start
 @tester_to_dta3.bgp(3) start
 IxDebugOn
 
 @tester_to_dta1.bgp(1) flapping_route -a2w "20" -w2a "10" -route_block "@tester.route_block(4)"
 @tester_to_dta2.bgp(2) flapping_route -a2w "20" -w2a "10" -route_block "@tester.route_block(5)"
 @tester_to_dta3.bgp(3) flapping_route -a2w "20" -w2a "10" -route_block "@tester.route_block(6)"
 
 Rfc2544 @tester.rfc2544
 @tester.rfc2544 unconfig
 @tester.rfc2544 throughput -dst_endpoint "@tester.route_block(1) @tester.route_block(2) @tester.route_block(3)" -latency_type "lifo" -traffic_mesh "fullmesh" -duration "10" -port_load {100 80 100} -resultdir "D:/1002----impeller/SR-performance/data/" -frame_len_type "custom" -traffic_type "ipv4" -resultfile "RT_CASE_PERF.00042_v600r008c10b300_20140605170511.csv" -frame_len {64} -resultlvl "0" -src_endpoint "@tester.route_block(1) @tester.route_block(2) @tester.route_block(3)" -measure_jitter "false"
