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
require 'cert_decompressor'

-- flowid to skip because of completed QUIC CRYPTO
skipflows = { } 

TrisulPlugin = { 

  id =  {
    name = "DHCP protocol ",
    description = "Listen to DHCP layer  ", -- optional
  },

  simplecounter = {

    -- QUIC, we created this guid.  see  quic-protocol
    protocol_guid = "{4AD3CEC7-3EFE-4FA9-3830-960511542348}", 

    -- Called for every  QGUIC  UDP 443 packet
    onpacket = function(engine,layer)

      local flowid =  layer:packet():flowid():id() 
      
      if skipflows[flowid] then return end 

      -- dissect the QUIC protocol into a Lua table fields 
      local fields  = do_dissect( layer:rawbytes():tostring() )
      
      if not fields then return end 

      -- Tag with string QUIC 
      engine:tag_flow( flowid, "QUIC")

      -- Tag with QUIC, ConnectionID, and SNI name 
      if fields.tag_sni then
        engine:tag_flow( flowid, fields.tag_sni)
      end

      if fields.tag_user_agent then
        engine:tag_flow( flowid, fields.tag_user_agent)
      end

      if fields.cid_str then
        engine:tag_flow( flowid, fields.cid_str)
      end 

      -- QUIC certificate chain into Trisul Resource
      if fields.tag_cert_chain then 
        skipflows[flowid] = flowid 
        local certs = decompress_chain_x509( fields.tag_cert_chain)
        if certs then
            engine:add_resource("{5AEE3F0B-9304-44BE-BBD0-0467052CF468}",
                            flowid,
                            "QUIC chain with "..#certs.."certs",
                            table.concat( certs,"\n"))
        end

      end 

    end,


  },
}

