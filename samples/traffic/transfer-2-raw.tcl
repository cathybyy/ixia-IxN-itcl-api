 package req IxiaNet
Login 111.207.146.100/8012
IxDebugOff

Port @tester_to_dta1 NULL NULL ::ixNet::OBJ-/vport:1
Port @tester_to_dta2 NULL NULL ::ixNet::OBJ-/vport:2
Port @tester_to_dta3 NULL NULL ::ixNet::OBJ-/vport:3
Port @tester_to_dta4 NULL NULL ::ixNet::OBJ-/vport:4

 @tester_to_dta1 config -location "192.168.3.200/12/1" -intf_ip "200.13.14.2" -dut_ip "200.13.14.1"
 Ospfv2Session @tester_to_dta1.ospf(1) @tester_to_dta1
 @tester_to_dta1.ospf(1) config -router_id "2.2.2.1" -loopback_ipv4_addr "2.2.2.1" -area_id "0.0.0.0" -loopback_ipv4_gw "170.170.170.170" -ipv4_gw "200.13.14.1" -ipv4_prefix_len "24" -ospf_obj "@tester_to_dta1.ospf(1)" -ipv4_addr "200.13.14.2"
 LdpSession @tester_to_dta1.ldp(1) @tester_to_dta1
 @tester_to_dta1.ldp(1) config -router_id "2.2.2.1" -ipv4_gw "" -ipv4_addr ""
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -prefix_len "32" -start "2.2.2.1" -step "1" -num "1"
 Ipv4PrefixLsp @tester_to_dta1.ldp(1).prefix_lsp(1) @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).prefix_lsp(1) config -route_block "@tester.route_block(1)"
 VcLsp @tester_to_dta1.ldp(1).vc_lsp @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).vc_lsp config -vc_id_start "1" -requested_vlan_id_start "1" -vc_id_step "1" -requested_vlan_id_step "1" -vc_id_count "25" -requested_vlan_id_count "1" -mac_start "00:01:00:00:00:00" -peer_address "170.170.170.170" -mac_step "1" -if_mtu "9600" -encap "LDP_LSP_ENCAP_ETHERNET_VLAN" -mac_num "25"
 @tester_to_dta2 config -location "192.168.3.200/12/6" -intf_ip "201.13.14.2" -dut_ip "201.13.14.1"
 Ospfv2Session @tester_to_dta2.ospf(2) @tester_to_dta2
 @tester_to_dta2.ospf(2) config -router_id "2.2.2.2" -loopback_ipv4_addr "2.2.2.2" -area_id "0.0.0.0" -loopback_ipv4_gw "170.170.170.170" -ipv4_gw "201.13.14.1" -ipv4_prefix_len "24" -ospf_obj "@tester_to_dta2.ospf(2)" -ipv4_addr "201.13.14.2"
 LdpSession @tester_to_dta2.ldp(2) @tester_to_dta2
 @tester_to_dta2.ldp(2) config -router_id "2.2.2.2" -ipv4_gw "" -ipv4_addr ""
 RouteBlock @tester.route_block(2)
 @tester.route_block(2) config -prefix_len "32" -start "2.2.2.2" -step "1" -num "1"
 Ipv4PrefixLsp @tester_to_dta2.ldp(2).prefix_lsp(2) @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).prefix_lsp(2) config -route_block "@tester.route_block(2)"
 VcLsp @tester_to_dta2.ldp(2).vc_lsp @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).vc_lsp config -vc_id_start "26" -requested_vlan_id_start "1" -vc_id_step "1" -requested_vlan_id_step "1" -vc_id_count "25" -requested_vlan_id_count "1" -mac_start "00:02:00:00:00:00" -peer_address "170.170.170.170" -mac_step "1" -if_mtu "9600" -encap "LDP_LSP_ENCAP_ETHERNET_VLAN" -mac_num "25"
 Host @tester_to_dta3.host @tester_to_dta3
 @tester_to_dta3.host config -count "25" -src_mac "00:0a:94:00:00:01" -outer_vlan_enable "true" -static "1" -outer_vlan_id "1"
 Host @tester_to_dta4.host @tester_to_dta4
 @tester_to_dta4.host config -count "25" -src_mac "00:0b:94:00:00:01" -outer_vlan_enable "true" -static "1" -outer_vlan_id "1"

 Traffic @tester_to_dta3.traffic(1) @tester_to_dta3
 @tester_to_dta3.traffic(1) config -src "@tester_to_dta3.host @tester_to_dta4.host" -traffic_pattern "pair" -stream_load "10" -dst "@tester_to_dta1.ldp(1).vc_lsp @tester_to_dta2.ldp(2).vc_lsp" -load_unit "percent" -no_mesh "1" 
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -src "@tester_to_dta1.ldp(1).vc_lsp @tester_to_dta2.ldp(2).vc_lsp" -traffic_pattern "pair" -stream_load "10" -dst "@tester_to_dta3.host @tester_to_dta4.host" -load_unit "percent" -no_mesh "1" 
 
 EtherHdr @tester.pdu.ether
 @tester.pdu.ether config -dst "00:0a:a1:00:00:01" -modify "1"

 @tester_to_dta3.traffic(1) config -pdu "@tester.pdu.ether" -to_raw 1
 IxDebugOn
 @tester_to_dta1.traffic(1) config -pdu "@tester.pdu.ether" -to_raw 1
