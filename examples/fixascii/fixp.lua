-- fixparse.lua
-- 
-- Uses BitMaul to handle FIX ASCII 
--
local PDURec = require'pdurecord'
local FixFields = require'fixtypes'

-- The dissector ; tells PDURecord about message boundaries. 
-- 
local FixDissector  = {

  -- how to get the next record 
  --  1st we get message length 9=??
  --  2nd we determine PDU ends at message_length from above 
  -- 
  what_next =  function( tbl, pdur, swbuf)

    if tbl.state=='init' then
      pdur:want_to_pattern("9=%d+\1")
    elseif tbl.state=='get_full_record' then 
      pdur:want_next(tbl.moredata)
    end

  end,


  -- handle a reassembled record
  -- we just print the fields here 
  on_record = function( tbl, pdur, strbuf)

    if tbl.state=='init' then
      tbl.state='get_full_record'
      tbl.header = strbuf 

      -- msg size 9=88
      local f,l,bytes = strbuf:find("9=(%d+)\1")
      tbl.moredata = tonumber(bytes) + 7 

    elseif tbl.state=='get_full_record' then 
      tbl.state='init'

      print("-----")
      for k,v in strbuf:gmatch("(%w+)=([^\1]+)\1") do
        print(FixFields[k].."="..v) 
      end
    end
  
  end ,

}

-- We need this metatable to store the state. 
new_fix = function()
  local p = setmetatable(  { state='init', moredata=0},   { __index = FixDissector})
  return p
end 



--------------------------------------
-- driver function 
-- read binary fix data from a file, randomly insert chunks into PDURecord
-- to test the reassembly and frame boundary calculation
--------------------------------------

if #arg ~= 1 then 
  print("Usage : fixp datafile")
  return
end 

local pdu1 =  PDURec.new("fixp", new_fix() )

local f = io.open(arg[1])
local payl = f:read( math.random(50) )
local payl = nil 
local cpos = 1 

-- pump the PDU record, it will call dissector:on_record() at the correct time 
while payl do 
  pdu1:push_chunk(cpos,payl)
  cpos = cpos + #payl
  payl = f:read( math.random(20) )
end


