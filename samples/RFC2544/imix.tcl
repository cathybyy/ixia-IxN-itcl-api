 package req IxiaNet
Login 111.207.146.100/8009
IxDebugOff
Port @tester_to_dta1 192.168.0.21/1/9
Port @tester_to_dta2 192.168.0.21/1/10

 @tester_to_dta1 config -dut_ip "30.30.30.1" -intf_ip "30.30.30.2"
 @tester_to_dta2 config -dut_ip "30.30.30.2" -intf_ip "30.30.30.1"

  #-- bgp
 BgpSession @tester_to_dta1.bgp(1) @tester_to_dta1
 @tester_to_dta1.bgp(1) config -type "external" -as "200" -dut_as "201" \
	-ipv4_addr "30.30.30.2" -dut_ip "30.30.30.1" -ip_version "ipv4"
 RouteBlock @tester.route_block(3)
 @tester.route_block(3) config -start "22.22.102.0" -step "1" -num "50" -prefix_len "255.255.255.0"
 @tester_to_dta1.bgp(1) set_route -route_block "@tester.route_block(3)"


 BgpSession @tester_to_dta2.bgp(2) @tester_to_dta2
 @tester_to_dta2.bgp(2) config -type "external" -as "201" -dut_as "200" \
	-ipv4_addr "30.30.30.1" -dut_ip "30.30.30.2" -ip_version "ipv4"
 RouteBlock @tester.route_block(4)
 @tester.route_block(4) config -start "22.23.102.0" -step "1" -num "50" -prefix_len "255.255.255.0"
 @tester_to_dta2.bgp(2) set_route -route_block "@tester.route_block(4)"

 IxDebugOn
 Rfc2544 @tester.rfc2544
 @tester.rfc2544 throughput -resultlvl "0" \
	-src_endpoint "@tester.route_block(3) @tester.route_block(4)" \
	-measure_jitter "false" \
	-dst_endpoint "@tester.route_block(3) @tester.route_block(4)" \
	-latency_type "lifo" -traffic_mesh "fullmesh" -duration "30" \
	-port_load {100 80 100} \
	-resultdir "H:/data/" \
	-frame_len_type "imix" \
	-resultfile "20140607130434mix.csv" \
	-frame_len {64 20 256 20 576 20 1200 10 1500 10 9600 20} \
	-traffic_type "ipv4"
