#!/usr/bin/env ipescript 
-- -*- lua -*-
----------------------------------------------------------------------
-- Updates the first slide in an ipe file
----------------------------------------------------------------------
--
-- Running this script as "ipescript updatetitleslide <input> <new> <output>"
-- will create <output> as a copy of the Ipe document <input>, but with
-- the first page replaced by the first page in <new>.
----------------------------------------------------------------------

if #argv ~= 3 then
    io.stderr:write("Usage: ipescript updatetitleslide <input> <new> <output>\n")
    return
  end
  
  local inname = argv[1]
  local sname = argv[2]
  local outname = argv[3]
  
  local doc = assert(ipe.Document(inname))
  local sdoc = assert(ipe.Document(sname))
  local ndoc = ipe.Document()
  
  local s = doc:sheets()
  ndoc:replaceSheets(s:clone())
  
  local t = doc:properties()
  ndoc:setProperties(t)
  ndoc:remove(1)
  ndoc:append(sdoc[1])
  for pno=2, #doc do
    local newpage = doc[pno]:clone()
    ndoc:append(newpage)
  end
    
  
  ndoc:save(outname)