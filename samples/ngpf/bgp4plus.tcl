 package req IxiaNet
Login 10.64.155.23
IxDebugOff

Port port1 NULL NULL ::ixNet::OBJ-/vport:1
Port port2 NULL NULL ::ixNet::OBJ-/vport:2
Port port3 NULL NULL ::ixNet::OBJ-/vport:3

DeviceGroup bgp4Group port1 BGP4

bgp4Group config -count 133
bgp4Group config_ethernet \
	-mac 01:02:03:04:05:06 \
	-mtu 6666 \
	-enable_vlan true
bgp4Group config_vlan \
	-tpid 0x9100 \
	-priority 1 \
	-vlan_id 123
bgp4Group config_ipv6 \
	-address 4010:1:1::2 \
	-gateway 4010:1:1::1 \
	-prefix 64
	
bgp4Group config_bgp4 \
	-type external \
	-as 101 \
	-hold_time_interval 120 \
	-update_interval 500 \
	-authentication null

RouteBlock rb
rb config \
	-start 1110:1:1::0 \
	-num 111 \
	-prefix_len 64 \
	-step 2
	
bgp4Group set_route -route_block rb
