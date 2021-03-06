local SB=require'sweepbuf'

-- TCP layer bytes exported from wireshark into hex
local tcp_bytes_hex = 
"bfd701bb4dbb04ad75a06b21b010015e7a3800000101080a0072a3b80e5a53010101050a75a06b2075a06b21"

-- convert above to binary string for feeding into SweepBuf 
local tcp_bytes_binary = tcp_bytes_hex:gsub('..', 
                                            function (cc)
                                              return string.char(tonumber(cc, 16))
                                            end)

-- Wrap the SweepBuffer over the binary buffer
local sb = SB.new(tcp_bytes_binary) 
print(sb) 

-- Print the fields
print("Source Port : " .. sb:next_u16())
print("Dest   Port : " .. sb:next_u16())
print("Sequence #  : " .. sb:next_u32())
print("Ack #       : " .. sb:next_u32())

local flags_fo =sb:next_bitfield_u16( { 4, 6, 1,1,1,1,1,1 } ) 
print("Flags/FO    : " )
print("    Header Len   : " .. flags_fo[1])
print("    Reserved     : " .. flags_fo[2])
print("           URG   : " .. flags_fo[3])
print("           ACK   : " .. flags_fo[4])
print("           PSH   : " .. flags_fo[5])
print("           RST   : " .. flags_fo[6])
print("           SYN   : " .. flags_fo[7])
print("           FIN   : " .. flags_fo[8])

print("Window Size : " .. sb:next_u16())
print("Checksum    : " .. sb:next_u16())
print("Urg         : " .. sb:next_u16())

-- TCP/options - showing how to process records till end 
-- 
sb:push_fence(sb:bytes_left())
while sb:has_more() do
  local option_type = sb:next_u8()
  if option_type==1 then
    -- NO OP
  elseif option_type==5 then
    -- SACK
    print("Option : SACK len="..sb:next_u8())
    print("   left edge            :"..sb:next_u32())
    print("   right edge           :"..sb:next_u32())
  elseif option_type==8 then
    -- Timestamp
    print("Option : TIMESTAMP len="..sb:next_u8())
    print("   Timestamp value      :"..sb:next_u32())
    print("   Timestamp echo reply :"..sb:next_u32())
  else
    print("Unknown Option : len="..sb:u8())
    sb:skip(sb:next_u8())
  end
end
sb:pop_fence() 

