# place your files under ../lib
lappend auto_path [file dirname [info script]]/lib

# package name
package req IxiaNet

# 192.168.8.128 locates the IxNetwork Tcl Server address, 1 means connect in a force way
Login 192.168.8.128 1

# generate Port object by reservint chassis 192.168.8.1 card 1 port 1
Port port1 192.168.8.1/1/1

# create bgp peer on certain port
BgpSession bgp port1

# config your bgp peer with specific params
bgp config \
	-ipv4_addr 199.1.1.2 \
	-bgp_id 199.1.1.2 \
	-ipv4_gw 199.1.1.1 \
	-dut_ip 199.1.1.1 \
	-type external \
	-as 102 \
	-dut_as 101
