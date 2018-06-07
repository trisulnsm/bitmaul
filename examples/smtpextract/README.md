SMTP Email Extraction 
==========

Extracts SMTP messages and attachments into `/tmp`

Demonstrates how you can use _PDURecord_ methods to deal with text based protocols like SMTP.


### The files

1. `smtp.lua` - Demonstrates usage of `want_to_pattern` and state tables to handle protocols like SMTP. 

## Drivers 

1. `test_file.lua` - Pump using a SMTP payload file, see `data/tcp_out_smtp.dat` 

2. `test_live_trisul.lua` - Plug into a Live Trisul system.  Works with PCAP import or live traffic.


## Test runs

> **note**  Before running make sure to copy the BITMAUL files sweepbuf.lua and pdurecord.lua  into this directory 

### Testing from a file

````shell


kev@kev14:~/bitmaul/examples/smtp$ luajit test_file.lua  data/tcp_Out_smtp.dat

Wrote attachments to /tmp

kev@kev14:~/bitmaul/examples/smtp$ ls -lrt /tmp

-rw-rw-r-- 1 kev kev   789 Jun  7 17:23 000301ca4581ef9e57f0cedb07d0in-headers
-rw-rw-r-- 1 kev kev  1934 Jun  7 17:23 000301ca4581ef9e57f0cedb07d0in-3-body
-rw-rw-r-- 1 kev kev    79 Jun  7 17:23 000301ca4581ef9e57f0cedb07d0in-2-body
-rw-rw-r-- 1 kev kev     2 Jun  7 17:23 000301ca4581ef9e57f0cedb07d0in-1-body
-rw-rw-r-- 1 kev kev    47 Jun  7 17:23 000301ca4581ef9e57f0cedb07d0in-0-body
-rw-rw-r-- 1 kev kev 10997 Jun  7 17:23 000301ca4581ef9e57f0cedb07d0in-4-NEWS.txt

````

### Live Trisul 

Copy the lua files in this directory into the [LUA Search Paths](https://www.trisul.org/docs/lua/basics.html#installing_and_uninstalling) for Trisul.

In this example below, 

- we create a new context `test1`
- install the LUA files there
- import a PCAP

````shell

# trisulctl_probe create context test1 

# cd /usr/local/var/lib/trisul-probe/domain0/probe0/context_test1/config/local-lua

# -- put the smtp lua files in this directory --

# trisulctl_probe importpcap /home/kev/pcaps/RigEx-sampledump.pcap

.. the SMTP files should be seen in /tmp

````
