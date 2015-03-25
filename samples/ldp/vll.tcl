 package req IxiaNet
Login 111.207.146.100/8009
IxDebugOff

Port @tester_to_dta3 192.168.0.21/1/11
Port @tester_to_dta4 192.168.0.21/1/12

 @tester_to_dta3 config -dut_ip "20.20.20.1" -intf_ip "20.20.20.2"
 @tester_to_dta4 config -dut_ip "20.20.20.2" -intf_ip "20.20.20.1"

 #-- OSPF
 Ospfv2Session @tester_to_dta3.ospf @tester_to_dta3
 @tester_to_dta3.ospf config -area_id "0.0.0.0" \
	-ipv4_gw "20.20.20.1" -ipv4_prefix_len "24" \
	-ipv4_addr "20.20.20.2" -router_id "2.2.2.2" \
	-loopback_ipv4_addr 2.2.2.2 \
	-loopback_ipv4_gw 1.1.1.1
	

 #-- LDP
 LdpSession @tester_to_dta3.ldp @tester_to_dta3
 @tester_to_dta3.ldp config -router_id "2.2.2.2" \
	-ipv4_gw "20.20.20.1" -ipv4_prefix_len "24" \
	-ipv4_addr "20.20.20.2"	

 RouteBlock @tester.route_block(1)
@tester.route_block(1) config -prefix_len "32" \
	-start "2.2.2.2" -step "1" -num "1"

 Ipv4PrefixLsp @tester_to_dta3.ldp.lsp @tester_to_dta3.ldp
 @tester_to_dta3.ldp.lsp config -route_block @tester.route_block(1)
 
VcLsp @tester_to_dta3.ldp.vc @tester_to_dta3.ldp
@tester_to_dta3.ldp.vc config \
	-encap LDP_LSP_ENCAP_ETHERNET_VLAN \
	-vc_id_start 1 \
	-mac_start 00:00:00:01:00:00 \
	-requested_vlan_id_start 10 \
	-peer_address 170.170.170.170 \
	-incr_vc_vlan 1

Host @tester_to_dta4.host @tester_to_dta4
@tester_to_dta4.host config -static 1 \
	-src_mac "00:11:22:33:44:55" \
	-dst_mac "55:44:33:22:11:00"
	
IxDebugOn
Traffic tra @tester_to_dta3
tra config -src @tester_to_dta3.ldp.vc \
	-dst @tester_to_dta4.host
