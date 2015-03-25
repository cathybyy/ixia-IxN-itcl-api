 package req IxiaNet
Login 111.207.146.100/8012
IxDebugOff

Port @tester_to_dta1 NULL NULL ::ixNet::OBJ-/vport:1
Port @tester_to_dta2 NULL NULL ::ixNet::OBJ-/vport:2
Port @tester_to_dta3 NULL NULL ::ixNet::OBJ-/vport:3
Port @tester_to_dta4 NULL NULL ::ixNet::OBJ-/vport:4

 @tester_to_dta1 config -location "190.2.152.83/4/1" -dut_ip "200.13.14.1" -intf_ip "200.13.14.2"
 Ospfv2Session @tester_to_dta1.ospf(1) @tester_to_dta1
 @tester_to_dta1.ospf(1) config -ospf_obj "@tester_to_dta1.ospf(1)" -ipv4_gw "200.13.14.1" -ipv4_prefix_len "24" -ipv4_addr "200.13.14.2" -router_id "2.2.2.1" -loopback_ipv4_addr "2.2.2.1" -area_id "0.0.0.0" -loopback_ipv4_gw "170.170.170.170"
 LdpSession @tester_to_dta1.ldp(1) @tester_to_dta1
 @tester_to_dta1.ldp(1) config -ipv4_gw "200.13.14.1" -ipv4_addr "200.13.14.2" -router_id "2.2.2.1"
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -start "2.2.2.1" -prefix_len "32" -step "1" -num "1"
 Ipv4PrefixLsp @tester_to_dta1.ldp(1).prefix_lsp(1) @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).prefix_lsp(1) config -route_block "@tester.route_block(1)"
 BgpSession @tester_to_dta1.bgp(1) @tester_to_dta1
 @tester_to_dta1.bgp(1) config -type "internal" -as "100" -dut_as "100" -ipv4_addr "2.2.2.1" -dut_ip "170.170.170.170" -router_id "2.2.2.1" -ip_version "ipv4"
 @tester.route_block(1) config -start "101.0.0.1" -prefix_len "255.255.255.0" -step "1" -num "3"
 Vpn @tester_to_dta1.bgp(1).vpn @tester_to_dta1.bgp(1)
 @tester_to_dta1.bgp(1).vpn config -rt "100:1" -route_block "@tester.route_block(1)" -rd "100:1"
 
 
 @tester_to_dta2 config -location "190.2.152.83/4/2" -dut_ip "201.13.14.1" -intf_ip "201.13.14.2"
 Ospfv2Session @tester_to_dta2.ospf(2) @tester_to_dta2
 @tester_to_dta2.ospf(2) config -ospf_obj "@tester_to_dta2.ospf(2)" -ipv4_gw "201.13.14.1" -ipv4_prefix_len "24" -ipv4_addr "201.13.14.2" -router_id "2.2.2.2" -loopback_ipv4_addr "2.2.2.2" -area_id "0.0.0.0" -loopback_ipv4_gw "170.170.170.170"
 LdpSession @tester_to_dta2.ldp(2) @tester_to_dta2
 @tester_to_dta2.ldp(2) config -ipv4_gw "201.13.14.1" -ipv4_addr "201.13.14.2" -router_id "2.2.2.2"
 @tester.route_block(1) config -start "2.2.2.2" -prefix_len "32" -step "1" -num "1"
 Ipv4PrefixLsp @tester_to_dta2.ldp(2).prefix_lsp(1) @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).prefix_lsp(1) config -route_block "@tester.route_block(1)"
 BgpSession @tester_to_dta2.bgp(2) @tester_to_dta2
 @tester_to_dta2.bgp(2) config -type "internal" -as "100" -dut_as "100" -ipv4_addr "2.2.2.2" -dut_ip "170.170.170.170" -router_id "2.2.2.2" -ip_version "ipv4"
 RouteBlock @tester.route_block(2)
 @tester.route_block(2) config -start "102.0.0.1" -prefix_len "255.255.255.0" -step "1" -num "3"
 Vpn @tester_to_dta2.bgp(2).vpn @tester_to_dta2.bgp(2)
 @tester_to_dta2.bgp(2).vpn config -rt "100:2" -route_block "@tester.route_block(2)" -rd "100:2"
 
 
 @tester_to_dta3 config -location "190.2.152.83/4/3" -dut_ip "1.13.14.1" -intf_ip "1.13.14.2"
 BgpSession @tester_to_dta3.bgp(1) @tester_to_dta3
 @tester_to_dta3.bgp(1) config -type "external" -as "200" -dut_as "100" -ipv4_addr "1.13.14.2" -dut_ip "1.13.14.1" -ip_version "ipv4"
 RouteBlock @tester.route_block(3)
 @tester.route_block(3) config -start "51.0.0.1" -prefix_len "255.255.255.0" -step "1" -num "3"
 @tester_to_dta3.bgp(1) set_route -route_block "@tester.route_block(3)"
 
 @tester_to_dta4 config -location "190.2.152.83/4/4" -dut_ip "2.13.14.1" -intf_ip "2.13.14.2"
 BgpSession @tester_to_dta4.bgp(2) @tester_to_dta4
 @tester_to_dta4.bgp(2) config -type "external" -as "200" -dut_as "100" -ipv4_addr "2.13.14.2" -dut_ip "2.13.14.1" -ip_version "ipv4"
 RouteBlock @tester.route_block(4)
 @tester.route_block(4) config -start "52.0.0.1" -prefix_len "255.255.255.0" -step "1" -num "3"
 @tester_to_dta4.bgp(2) set_route -route_block "@tester.route_block(4)"
 
 Traffic @tester_to_dta3.traffic(1) @tester_to_dta3
 @tester_to_dta3.traffic(1) config -src "@tester.route_block(3) @tester.route_block(4)" -traffic_pattern "pair" -dst "@tester.route_block(1) @tester.route_block(2)" -stream_load "10" -load_unit "percent"

# IxDebugOn
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -src "@tester.route_block(1) @tester.route_block(2)" -traffic_pattern "pair" -dst "@tester.route_block(3) @tester.route_block(4)" -stream_load "10" -load_unit "percent"
