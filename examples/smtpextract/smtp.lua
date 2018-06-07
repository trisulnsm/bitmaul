-- smtp.lua
-- 
-- Uses BitMaul to Extract SMTP messages as well as all Attachments 
--

local SB=require'sweepbuf'

local SMTPDissector   = {

  -- What delimiter are we looking for at what state 
  -- 
  what_next =  function( tbl, pdur, swbuf)

    if tbl.state == "init" then 
      pdur:want_to_pattern("DATA\r\n")
    elseif tbl.state == "mime_start"  then
      pdur:want_to_pattern("\r\n\r\n")
    elseif tbl.state =="multipart_body" then 
      pdur:want_to_pattern(tbl:multipart_boundary())
    elseif tbl.state =="multipart_header" then 
      pdur:want_to_pattern("\r\n\r\n")
    end 

  end,

  -- handle a reassembled record
  -- Depending on state, do stuff 
  on_record = function( tbl, pdur, strbuf)

    local sw = SB.new(strbuf)

    if tbl.state=="init" then

      -- enter the state m/c 
      tbl.state="mime_start"

    elseif tbl.state=="mime_start"  then

      -- the SMTP header 
      -- save the message_ID and other fields in state, 
      -- write out the SMTP headers in a /tmp/{messageid}.header file 
      -- 
      local fields=sw:split_fields("([%w%p]+)%s*:%s*(.-)\r\n")

      if fields["Message-ID"] then 
        tbl.message_id = fields["Message-ID"]:gsub("[^%w]","")
      end

      local f=io.open("/tmp/"..tbl.message_id.."-headers",'w')
      f:write(strbuf)
      f:close()

      local _,_,boundary=sw.buff:find("boundary=\"(.-)\"\r\n")
      tbl:push_multipart_boundary(boundary)
      tbl.state="multipart_body"

    elseif tbl.state=="multipart_header" then

      -- state: multipart header, get the nested boundary or the attachment filename
      --
      if strbuf=="--\r\n\r\n" then
        tbl:pop_multipart_boundary()
        tbl.state="multipart_header"
      else 
        local _,_,boundary=sw.buff:find("boundary=\"(.-)\"\r\n")
        if boundary then 
          tbl:push_multipart_boundary(boundary)
        end 

        local _,_,filename=sw.buff:find("filename=\"(.-)\"\r\n")
        if filename then
          tbl.filename=filename
        else 
          tbl.filename="body"
        end

        tbl.count=tbl.count+1
        tbl.state="multipart_body"
      end

    elseif tbl.state=="multipart_body" then

      -- a multipart body, strip out the boundary string and write it out in /tmp 
      -- 
      local strdata=strbuf:gsub(tbl:multipart_boundary(),"")

      local f=io.open("/tmp/"..tbl.message_id.."-"..tbl.count.."-"..tbl.filename,"w")
      f:write(strdata)
      f:close()

      tbl.state="multipart_header"
    end
  end ,


  -- helper methods to manage nested Multipart 
  push_multipart_boundary=function(tbl,bstr)
    tbl.mime_multipart_boundaries[#tbl.mime_multipart_boundaries+1]="--"..bstr
  end,

  multipart_boundary=function(tbl)
    return tbl.mime_multipart_boundaries[#tbl.mime_multipart_boundaries]
  end,

  pop_multipart_boundary=function(tbl)
    tbl.mime_multipart_boundaries[#tbl.mime_multipart_boundaries]=nil
  end

}



-- nothing here except the state table {}
-- just template code return a new dissector
-- 
return {
    new= function(key)
      local p = setmetatable(  {
                state="init", 
                count=0,
                filename="body",
                message_id="",
                mime_multipart_boundaries={}  
              }, { __index = SMTPDissector})
    return p
  end
}

