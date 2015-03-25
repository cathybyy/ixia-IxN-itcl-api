 @tester_to_dta1 config -dut_ip "200.13.14.1" -location "190.2.152.83/4/1" -intf_ip "200.13.14.2"
 Ospfv2Session @tester_to_dta1.ospf(1) @tester_to_dta1
 @tester_to_dta1.ospf(1) config -ipv4_addr "200.13.14.2" -router_id "2.2.2.1" -loopback_ipv4_addr "2.2.2.1" -area_id "0.0.0.0" -loopback_ipv4_gw "170.170.170.170" -ospf_obj "@tester_to_dta1.ospf(1)" -ipv4_gw "200.13.14.1" -ipv4_prefix_len "24"
 LdpSession @tester_to_dta1.ldp(1) @tester_to_dta1
 @tester_to_dta1.ldp(1) config -ipv4_addr "" -router_id "2.2.2.1" -ipv4_gw ""
 RouteBlock @tester.route_block(1)
 @tester.route_block(1) config -start "2.2.2.1" -step "1" -prefix_len "32" -num "1"
 Ipv4PrefixLsp @tester_to_dta1.ldp(1).prefix_lsp(1) @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).prefix_lsp(1) config -route_block "@tester.route_block(1)"
 VcLsp @tester_to_dta1.ldp(1).vc_lsp @tester_to_dta1.ldp(1)
 @tester_to_dta1.ldp(1).vc_lsp config -mac_start "00:00:00:01:00:00" -peer_address "170.170.170.170" -mac_step "1" -if_mtu "9600" -encap "LDP_LSP_ENCAP_ETHERNET_VLAN" -mac_num "1" -vc_id_start "1" -requested_vlan_id_start "1" -vc_id_step "1" -requested_vlan_id_step "1" -vc_id_count "1" -requested_vlan_id_count "1"
 @tester_to_dta2 config -dut_ip "201.13.14.1" -location "190.2.152.83/4/2" -intf_ip "201.13.14.2"
 Ospfv2Session @tester_to_dta2.ospf(2) @tester_to_dta2
 @tester_to_dta2.ospf(2) config -ipv4_addr "201.13.14.2" -router_id "2.2.2.2" -loopback_ipv4_addr "2.2.2.2" -area_id "0.0.0.0" -loopback_ipv4_gw "170.170.170.170" -ospf_obj "@tester_to_dta2.ospf(2)" -ipv4_gw "201.13.14.1" -ipv4_prefix_len "24"
 LdpSession @tester_to_dta2.ldp(2) @tester_to_dta2
 @tester_to_dta2.ldp(2) config -ipv4_addr "" -router_id "2.2.2.2" -ipv4_gw ""
 RouteBlock @tester.route_block(2)
 @tester.route_block(2) config -start "2.2.2.2" -step "1" -prefix_len "32" -num "1"
 Ipv4PrefixLsp @tester_to_dta2.ldp(2).prefix_lsp(2) @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).prefix_lsp(2) config -route_block "@tester.route_block(2)"
 VcLsp @tester_to_dta2.ldp(2).vc_lsp @tester_to_dta2.ldp(2)
 @tester_to_dta2.ldp(2).vc_lsp config -mac_start "00:00:00:02:00:00" -peer_address "170.170.170.170" -mac_step "1" -if_mtu "9600" -encap "LDP_LSP_ENCAP_ETHERNET_VLAN" -mac_num "1" -vc_id_start "2" -requested_vlan_id_start "1" -vc_id_step "1" -requested_vlan_id_step "1" -vc_id_count "1" -requested_vlan_id_count "1"
 Host @tester_to_dta3.host @tester_to_dta3
 @tester_to_dta3.host config -outer_vlan_id "1" -static "1" -src_mac "00:0a:94:00:00:01" -outer_vlan_enable "true"
 Host @tester_to_dta4.host @tester_to_dta4
 @tester_to_dta4.host config -outer_vlan_id "1" -static "1" -src_mac "00:0b:94:00:00:01" -outer_vlan_enable "true"
 Tester::start_router
 Ipv4Hdr @tester.pdu.ipv4(1)
 @tester.pdu.ipv4(1) config -dst_mod "24" -src "200.0.0.2" -dst "200.0.0.2" -src_mod "24"
 Traffic @tester_to_dta3.traffic(1) @tester_to_dta3
 @tester_to_dta3.traffic(1) config -load_unit "percent" -src "@tester_to_dta3.host @tester_to_dta4.host" -dst "@tester_to_dta1.ldp(1).vc_lsp @tester_to_dta2.ldp(2).vc_lsp" -pdu "@tester.pdu.ipv4(1)" -traffic_pattern "pair" -stream_load "10"
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -load_unit "percent" -src "@tester_to_dta1.ldp(1).vc_lsp @tester_to_dta2.ldp(2).vc_lsp" -dst "@tester_to_dta3.host @tester_to_dta4.host" -traffic_pattern "pair" -stream_load "10"
 Tester::start_traffic
 Tester::stop_traffic
 Tester::save_config H:/data/RT_CASE_PERF.00100.ixncfg
 Rfc2544 @tester.rfc2544
 @tester.rfc2544 unconfig
 @tester.rfc2544 throughput -frame_len_type "custom" -streams "@tester_to_dta3.traffic(1) @tester_to_dta1.traffic(1)" -resultfile "20140707114330.csv" -frame_len {128} -resultlvl "0" -measure_jitter "false"  -latency_type "lifo" -mac_learning "0" -duration "10" -port_load {100 10 100} -resultdir "H:/data/"
