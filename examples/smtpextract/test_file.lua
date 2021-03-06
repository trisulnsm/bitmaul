-- test_file.lua
-- 
-- Driver for SMTP dissector sample 
--

local PDURec = require'pdurecord'
local SMTPDissector=require 'smtp'

-- usage test_file <filename> 
if #arg ~= 1 then 
  print("Usage : test_file  datafile")
  return
end 

-- a PDURecord, we will pump this  with chunks from the binary file 
local pdu1 =  PDURec.new("bgp", SMTPDissector.new() )




-- pump the PDU record using push_xx() 
-- it will call dissector:on_record() at the correct time 
local f = io.open(arg[1])
local payl = f:read( math.random(50) )
local cpos = 1 
while payl do 
  pdu1:push_chunk(cpos,payl)
  cpos = cpos + #payl
  payl = f:read( math.random(20) )
end


