BGP Dissector
==========

A very simple  BGP dissector.

### The files

1. `bgp.lua` - Demonstrates usage of `want_to_start_pattern(..)` when working with protocols like BGP which have a marker pattern (0xff 16 time) at the start of every PDU boundary.

2. `handlers.lua` - Demonstrate use of function tables to organize message dissection.

3. `inspect.lua` - Helper library to pretty print LUA Tables

````shell


kev@kev14:~/bitmaul/examples/bgp$ luajit test_file.lua  data/bgp-payload.dat 


{
  length = 87,
  msg = {
    nlri = { "203.0.113.13" },
    path_attr = { {
        ORIGIN = "IGP"
      }, {
        AS_PATH = {
          as_type = "AS_SEQUENCE",
          aslist = { 65536 }
        }
      }, {
        NEXT_HOP = "192.0.2.2"
      }, { 30, 36 } },
    path_attr_length = 59,
    withdrawn_routes = {},
    withdrawn_routes_length = 0
  },
  msgname = "UPDATE",
  msgtype = 2
}

````
