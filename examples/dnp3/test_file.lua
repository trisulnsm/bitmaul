--
-- test_file.lua - Test a PDU Record based dissector by pumping chunks of payload
-- 
-- Reads from a FILE containing raw TCP stream bytes and tests dissector 
-- by randomly reading nbytes from fiel and pumping the PDU record.
-- this simulates a network reassembly scenario
--
local PDURec = require'pdurecord'
local Dissector=require 'dnp3'

-- usage test_file <filename> 
if #arg ~= 1 then 
  print("Usage : test_file  datafile")
  return
end 

-- a PDURecord, we will pump this  with chunks from the binary file 
local pdu1 =  PDURec.new("fixp", Dissector.new() )

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


