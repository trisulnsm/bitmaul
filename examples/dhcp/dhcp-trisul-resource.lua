-- DHCP Log - this is how we create new LOG types, 
-- dhcp-trisul-counter will create Logs of this type 
--
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "DHCP ",
    description = "logs DHCP activity", -- optional
  },

  resourcegroup  = {

    -- table control 
    -- WHEN CALLED: specify details of your new resource  group
    --              you can use 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{7BB8B78D-1978-475C-3B20-346A574B046B}", 
      name = "DHCP logs",
      description = "Logs important DHCP messages",
    },

  },
}
