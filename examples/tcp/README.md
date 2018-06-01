TCP analyzer
============

The `tcp.lua` script uses SweepBuf to dissect the  TCP protocol and extensions.

> #### Usage
> Copy the `sweepbuf.lua` into this directory before running as shown below 
> To run `$ luajit tcp.lua` 


### Code

You can get a feel for how SweepBuf works by looking a the simple code.

````lua
-- Wrap the SweepBuffer over the binary buffer
local sb = SB.new(tcp_bytes_binary) 

-- Print the fields
print("Source Port : " .. sb:next_u16())
print("Dest   Port : " .. sb:next_u16())
print("Sequence #  : " .. sb:next_u32())
print("Ack #       : " .. sb:next_u32())

local flags_fo =sb:next_bitfield_u16( { 4, 6, 1,1,1,1,1,1 } ) 
print("Flags/FO    : " )
print("    Header Len   : " .. flags_fo[1])
print("    Reserved     : " .. flags_fo[2])
print("           URG   : " .. flags_fo[3])
print("           ACK   : " .. flags_fo[4])
print("           PSH   : " .. flags_fo[5])
print("           RST   : " .. flags_fo[6])
print("           SYN   : " .. flags_fo[7])
print("           FIN   : " .. flags_fo[8])

print("Window Size : " .. sb:next_u16())
print("Checksum    : " .. sb:next_u16())
print("Urg         : " .. sb:next_u16())
````

### Output

````
jjoey@jjoeyu14:~/examples/tcp$ luajit tcp.lua 
SB: Len=44 Seek=1 Avail=44 L=1 R=45 F=44
Source Port : 49111
Dest   Port : 443
Sequence #  : 1304102061
Ack #       : 1973447457
Flags/FO    : 
    Header Len   : 11
    Reserved     : 0
           URG   : 0
           ACK   : 1
           PSH   : 0
           RST   : 0
           SYN   : 0
           FIN   : 0
Window Size : 350
Checksum    : 31288
Urg         : 0
Option : TIMESTAMP len=10
   Timestamp value      :7513016
   Timestamp echo reply :240800513
Option : SACK len=10
   left edge            :1973447456
   right edge           :1973447457


````

### Wireshark output


![Wirshark output of the same packet](https://github.com/trisulnsm/bitmaul/blob/master/examples/tcp/wiresharktcp.png?raw=true) 




