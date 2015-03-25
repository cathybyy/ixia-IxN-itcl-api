package req IxiaNet 

IxDebugOff
#-- This is a sample of port initialization
Login
Port port1 10.206.25.136/1/1
Port port2 10.206.25.136/1/2

GreHdr hdr
hdr config \
	-version 0x01 \
	-gre_protocol 0x02 \
	-checksum_present true \
	-key_present true \
	-sn_present true \
	-checksum 0x03 \
	-key 0x04 \
	-sn 0x05
	
Traffic tra port1
IxDebugOn
tra config -pdu hdr
