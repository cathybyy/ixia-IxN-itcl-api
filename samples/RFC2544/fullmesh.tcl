package req IxiaNet
Login 190.2.152.81/8012

Port @tester_to_dta1 190.2.152.82/5/1
@tester_to_dta1 config -location "190.2.152.82/5/1" -flow_control "false"
Port @tester_to_dta2 190.2.152.82/5/2
@tester_to_dta2 config -location "190.2.152.82/5/2" -flow_control "false"
Port @tester_to_dta3 190.2.152.82/5/3
@tester_to_dta3 config -location "190.2.152.82/5/3" -flow_control "false"

Host @tester_to_dta1.host @tester_to_dta1
@tester_to_dta1.host config -ip_version "ipv4" -ipv4_addr "20.13.14.2" -ipv4_gw "20.13.14.1"
Host @tester_to_dta2.host @tester_to_dta2
@tester_to_dta2.host config -ip_version "ipv4" -ipv4_addr "21.13.14.2" -ipv4_gw "21.13.14.1"
Host @tester_to_dta3.host @tester_to_dta3
@tester_to_dta3.host config -ip_version "ipv4" -ipv4_addr "22.13.14.2" -ipv4_gw "22.13.14.1"

Rfc2544 @tester.rfc2544
@tester.rfc2544 unconfig
@tester.rfc2544 throughput -frame_len_type "custom" \
							-resultfile "20140603115920.csv" \
							-frame_len {64} \
							-src_endpoint "@tester_to_dta1.host @tester_to_dta2.host @tester_to_dta3.host" \
							-measure_jitter "false" \
							-dst_endpoint "@tester_to_dta1.host @tester_to_dta2.host @tester_to_dta3.host" \
							-latency_type "lifo" \
							-traffic_type "l3" \
							-traffic_mesh "fullmesh" \
							-duration "10" \
							-port_load {100 80 100} \
							-resultdir "D:/data/" \
							-resultlvl 0
