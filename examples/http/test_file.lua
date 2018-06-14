-- test_file.lua
-- 
-- Benchmark driver for HTTP parsing using BITMAUL 
-- read the single HTTP header in headers.txt and parse in loop 
--

local SB=require'sweepbuf'
local jit=require'jit'

if #arg ~= 1 then 
  print("Usage : test_file  datafile")
  return
end 

-- it will call dissector:on_record() at the correct time 
local f = io.open(arg[1])
local payl = f:read( "*a") 

-- Record time taken to process 10 Million 
local start_secs=os.time() 
local iter=0
while iter < 10000000  
do 

  local sw = SB.new(payl)

  -- request line
  local method = sw:next_str_to_pattern(" ") 
  local uri    = sw:next_str_to_pattern(" ") 
  local version = sw:next_str_to_pattern("\r\n") 

  -- 'fields' is a LUA table containing f[attribute]=value
  -- so print( fields['Host'] ) =>  "gmane.org"
  -- 
  local fields=sw:split_fields_fast(": ","\r\n")

  -- print the parsed fields 
  -- print(uri)
  -- for k,v in pairs(fields) do
  --  print(k..'='..v)
  -- end

  iter = iter + 1 
  if iter%100000 == 0 then
    -- print(iter)   -- just to print progress 
  end 

end


local elapsed_secs=os.time() -start_secs
print("JIT version "..jit.version_num)
print("Processed "..iter.." iterations in ".. elapsed_secs..
        " secs. Throughput = "..math.floor((iter*#payl*8)/elapsed_secs).." bps")

