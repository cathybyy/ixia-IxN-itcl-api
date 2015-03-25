package req IxiaNet

# 连接IxNetwork Tcl Server
Login localhost/8009

# 占用端口
Port port1 192.168.0.110/1/1
Port port2 192.168.0.110/1/2

Port port3 192.168.0.110/1/3 
Port port4 192.168.0.110/1/4

Port port5 192.168.0.110/1/5 
Port port6 192.168.0.110/1/6

#配置端口
port1 config -flow_control 1

set hostList [ list ]

for { set index 1 } { $index <= 6 } { incr index } {

	#新建 protocol interface
	Host port${index}.host port${index}

	#配置 protocol interface
	port${index}.host config \
		-count 10 \
		-ipv4_addr 1.1.1.$index \
		-ipv4_gw 1.1.1.1 \
		-ipv4_gw_step 0.0.0.2 \ 
		-ipv6_addr ::$index \
		-ipv6_gw ::1 \
		-vlan_id1 $index
		
	lappend hostList port${index}.host
	
}

#新建rfc2544测试套，建立fully mesh流量进行2544测试
Rfc2544 qt
qt throughput \
	-resultfile "RFC2544.csv" \
	-frame_len {94 10 256 10 512 10 1000 40 1518 20 3000 5 9000 5} \
	-frame_len_type "imix" \
	-measure_jitter "true" \
	-duration "3" \
	-traffic_type "ipv4" \
	-src_endpoint $hostList \
	-dst_endpoint $hostList \
	-traffic_mesh "fullmesh" \
	-resultdir "e:/download" 
	
