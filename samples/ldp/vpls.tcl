 package req IxiaNet
Login 111.207.146.100/8009
IxDebugOff
Port @tester_to_dta1 192.168.0.21/1/9
Port @tester_to_dta2 192.168.0.21/1/10
Port @tester_to_dta3 192.168.0.21/1/11
Port @tester_to_dta4 192.168.0.21/1/12

 @tester_to_dta1 config -location "190.2.152.82/5/4" -dut_ip "200.13.14.1" -intf_ip "200.13.14.2"

 Ospfv2Session @tester_to_dta1.ospf(1) @tester_to_dta1
 @tester_to_dta1.ospf(1) config -loopback_ipv4_gw "170.170.170.170" -ipv4_gw "200.13.14.1" -ipv4_prefix_len "24" -ospf_obj "@tester_to_dta1.ospf(1)" -ipv4_addr "200.13.14.2" -router_id "2.2.2.1" -loopback_ipv4_addr "2.2.2.1" -area_id "0.0.0.0"

 LdpSession @tester_to_dta1.ldp(1) @tester_to_dta1
 @tester_to_dta1.ldp(1) config -ipv4_gw "" -ipv4_addr "" -router_id "2.2.2.1" 
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -prefix_len "32" -start "2.2.2.1" -step "1" -num "1"
 Ipv4PrefixLsp @tester_to_dta1.ldp(1).prefix_lsp(1) @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).prefix_lsp(1) config -route_block "@tester.route_block(1)"
IxDebugOn
 VcLsp @tester_to_dta1.ldp(1).vc_lsp @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).vc_lsp config \
	-encap "LDP_LSP_ENCAP_ETHERNET_VPLS" -mac_num "1" -vc_id_start "1" \
	-requested_vlan_id_start "1" -vc_id_step "1" -requested_vlan_id_step "1" \
	-vc_id_count "1" -requested_vlan_id_count "1" -mac_start "00:00:00:01:00:00" -mac_step "1" \
	-peer_address "170.170.170.170" -if_mtu "9600"
IxDebugOff
 @tester_to_dta2 config -location "190.2.152.82/5/6" -dut_ip "201.13.14.1" -intf_ip "201.13.14.2"

 Ospfv2Session @tester_to_dta2.ospf(2) @tester_to_dta2
 @tester_to_dta2.ospf(2) config -loopback_ipv4_gw "170.170.170.170" -ipv4_gw "201.13.14.1" -ipv4_prefix_len "24" -ospf_obj "@tester_to_dta2.ospf(2)" -ipv4_addr "201.13.14.2" -router_id "2.2.2.2" -loopback_ipv4_addr "2.2.2.2" -area_id "0.0.0.0"

 LdpSession @tester_to_dta2.ldp(2) @tester_to_dta2
 @tester_to_dta2.ldp(2) config -ipv4_gw "" -ipv4_addr "" -router_id "2.2.2.2" 
 RouteBlock @tester.route_block(2)
 @tester.route_block(2) config -prefix_len "32" -start "2.2.2.2" -step "1" -num "1"
 Ipv4PrefixLsp @tester_to_dta2.ldp(2).prefix_lsp(2) @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).prefix_lsp(2) config -route_block "@tester.route_block(2)"
 VcLsp @tester_to_dta2.ldp(2).vc_lsp @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).vc_lsp config -encap "LDP_LSP_ENCAP_ETHERNET_VPLS" \
	-mac_num "1" -vc_id_start "1" -requested_vlan_id_start "1" -vc_id_step "1" \
	-requested_vlan_id_step "1" -vc_id_count "1" -requested_vlan_id_count "1" \
	-mac_start "00:00:00:01:00:00" -mac_step "1" \
	-peer_address "170.170.170.170" -if_mtu "9600"

 Host @tester_to_dta3.host @tester_to_dta3
 @tester_to_dta3.host config -src_mac "00:10:94:00:00:01" -outer_vlan_enable "true" -outer_vlan_id "1" -static "1"
 Host @tester_to_dta4.host @tester_to_dta4
 @tester_to_dta4.host config -src_mac "00:11:94:00:00:01" -outer_vlan_enable "true" -outer_vlan_id "1" -static "1"

 Tester::start_router

 Host @tester_to_dta1.host(1) @tester_to_dta1
 @tester_to_dta1.host(1) config -ip_version "ipv6" -ipv6_prefix_len "64" -ipv6_gw "2100:0000::1" -ipv6_addr "2100:0000::2" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1"
 Host @tester_to_dta2.host(2) @tester_to_dta2
 @tester_to_dta2.host(2) config -ip_version "ipv6" -ipv6_prefix_len "64" -ipv6_gw "2100:0001::1" -ipv6_addr "2100:0001::2" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1"
 Host @tester_to_dta3.host(3) @tester_to_dta3
 @tester_to_dta3.host(3) config -ip_version "ipv6" -ipv6_prefix_len "64" -ipv6_gw "2100:0002::1" -ipv6_addr "2100:0002::2" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1"
 MulticastGroup @tester.multicast_group(1)
 @tester.multicast_group(1) config -group_ip "FF03:0000::1" -group_num "1" -group_step "1"
 MldHost @tester_to_dta1.mld_host @tester_to_dta1
 @tester_to_dta1.mld_host config -ipv4_gw "2200:0000::1" -ipv6_addr "2200:0000::2" -outer_vlan_enable "true" -outer_vlan_step "1" -version "v1" -outer_vlan_id "2"
 @tester_to_dta1.mld_host join_group -group "@tester.multicast_group(1)"
 MulticastGroup @tester.multicast_group(2)
 @tester.multicast_group(2) config -group_ip "FF03:0001::1" -group_num "1" -group_step "1"
 MldHost @tester_to_dta2.mld_host @tester_to_dta2
 @tester_to_dta2.mld_host config -ipv4_gw "2200:0001::1" -ipv6_addr "2200:0001::2" -outer_vlan_enable "true" -outer_vlan_step "1" -version "v1" -outer_vlan_id "2"
 @tester_to_dta2.mld_host join_group -group "@tester.multicast_group(2)"
 MulticastGroup @tester.multicast_group(3)
 @tester.multicast_group(3) config -group_ip "FF03:0002::1" -group_num "1" -group_step "1"
 MldHost @tester_to_dta3.mld_host @tester_to_dta3
 @tester_to_dta3.mld_host config -ipv4_gw "2200:0002::1" -ipv6_addr "2200:0002::2" -outer_vlan_enable "true" -outer_vlan_step "1" -version "v1" -outer_vlan_id "2"
 @tester_to_dta3.mld_host join_group -group "@tester.multicast_group(3)"
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -stream_load "100" -src "@tester_to_dta1.host(1) @tester_to_dta2.host(2) @tester_to_dta3.host(3)" -load_unit "percent" -bidirection "false" -dst "@tester.multicast_group(1) @tester.multicast_group(2) @tester.multicast_group(3)" -selfdst "true" -traffic_pattern "pair"
