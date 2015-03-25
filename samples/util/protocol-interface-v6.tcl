 package req IxiaNet
Login 111.207.146.100/8012
IxDebugOff
Port @tester_to_dta1 NULL NULL ::ixNet::OBJ-/vport:1

IxDebugOn
 Host @tester_to_dta1.host(1) @tester_to_dta1
 @tester_to_dta1.host(1) config -ip_version "ipv6" -outer_vlan_enable "true" -ipv6_addr "2300:0000:0000::2" -outer_vlan_step "1" -ipv6_addr_step "1" -outer_vlan_id "1" -ipv6_prefix_len "64" -ipv6_gw "2300:0000:0000::1" -ipv6_gw_step "1"
 
 
