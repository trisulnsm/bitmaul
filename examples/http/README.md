BITMAUL HTTP Parsing Benchmark
======================

We put our BITMAUL HTTP header parser to work here in this benchmark. This benchmark 

 - loads a HTTP header with a long URI from into a string
 - parses it into method,url,version, {fields} repeatedly 
 - repeats it 10 million times 

### The parser method

We use the [Sweepbuf method](../../SWEEPBUF.md) `split_fields_fast` to extract the fields and their values into a LUA table. 

```
local fields=sw:split_fields_fast(": ","\r\n")
```

## To run the benchmark

1. copy the sweepbuf.lua from the BITMAUL library
2. run `luajit test_file.lua headers.txt` to parse the HTTP header into repeatedly and print the benchmark results 

## Results

> 10-Million iterations of parsing the string in file header.txt 

### 2.3 Gbps - LuaJIT 2.0.4 

````
$ /usr/local/bin/luajit-2.0.4   test_file.lua header.txt 
JIT version 20004
Processed 10000000 iterations in 30 secs. Throughput = 2322666666 bps
````


### 5.4 Gbps - LuaJIT 2.1.0 

````
$ /usr/local/bin/luajit-2.1.0-beta3    test_file.lua header.txt 
JIT version 20100
Processed 10000000 iterations in 13 secs. Throughput = 5360000000 bps
````


## Performance tips to BITMAUL users

Avoiding usage of Regex is the key to best speed.  You can extract the request line fields like shown below. 

````lua
local method = sw:next_str_to_pattern(" ")
local uri    = sw:next_str_to_pattern(" ")
local version = sw:next_str_to_pattern("\r\n") 
````

You can also use a Regex to capture the three values as shown below. 


````lua
local request_line= sw:next_str_to_pattern("\r\n")
local method,uri,version = request_line:match("(%S+)%s+(%S+)%s+(%S+)")
````

This is SLOWER , throughput drops to 1.5 Gbps (still blazing fast !!)

#### Rule of Thumb 

1. Dealing with a slower protocol. Almost always prefer the regex because it is more flexible and catches the corner cases (2 spaces, tabs instead of spaces)
2. Performance is supreme. Then dont use the regexes 



## Profiling BITMAUL module SWEEPBUF performance  

Roughly 30% of the time is spent in building the return Lua table. The following JIT profile shows the areas for future improvement we will be working on !! 



````
JIT version 20100
Processed 10000000 iterations in 13 secs. Throughput = 5360000000 bps

====== ./sweepbuf.lua ======
@@ 110 @@
      |     is_plain=is_plain or true 
      |     local f,l =string.find(tbl.buff,patt,tbl.seekpos,is_plain)  -- last param = false=regex, true=not-regex 
      |     if f then
   9% |         local r = string.sub(tbl.buff,tbl.seekpos,l)
      |         tbl.seekpos = l+1
      |         return r
      |     else
@@ 295 @@
      |   local ret={}
      | 
      |   while pos<len-#delim_record do
  19% |     local f1,l1 = string.find(tbl.buff, delim_name, pos, true)
   8% |     local f2,l2 = string.find(tbl.buff, delim_record, l1+1, true)
      | 
  15% |     local f=string.sub(tbl.buff,pos,f1-1)
   8% |     local v=string.sub(tbl.buff,l1+1,f2-1)
      |     pos=l2+1
      | 
  29% |     ret[f]=v
      |   end 
      | 
      |   return ret
@@ 356 @@
      | 
      |    new = function( rawbuffer , pos) 
      |        pos = pos or 1 
   4% |        return setmetatable(  {
      |           buff=rawbuffer,
      |           left=pos,
      |           right=pos+#rawbuffer,

````
