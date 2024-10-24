#!/usr/bin/env ipescript 
-- -*- lua -*-
----------------------------------------------------------------------
-- Remove all but the last view of each page for
-- printable lecture slides
----------------------------------------------------------------------
--
-- Running this script as "ipescript noclicks <input> <output>" will
-- create <output> as a copy of the Ipe document <input>, but with
-- each page only containing the last view.
--
----------------------------------------------------------------------

if #argv ~= 2 then
    io.stderr:write("Usage: ipescript noclicks <input> <output>\n")
    return
end

local inname = argv[1]
local outname = argv[2]

local doc = assert(ipe.Document(inname))
local ndoc = ipe.Document()

local s = doc:sheets()
ndoc:replaceSheets(s:clone())

local t = doc:properties()
ndoc:setProperties(t)
ndoc:remove(1)

for i,p in doc:pages() do
  local newpage = p:clone()
  while newpage:countViews() > 1 do
      newpage:removeView(1)
  end
  ndoc:insert(i,newpage)
end
ndoc:save(outname)