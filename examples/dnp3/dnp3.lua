-- fixparse.lua
-- 
-- Uses BitMaul to handle  DNP3 segmentation and dissection 
--

-- The dissector ; tells PDURecord about message boundaries. 
-- 
require'crc'

local Dnp3Dissector  = {

  -- how to get the next record - message length in 
  -- 
  what_next =  function( tbl, pdur, swbuf)

	if swbuf:bytes_left()  > 10 then 
		local sync=swbuf:next_u16()
		local nbytes=swbuf:next_u16()
print(nbytes)
		pdur:want_next(nbytes  + 2 + 2 ) 
    end

  end,

  -- handle a reassembled record
  -- we just print the fields here 
  on_record = function( tbl, pdur, strbuf)

	local payload=SweepBuf.new(strbuf:tostring())

	print( "magic ="..payload:next_u16_le())
	print( "length ="..payload:next_u8_le())
	print( "control ="..payload:next_u8_le())
	print( "destination ="..payload:next_u16_le())
	print( "source ="..payload:next_u16_le())
	print( "crc ="..payload:next_u16_le())

	local crc_calculated=crc(buffer:tostring(0,8))
	print( "calccrc ="..crc_calculated);
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

