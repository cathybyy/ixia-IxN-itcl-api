package req IxiaNet 

IxDebugOff
#-- This is a sample of port initialization
Login
Port @tester_to_dta1 10.206.25.136/1/1
Port @tester_to_dta2  10.206.25.136/1/2

 Host @tester_to_dta1.host(1) @tester_to_dta1
 @tester_to_dta1.host(1) config -ipv4_gw "30.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1" -ip_version "ipv4" -ipv4_addr "30.13.14.2"
 MulticastGroup @tester.multicast_group(1)
 @tester.multicast_group(1) config -group_ip "225.0.1.1" -group_num "1" -group_step "1"
 IgmpHost @tester_to_dta1.igmp_host @tester_to_dta1
 @tester_to_dta1.igmp_host config -ipv4_gw "90.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2" -ipv4_addr "90.13.14.2"
 @tester_to_dta1.igmp_host join_group -group "@tester.multicast_group(1)"

 Host @tester_to_dta2.host(2) @tester_to_dta2
 @tester_to_dta2.host(2) config -ipv4_gw "31.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1" -ip_version "ipv4" -ipv4_addr "31.13.14.2"
 MulticastGroup @tester.multicast_group(2)
 @tester.multicast_group(2) config -group_ip "225.0.2.1" -group_num "1" -group_step "1"
 IgmpHost @tester_to_dta2.igmp_host @tester_to_dta2
 @tester_to_dta2.igmp_host config -ipv4_gw "91.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2" -ipv4_addr "91.13.14.2"
 @tester_to_dta2.igmp_host join_group -group "@tester.multicast_group(2)"

 Tester::cleanup -new_config "0"

 Host @tester_to_dta1.host(1) @tester_to_dta1
 @tester_to_dta1.host(1) config -ipv4_gw "30.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1" -ip_version "ipv4" -ipv4_addr "30.13.14.2"
 MulticastGroup @tester.multicast_group(1)
 @tester.multicast_group(1) config -group_ip "225.0.1.1" -group_num "1" -group_step "1"
 IgmpHost @tester_to_dta1.igmp_host @tester_to_dta1
 @tester_to_dta1.igmp_host config -ipv4_gw "90.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2" -ipv4_addr "90.13.14.2"
 @tester_to_dta1.igmp_host join_group -group "@tester.multicast_group(1)"

 Host @tester_to_dta2.host(2) @tester_to_dta2
 @tester_to_dta2.host(2) config -ipv4_gw "31.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "1" -ip_version "ipv4" -ipv4_addr "31.13.14.2"
 MulticastGroup @tester.multicast_group(2)
 @tester.multicast_group(2) config -group_ip "225.0.2.1" -group_num "1" -group_step "1"
 IgmpHost @tester_to_dta2.igmp_host @tester_to_dta2
 @tester_to_dta2.igmp_host config -ipv4_gw "91.13.14.1" -outer_vlan_enable "true" -outer_vlan_step "1" -outer_vlan_id "2" -version "v2" -ipv4_addr "91.13.14.2"
 @tester_to_dta2.igmp_host join_group -group "@tester.multicast_group(2)"
