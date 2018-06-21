--
-- protocol_handler.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     DHCP 
-- DESCRIPTION: creates a new DHCP layer attaching to UDP ports 67,68
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "DHCP",
    description = "DHCP Protocol layer", -- optional
  },


  -- protocol_handler  block
  -- 
  protocol_handler  = {

  -- new protocol for DHCP 
  control = {
    guid  = "{E1BD4415-DED3-4D81-974A-3E23C8CE6F5B}",  -- new protocol GUID, use tp testbench guid to create
    name  = "DHCP",  -- new protocol name 
	host_protocol_guid = '{14D7AB53-CC51-47e9-8814-9C06AAE60189}',
	host_protocol_ports = { 67,68 } 
  },


  -- WHEN CALLED: when lower layer is constructed and 
  -- return  ( nEaten, nextProtID) 
  parselayer = function(layer)
  	return layer:layer_bytes(),nil 
    -- return nEaten, nextProtocolGUID
    -- if you have no idea about next protocol, return nothing

  end,


  },
}
