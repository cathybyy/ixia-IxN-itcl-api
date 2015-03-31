import Tkinter
import time
tcl = Tkinter.Tcl()
tcl.eval('lappend auto_path {C:\ixia\CVS\project}')
tcl.eval('lappend auto_path "C:/Program Files (x86)/Ixia/IxNetwork/7.30-EA/TclScripts/lib"')
tcl.eval('package req Itcl')
tcl.eval('namespace import itcl::*')
tcl.eval('package req IxiaNet')

tcl.eval('Login')
tcl.eval('Port portTx 10.206.25.136/1/1')
tcl.eval('Port portRx 10.206.25.136/1/2')

tcl.eval('EtherHdr eth')
tcl.eval('eth config  -src "00-10-94-00-00-05" -dst "00-00-01-00-00-02"')

tcl.eval('Ipv4Hdr ipv4')
tcl.eval('ipv4 config -src 1.1.1.1 -dst 1.1.1.2 -dscp 35 ')

tcl.eval('Traffic traP7 portTx')
tcl.eval('traP7 config -pdu {eth ipv4}')

tcl.eval('ipv4 config -src 1.1.1.1 -dst 1.1.1.2 -precedence 4')
print tcl.eval('Traffic traP4 portTx')
print tcl.eval('traP4 config -pdu {eth ipv4}')

tcl.eval('Tester::start_traffic')
time.sleep(10)

print tcl.eval('GetStatsFromReturn [traP7 get_stats] rx_frame_rate')

tcl.eval('Tester::stop_traffic')

tcl.eval('Tester::cleanup')
