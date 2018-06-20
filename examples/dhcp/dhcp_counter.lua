--
-- dhcp_counter.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     handle packets and update metrics 
-- DESCRIPTION: Use this to monitor raw network traffic and update metrics 
--
--
-- 
-- 
local dh=require'dhcp-dissect' 

TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "DHCP protocol ",
    description = "Listen to DHCP layer  ", -- optional
  },

  -- simple_counter  block
  -- 
  simplecounter = {

    -- Required field : which protocol (layer) do you wish to attach to 
    -- as admin > Profile > Trisul Protocols for a list 
    protocol_guid = "{E1BD4415-DED3-4D81-974A-3E23C8CE6F5B}",  


    -- WHEN CALLED: when the Trisul platform detects a packet at the protocol_guid layer
    --              above. In this case, every DNS packet
    -- 
    onpacket = function(engine,layer)

		local rstr = do_dissect( layer:rawbytes():tostring() )
		print(rstr) 
    end,


  },
}
