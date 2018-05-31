--
-- reassembly_handler.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Hook into Trisul's TCP reassembly engine 
-- DESCRIPTION: DNP3 over TCP 20000 
-- 
local SweepBuf=require'sweepbuf' 

TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "DNP3",
    description = "On to TCP Reassembly at 20000"
  },



  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- WHEN CALLED: a new flow is detected (eg from a SYN packet) 
    --  look at flow tuples and decide if you want to reassemble 
    --  return true : to enable reassembly , false to disable
    --  skip this function if you always want to enable 
    filter = function(engine, timestamp, flowkey) 
      return (flowkey:porta_readable()=="20000" or flowkey:portz_readable()=="20000" )
    end,


    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    -- handle reassembled byte stream here , 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

	print( buffer:hexdump())
	local payload=SweepBuf.new(buffer:tostring())

	print( "magic ="..payload:next_u16_le())
	print( "length ="..payload:next_u8_le())
	print( "control ="..payload:next_u8_le())
	print( "destination ="..payload:next_u16_le())
	print( "source ="..payload:next_u16_le())
	print( "crc ="..payload:next_u16_le())

	local crc_calculated=crc(buffer:tostring(0,8))
	print( "calccrc ="..crc_calculated);

    end,

  },

}
