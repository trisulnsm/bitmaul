-- test_file.lua
-- 
-- Reads from a FILE and tests the FIXP dissector in fixp.lua 
--

local PDURec = require'pdurecord'
local FixDissector=require 'fixp'

-- usage test_file <filename> 
if #arg ~= 1 then 
  print("Usage : fixp datafile")
  return
end 

-- a PDURecord, we will pump this  with chunks from the binary file 
local pdu1 =  PDURec.new("fixp", FixDissector.new() )

local f = io.open(arg[1])
local payl = f:read( math.random(50) )
local cpos = 1 

-- pump the PDU record, 
-- it will call dissector:on_record() at the correct time 
while payl do 
  pdu1:push_chunk(cpos,payl)
  cpos = cpos + #payl
  payl = f:read( math.random(20) )
end


