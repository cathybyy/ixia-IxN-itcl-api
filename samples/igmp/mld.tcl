 package req IxiaNet
Login 111.207.146.100/8009
IxDebugOff
Port @tester_to_dta1 192.168.0.21/1/9
Port @tester_to_dta2 192.168.0.21/1/10
Port @tester_to_dta3 192.168.0.21/1/11
Port @tester_to_dta4 192.168.0.21/1/12

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
 
 IxDebugOn
 @tester_to_dta1.traffic(1) config -stream_load "100" -src "@tester_to_dta1.host(1) @tester_to_dta2.host(2) @tester_to_dta3.host(3)" -load_unit "percent" -bidirection "false" -dst "@tester.multicast_group(1) @tester.multicast_group(2) @tester.multicast_group(3)" -selfdst "true" -traffic_pattern "pair"
