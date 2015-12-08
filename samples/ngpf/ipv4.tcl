 package req IxiaNet
Login 10.64.155.23
IxDebugOff

Port port1 NULL NULL ::ixNet::OBJ-/vport:1
Port port2 NULL NULL ::ixNet::OBJ-/vport:2
Port port3 NULL NULL ::ixNet::OBJ-/vport:3

DeviceGroup ipv4Group port1

DeviceGroup ipv6Group port2

DeviceGroup ipv4Group2 port3 IPV4

ipv4Group config -count 133 -type ipv4
ipv6Group config -count 266 -type ipv6

ipv4Group2 config -count 399

ipv4Group config_ethernet \
	-src_mac 01:02:03:04:05:06 \
	-src_mac_step 00:00:00:00:00:01 \
	-mtu 6666 
ipv6Group config_ethernet \
	-mac 01:02:03:04:05:08 \
	-mtu 8888 	

ipv4Group config_vlan \
	-tpid 0x9100 \
	-priority 1 \
	-vlan_id1 123 \
	-vlan_id1_step 11 \
	-vlan_id2 213 \
	-vlan_id2_step 22
	
ipv6Group config_vlan \
	-tpid 0x9100 \
	-priority 2 \
	-vlan_id 111

ipv4Group config_ipv4 \
	-ipv4_addr 199.1.1.2 \
	-ipv4_addr_step 0.0.0.2 \
	-ipv4_gw 199.1.1.1 \
	-ipv4_gw_step 0.0.0.2 \
	-ipv4_prefix_len 24
	
ipv6Group config_ipv6 \
	-address 4010:1:1::2 \
	-gateway 4010:1:1::1 \
	-prefix 64

ipv4Group2 config_ipv4 \
	-address 199.1.1.1 \
	-gateway 199.1.1.2 \
	-prefix 24

Traffic tra port1
tra config -src ipv4Group -dst ipv4Group2

