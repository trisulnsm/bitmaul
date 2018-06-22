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
local JSON=require'JSON'

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

          -- dissect the DHCP protocol into a Lua table fields 
          local fields  = do_dissect( layer:rawbytes():tostring() )

          -- push new Trisul metrics 
          add_trisul_resource( engine, layer:packet():flowid():id(), fields ) 

          -- push new Trisul edges for graph analytics
          add_trisul_edges(engine, fields)

    end,


  },
}

--
--  a Trisul resource 
--    we dont add a resouce for EVERY packet, but only when certain events are seen 
--      client asks for IP, gets a new Lease, client asks for other parameters via INFORM 
-- 
--    URI      : readable log message
--    contents : the JSON breakup 
-- 
function add_trisul_resource( engine, flowkey, fields)

  local log_message = nil  

  local optstr = find_extension(fields.options,53) 
  if  optstr == "5 DHCPACK" then 
    log_message = "Client with MAC ".. fields.chaddr.." obtains a new IP address ".. fields.yiaddr 
  elseif  optstr == "3 DHCPREQUEST" then 
    local cname = find_extension(fields.options,12)
    log_message = "Client with MAC ".. fields.chaddr.." and name ".. cname.. " requests IP address "
  elseif  optstr == "8 DHCPINFORM" then 
    local cname = find_extension(fields.options,12)
    log_message = "INFORM client with MAC ".. fields.chaddr.." and name ".. cname.. " and IP" .. fields.ciaddr.."  requests additional config"
  end

  -- add a resource - the GUID identifies the new "DHCP Log" we setup in dhcp-trisul-resource.lua
  if log_message then 
    engine:add_resource( "{7BB8B78D-1978-475C-3B20-346A574B046B}",
               flowkey,
               log_message,
               JSON:encode(fields))
  end 
end


-- Trisul EDGE
-- for graph analytics, 
-- we add the vertices for MAC -> IP,  MAC -> Hostname (From DHCP Request),  IP->MAC, 
-- 
function add_trisul_edges(engine, fields)
    -- mac to IP, mac to Name, IP to name
    -- Add BI-DIRECTIONAL EDGES 
    local optstr = find_extension(fields.options,53) 
    local cname  = find_extension(fields.options,12)

    if optstr == "5 DHCPACK" then 
      engine:add_edge("{4B09BD22-3B99-40FC-8215-94A430EA0A35}",  fields.chaddr, 
              "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ip_to_key(fields.yiaddr) )

      engine:add_edge("{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ip_to_key(fields.yiaddr), 
              "{4B09BD22-3B99-40FC-8215-94A430EA0A35}",  fields.chaddr )
    end

    if #cname > 0 then
      engine:add_edge("{4B09BD22-3B99-40FC-8215-94A430EA0A35}",  fields.chaddr, 
                "{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}",  cname)

      engine:add_edge("{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ip_to_key(fields.ciaddr), 
              "{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}",  cname)
    end
end