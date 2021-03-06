# SweepBuf documentation

Sweepbuf works on a LUA string which represents a network payload byte array.  The library maintains an internal "pointer" so you can use methods like `next_XYZ(..)` to elegantly extract fields. Common network idioms like endian-ness, searching for terminators, looping over attribute values, are all supported. 

> #### What does SweepBuf mean ? 
> A typical network protocol dissector calls a sequence of next_XXX(). This return the field at that position and then advanced the internal pointer. This reflects typical network protocol design which enables a single pass sweep. Hence the name _SweepBuf_ for "Sweep a Buffer". 

Doc links :  [Construction](#construction) | [Extracting number fields](#extracting-numbers) | [Extracting arrays](#extracting-arrays-of-numbers) | [String fields](#extracting-strings) | [Text based headers](#text-based-headers) | [Record fields](#working-with-records) | [Bitfields](#bitfields) | [IP and MAC Addresses](#ip-addresses) |   [Utility functions](#utility-methods) | [Full examples](#examples) 

## Construction

If you have a byte buffer stored in `bytestring` construct a SweepBuf over it like so

````lua
local SWP=require 'sweepbuf.lua'

sw=SWP.new( bytestring)

checksum=sw:next_u16()  -- use sw 

````

------------

## Extracting numbers 

For example if a part of your  protocol is 

````cpp
...
byte        message_type;       /* 1 byte  */
uint16_t    message_length;     /* 2 bytes */   
uint32_t    timestamp;          /* 4 bytes */
...

```` 

You would use something like this. 

````lua

local SWP=require 'sweepbuf.lua'
sw=SWP.new( bytestring)


mtype = sw:next_u8()
mlen  = sw:next_u16()
ts    = sw:next_u32()


````

Under the covers SweepBuf automatically converts from network byte to host byte order `ntohs/ntohl` 


### Functions  Reference 

You would most likely be working with the following `next_` functions. These return the field at the current position and then advanced the internal pointer. 

#### Sweep  `next` functions

* `next_u8` - unsigned byte
* `next_u16` - unsigned 16 bit number
* `next_u24` - unsigned 24
* `next_u32` - unsigned 32 
* `next_uN(numbytes)` - unsigned N byte number. `next_uN(2) is same as next_u16()` 


Then the Little Endian versions. Rarely network protocols use this. 

* `next_u8_le` - unsigned 8 bits
* `next_u16_le` - unsigned 16 bits when buffer contents in little endian 
* `next_u24_le`
* `next_u32_le`

> 64-bits: There is no `next_u64()` because currently LuaJIT only supports 56 bit numbers. 
> Use two calls to `next_u32()` to load the HI and LO 32-bit words.

Then a helper enum function
* `next_u8_enum( lookup_table) ` - unsigned byte , returns an array [value, enumerated string] if there is a match on the supplied lookup table
* `next_uN_enum( numbytes, lookup_table) ` - unsigned N byte , returns an array [value, enumerated string]


These functions return the value but do not advance the internal pointer.

````lua 
checksum = payload:u32()
payload:inc(4)

is the same as
checksum = payload:next_32() 

etype = payload:next_u8_enum( { [1] = "DHCPREQUEST", [2]="DHCPRESPONSE"} )
-- will return { 1, "DHCPREQUEST"} or {5, ""} depending on a match

````

#### Get `u_()` functions

These functions return the number at this position but without advancing the pointer. 

* `u8` - unsigned 8 bits
* `u16` - unsigned 16 bits
* `u24` - unsigned 24 bits
* `u32` - unsigned 32 bits

You also have the u8_le, u16_le, .. lower endian versions of the above

#### Peek functions

These functions are used to PEEK ahead without moving the internal pointer. 

* `peek_u8(offset)` - peek at an unsigned 8 bits at offset from current pointer 
* `peek_u16(offset)` - peek at an unsigned 16 bit number at offset from current pointer 
* `peek_u24(offset)`
* `peek_u32(offset)`


------------


## Extracting arrays of numbers 

These enable a common idiom found in network protocols, an array of fields.  You can consider the following specification of the SSL/TLS protocol.

````c
 {
  uint_16  cipher_suite_bytes;
  uint_16  cipher_suites[]
 }

````


You can get the cipher suites into a LUA array 

````lua 

local Ciphers = payload:next_u16_arr( payload:next_u16()/2)

````


### Functions  Reference 

These extract array of integers. 

* `next_u8_arr(nitems)` = Array of nitems of u8
* `next_u16_arr(nitems)` = Array of nitems of u16
* `next_u32_arr(nitems)` = Array of nitems of u32


------------


## Extracting Strings

In network protocols , strings are generally represented by one of two mechanisms.  

* Length prefix or
* delimited 

Here is an example of length prefixed string.

````c
  uint16_t  username_len
  char      username[username_len]
````

This is a length prefixed string and the length field is a u
````lua
  local slen = payload:next_u16()
  local username = payload:next_str_to_len(slen)

````

Or in a single line 
````lua
  local username = payload:next_str_to_len( payload:next_u16())
````


Here is an example of delimited string. By `\r\n` a common delimiter

````lua
  local username = payload:next_str_to_pattern( '\r\n')
````


### Methods reference

These two methods should cover 99% of common network protocol idioms dealing with strings. 

* `next_str_to_pattern (patt (, pattern_is_plain) )` = extract string till you see the Regex pattern, include the pattern in the matched string. Use this to match delimiter patterns between PDUs.  The second optional parameter _is_plain_ is used to tell the framework whether the pattern is a plain string or a regular expression. To use a regex pattern, set the second parameter to `false` Example: `next_str_to_pattern("(%S+)%s+HTTP", false)`  If using a plain pattern, you can just omit this parameter. 
* `next_str_to_pattern_exclude (patt (, pattern_is_plain) )` = extract string till you see the next pattern, dont include the pattern in the matched string. Use this for matching marker bytes that appear at the START of each PDU. The second optional parameter `is_plain` is true when pattern is plain string and false when the pattern is a regex. If using a plain pattern, you can just omit this parameter. 
* `next_str_to_len(string_len)` = extract string of given length
* `next_hex_str_to_len(string_len)` = extract binary string of given length into a hex string 



----

## Bitfields

Bitfields can be a bit hairy, but SweepBuf makes it trivial to dissect it.

For example this is the TCP Header field `flags_frame_offset`

![TCP Flags Screenshot](tcpflags.png)

````c

  uint16_t  flags_frame_offset {
    4-bits    header_len;
    6-bits    reserved;
    flags {
      1-bit urg;
      1-bit ack;
      1-bit psh;
      1-bit rst;
      1-bit syn;
      1-bit fin;

    }
  }
````

You can dissect this in just one line with the `next_bitfield` function. 
Just pass a LUA table of bitfield lengths from MOST to LEAST significant bit as seen on Wireshark. 

````lua
  local flags_fo = payload:next_bitfield_u16( {4,6,1,1,1,1,1,1})

  -- now flags_fo[1]=header_len
  --     flags_fo[2]=reserved;
  --     flags_fo[3]=urg
  --     flags_fo[4]=ack 
  --     etc etc 


````


### Methods reference

These two methods are available for bit fields. They parse the bitfield and advance the internal pointer.   

* `next_bitfield_u8 ( {bitfield-widths})` = parse next 8 bit as a bitfield 
* `next_bitfield_u16 ( {bitfield-widths})` = parse next 16 bit as a bitfield 
* `next_bitfield_u8_named ( {bitfield-widths}, {bitfield-names})` = parse next 8 bit as a bitfield and return a hash of named bitfields

````lua
local flags_fo = payload:next_bitfield_u16_named( 
                  {4,6,1,1,1,1,1,1},   -- widths
                  {'header_len','reserved','urg','ack','psh','rst','syn','fin'}) -- names

  -- now flags_fo.syn= 1 or 0 etc 
  --
````


Both these methods 

1. return a table containing requested fields from MSB to LSB order. 
2. accept a `bitfield-widths` table. This is a LUA array consisting of Bitfield Widths in  MSB to LSB order. If you look at a protocol diagram this is from Left to Right order. 
3. you are expected to supply the entire set of bit field widths.  Otherwise the function will return only the number of widths you supplied. 


------

## IP Addresses 

Two methods to get IPv4 addresses in dotted decimal format
````lua
local ip = payload:next_ipv4() -- a single IP Address as a dotted-decimal 

local iplist = payload:next_ipv4_arr( 10)  -- an array of dotted-decimal str 

````


### Methods reference


* `next_ipv4 ()` = get next 4 bytes are dotted-decimal IP v4 address
* `next_ipv4_arr(nitems)` = get next `nitems` IPv4 addrsses as an array of strings (dotted-decimal IPv4) 
* `next_mac ()` = get next 6 bytes as a MAC address. Useful for L2 protocol analyzers 


------


## Working with records 

Records are another common pattern in network protocols. There is a record of some sort that is repeated until a particular end position.

Say you have something like

````c

Extensions = struct {
  uint16_t  ext_type;
  uint16_t  ext_len;
}

uint16_t  extensions_length;
Extensions extensions;
````


You can use the fence methods to set the end position and loop until you hit the end.

````lua
  payload:push_fence(payload:next_u16())

  local snihostname  = nil

  while payload:has_more() do
    local ext_type = payload:next_u16()
    local ext_len =  payload:next_u16()
    if ext_type == 10 then
       .. 
  end
  payload:pop_fence() 

````


### Functions  Reference 

Help handle records by setting when the record ends. 

* `push_fence(bytes_ahead)` = Set a fence at bytes_ahead from the current position.
* `has_more()` = Has the fence been hit 
* `pop_fence()` = remove the fence, back to one level up.

Sweepbuf allows you to nest fences to reflect nested record structures.



------

## Text based headers  

The big example of this is HTTP headers, which are of the form.

````lua
Host: www.google-analytics.com
Accept: image/png,image/*;q=0.8,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Referer: http://www.reddit.com/

````

BITMAUL has two simple methods `split_fields` and `split_fields_fast` . These functions make it trivial to parse this into a LUA table in one call. The pattern is shown below 

````lua
local http = payload:split_fields("(%S+):%s(%S+)","\r\n")

assert http['Referer'] == "http://www.reddit.com"

````


### Methods reference


* `split_fields ( regex_with_two_captures, record_delimiter)` : The first parameters is a LUA regex with two captures. Capture 1 is the field name and Capture 2 is the field value.  The second parameter is the record delimiter. Return value = LUA table of the form _{field-name, field-value}_ 
* `split_fields_fast ( field_delimiter, record_delimiter)` : A faster but less flexible version of the `split_fields` method.  Field delimiter is the separator between the name and value. Record delimiter is a string that separates records. Return value = LUA table of the form _{field-name, field-value}_ 


### Notes

Use the fast version if you trust the input to be correct without extra spaces.  The following snippet illustrates this. 

````lua
local fields=sw:split_fields_fast(": ","\r\n")
````

------------------

## Utility methods

* `hexdump()` prints a hexdump of the byte buffer in a canonical format.
* `hexdump_left()` prints a hexdump of the bytes from the current position till the end, what is left.
* `split(str,delim)` Utility method to split a string
* `to_string()` prints details about the SweepBuf object itself, like size of string, position of the pointers, etc.
* `reset()` reset the seek pointer and remove all fences 
* `inc(nbytes)`  move the internal pointer by n bytes. 
* `skip(nbytes)`  skip n bytes. 
* `bytes_left` how many bytes left to process. End - current internal pointer position
* `buffer_left` return the buffer left to be parsed 

------------------

## Examples

See for sweepbuf usage in real application 

 - Trisul APP [TLS Server Name Indication](https://github.com/trisulnsm/apps/tree/master/analyzers/sni-tls) for a full working example.
 - Trisul APP [JA3 Hash TLS Fingerprint](https://github.com/trisulnsm/apps/tree/master/analyzers/tls-print) 
