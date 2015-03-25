 package req IxiaNet
Login 111.207.146.100/8009
IxDebugOff

Port @tester_to_dta1 192.168.0.21/1/9

 BgpSession @tester_to_dta1.bgp(1) @tester_to_dta1
 @tester_to_dta1.bgp(1) config -type "external" -as "200" -dut_as "100" -ipv4_addr "15.13.14.2" -dut_ip "15.13.14.1" -ip_version "ipv4"
 
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -start "150.0.0.1" -step "1" -num "3" -prefix_len "255.255.255.0"
 @tester_to_dta1.bgp(1) set_route -route_block "@tester.route_block(1)"
 
IxDebugOn
 
 @tester_to_dta1.bgp(1) flapping_route -a2w "20" -w2a "10" -route_block "@tester.route_block(1)"

