--
-- test_live.lua 
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Hook into Trisul's TCP reassembly engine 
-- DESCRIPTION: Shows how to hool FIX .lua into Trisul's reassembly engine 
--
local FixDissector=require'fixp'
local PDURec=require'pdurecord'

TrisulPlugin = { 

  id =  {
    name = "FIX ASCII",
    description = "FIX Ascii dissector generating logs",
  },

  onload=function()
    T.fixflows={} 
  end,

  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

      -- Per Flow : protocol detection 
      -- if start of flow is not FIXT marker, then ignore entire flow 
      if seekpos==0 then
        if   buffer:tostring(0,6)=="8=FIXT" then 
          T.fixflows[flowkey:id() ]= {
            [0]=PDURec.new("fixp", FixDissector.new()),
            [1]=PDURec.new("fixp", FixDissector.new())}
        else 
          T.fixflows[flowkey:id() ]=nil
          return
        end
      else
        if T.fixflows[flowkey:id() ]==nil then  return end 
      end 

      local fixDissector = T.fixflows[flowkey:id()][direction]
      fixDissector:push_chunk(seekpos,buffer:tostring())
    end,

    onterminate=function(engine,timestamp,flowkey)
      T.fixflows[flowkey]=nil 
    end, 
  },
}

