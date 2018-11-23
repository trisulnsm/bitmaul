-- BITMAUL working example
-- QUIC dissector using SweepBuf 
--
-- Parses the QUIC messages into a LUA Table
--
local SWB=require'sweepbuf'
local TblInspect=require'inspect' 

-- 
-- return a LUA table -- field value
-- 
function do_dissect( buff)

  local swb=SWB.new(buff)

  local ret={}

  ret.flags   = swb:next_bitfield_u8( {1,1,2,  1,1,1,1} )

  ret.pkt_number_len = math.pow(2,ret.flags[3])

  
  if ret.flags[4]==1 then
	  ret.cid_hi   = swb:next_u32()
	  ret.cid_lo   = swb:next_u32()
	  ret.cid_str  = string.format("%08X",ret.cid_hi)..string.format("%08X",ret.cid_lo) 
  end

  if ret.flags[7]==1 then
	  ret.version   = swb:next_str_to_len(4)
  end 

  ret.pkt_number = swb:next_uN(ret.pkt_number_len)

  if ret.pkt_number ==1 then

  	-- special


  end

  print(TblInspect(ret))


end
