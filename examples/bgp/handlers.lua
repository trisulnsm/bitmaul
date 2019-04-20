-- handlers
-- shows how you can use functions to modularize parsing
-- dont worry about perf. tracing LuaJIT will optmize commonly used function paths 

local dbg=require'debugger'
local IP6=require'ip6'

BGP_Message_Types =
{
  [1]="OPEN",
  [2]="UPDATE",
  [3]="NOTIFICATION",
  [4]="KEEPALIVE",
}

BGP_Path_Attributes = 
{
  [1] = function(swbuf,len)  
    -- ORIGIN 
    local tbl={
      [0]="IGP",
      [1]="EGP",
      [2]="INCOMPLETE",
    }
    return { ["ORIGIN"] = tbl[swbuf:next_u8()] } 
  end ,


  [2] = function(swbuf,len)

    -- AS_PATH
    local tbl={
      [0]="AS_SET",
      [2]="AS_SEQUENCE",
    }
    local flds = {}
    flds.as_type = tbl[swbuf:next_u8()]
    local num_as = swbuf:next_u8() 

    if num_as ~= (len-2)/2 and num_as == (len-2)/4 then 
      flds.aslist  = swbuf:next_u32_arr( num_as)   -- 4 byte AS
    else
      flds.aslist  = swbuf:next_u16_arr( num_as)   -- 2 byte AS 
    end 

    return { ["AS_PATH"] =  flds } 
  end,

  [3] = function(swbuf,len)
    -- NEXT_HOP 
    return { ["NEXT_HOP"] =  swbuf:next_ipv4()  } 

  end,

  [4] = function(swbuf,len)
    -- MULTI_EXIT_DISC 
    return { ["MULTI_EXIT_DISC"] =  swbuf:next_u32()  } 

  end,

  [7] = function(swbuf,len)
  	-- AGGREGATOR
    return { ["AGGREGATOR"] =  {
		asn = swbuf:next_u32(),
		ip = swbuf:next_ipv4()
		} 
	}
  end,


  [8] = function(swbuf,len)
  	-- COMMUNITIES
	local tbl= {}
	local i
	for i = 1 , len/4  do 
		local lv = swbuf:next_u16()
		local as = swbuf:next_u16()
		table.insert( tbl, lv..":"..as)
	end 

    return { ["COMMUNITIES"] =  table.concat(tbl,",") }

  end,

  [14] = function(swbuf,len)
  	-- MP NLRI 
    local flds = {}
    flds.afi = swbuf:next_u16()
    flds.safi = swbuf:next_u8()
	local nlen=swbuf:next_u8()
	if flds.afi==2 and flds.safi==1 and nlen==16 then
		flds.nexthop = IP6.bin_to_ip6( swbuf:next_str_to_len(nlen))
	else
		swbuf:skip(nlen)
	end
	swbuf:skip(1) -- reserved

    local prefixlength = swbuf:next_u8()
	if flds.afi==2 and flds.safi==1 then 
		local farr = swbuf:next_str_to_len( math.ceil( prefixlength/8))
		local barr = farr..string.rep("\x00",16-math.ceil(prefixlength/8))
		flds.nlri = IP6.bin_to_ip6( barr).."/"..prefixlength

	end

    -- MP-NLRI 
    return { ["MP-NLRI"] =  flds   } 

  end,

  [16] = function(swbuf,len)
  	-- EXTENDED COMMUNITIES 

	local ec = {} 
	for i = 1 , len/8  do 
		local ty = swbuf:next_u8()
		local st = swbuf:next_u8()

		if ty==0x00 or ty==0x40 then
			table.insert( ec, swbuf:next_u16()..":"..swbuf:next_u32()) 
		else 
			table.insert( ec, swbuf:next_u16()..":"..swbuf:next_u32()) 
		end 
	end 

    -- MP-NLRI 
    return { ["EXTENDED-COMMUNITES"] =  ec   } 

  end,

  [32] = function(swbuf,len)
  	-- LARGE COMMUNITY 

	local ec = {} 
	for i = 1 , len/12  do 
		table.insert( ec, swbuf:next_u32()..":"..swbuf:next_u32()..":"..swbuf:next_u32()) 
	end 

    -- MP-NLRI 
    return { ["LARGE-COMMUNITES"] =  ec   } 

  end,

} 

-- v4/v6 IP prefix a common pattern
function parse_prefix(swbuf)
  local prefixlength = swbuf:next_u8()
  if  swbuf:bytes_left() < math.ceil(prefixlength/8)  then
  	return nil
  elseif prefixlength <= 32 then 
	  local ip4num=swbuf:next_uN_le( math.ceil(prefixlength/8)) or 0 
	  return string.format("%d.%d.%d.%d/%d", 
			bit.band(bit.rshift(ip4num,0),0xff),
			bit.band(bit.rshift(ip4num,8),0xff), 
			bit.band(bit.rshift(ip4num,16),0xff), 
			bit.rshift(ip4num,24), 
			prefixlength)
  elseif prefixlength <= 128 then
	 local farr = swbuf:next_str_to_len( math.ceil( prefixlength/8))
	 local barr = farr..string.rep("\x00",16-math.ceil(prefixlength/8))
	 return IP6.bin_to_ip6( barr).."/"..prefixlength 
  end 
end

BGP_Handlers =
{


  [1]   = function(swbuf)

    -- BGP OPEN -notice how clean and simple BITMAUL makes this 
    local flds = {}

    flds.version  = swbuf:next_u8() 
    flds.my_as    = swbuf:next_u16() 
    flds.hold_time  = swbuf:next_u16() 
    flds.bgp_id   = swbuf:next_u32()


    flds.params = {}

    -- TLV  - capability codes 
    swbuf:push_fence( swbuf:next_u8() )
    while swbuf:has_more() do

      local t= swbuf:next_u8()
      local l= swbuf:next_u8()
      local v= swbuf:next_str_to_len(l) 

      flds.params[#flds.params+1] =  {  t, l, v } 
    end
    swbuf:pop_fence()

    return flds

  end,


  [2]   = function(swbuf )

    -- BGP UPDATE 
    local flds = {}

    -- withdrawn routes 
    flds.withdrawn_routes_length  = swbuf:next_u16()
    flds.withdrawn_routes   = {}
    swbuf:push_fence(flds.withdrawn_routes_length)
    while swbuf:has_more() do 
		table.insert( flds.withdrawn_routes, parse_prefix(swbuf))
    end 

    -- path attributes
	if swbuf:bytes_left() < 2 then return flds end 
    flds.path_attr_length   = swbuf:next_u16()
    flds.path_attr  = {}
    swbuf:push_fence(flds.path_attr_length)
    while swbuf:has_more() do 

      local attr_flags = swbuf:next_bitfield_u8( {1,1,1,1,4} )
      local attr_type = swbuf:next_u8()
      local attr_len
      if attr_flags[4]==1 then 
        attr_len = swbuf:next_u16() 
      else
        attr_len = swbuf:next_u8() 
      end 

      local path_attr_fn  = BGP_Path_Attributes[attr_type]
      if path_attr_fn then
        flds.path_attr [#flds.path_attr+1]= path_attr_fn(swbuf,attr_len)
      else
        flds.path_attr [#flds.path_attr+1]= { attr_type , attr_len } 
        swbuf:skip(attr_len) 
      end

    end 


    -- NLRI 
    flds.nlri = {} 
    while swbuf:bytes_left() > 0  do
		table.insert(  flds.nlri, parse_prefix(swbuf))
    end

    return flds

  end, 

}
