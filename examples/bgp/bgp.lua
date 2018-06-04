-- bgp.lua
-- 
-- Uses BitMaul to handle BGP
--

local SB=require'sweepbuf'

local BGPDissector  = {

  -- BGP is length terminated but it also demarcated by 16 0xff Bytes, we use that 
  -- 
  what_next =  function( tbl, pdur, swbuf)

    pdur:want_to_start_pattern("\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff")

  end,

  -- handle a reassembled record
  -- we just print the fields here 
  on_record = function( tbl, pdur, strbuf)

  	local sw = SB.new(strbuf)


	sw:hexdump() 


	print("---")


  
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

