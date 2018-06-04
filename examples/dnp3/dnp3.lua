-- dnp3.lua
-- 
-- Uses BitMaul to handle  DNP3 segmentation and dissection 
-- 

local SB = require 'sweepbuf'   -- sweepbuf part of BitMAUL
local CRC= require 'crc'      -- CRC function - demo
local EN = require 'enums'          -- DNP3 message fields, pulled out into enums.lua 

-- The Dissector 
local Dnp3Dissector  = {

 
  -- what_next(..) : tells PDURecord where to field the end of DNP3 PDU from TCP bytestream
  -- 
  -- the length field + sum of all checksum fields 
  --
  -- 
  what_next =  function( tbl, pdur, swbuf)

    -- we need atleast 10 bytes to decide, that is where the length field can be found
    -- 
    if swbuf:bytes_left()  > 10 then 
        local tlen = swbuf:peek_u8(2)  -- use peek(..) to preserve internal pointer, not next(..)
        local n_checksums = 1
        local q,r = math.modf( (tlen - 5) / 16) 
        n_checksums =n_checksums + q 
        if r > 0 then n_checksums = n_checksums + 1 end 

        -- want_next() - tell PDURecord we want the next X bytes as full PDU
        pdur:want_next(3 + swbuf:peek_u8(2)  + 2*n_checksums ) 
    end

  end,

  -- handle a reassembled record
  -- we just print the fields here 
  on_record = function( tbl, pdur, strbuf)

    local payload=SB.new(strbuf)

    -- basic parsing of DNP3 header fields 
    print( "magic ="..payload:next_u16_le())
    print( "length ="..payload:next_u8_le())
    print( "control ="..payload:next_u8_le())
    print( "destination ="..payload:next_u16_le())
    print( "source ="..payload:next_u16_le())
    print( "crc ="..payload:next_u16_le())

    -- compare the CRC , see crc.lua for how we calculate 
    local crc_calculated=crc(strbuf:sub(1,8))
    print( "calccrc ="..crc_calculated);
    print( "transport_flag  ="..payload:next_u8());


    -- a fun part here. the DNP3 message itself needs to be reconstructed from 
    -- Application data "chunks". Each chunk is 16 bytes or less with a Checksum field.
    -- this loop constructs appdata_buffers , a buffer representing the full chunk
    -- we use a table of strings and just concat them in the end into a single buffer for performance 
    -- reasons 
    local appdata_buffers = {} 
    payload:push_fence(payload:bytes_left())
    while payload:has_more() do
      if payload:bytes_left_to_fence()>=18 then
        if #appdata_buffers == 0 then 
          appdata_buffers[#appdata_buffers+1]= payload:next_str_to_len(15)
        else
          appdata_buffers[#appdata_buffers+1]= payload:next_str_to_len(16)
        end
      else 
        appdata_buffers[#appdata_buffers+1]= payload:next_str_to_len(payload:bytes_left_to_fence()-2)
      end
      payload:next_u16() --over CRC 
    end
    payload:pop_fence()

    -- dump the DNP3 objects 
    tbl.parse_dnp3_objects( tbl, pdur, SB.new(table.concat(appdata_buffers,"")) )

  end,

  
  -- parse_dnp3_objects(..) print the objects. Demostrates how you can use bitfields(..)
  -- and function call table to handle dissecton. 
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

      -- bitfields from Sweepbuf make it easy to break up to bit level
      local qualifier=swbuf:next_bitfield_u8( {1,3,4} ) 
      local opc=qualifier[2]
      local rsc=qualifier[3]
      local object_size= DNP_Group_Var_Bitlength[group][variation] 

      print("Group="..group)
      print("Var="..variation)
      print("BitLength= ".. object_size)

      print("                                                OPC = ".. opc)
      print("                                                RSC = ".. rsc)

      -- number of objects in DNP3 can be a single field, a start and stop field, or nothing at all
      -- the DNP3_RSC_Num_Objects table contains functions that can tell you the number of objects
      -- demonstrates how you can use function tables to perform dissection of messages. 
      -- a clean interface 
      local nobjects = DNP3_RSC_Num_Objects_Functions[rsc](swbuf) 

      print("                                                NOBJ = ".. nobjects)

      local total_object_size = math.ceil((nobjects * object_size) / 8 )
      print("                                                TOTALOBJSIZE = ".. total_object_size)

      -- skip over the object size, we can dissect this further if we want
      -- 
      swbuf:skip( total_object_size) 

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

