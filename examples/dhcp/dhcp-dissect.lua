-- BITMAUL working example
-- DHCP dissector using SweepBuf 
--
-- Parses the DHCP messages into a LUA Table
--
local SWB=require'sweepbuf'
require 'dhcp-enums'

-- 
-- return a LUA table -- field value
-- 
function do_dissect( buff)

  local swb=SWB.new(buff)

  local ret={}

  ret.op      = swb:next_u8_enum( { "BOOTREQUEST", "BOOTREPLY"})
  ret.htype   = swb:next_u8() 
  ret.hlen    = swb:next_u8() 
  ret.hops    = swb:next_u8() 
  ret.xid     = swb:next_u32()
  ret.secs    = swb:next_u16()
  ret.flags   = swb:next_bitfield_u16( {1,15} )
  ret.ciaddr  = swb:next_ipv4()
  ret.yiaddr  = swb:next_ipv4()
  ret.siaddr  = swb:next_ipv4()
  ret.giaddr  = swb:next_ipv4()
  ret.chaddr  = swb:next_mac()
  _           = swb:skip(10)
  _           = swb:next_str_to_len(64)
  _           = swb:next_str_to_len(128)
  _           = swb:skip(4)

  -- options start
  ret.options  = { }
    while swb:has_more() do

      local et= swb:next_u8_enum(MESSAGE_TYPES)

      -- lazy create global handler_functions, goal is to keep the coding inline in this place, 
      handler_fns = handler_fns or {
        [1] = function(swb) 
            return swb:next_ipv4(swb:next_u8())
           end,
        [51] = function(swb) 
            return string.format("%d seconds", swb:next_uN(swb:next_u8()))
           end,
        [53] = function(swb) 
            return swb:next_uN_enum(swb:next_u8(),MSG_TYPE_53)
           end,
        [55] = function(swb) 
            return swb:next_u8_enum_arr(swb:next_u8(),MESSAGE_TYPES)
           end,
        [58] = function(swb) 
            return string.format("%d seconds", swb:next_uN(swb:next_u8()))
           end,
        [61] = function(swb) 
            local len=swb:next_u8()
            if swb:next_u8()  == 1 then 
              return swb:next_mac()          -- hardware_type = 1 (Ethernet) 
            else
              return swb:next_str_to_len(len-1)  -- hardware_type = other
            end
          end,
      }

      if handler_fns[et[1]] then
        ret.options[#ret.options+1] =  {  et, handler_fns[et[1]](swb)  } 
      else 
        local l= swb:next_u8()
        local v= swb:next_str_to_len(l) 
        ret.options[#ret.options+1] =  {  et, {v} } 
      end 
    end
    return ret
end

-- just a lookup by extention number 
--  returns a string "{val} {enum}" 
function find_extension(tbl, eid)
  for _,v in ipairs(tbl)
  do 
    local et=v[1]
    if et[1]==eid then return  table.concat(v[2]," ")  end
  end
  return ""
end



function ip_to_key( ip_dotted_from)
  local _, _, b1,b2,b3,b4= ip_dotted_from:find("(%d+)%.(%d+)%.(%d+)%.(%d+)")
  return string.format("%02X.%02X.%02X.%02X", b1,b2,b3,b4)
end

