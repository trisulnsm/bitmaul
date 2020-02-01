--
-- protocol_handler.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     BGP 
-- DESCRIPTION: Per packet because BGP sessions are hard to break into in the middle 
-- 
TrisulPlugin = { 

  id =  {
    name = "BGP",
    description = "BGP Protocol layer", -- optional
  },


  -- protocol_handler  block
  -- 
  protocol_handler  = {

  -- new protocol for BGP 
  control = {
    guid  = "{B7524296-F14D-4BCA-D302-5760485A133B}",               -- new protocol GUID, use tp testbench guid to create
    name  = "BGP",                                                  -- new protocol name 
    host_protocol_guid = '{77E462AB-2E42-42ec-9A58-C1A6821D6B31}',  -- TCP
    host_protocol_ports = { 179 }                                   -- Ports 67,68 
  },


  -- parselayer 
  -- DHCP eats all bytes, (there is no NEXT protocol)
  -- 
  parselayer = function(layer)
    return layer:layer_bytes(),nil 
  end,


  },
}
