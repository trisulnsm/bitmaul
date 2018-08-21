--
-- dhcp_counter.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     each BGP packet 
-- DESCRIPTION: add each BGP packet to a PDURecord and print 
--
--
-- 
-- 
local PDURec = require'pdurecord'
local BGPDissector=require 'bgp'

TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "BGP protocol ",
    description = "Listen to  layer  ", -- optional
  },

  -- simple_counter  block
  -- 
  simplecounter = {

    -- Required field : which protocol (layer) do you wish to attach to 
    -- as admin > Profile > Trisul Protocols for a list 
    protocol_guid = "{B7524296-F14D-4BCA-D302-5760485A133B}",               -- new protocol GUID, use tp testbench guid to create


    -- WHEN CALLED: when the Trisul platform detects a packet at the protocol_guid layer
    --              above. In this case, every DNS packet
    -- 
    onpacket = function(engine,layer)

		local pdu1 =  PDURec.new("bgp", BGPDissector.new() )

		pdu1:push_chunk(1,  layer:rawbytes():tostring() )



    end,


  },
}

