package req IxiaNet
Login 190.2.152.81/8012
IxDebugOff
Port @tester_to_dta1 190.2.152.82/5/1
Port @tester_to_dta2 190.2.152.82/5/2
Port @tester_to_dta3 190.2.152.82/5/3

 @tester_to_dta1 config -ipv6_addr "2000:0000::2" -location "190.2.152.82/5/4" -ipv6_gw "2000:0000::1" -ipv6_prefix_len "32" -dut_ip "15.13.14.1" -intf_ip "15.13.14.2"
 BgpSession @tester_to_dta1.bgp(1) @tester_to_dta1
 @tester_to_dta1.bgp(1) config -type "external" -dut_as "100" -ipv4_addr "15.13.14.2" -ip_version "ipv4" -dut_ip "15.13.14.1" -as "200"
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -start "150.0.0.1" -step "1" -prefix_len "255.255.255.0" -num "3"
 @tester_to_dta1.bgp(1) set_route -route_block "@tester.route_block(1)"
 BgpSession @tester_to_dta1.bgp(4) @tester_to_dta1
 @tester_to_dta1.bgp(4) config -type "external" -dut_as "100" -router_id "200.13.14.2" -ipv6_addr "2000:0000::2" -ip_version "ipv6" -dut_ip "2000:0000::1" -as "200"
 RouteBlock @tester.route_block(4)
 @tester.route_block(4) config -start "2200:0000::1" -step "1" -prefix_len "64" -num "3"
 @tester_to_dta1.bgp(4) set_route -route_block "@tester.route_block(4)"
 @tester_to_dta2 config -ipv6_addr "2000:0001::2" -location "190.2.152.82/5/6" -ipv6_gw "2000:0001::1" -ipv6_prefix_len "32" -dut_ip "16.13.14.1" -intf_ip "16.13.14.2"
 BgpSession @tester_to_dta2.bgp(2) @tester_to_dta2
 @tester_to_dta2.bgp(2) config -type "external" -dut_as "100" -ipv4_addr "16.13.14.2" -ip_version "ipv4" -dut_ip "16.13.14.1" -as "200"
 RouteBlock @tester.route_block(2)
 @tester.route_block(2) config -start "151.0.0.1" -step "1" -prefix_len "255.255.255.0" -num "3"
 @tester_to_dta2.bgp(2) set_route -route_block "@tester.route_block(2)"
 BgpSession @tester_to_dta2.bgp(5) @tester_to_dta2
 @tester_to_dta2.bgp(5) config -type "external" -dut_as "100" -router_id "201.13.14.2" -ipv6_addr "2000:0001::2" -ip_version "ipv6" -dut_ip "2000:0001::1" -as "200"
 RouteBlock @tester.route_block(5)
 @tester.route_block(5) config -start "2200:0001::1" -step "1" -prefix_len "64" -num "3"
 @tester_to_dta2.bgp(5) set_route -route_block "@tester.route_block(5)"
 @tester_to_dta3 config -ipv6_addr "2000:0002::2" -location "190.2.152.82/5/5" -ipv6_gw "2000:0002::1" -ipv6_prefix_len "32" -dut_ip "17.13.14.1" -intf_ip "17.13.14.2"
 BgpSession @tester_to_dta3.bgp(3) @tester_to_dta3
 @tester_to_dta3.bgp(3) config -type "external" -dut_as "100" -ipv4_addr "17.13.14.2" -ip_version "ipv4" -dut_ip "17.13.14.1" -as "200"
 RouteBlock @tester.route_block(3)
 @tester.route_block(3) config -start "152.0.0.1" -step "1" -prefix_len "255.255.255.0" -num "3"
 @tester_to_dta3.bgp(3) set_route -route_block "@tester.route_block(3)"
 BgpSession @tester_to_dta3.bgp(6) @tester_to_dta3
 @tester_to_dta3.bgp(6) config -type "external" -dut_as "100" -router_id "202.13.14.2" -ipv6_addr "2000:0002::2" -ip_version "ipv6" -dut_ip "2000:0002::1" -as "200"
 RouteBlock @tester.route_block(6)
 @tester.route_block(6) config -start "2200:0002::1" -step "1" -prefix_len "64" -num "3"
 @tester_to_dta3.bgp(6) set_route -route_block "@tester.route_block(6)"

IxDebugOn
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -src "@tester.route_block(1) @tester.route_block(2) @tester.route_block(3)" -dst "@tester.route_block(1) @tester.route_block(2) @tester.route_block(3)" -traffic_pattern "mesh" -stream_load "20" -load_unit "percent"
 Traffic @tester_to_dta1.traffic(2) @tester_to_dta1
 @tester_to_dta1.traffic(2) config -src "@tester.route_block(4) @tester.route_block(5) @tester.route_block(6)" -dst "@tester.route_block(4) @tester.route_block(5) @tester.route_block(6)" -traffic_pattern "mesh" -stream_load "80" -load_unit "percent"
