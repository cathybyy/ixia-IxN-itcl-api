 package req IxiaNet
Login 190.2.152.81/8012
IxDebugOff
Port @tester_to_dta1 190.2.152.82/5/1
Port @tester_to_dta2 190.2.152.82/5/2
Port @tester_to_dta3 190.2.152.82/5/3

 Host @tester_to_dta1.host(1) @tester_to_dta1
 @tester_to_dta1.host(1) config -ipv4_gw_step "1" -ip_version "ipv4" -outer_vlan_enable "true" -ipv4_addr "10.13.14.2" -outer_vlan_step "1" -ipv4_addr_step "1" -outer_vlan_id "1" -ipv4_prefix_len "24" -ipv4_gw "10.13.14.1"
 
 MulticastGroup @tester.multicast_group(1)
 @tester.multicast_group(1) config -group_ip "225.0.1.1" -group_num "1" -group_step "1"
 IxDebugOn
 IgmpHost @tester_to_dta1.igmp_host @tester_to_dta1
 @tester_to_dta1.igmp_host config -outer_vlan_enable "true" -ipv4_addr "10.13.14.2" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2"
 @tester_to_dta1.igmp_host join_group -group "@tester.multicast_group(1)"
 IxDebugOff
 Host @tester_to_dta2.host(2) @tester_to_dta2
 @tester_to_dta2.host(2) config -ipv4_gw_step "1" -ip_version "ipv4" -outer_vlan_enable "true" -ipv4_addr "11.13.14.2" -outer_vlan_step "1" -ipv4_addr_step "1" -outer_vlan_id "1" -ipv4_prefix_len "24" -ipv4_gw "11.13.14.1"
 
 MulticastGroup @tester.multicast_group(2)
 @tester.multicast_group(2) config -group_ip "225.0.2.1" -group_num "1" -group_step "1"
 
 IgmpHost @tester_to_dta2.igmp_host @tester_to_dta2
 @tester_to_dta2.igmp_host config -outer_vlan_enable "true" -ipv4_addr "11.13.14.2" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2"
 @tester_to_dta2.igmp_host join_group -group "@tester.multicast_group(2)"
 
 Host @tester_to_dta3.host(3) @tester_to_dta3
 @tester_to_dta3.host(3) config -ipv4_gw_step "1" -ip_version "ipv4" -outer_vlan_enable "true" -ipv4_addr "12.13.14.2" -outer_vlan_step "1" -ipv4_addr_step "1" -outer_vlan_id "1" -ipv4_prefix_len "24" -ipv4_gw "12.13.14.1"
 
 MulticastGroup @tester.multicast_group(3)
 @tester.multicast_group(3) config -group_ip "225.0.3.1" -group_num "1" -group_step "1"
 
 IgmpHost @tester_to_dta3.igmp_host @tester_to_dta3
 @tester_to_dta3.igmp_host config -outer_vlan_enable "true" -ipv4_addr "12.13.14.2" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2"
 @tester_to_dta3.igmp_host join_group -group "@tester.multicast_group(3)"
 
 Traffic @tester_to_dta1.traffic(1) @tester_to_dta1
 @tester_to_dta1.traffic(1) config -src "@tester_to_dta1.host(1) @tester_to_dta2.host(2) @tester_to_dta3.host(3)" -traffic_pattern "pair" -dst "@tester.multicast_group(1) @tester.multicast_group(2) @tester.multicast_group(3)" -stream_load "100" -load_unit "percent"
