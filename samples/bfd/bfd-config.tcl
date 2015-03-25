package req IxiaNet
Login
IxDebugOff
Port @tester_to_dta1 10.206.25.136/1/1
@tester_to_dta1 config -location "192.168.3.200/2/1" -dut_ip "1.21.14.1" -intf_ip "1.21.14.2"

Port @tester_to_dta2 10.206.25.136/1/2
@tester_to_dta1 config -location "192.168.3.200/2/1" -dut_ip "1.22.14.1" -intf_ip "1.22.14.2"

Port @tester_to_dta3 10.206.25.136/1/3
@tester_to_dta1 config -location "192.168.3.200/2/1" -dut_ip "1.23.14.1" -intf_ip "1.23.14.2"

IxDebugOn
BfdSession @tester_to_dta1.bfd(0) @tester_to_dta1
@tester_to_dta1.bfd(0) config \
	-router_id "1.0.1.2" \
	-peer_ip "1.0.1.1" \
	-local_disc "1000" \
	-remote_disc "2000" \
	-rx_interval "3" \
	-tx_interval "3" \
	-source_ip "1.0.1.2"
IxDebugOff
BfdSession @tester_to_dta2.bfd(1) @tester_to_dta2
@tester_to_dta2.bfd(1) config -router_id "1.0.2.2" -peer_ip "1.0.2.1" -local_disc "1001" -remote_disc "2001" -rx_interval "3" -tx_interval "3" -source_ip "1.0.2.2"

BfdSession @tester_to_dta3.bfd(2) @tester_to_dta3
@tester_to_dta3.bfd(2) config -router_id "1.0.3.2" -peer_ip "1.0.3.1" -local_disc "1002" -remote_disc "2002" -rx_interval "3" -tx_interval "3" -source_ip "1.0.3.2"
