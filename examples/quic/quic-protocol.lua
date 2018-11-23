--
-- protocol_handler.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     QUIC 
-- DESCRIPTION: creates a new QUIC protocol at UDP 443 , could have made
-- 
TrisulPlugin = { 

  id =  {
    name = "QUIC",
    description = "Google QUIC", 
  },


  -- protocol_handler  block
  -- 
  protocol_handler  = {

  -- new protocol for QUIC 
  control = {
    guid  = "{4AD3CEC7-3EFE-4FA9-3830-960511542348}",               -- new protocol GUID, use tp testbench guid to create
    name  = "QUIC",                                                 -- new protocol name 
    host_protocol_guid = '{14D7AB53-CC51-47e9-8814-9C06AAE60189}',  -- UDP
    host_protocol_ports = { 443 }                                   -- Ports 67,68 
  },


  -- parselayer 
  -- QUIC eats all bytes, (there is no NEXT protocol)
  -- 
  parselayer = function(layer)
    return layer:layer_bytes(),nil 
  end,

  },
}
