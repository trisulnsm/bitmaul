-- fixparse.lua
-- 
-- Uses BitMaul to handle FIX ASCII 
--
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

      local resource={}
      for k,v in strbuf:gmatch("(%w+)=([^\1]+)\1") do
        resource[#resource+1] = (FixFields[k].."="..v) 
      end

      -- generate a Resource - in Trisul a LOG entry is a RESOURCE 
      --
      if pdur.engine then 
        pdur.engine:add_resource("{7D1B9296-BF19-403C-0497-E002FEBB385B}",pdur.flowkey:id(),
          "FIX log", table.concat(resource,","))
      else
	  	print("-------------------------")
        print(table.concat(resource,"\n"))
      end 
    end
  
  end ,

}

-- so return a new dissector
-- 
return {
    new= function(key)
      local p = setmetatable(  {state="init", moredata=0},   { __index = FixDissector})
    return p
  end
}

