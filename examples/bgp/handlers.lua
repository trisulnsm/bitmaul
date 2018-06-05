-- handlers
-- shows how you can use functions to modularize parsing
-- dont worry about perf. tracing LuaJIT will optmize commonly used function paths 

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
			-- 4 byte AS
			flds.aslist  = swbuf:next_u32_arr( num_as)
		else
			-- 2 byte AS
			flds.aslist  = swbuf:next_u16_arr( num_as) 
		end 

		return { ["AS_PATH"] =  flds } 
	end,

	[3] = function(swbuf,len)
		-- NEXT_HOP 
		return { ["NEXT_HOP"] =  swbuf:next_ipv4()  } 

	end


} 

BGP_Handlers =
{


	[1] 	= function(swbuf)

		-- BGP OPEN -notice how clean and simple BITMAUL makes this 
		local flds = {}

		flds.version 	= swbuf:next_u8() 
		flds.my_as   	= swbuf:next_u16() 
		flds.hold_time  = swbuf:next_u16() 
		flds.bgp_id		= swbuf:next_u32()


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


	[2] 	= function(swbuf )

		-- BGP UPDATE 
		local flds = {}

		-- withdrawn routes 
		flds.withdrawn_routes_length 	= swbuf:next_u16()
		flds.withdrawn_routes 	= {}
		swbuf:push_fence(flds.withdrawn_routes_length)
		while swbuf:has_more() do 

			local prefix_bits = swbuf:next_u8()
			local route = swbuf:next_str_to_len(math.ceil(prefix_bits/8))

			flds.withdrawn_routes[#flds.withdrawn_routes+1] =  {  prefix_bits, route  } 

		end 

		-- path attributes
		flds.path_attr_length 	= swbuf:next_u16()
		flds.path_attr 	= {}
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
			local prefixlength = swbuf:next_u8()
			if prefixlength>24 then
				flds.nlri[#flds.nlri+1] = swbuf:next_ipv4()
			elseif prefixlength>16 then
				flds.nlri[#flds.nlri+1] = string.format("%d.%d.%d", swbuf:next_u8(), swbuf:next_u8(),swbuf:next_u8())
			elseif prefixlength>8 then
				flds.nlri[#flds.nlri+1] = string.format("%d.%d", swbuf:next_u8(), swbuf:next_u8())
			elseif prefixlength>0 then
				flds.nlri[#flds.nlri+1] = string.format("%d", swbuf:next_u8())
			end
		end

		return flds

	end, 



}
