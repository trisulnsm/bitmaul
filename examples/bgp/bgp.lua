-- bgp.lua
-- 
-- Uses BitMaul to handle BGP
--

local SB=require'sweepbuf'
local Inspect=require'inspect' 

require'handlers'

local BGPDissector  = {

  -- BGP is length terminated but it also demarcated by 16 0xff Bytes, we use that 
  what_next =  function( tbl, pdur, swbuf)

      -- BGP PDU start with a marker 
      pdur:want_to_start_pattern("\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff")

  end,

  -- handle a reassembled record
  -- we just print the fields here 
  on_record = function( tbl, pdur, strbuf)

    local sw = SB.new(strbuf)

    -- fields here in this table 
    local fields = {}

    sw:skip(16); 
    fields.length = sw:next_u16();
	sw:clip(fields.length);

    fields.msgtype = sw:next_u8(); 
    fields.msgname = BGP_Message_Types[fields.msgtype]



    local handlerfn = BGP_Handlers[fields.msgtype]
    if handlerfn then
      fields.msg = handlerfn(sw)
    end


    print(Inspect(fields))   -- Inspect is from inspect.lua - pretty prints the Lua Table 
    
    end ,

}



-- so return a new dissector
-- 
return {
    new= function(key)
      local p = setmetatable(  {state="init", moredata=0},   { __index = BGPDissector})
    return p
  end
}

