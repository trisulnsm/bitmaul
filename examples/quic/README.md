# QUIC Protocol for Trisul


A Trisul script that performs a full decode the the *QUIC Crypto handshake* which 
always happens when you connect to Google services like YouTube  over QUIC. 

## Links

We use the Trisul LUA Scripting API along with the SweepBuf protocol dissection library from BITMAUL.

* The version supported is Google **QUIC Version Q043**  The QUIC RFC is quite a bit different 
* Link to the [Google GUID CRYPTO Protocol](https://github.com/romain-jacotin/quic/blob/master/doc/QUIC_crypto_protocol.md) we are working with here. 
* [Trisul LUA Scripting](https://www.trisul.org/docs/lua/)
* [BITMAUL Protocol Dissection Library](https://github.com/trisulnsm/bitmaul) 
* [SweepBuf from BITMAUL helps you parse packets](https://github.com/trisulnsm/bitmaul/blob/master/SWEEPBUF.md)



## What `quic-dissect.lua`  does 

   1.  attaches a new Protocol (Google-QUIC) to UDP port 443
   2.  performs a full decode of the CRYPTO handshake messages into a LUA table
   3.  tags UDP flow with QUIC connection IDs
   4.  tags the UDP flow with SNI Tag extracted from QUIC Client Hello 
   5.  basic reassembly to pick up fragmented CRYPTO handshake 



## Example Inchoate Client Hello CHLO 

From the 1st packet, which is the so called "Inchoate CHLO" - we extract out the  ConnectionID, SNI, Client User Agent  ID (CUID).

````lua
{
  cid_hi = 643620114,
  cid_lo = 2665768574,
  cid_str = "265CDD129EE4667E",
  data_length = 1300,
  flags = { 0, 0, 0, 1, 1, 0, 1 },
  mac_hash = "EE1836F6C14D4B3B3C62B3E1",
  pkt_number = 1,
  pkt_number_len = 1,
  stream_flags = {
    data_length = 1,
    fin = 0,
    offset_length = 0,
    stream = 1,
    stream_length = 0
  },
  stream_id = 1,
  tag = "CHLO",
  tag_count = 18,
  tag_offsets = { { "PAD\0", 1007 }, { "SNI\0", 1023 }, { "VER\0", 1027 }, { "CCS\0", 1043 }, { "MSPC", 1047 }, { "UAID", 1080 }, { "TCID", 1084 }, { "PDMD", 1088 }, { "SMHL", 1092 }, { "ICSL", 1096 }, { "NONP", 1128 }, { "MIDS", 1132 }, { "SCLS", 1136 }, { "CSCT", 1136 }, { "COPT", 1136 }, { "IRTT", 1140 }, { "CFCW", 1144 }, { "SFCW", 1148 } },
  tag_sni = "www.google.co.in",
  tag_user_agent = "Chrome/68.0.3440.106 Linux x86_64",
  version = "Q043"
}

````


