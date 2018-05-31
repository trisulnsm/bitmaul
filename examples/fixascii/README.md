FIX-ASCII
==========

A [FIX - Financial Information Exchange](https://en.wikipedia.org/wiki/Financial_Information_eXchange) protocol example. This is intended to demonstrate the capabilities of BITMAUL. 


### The files

1. `fixp.lua` - the main file protocol dissector. Segments the byte stream into complete FIX messages and also handles completed payloads. 
2. `fixtypes.lua` - just a file containing Message Types mappings 
3. `test_file.lua` -  Driver using binary file containing FIX bytestreamas input 
4. `test_live_trisul.lua` - Driver using Network Analytics- either live capture or PCAP file import

### Data 

1. `data/fix-ascii-bytes.data` - a binary dump of FIX payloads. This is extracted using the Trisul script [savetcp.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/reassembly/save_payloads)

## How it works

The two main tasks you want to do are : 

 1. to pick out the complete messages from a  byte stream  
 2. dissect the FIX message themselves

The `what_next(.)` function is called by PDURecord to  demarcate the PDUs. We look at the  FIX protocol and find that it  contains a field msg_type `9=length\1` so initially we pick out the length field using `pdur:want_to_pattern("9=..")` Then we mark the next PDU at the length bytes. 

The `on_record(..)` function is called whenever a full PDU is reached. It is called twice, once when the pattern `9=<length>` is found. Next when the entire record is found. Notice how we store the state information in `tbl.state` 



## Running test_file driver

> Copy the BITMAUL files `sweepbuf.lua` and `pdurecord.lua` into your directory.  Then 

````

vk@vk14:~/examples/fixascii$ luajit test_file.lua data/fix-ascii-bytes.data  
-----
MsgType_val=A
SenderCompID=DLD_TEX
TargetCompID=TEX1_DLD
MsgSeqNum=1
SendingTime=20151128-17:59:35.877
EncryptMethod_val=0
HeartBtInt=10
DefaultApplVerID=8
CheckSum=035
-----
MsgType_val=0
SenderCompID=DLD_TEX
TargetCompID=TEX1_DLD
MsgSeqNum=2
SendingTime=20151128-17:59:45.931
CheckSum=177

````


## Running test_live_trisul driver

Copy the BITMAUL files `sweepbuf.lua` and `pdurecord.lua` and all the LUA files into the Trisul LUA scripts directory.

````sh

cp *.lua /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua 
trisulctl_probe restart context default 

````


## Generating Log file

The test samples just print the protocol fields. You can plug BITMAUL into a Network Analytics platform like Trisul to generate logs in a structured manner.


