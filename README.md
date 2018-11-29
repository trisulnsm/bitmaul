BITMAUL - The Mauler of packetz 
======

![BITMAUL ICON](maulaxe.png)

BITMAUL is a LUA helper library to help you write protocol dissectors. 

It consists of two libs you can use independently. 

1. **sweepbuf** : Extract protocol fields from a chunk of bytes [Sweepbuf docs](SWEEPBUF.md) 
2. **pdurecord**  : Constructs TCP records from bytestream [PDURecord docs](PDURECORD.md)  


> #### Usage
> Just put the files `sweepbuf.lua` and `pdurecord.lua` in the same directory as your LUA scripts. 


Bitmaul Docs
=============

SweepBuf documentation
----------------------

Sweepbuf works on a LUA string which represents a network payload byte array.  The library maintains an internal "pointer" so you can use methods like `next_XYZ(..)` to extract fields.  Common network idioms like endian-ness, searching for terminators, looping over attribute values, are all supported.

Read [SweepBuf Documentation](SWEEPBUF.md)



PDURecord documentation
-----------------------

A common first step in any stream based packet dissection is breaking up a bytestream into Protocol Data Units (PDUs also know as records/messages). PDURecord is a tiny library that makes it really easy to do this. 

Read [PDURecord Documentation](PDURECORD.md)



Typical uses 
------------

 * for a *TCP based analyzer* which needs reassembly, you typically need to use both PDURecord and SweepBuf
 * for a *UDP/Ethernet analyzer*, which does not need reassembly, you only need SweepBuf 

Examples
--------

Take a look at the [TCP Analyzer](examples/tcp/README.md) example for a feel for what  SweepBuf looks like

For more,  see the examples directory

