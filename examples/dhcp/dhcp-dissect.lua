local SWB=require'sweepbuf'
local JSON=require'JSON'
require 'dhcp-enums'




-- 
-- return a LUA table -- field value
-- 
function do_dissect( buff)

	local swb=SWB.new(buff)

	local ret={}


	ret.op      	= swb:next_u8_enum( { "BOOTREQUEST", "BOOTREPLY"})
	ret.htype 		= swb:next_u8() 
	ret.hlen 		= swb:next_u8() 
	ret.hops		= swb:next_u8() 
	ret.xid			= swb:next_u32()
	ret.secs		= swb:next_u16()
	ret.flags		= swb:next_bitfield_u16( {1,15} )
	ret.ciaddr		= swb:next_ipv4()
	ret.yiaddr		= swb:next_ipv4()
	ret.siaddr		= swb:next_ipv4()
	ret.giaddr		= swb:next_ipv4()
	ret.chaddr		= swb:next_mac()
	_ 				= swb:skip(10)
	_				= swb:next_str_to_len(64)
	_ 				= swb:next_str_to_len(128)
	_				= swb:skip(4)

	-- options start
	ret.options  = { }
    while swb:has_more() do

      local et= swb:next_u8_enum(MESSAGE_TYPES)

	  handler_fns = handler_fns or {
	  	[53] = function(swb) 
				local l= swb:next_u8()
				return swb:next_u8_enum(MSG_TYPE_53)
			   end,
	  	[1] = function(swb) 
				local l= swb:next_u8()
				return swb:next_ipv4()
			   end,
	  	[51] = function(swb) 
				local l= swb:next_u8()
				return string.format("%d seconds", swb:next_u32())
			   end,
	  	[58] = function(swb) 
				local l= swb:next_u8()
				return string.format("%d seconds", swb:next_u32())
			   end,
	  }

	  if handler_fns[et[1]] then
		  ret.options[#ret.options+1] =  {  et, handler_fns[et[1]](swb)  } 
	  else 
		  local l= swb:next_u8()
		  local v= swb:next_str_to_len(l) 
		  ret.options[#ret.options+1] =  {  et, v } 
	  end 
    end


	print(JSON:encode(ret))




end
