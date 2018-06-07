--
-- test_live.lua 
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Hook into Trisul's TCP reassembly engine and save SMTP files 
-- 
--
local SMTPDissector=require'smtp'
local PDURec=require'pdurecord'

TrisulPlugin = { 

  id =  {
    name = "SMTP extraction",
    description = "SMTP extraction example ",
  },

  onload=function()
    T.smtpflows={} 
  end,

  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

      -- not interested in incoming direction for SMTP 
      if direction==0 then return end

      -- Port independent , we look for EHLO (most SMTP servers these days basically )
      -- 
      if seekpos==0 then
        if   buffer:tostring(0,4)=="EHLO" then 
          T.smtpflows[flowkey:id() ]= {
            [1]=PDURec.new("smtp", SMTPDissector.new())}
        else 
          T.smtpflows[flowkey:id() ]=nil
          return
        end
      else
        if T.smtpflows[flowkey:id() ]==nil then  return end 
      end 

      local smtpDissector = T.smtpflows[flowkey:id()][direction]
      smtpDissector:push_chunk(seekpos,buffer:tostring())
    end,

    -- clean up 
    onterminate=function(engine,timestamp,flowkey)
      T.smtpflows[flowkey]=nil 
    end, 
  },
}


