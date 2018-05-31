TCP analyzer
============

The `tcp.lua` script uses SweepBuf to dissect the  TCP protocol and extensions.

> #### Usage
 Copy the `sweepbuf.lua` into this directory before running as shown below 


### Output

````
jjoey@jjoeyu14:~/examples/tcp$ luajit tcp.lua 

SB: Len=44 Seek=1 Avail=44 L=1 R=45 F=44
Source Port : 49111
Dest   Port : 443
Sequence #  : 1304102061
Ack #       : 1973447457
Flags/FO    : 45072
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




