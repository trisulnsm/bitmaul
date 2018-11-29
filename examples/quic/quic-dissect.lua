-- BITMAUL working example
-- QUIC dissector using SweepBuf 
--
-- Parses the QUIC messages into a LUA Table
--

local SWB=require'sweepbuf'
local TblInspect=require'inspect' 

-- CID -> payloadstr 
local pending = {  } 

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

  -- checkif reassembly is needed 
  local pending_buff = pending[ret.cid_str]
  if pending_buff then 
    pending[ret.cid_str]=nil 
  local newbuff = pending_buff .. string.sub(buff,10)
  return do_dissect(newbuff)
  end 


  if ret.flags[7]==1 then
    ret.version   = swb:next_str_to_len(4)
  end 

  ret.pkt_number = swb:next_uN(ret.pkt_number_len)

  -- post full CHLO we have encryption, nothing more..
  if ret.pkt_number > 3  then return nil end;


    -- special
  ret.mac_hash = swb:next_hex_str_to_len(12)

  ret.stream_flags = swb:next_bitfield_u8_named( {1,1,1,  3,2} , {'stream','fin','data_length','offset_length','stream_length'} )

  if ret.stream_flags.stream == 1 then

    ret.stream_id = swb:next_uN(math.pow(2,ret.stream_flags.stream_length))

    ret.data_length  = swb:next_uN(2*ret.stream_flags.data_length)

    -- 
    -- stream_id = 1 is special 
    if ret.stream_id == 1 then

      ret.tag = swb:next_str_to_len(4)
      ret.tag_count  = swb:next_u16_le(2)
      _              = swb:next_u16(2)

      ret.tag_offsets = { } 
      for i = 1 , ret.tag_count do
        local t = swb:next_str_to_len(4)
        local v = swb:next_u32_le()
        table.insert( ret.tag_offsets,  { t , v } )
      end


      local pos = 0 
      for i = 1 , ret.tag_count do
        local tv = ret.tag_offsets[i] 
        local len = tv[2] - pos
        pos = tv[2]

        if swb:bytes_left() < len then
          pending[ ret.cid_str] = buff 
          print("Truncated, waiting for next packet number want="..len.." left="..swb:bytes_left()) 
          return nil
        end 

        if tv[1]=='SNI\0' then
          ret.tag_sni = swb:next_str_to_len(len)
        elseif tv[1]=='UAID' then
          ret.tag_user_agent = swb:next_str_to_len(len)
        elseif tv[1]:match("^CRT")  then
		  local entrytype=swb:next_u8()
		  local nentries=swb:next_u8()
		  swb:skip( nentries)
		  local uncompressed_length = swb:next_u32() 
		  local compressed_len=len-1-1-nentries-4
          ret.tag_cert_chain= swb:next_str_to_len(compressed_len+1)
        else
          swb:skip(len)
        end
      end
    end

  end

  -- uncomment to dump the field breakup 
  -- print(TblInspect(ret))

  return ret

end
