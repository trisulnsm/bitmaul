-- fixparse.lua
-- 
-- Uses BitMaul to handle  DNP3 segmentation and dissection 
--

-- The dissector ; tells PDURecord about message boundaries. 
-- 
require'crc'
local SB=require'sweepbuf'
require 'enums'

local Dnp3Dissector  = {

  -- how to get the next record - message length in 
  -- 
  what_next =  function( tbl, pdur, swbuf)

	if swbuf:bytes_left()  > 10 then 
		local tlen = swbuf:peek_u8(2)
		local n_checksums = 1
		local q,r = math.modf( (tlen - 5) / 16) 
		n_checksums =n_checksums + q 
		if r > 0 then n_checksums = n_checksums + 1 end 

		pdur:want_next(3 + swbuf:peek_u8(2)  + 2*n_checksums ) 
    end

  end,

  -- handle a reassembled record
  -- we just print the fields here 
  on_record = function( tbl, pdur, strbuf)

	local payload=SB.new(strbuf)

	print( "magic ="..payload:next_u16_le())
	print( "length ="..payload:next_u8_le())
	print( "control ="..payload:next_u8_le())
	print( "destination ="..payload:next_u16_le())
	print( "source ="..payload:next_u16_le())
	print( "crc ="..payload:next_u16_le())

	local crc_calculated=crc(strbuf:sub(1,8))
	print( "calccrc ="..crc_calculated);

	-- transport layer flag 
	print( "transport_flag  ="..payload:next_u8());

	-- construct the app data 
	local appdata_buffers = {} 
	payload:push_fence(payload:bytes_left())
	while payload:has_more() do
		if payload:bytes_left_to_fence()>=18 then
			appdata_buffers[#appdata_buffers+1]= payload:next_str_to_len(16)
		else 
			appdata_buffers[#appdata_buffers+1]= payload:next_str_to_len(payload:bytes_left_to_fence()-2)
		end
		payload:next_u16() --over CRC 
	end
	payload:pop_fence()

	-- dump the DNP3 objects 
	tbl.parse_dnp3_objects( tbl, pdur, SB.new(table.concat(appdata_buffers,"")) )

  end,

  parse_dnp3_objects=function(tbl, pdur, swbuf)

  	swbuf:hexdump()

	local control = swbuf:next_u8()
	local fcode = swbuf:next_u8()

	if fcode==0x81 or fcode==0x82 then 
		-- response or unsolicited response 
		local internal_indications = swbuf:next_u16()
	end 

	swbuf:push_fence(swbuf:bytes_left())
	print("Function Code = "..DNP3_Function_Codes[fcode])

	while swbuf:has_more() do

		local group=swbuf:next_u8()
		local variation=swbuf:next_u8()

		local qualifier=swbuf:next_bitfield_u8( {1,3,4} ) 

		print("Group="..group)
		print("Var="..variation)
		print("Qualifier.object_prefix_code="..qualifier[2])
		print("Qualifier.range_specifier_code="..qualifier[3])
		break

	end

	print("-------------------")
	

  end,

}

-- so return a new dissector
-- 
return {
    new= function(key)
      local p = setmetatable(  {state="init"},   { __index = Dnp3Dissector})
    return p
  end
}

