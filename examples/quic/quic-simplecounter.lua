--
-- quic_counter.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     handle packets and update metrics 
-- DESCRIPTION: Use this to monitor raw network traffic and update metrics 
--
-- 
-- 
local dh=require'quic-dissect' 

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
    protocol_guid = "{4AD3CEC7-3EFE-4FA9-3830-960511542348}", --QUIC, we created this guid.  see  quic-protocol


    -- WHEN CALLED: when the Trisul platform detects a packet at the protocol_guid layer
    --              above. In this case, every DNS packet
    -- 
    onpacket = function(engine,layer)

          -- dissect the QUIC protocol into a Lua table fields 
          local fields  = do_dissect( layer:rawbytes():tostring() )

		  -- Tag with QUIC, ConnectionID, and SNI name 
		  if fields.tag_sni then
		  	print("SNI= "..fields.tag_sni)
		  end

		  if fields.tag_user_agent then
		  	print("USERAGENT= "..fields.tag_user_agent)
		  end



    end,


  },
}

